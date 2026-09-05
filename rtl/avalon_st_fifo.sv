// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

package avalon_st_fifo_pkg;
    function automatic integer unsigned clog2(input integer unsigned n);
        integer unsigned value;
        integer unsigned result;
        begin
            if (n <= 1) begin
                return 0;
            end

            value = n - 1;
            result = 0;
            while (value > 0) begin
                value = value / 2;
                result = result + 1;
            end
            return result;
        end
    endfunction

    function automatic integer unsigned max_natural(
        input integer unsigned a,
        input integer unsigned b
    );
        return (a > b) ? a : b;
    endfunction
endpackage

module avalon_st_fifo #(
    // FIFO depth expressed in Avalon-ST beats. The internal memory depth is
    // rounded up to the next power of two.
    parameter int unsigned DEPTH = 4096,

    // DATA_W must be a multiple of eight.
    parameter int unsigned DATA_W = 8,

    // Zero disables channel storage while retaining a one-bit physical port.
    parameter int unsigned CHANNEL_W = 0,

    parameter bit FRAME_FIFO = 1'b0,
    parameter bit DROP_OVERSIZE_FRAME = 1'b0,
    parameter bit DROP_WHEN_FULL = 1'b0
) (
    input  logic clk,
    input  logic rst,

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

    output logic [avalon_st_fifo_pkg::clog2(DEPTH):0] status_depth,
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

    (* ramstyle = "no_rw_check" *)
    logic [WORD_W-1:0] mem [0:MEM_DEPTH-1];

    logic [PTR_W-1:0] wr_ptr = '0;
    logic [PTR_W-1:0] wr_ptr_commit = '0;
    logic [PTR_W-1:0] rd_ptr = '0;

    logic full;
    logic full_wr;
    logic mem_empty;
    logic drop_frame = 1'b0;
    logic send_frame = 1'b0;
    logic [PTR_W-1:0] depth_reg = '0;
    logic overflow_reg = 1'b0;
    logic asi_ready_int;

    logic [WORD_W-1:0] aso_word_reg = '0;
    logic aso_valid_reg = 1'b0;

    initial begin : parameter_validation
        if (DEPTH < 2)
            $fatal(1, "avalon_st_fifo: DEPTH must be at least 2");
        if (DATA_W < 8)
            $fatal(1, "avalon_st_fifo: DATA_W must be at least 8");
        if ((DATA_W % 8) != 0)
            $fatal(1, "avalon_st_fifo: DATA_W must be a multiple of 8");
        if (DROP_OVERSIZE_FRAME && !FRAME_FIFO)
            $fatal(1, "avalon_st_fifo: DROP_OVERSIZE_FRAME requires FRAME_FIFO");
        if (DROP_WHEN_FULL && !(FRAME_FIFO && DROP_OVERSIZE_FRAME))
            $fatal(1, "avalon_st_fifo: DROP_WHEN_FULL requires FRAME_FIFO and DROP_OVERSIZE_FRAME");
    end

    always_comb begin
        full = (wr_ptr == toggle_msb(rd_ptr));
        full_wr = (wr_ptr == toggle_msb(wr_ptr_commit));
        mem_empty = (wr_ptr_commit == rd_ptr);

        asi_ready_int = 1'b0;
        if (FRAME_FIFO) begin
            if (!full || (full_wr && DROP_OVERSIZE_FRAME) || DROP_WHEN_FULL)
                asi_ready_int = 1'b1;
        end else if (!full) begin
            asi_ready_int = 1'b1;
        end
    end

    assign asi_ready = asi_ready_int;

    always_ff @(posedge clk) begin : write_proc
        overflow_reg <= 1'b0;

        if (FRAME_FIFO) begin
            if (asi_valid && asi_ready_int) begin
                if ((full && DROP_WHEN_FULL) ||
                    (full_wr && DROP_OVERSIZE_FRAME) || drop_frame) begin
                    drop_frame <= 1'b1;

                    if (asi_endofpacket) begin
                        // Restoring the write pointer cancels the current frame.
                        wr_ptr <= wr_ptr_commit;
                        drop_frame <= 1'b0;
                        overflow_reg <= 1'b1;
                    end
                end else begin
                    mem[wr_ptr[ADDR_W-1:0]] <= pack_word(
                        asi_data,
                        asi_startofpacket,
                        asi_endofpacket,
                        asi_empty,
                        asi_channel
                    );
                    wr_ptr <= wr_ptr + 1'b1;

                    if (asi_endofpacket ||
                        (!DROP_OVERSIZE_FRAME && (full_wr || send_frame))) begin
                        wr_ptr_commit <= wr_ptr + 1'b1;
                        if (asi_endofpacket)
                            send_frame <= 1'b0;
                        else
                            send_frame <= 1'b1;
                    end
                end
            end else if (asi_valid && full_wr && !DROP_OVERSIZE_FRAME) begin
                // Commit the received portion of an oversized frame so that
                // output traffic can free space.
                send_frame <= 1'b1;
                wr_ptr_commit <= wr_ptr;
            end
        end else if (asi_valid && asi_ready_int) begin
            mem[wr_ptr[ADDR_W-1:0]] <= pack_word(
                asi_data,
                asi_startofpacket,
                asi_endofpacket,
                asi_empty,
                asi_channel
            );
            wr_ptr <= wr_ptr + 1'b1;
            wr_ptr_commit <= wr_ptr + 1'b1;
        end

        if (rst) begin
            wr_ptr <= '0;
            wr_ptr_commit <= '0;
            drop_frame <= 1'b0;
            send_frame <= 1'b0;
            overflow_reg <= 1'b0;
        end
    end

    // The output register keeps all Avalon-ST outputs stable under backpressure.
    always_ff @(posedge clk) begin : read_proc
        if (!aso_valid_reg || aso_ready) begin
            if (!mem_empty) begin
                aso_word_reg <= mem[rd_ptr[ADDR_W-1:0]];
                aso_valid_reg <= 1'b1;
                rd_ptr <= rd_ptr + 1'b1;
            end else begin
                aso_valid_reg <= 1'b0;
            end
        end

        if (rst) begin
            rd_ptr <= '0;
            aso_word_reg <= '0;
            aso_valid_reg <= 1'b0;
        end
    end

    always_ff @(posedge clk) begin : depth_proc
        depth_reg <= wr_ptr - rd_ptr;
        if (rst)
            depth_reg <= '0;
    end

    assign aso_data = aso_word_reg[DATA_OFFSET +: DATA_W];
    assign aso_valid = aso_valid_reg;
    assign aso_startofpacket = aso_word_reg[SOP_OFFSET];
    assign aso_endofpacket = aso_word_reg[EOP_OFFSET];
    assign aso_empty = unpack_empty(aso_word_reg);
    assign aso_channel = unpack_channel(aso_word_reg);

    assign status_depth = depth_reg;
    assign status_overflow = overflow_reg;
endmodule
