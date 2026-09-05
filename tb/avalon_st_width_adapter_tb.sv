// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

`resetall
`timescale 1ns / 1ps
`default_nettype none

module avalon_st_width_adapter_tb #(
    parameter bit USE_FIFO = 1'b0,
    parameter int unsigned S_DATA_W = 8,
    parameter int unsigned M_DATA_W = 32
);
    localparam int unsigned CHANNEL_W = 3;
    localparam int unsigned CHANNEL_PORT_W = CHANNEL_W;
    localparam int unsigned S_BYTE_COUNT = S_DATA_W / 8;
    localparam int unsigned M_BYTE_COUNT = M_DATA_W / 8;
    localparam int unsigned WIDE_BYTE_COUNT =
        (S_BYTE_COUNT > M_BYTE_COUNT) ? S_BYTE_COUNT : M_BYTE_COUNT;
    localparam int unsigned S_EMPTY_W = (S_DATA_W > 8) ?
        $clog2(S_DATA_W / 8) : 1;
    localparam int unsigned M_EMPTY_W = (M_DATA_W > 8) ?
        $clog2(M_DATA_W / 8) : 1;
    localparam int unsigned FIFO_DEPTH = 64;
    localparam int unsigned FIFO_PTR_W = $clog2(FIFO_DEPTH) + 1;

    logic clk = 1'b0;
    logic rst = 1'b1;

    logic [S_DATA_W-1:0] asi_data = '0;
    logic asi_valid = 1'b0;
    logic asi_ready;
    logic asi_startofpacket = 1'b0;
    logic asi_endofpacket = 1'b0;
    logic [S_EMPTY_W-1:0] asi_empty = '0;
    logic [CHANNEL_PORT_W-1:0] asi_channel = '0;

    logic [M_DATA_W-1:0] aso_data;
    logic aso_valid;
    logic aso_ready = 1'b0;
    logic aso_startofpacket;
    logic aso_endofpacket;
    logic [M_EMPTY_W-1:0] aso_empty;
    logic [CHANNEL_PORT_W-1:0] aso_channel;

    logic [FIFO_PTR_W-1:0] status_depth;
    logic status_overflow;

    always #5 clk = ~clk;

    generate
        if (USE_FIFO) begin : g_fifo_adapter
            avalon_st_fifo_adapter #(
                .DEPTH(FIFO_DEPTH),
                .S_DATA_W(S_DATA_W),
                .M_DATA_W(M_DATA_W),
                .CHANNEL_W(CHANNEL_W),
                .FRAME_FIFO(1'b1),
                .DROP_OVERSIZE_FRAME(1'b1),
                .DROP_WHEN_FULL(1'b1)
            ) dut (
                .clk(clk),
                .rst(rst),
                .asi_data(asi_data),
                .asi_valid(asi_valid),
                .asi_ready(asi_ready),
                .asi_startofpacket(asi_startofpacket),
                .asi_endofpacket(asi_endofpacket),
                .asi_empty(asi_empty),
                .asi_channel(asi_channel),
                .aso_data(aso_data),
                .aso_valid(aso_valid),
                .aso_ready(aso_ready),
                .aso_startofpacket(aso_startofpacket),
                .aso_endofpacket(aso_endofpacket),
                .aso_empty(aso_empty),
                .aso_channel(aso_channel),
                .status_depth(status_depth),
                .status_overflow(status_overflow)
            );
        end else begin : g_plain_adapter
            avalon_st_adapter #(
                .S_DATA_W(S_DATA_W),
                .M_DATA_W(M_DATA_W),
                .CHANNEL_W(CHANNEL_W)
            ) dut (
                .clk(clk),
                .rst(rst),
                .asi_data(asi_data),
                .asi_valid(asi_valid),
                .asi_ready(asi_ready),
                .asi_startofpacket(asi_startofpacket),
                .asi_endofpacket(asi_endofpacket),
                .asi_empty(asi_empty),
                .asi_channel(asi_channel),
                .aso_data(aso_data),
                .aso_valid(aso_valid),
                .aso_ready(aso_ready),
                .aso_startofpacket(aso_startofpacket),
                .aso_endofpacket(aso_endofpacket),
                .aso_empty(aso_empty),
                .aso_channel(aso_channel)
            );

            assign status_depth = '0;
            assign status_overflow = 1'b0;
        end
    endgenerate

    function automatic logic [7:0] expected_byte(
        input int unsigned frame_index,
        input int unsigned byte_index
    );
        logic [7:0] result;
        begin
            result = 8'h21 + frame_index*8'h35 + byte_index*8'h07;
            return result;
        end
    endfunction

    task automatic send_frame(
        input int unsigned frame_index,
        input int unsigned frame_length
    );
        int unsigned byte_offset;
        int unsigned valid_byte_count;
        logic [S_DATA_W-1:0] beat_data;
        begin
            byte_offset = 0;

            while (byte_offset < frame_length) begin
                valid_byte_count = frame_length-byte_offset;
                if (valid_byte_count > S_BYTE_COUNT)
                    valid_byte_count = S_BYTE_COUNT;

                beat_data = '0;
                for (int unsigned lane = 0;
                     lane < valid_byte_count; lane++) begin
                    beat_data[lane*8 +: 8] =
                        expected_byte(frame_index, byte_offset+lane);
                end

                @(negedge clk);
                asi_data = beat_data;
                asi_valid = 1'b1;
                asi_startofpacket = (byte_offset == 0);
                asi_endofpacket =
                    (byte_offset+valid_byte_count == frame_length);
                asi_empty = asi_endofpacket ?
                    S_BYTE_COUNT-valid_byte_count : '0;
                asi_channel = frame_index;
                #1;

                while (asi_ready !== 1'b1) begin
                    @(negedge clk);
                    #1;
                end

                @(posedge clk);
                byte_offset = byte_offset + valid_byte_count;
            end

            @(negedge clk);
            asi_data = '0;
            asi_valid = 1'b0;
            asi_startofpacket = 1'b0;
            asi_endofpacket = 1'b0;
            asi_empty = '0;
            asi_channel = '0;
        end
    endtask

    task automatic receive_frame(
        input int unsigned frame_index,
        input int unsigned frame_length
    );
        int unsigned byte_offset;
        int unsigned valid_byte_count;
        logic [M_DATA_W-1:0] held_data;
        logic held_startofpacket;
        logic held_endofpacket;
        logic [M_EMPTY_W-1:0] held_empty;
        logic [CHANNEL_PORT_W-1:0] held_channel;
        logic expected_startofpacket;
        logic expected_endofpacket;
        logic [M_EMPTY_W-1:0] expected_empty;
        begin
            byte_offset = 0;

            while (byte_offset < frame_length) begin
                valid_byte_count = frame_length-byte_offset;
                if (valid_byte_count > M_BYTE_COUNT)
                    valid_byte_count = M_BYTE_COUNT;

                #1;
                while (aso_valid !== 1'b1) begin
                    @(negedge clk);
                    #1;
                end

                expected_startofpacket = (byte_offset == 0);
                expected_endofpacket =
                    (byte_offset+valid_byte_count == frame_length);
                expected_empty = expected_endofpacket ?
                    M_BYTE_COUNT-valid_byte_count : '0;

                for (int unsigned lane = 0;
                     lane < valid_byte_count; lane++) begin
                    if (aso_data[lane*8 +: 8] !==
                        expected_byte(frame_index, byte_offset+lane)) begin
                        $fatal(1,
                            "Data mismatch: fifo=%0d, %0d->%0d, frame=%0d, byte=%0d",
                            USE_FIFO, S_DATA_W, M_DATA_W,
                            frame_index, byte_offset+lane);
                    end
                end

                if (aso_startofpacket !== expected_startofpacket ||
                    aso_endofpacket !== expected_endofpacket ||
                    aso_empty !== expected_empty ||
                    aso_channel !== frame_index) begin
                    $fatal(1,
                        "Sideband mismatch: fifo=%0d, %0d->%0d, frame=%0d, offset=%0d",
                        USE_FIFO, S_DATA_W, M_DATA_W,
                        frame_index, byte_offset);
                end

                held_data = aso_data;
                held_startofpacket = aso_startofpacket;
                held_endofpacket = aso_endofpacket;
                held_empty = aso_empty;
                held_channel = aso_channel;

                repeat (2) begin
                    @(posedge clk);
                    #1;
                    if (aso_valid !== 1'b1 || aso_data !== held_data ||
                        aso_startofpacket !== held_startofpacket ||
                        aso_endofpacket !== held_endofpacket ||
                        aso_empty !== held_empty ||
                        aso_channel !== held_channel) begin
                        $fatal(1,
                            "Output changed under backpressure: fifo=%0d, %0d->%0d",
                            USE_FIFO, S_DATA_W, M_DATA_W);
                    end
                end

                @(negedge clk);
                aso_ready = 1'b1;
                @(posedge clk);
                byte_offset = byte_offset + valid_byte_count;
                @(negedge clk);
                aso_ready = 1'b0;
            end
        end
    endtask

    initial begin : test_proc
        int unsigned frame_length;

        repeat (4) @(posedge clk);
        rst = 1'b0;
        repeat (2) @(posedge clk);

        for (int unsigned frame_index = 0;
             frame_index < 5; frame_index++) begin
            case (frame_index)
                0: frame_length = 1;
                1: frame_length = S_BYTE_COUNT;
                2: frame_length = M_BYTE_COUNT;
                3: frame_length = WIDE_BYTE_COUNT+3;
                default: frame_length = 2*WIDE_BYTE_COUNT+5;
            endcase

            fork
                send_frame(frame_index, frame_length);
                receive_frame(frame_index, frame_length);
            join
        end

        repeat (4) @(posedge clk);
        if (USE_FIFO && status_depth !== '0)
            $fatal(1, "FIFO did not drain after the final frame");
        if (status_overflow !== 1'b0)
            $fatal(1, "Unexpected FIFO overflow");

        $display(
            "avalon_st_width_adapter_tb: PASS fifo=%0d conversion=%0d->%0d",
            USE_FIFO, S_DATA_W, M_DATA_W);
        $finish;
    end
endmodule

`resetall
