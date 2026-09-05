// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

// Dual-clock Avalon-ST FIFO. Pointers cross the CDC boundary in Gray code,
// while the frame-commit pointer uses a stable snapshot and toggle/ack
// handshake so that incomplete frames never reach the source interface.
module avalon_st_async_fifo #(
    parameter int unsigned DEPTH = 2048,
    parameter int unsigned DATA_W = 8,
    parameter int unsigned CHANNEL_W = 0,
    parameter bit FRAME_FIFO = 1'b0,
    parameter bit DROP_OVERSIZE_FRAME = 1'b0,
    parameter bit DROP_WHEN_FULL = 1'b0,
    parameter int unsigned ALMOST_FULL_THRESHOLD = 1792
) (
    input  logic asi_clk,
    input  logic asi_rst,
    input  logic aso_clk,
    input  logic aso_rst,

    input  logic [DATA_W-1:0] asi_data,
    input  logic              asi_valid,
    output logic              asi_ready,
    input  logic              asi_startofpacket,
    input  logic              asi_endofpacket,
    input  logic [avalon_st_fifo_pkg::max_natural(
                      1, avalon_st_fifo_pkg::clog2(DATA_W / 8))-1:0] asi_empty,
    input  logic [avalon_st_fifo_pkg::max_natural(1, CHANNEL_W)-1:0] asi_channel,

    output logic [DATA_W-1:0] aso_data,
    output logic              aso_valid,
    input  logic              aso_ready,
    output logic              aso_startofpacket,
    output logic              aso_endofpacket,
    output logic [avalon_st_fifo_pkg::max_natural(
                      1, avalon_st_fifo_pkg::clog2(DATA_W / 8))-1:0] aso_empty,
    output logic [avalon_st_fifo_pkg::max_natural(1, CHANNEL_W)-1:0] aso_channel,

    // All status outputs are synchronous to asi_clk.
    output logic [avalon_st_fifo_pkg::clog2(DEPTH):0] status_depth,
    output logic status_almost_full,
    output logic status_full,
    output logic status_overflow
);
    import avalon_st_fifo_pkg::*;

    localparam int unsigned ADDR_W = clog2(DEPTH);
    localparam int unsigned PTR_W = ADDR_W + 1;
    localparam int unsigned MEM_DEPTH = 2**ADDR_W;

    localparam int unsigned BYTE_COUNT = DATA_W / 8;
    localparam int unsigned EMPTY_W = clog2(BYTE_COUNT);
    localparam int unsigned EMPTY_PORT_W = max_natural(1, EMPTY_W);
    localparam int unsigned CHANNEL_PORT_W = max_natural(1, CHANNEL_W);

    // FIFO word layout: [ channel ][ empty ][ EOP ][ SOP ][ data ].
    localparam int unsigned DATA_OFFSET = 0;
    localparam int unsigned SOP_OFFSET = DATA_OFFSET + DATA_W;
    localparam int unsigned EOP_OFFSET = SOP_OFFSET + 1;
    localparam int unsigned EMPTY_OFFSET = EOP_OFFSET + 1;
    localparam int unsigned CHANNEL_OFFSET = EMPTY_OFFSET + EMPTY_W;
    localparam int unsigned WORD_W = CHANNEL_OFFSET + CHANNEL_W;

    function automatic logic [WORD_W-1:0] pack_word(
        input logic [DATA_W-1:0] data,
        input logic startofpacket,
        input logic endofpacket,
        input logic [EMPTY_PORT_W-1:0] empty,
        input logic [CHANNEL_PORT_W-1:0] channel
    );
        logic [WORD_W-1:0] result;
        begin
            result = '0;
            result[DATA_OFFSET +: DATA_W] = data;
            result[SOP_OFFSET] = startofpacket;
            result[EOP_OFFSET] = endofpacket;
            for (int unsigned i = 0; i < EMPTY_W; i++) begin
                result[EMPTY_OFFSET + i] = empty[i];
            end
            for (int unsigned i = 0; i < CHANNEL_W; i++) begin
                result[CHANNEL_OFFSET + i] = channel[i];
            end
            return result;
        end
    endfunction

    function automatic logic [EMPTY_PORT_W-1:0] unpack_empty(
        input logic [WORD_W-1:0] word
    );
        logic [EMPTY_PORT_W-1:0] result;
        begin
            result = '0;
            for (int unsigned i = 0; i < EMPTY_W; i++) begin
                result[i] = word[EMPTY_OFFSET + i];
            end
            return result;
        end
    endfunction

    function automatic logic [CHANNEL_PORT_W-1:0] unpack_channel(
        input logic [WORD_W-1:0] word
    );
        logic [CHANNEL_PORT_W-1:0] result;
        begin
            result = '0;
            for (int unsigned i = 0; i < CHANNEL_W; i++) begin
                result[i] = word[CHANNEL_OFFSET + i];
            end
            return result;
        end
    endfunction

    function automatic logic [PTR_W-1:0] bin_to_gray(
        input logic [PTR_W-1:0] value
    );
        return value ^ (value >> 1);
    endfunction

    function automatic logic [PTR_W-1:0] gray_to_bin(
        input logic [PTR_W-1:0] value
    );
        logic [PTR_W-1:0] result;
        begin
            result = '0;
            result[PTR_W-1] = value[PTR_W-1];
            for (int i = PTR_W-2; i >= 0; i--) begin
                result[i] = result[i+1] ^ value[i];
            end
            return result;
        end
    endfunction

    function automatic logic [PTR_W-1:0] invert_top_two(
        input logic [PTR_W-1:0] value
    );
        logic [PTR_W-1:0] result;
        begin
            result = value;
            result[PTR_W-1 -: 2] = ~result[PTR_W-1 -: 2];
            return result;
        end
    endfunction

    function automatic logic [PTR_W-1:0] toggle_msb(
        input logic [PTR_W-1:0] value
    );
        logic [PTR_W-1:0] result;
        begin
            result = value;
            result[PTR_W-1] = ~result[PTR_W-1];
            return result;
        end
    endfunction

    logic ram_write_enable;
    logic [WORD_W-1:0] ram_write_data;
    logic [ADDR_W-1:0] ram_write_address;
    logic [ADDR_W-1:0] ram_read_address;

    logic [PTR_W-1:0] wr_ptr = '0;
    logic [PTR_W-1:0] wr_ptr_commit = '0;
    logic [PTR_W-1:0] wr_ptr_gray = '0;
    logic [PTR_W-1:0] rd_ptr = '0;
    logic [PTR_W-1:0] rd_ptr_gray = '0;

    (* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED; -name PRESERVE_REGISTER ON" *)
    logic [PTR_W-1:0] rd_ptr_gray_sync1 = '0;
    (* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED; -name PRESERVE_REGISTER ON" *)
    logic [PTR_W-1:0] rd_ptr_gray_sync2 = '0;
    (* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED; -name PRESERVE_REGISTER ON" *)
    logic [PTR_W-1:0] wr_ptr_gray_sync1 = '0;
    (* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED; -name PRESERVE_REGISTER ON" *)
    logic [PTR_W-1:0] wr_ptr_gray_sync2 = '0;

    logic [PTR_W-1:0] wr_commit_snapshot = '0;
    logic wr_commit_toggle = 1'b0;
    logic wr_commit_pending = 1'b0;
    (* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED; -name PRESERVE_REGISTER ON" *)
    logic wr_commit_ack_sync1 = 1'b0;
    (* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED; -name PRESERVE_REGISTER ON" *)
    logic wr_commit_ack_sync2 = 1'b0;
    (* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED; -name PRESERVE_REGISTER ON" *)
    logic wr_commit_toggle_sync1 = 1'b0;
    (* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED; -name PRESERVE_REGISTER ON" *)
    logic wr_commit_toggle_sync2 = 1'b0;
    logic wr_commit_toggle_seen = 1'b0;
    logic [PTR_W-1:0] rd_commit_ptr = '0;

    logic wr_full = 1'b0;
    logic full_wr;
    logic drop_frame = 1'b0;
    logic send_frame = 1'b0;
    logic asi_ready_int;
    logic [PTR_W-1:0] depth_reg = '0;
    logic overflow_reg = 1'b0;

    localparam int unsigned OUTPUT_QUEUE_DEPTH = 4;
    wire [WORD_W-1:0] ram_read_word;
    logic [1:0] read_pending = '0;
    logic [WORD_W-1:0] output_queue [0:OUTPUT_QUEUE_DEPTH-1];
    logic [$clog2(OUTPUT_QUEUE_DEPTH + 1)-1:0] output_count = '0;

    (* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED; -name PRESERVE_REGISTER ON" *)
    logic [2:0] asi_reset_pipe = '1;
    (* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED; -name PRESERVE_REGISTER ON" *)
    logic [2:0] aso_reset_pipe = '1;
    logic asi_reset_local;
    logic aso_reset_local;

    initial begin : parameter_validation
        if (DEPTH < 2)
            $fatal(1, "avalon_st_async_fifo: DEPTH must be at least 2");
        if ((DATA_W < 8) || ((DATA_W % 8) != 0))
            $fatal(1, "avalon_st_async_fifo: DATA_W must be a multiple of 8");
        if (DROP_OVERSIZE_FRAME && !FRAME_FIFO)
            $fatal(1, "avalon_st_async_fifo: DROP_OVERSIZE_FRAME requires FRAME_FIFO");
        if (DROP_WHEN_FULL && !(FRAME_FIFO && DROP_OVERSIZE_FRAME))
            $fatal(1, "avalon_st_async_fifo: DROP_WHEN_FULL requires FRAME_FIFO and DROP_OVERSIZE_FRAME");
        if (ALMOST_FULL_THRESHOLD > MEM_DEPTH)
            $fatal(1, "avalon_st_async_fifo: invalid ALMOST_FULL_THRESHOLD");
    end

    assign full_wr = (wr_ptr == toggle_msb(wr_ptr_commit));
    assign asi_ready_int = !asi_reset_local &&
                           ((FRAME_FIFO && DROP_WHEN_FULL) ||
                            (FRAME_FIFO && full_wr && DROP_OVERSIZE_FRAME) ||
                            !wr_full);
    assign asi_ready = asi_ready_int;

    assign asi_reset_local = asi_reset_pipe[2];
    assign aso_reset_local = aso_reset_pipe[2];

    assign ram_write_enable = !asi_reset_local && asi_valid && asi_ready_int &&
        (!FRAME_FIFO || !((DROP_WHEN_FULL && wr_full) ||
                          (DROP_OVERSIZE_FRAME && full_wr) || drop_frame));
    assign ram_write_data = pack_word(
        asi_data, asi_startofpacket, asi_endofpacket, asi_empty, asi_channel
    );
    assign ram_write_address = wr_ptr[ADDR_W-1:0];
    assign ram_read_address = rd_ptr[ADDR_W-1:0];

    altsyncram #(
        .operation_mode("DUAL_PORT"),
        .width_a(WORD_W),
        .widthad_a(ADDR_W),
        .numwords_a(MEM_DEPTH),
        .width_b(WORD_W),
        .widthad_b(ADDR_W),
        .numwords_b(MEM_DEPTH),
        .address_reg_b("CLOCK1"),
        .outdata_reg_b("CLOCK1"),
        .read_during_write_mode_mixed_ports("DONT_CARE"),
        .power_up_uninitialized("FALSE"),
        .intended_device_family("Cyclone IV E")
    ) storage (
        .clock0(asi_clk),
        .clock1(aso_clk),
        .wren_a(ram_write_enable),
        .wren_b(1'b0),
        .rden_a(1'b1),
        .rden_b(1'b1),
        .data_a(ram_write_data),
        .data_b({WORD_W{1'b0}}),
        .address_a(ram_write_address),
        .address_b(ram_read_address),
        .clocken0(1'b1),
        .clocken1(1'b1),
        .clocken2(1'b1),
        .clocken3(1'b1),
        .aclr0(1'b0),
        .aclr1(1'b0),
        .addressstall_a(1'b0),
        .addressstall_b(1'b0),
        .byteena_a(1'b1),
        .byteena_b(1'b1),
        .q_a(),
        .q_b(ram_read_word),
        .eccstatus()
    );

    // Asynchronous assertion and synchronous deassertion in each clock domain.
    always_ff @(posedge asi_clk or posedge asi_rst) begin
        if (asi_rst)
            asi_reset_pipe <= '1;
        else
            asi_reset_pipe <= {asi_reset_pipe[1:0], 1'b0};
    end

    always_ff @(posedge aso_clk or posedge aso_rst) begin
        if (aso_rst)
            aso_reset_pipe <= '1;
        else
            aso_reset_pipe <= {aso_reset_pipe[1:0], 1'b0};
    end

    always_ff @(posedge asi_clk or posedge asi_reset_local) begin
        if (asi_reset_local) begin
            rd_ptr_gray_sync1 <= '0;
            rd_ptr_gray_sync2 <= '0;
            wr_commit_ack_sync1 <= 1'b0;
            wr_commit_ack_sync2 <= 1'b0;
        end else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
            wr_commit_ack_sync1 <= wr_commit_toggle_seen;
            wr_commit_ack_sync2 <= wr_commit_ack_sync1;
        end
    end

    always_ff @(posedge asi_clk or posedge asi_reset_local) begin : write_logic
        logic [PTR_W-1:0] final_wr_ptr;
        logic [PTR_W-1:0] commit_value;
        logic commit_event;

        if (asi_reset_local) begin
            wr_ptr <= '0;
            wr_ptr_commit <= '0;
            wr_ptr_gray <= '0;
            wr_commit_snapshot <= '0;
            wr_commit_toggle <= 1'b0;
            wr_commit_pending <= 1'b0;
            wr_full <= 1'b0;
            drop_frame <= 1'b0;
            send_frame <= 1'b0;
            depth_reg <= '0;
            overflow_reg <= 1'b0;
        end else begin
            final_wr_ptr = wr_ptr;
            commit_value = wr_ptr_commit;
            commit_event = 1'b0;
            overflow_reg <= 1'b0;
            depth_reg <= wr_ptr - gray_to_bin(rd_ptr_gray_sync2);

            if (FRAME_FIFO) begin
                if (asi_valid && asi_ready_int) begin
                    if ((wr_full && DROP_WHEN_FULL) ||
                        (full_wr && DROP_OVERSIZE_FRAME) || drop_frame) begin
                        drop_frame <= 1'b1;
                        if (asi_endofpacket) begin
                            final_wr_ptr = wr_ptr_commit;
                            wr_ptr <= wr_ptr_commit;
                            wr_ptr_gray <= bin_to_gray(wr_ptr_commit);
                            drop_frame <= 1'b0;
                            overflow_reg <= 1'b1;
                        end
                    end else begin
                        final_wr_ptr = wr_ptr + 1'b1;
                        wr_ptr <= final_wr_ptr;
                        wr_ptr_gray <= bin_to_gray(final_wr_ptr);

                        if (asi_endofpacket ||
                            (!DROP_OVERSIZE_FRAME && (full_wr || send_frame))) begin
                            wr_ptr_commit <= final_wr_ptr;
                            commit_value = final_wr_ptr;
                            commit_event = 1'b1;
                            if (asi_endofpacket)
                                send_frame <= 1'b0;
                            else
                                send_frame <= 1'b1;
                        end
                    end
                end else if (asi_valid && full_wr && !DROP_OVERSIZE_FRAME) begin
                    wr_ptr_commit <= wr_ptr;
                    commit_value = wr_ptr;
                    commit_event = 1'b1;
                    send_frame <= 1'b1;
                end
            end else if (asi_valid && asi_ready_int) begin
                final_wr_ptr = wr_ptr + 1'b1;
                wr_ptr <= final_wr_ptr;
                wr_ptr_commit <= final_wr_ptr;
                wr_ptr_gray <= bin_to_gray(final_wr_ptr);
            end

            if (FRAME_FIFO) begin
                if (commit_event) begin
                    if (wr_commit_toggle == wr_commit_ack_sync2) begin
                        wr_commit_snapshot <= commit_value;
                        wr_commit_toggle <= ~wr_commit_ack_sync2;
                        wr_commit_pending <= 1'b0;
                    end else begin
                        wr_commit_pending <= 1'b1;
                    end
                end else if (wr_commit_pending &&
                             (wr_commit_toggle == wr_commit_ack_sync2)) begin
                    wr_commit_snapshot <= wr_ptr_commit;
                    wr_commit_toggle <= ~wr_commit_ack_sync2;
                    wr_commit_pending <= 1'b0;
                end
            end

            wr_full <= (bin_to_gray(final_wr_ptr) ==
                        invert_top_two(rd_ptr_gray_sync2));
        end
    end

    always_ff @(posedge aso_clk or posedge aso_reset_local) begin
        if (aso_reset_local) begin
            wr_ptr_gray_sync1 <= '0;
            wr_ptr_gray_sync2 <= '0;
            wr_commit_toggle_sync1 <= 1'b0;
            wr_commit_toggle_sync2 <= 1'b0;
            wr_commit_toggle_seen <= 1'b0;
            rd_commit_ptr <= '0;
        end else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
            wr_commit_toggle_sync1 <= wr_commit_toggle;
            wr_commit_toggle_sync2 <= wr_commit_toggle_sync1;

            if (wr_commit_toggle_sync2 != wr_commit_toggle_seen) begin
                rd_commit_ptr <= wr_commit_snapshot;
                wr_commit_toggle_seen <= wr_commit_toggle_sync2;
            end
        end
    end

    always_ff @(posedge aso_clk or posedge aso_reset_local) begin : read_logic
        logic [PTR_W-1:0] available_ptr;
        logic [PTR_W-1:0] next_rd_ptr;
        logic [WORD_W-1:0] next_output_queue [0:OUTPUT_QUEUE_DEPTH-1];
        logic [1:0] next_read_pending;
        logic [$clog2(OUTPUT_QUEUE_DEPTH + 1)-1:0] next_output_count;
        integer unsigned reserved_count;

        if (aso_reset_local) begin
            rd_ptr <= '0;
            rd_ptr_gray <= '0;
            read_pending <= '0;
            for (int i = 0; i < OUTPUT_QUEUE_DEPTH; i++) begin
                output_queue[i] <= '0;
            end
            output_count <= '0;
        end else begin
            if (FRAME_FIFO)
                available_ptr = rd_commit_ptr;
            else
                available_ptr = gray_to_bin(wr_ptr_gray_sync2);

            next_output_count = output_count;
            for (int i = 0; i < OUTPUT_QUEUE_DEPTH; i++) begin
                next_output_queue[i] = output_queue[i];
            end
            next_read_pending = '0;
            next_read_pending[1] = read_pending[0];

            if ((output_count > 0) && aso_ready) begin
                for (int i = 0; i < OUTPUT_QUEUE_DEPTH-1; i++) begin
                    next_output_queue[i] = output_queue[i+1];
                end
                next_output_count = next_output_count - 1'b1;
            end

            if (read_pending[1]) begin
                assert (next_output_count < OUTPUT_QUEUE_DEPTH)
                    else $fatal(1, "avalon_st_async_fifo: output elastic buffer overflow");
                if (next_output_count < OUTPUT_QUEUE_DEPTH) begin
                    next_output_queue[next_output_count] = ram_read_word;
                    next_output_count = next_output_count + 1'b1;
                end
            end

            reserved_count = next_output_count;
            for (int i = 0; i < 2; i++) begin
                if (next_read_pending[i])
                    reserved_count = reserved_count + 1;
            end

            if ((reserved_count < OUTPUT_QUEUE_DEPTH) &&
                (rd_ptr != available_ptr)) begin
                next_read_pending[0] = 1'b1;
                next_rd_ptr = rd_ptr + 1'b1;
                rd_ptr <= next_rd_ptr;
                rd_ptr_gray <= bin_to_gray(next_rd_ptr);
            end

            read_pending <= next_read_pending;
            for (int i = 0; i < OUTPUT_QUEUE_DEPTH; i++) begin
                output_queue[i] <= next_output_queue[i];
            end
            output_count <= next_output_count;
        end
    end

    assign aso_data = output_queue[0][DATA_OFFSET +: DATA_W];
    assign aso_valid = (output_count > 0);
    assign aso_startofpacket = output_queue[0][SOP_OFFSET];
    assign aso_endofpacket = output_queue[0][EOP_OFFSET];
    assign aso_empty = unpack_empty(output_queue[0]);
    assign aso_channel = unpack_channel(output_queue[0]);

    assign status_depth = depth_reg;
    assign status_almost_full = (depth_reg >= ALMOST_FULL_THRESHOLD);
    assign status_full = wr_full;
    assign status_overflow = overflow_reg;
endmodule
