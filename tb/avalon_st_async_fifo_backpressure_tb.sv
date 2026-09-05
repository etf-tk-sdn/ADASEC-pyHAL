// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

`timescale 1ns/1ps

module avalon_st_async_fifo_backpressure_tb;
    localparam time ASI_PERIOD = 10ns;
    localparam time ASO_PERIOD = 14ns;

    logic asi_clk = 1'b0;
    logic aso_clk = 1'b0;
    logic asi_rst = 1'b1;
    logic aso_rst = 1'b1;

    logic [7:0] asi_data = '0;
    logic asi_valid = 1'b0;
    wire asi_ready;
    logic asi_sop = 1'b0;
    logic asi_eop = 1'b0;

    wire [7:0] aso_data;
    wire aso_valid;
    logic aso_ready = 1'b0;
    wire aso_sop;
    wire aso_eop;

    wire [3:0] status_depth;
    wire status_almost_full;
    wire status_full;
    wire status_overflow;
    logic overflow_seen = 1'b0;
    integer unsigned received_count = 0;

    always #(ASI_PERIOD / 2) asi_clk = ~asi_clk;
    always #(ASO_PERIOD / 2) aso_clk = ~aso_clk;

    avalon_st_async_fifo #(
        .DEPTH(8),
        .DATA_W(8),
        .CHANNEL_W(0),
        .FRAME_FIFO(1'b1),
        .DROP_OVERSIZE_FRAME(1'b1),
        .DROP_WHEN_FULL(1'b0),
        .ALMOST_FULL_THRESHOLD(6)
    ) dut (
        .asi_clk(asi_clk),
        .asi_rst(asi_rst),
        .aso_clk(aso_clk),
        .aso_rst(aso_rst),
        .asi_data(asi_data),
        .asi_valid(asi_valid),
        .asi_ready(asi_ready),
        .asi_startofpacket(asi_sop),
        .asi_endofpacket(asi_eop),
        .asi_empty(1'b0),
        .asi_channel(1'b0),
        .aso_data(aso_data),
        .aso_valid(aso_valid),
        .aso_ready(aso_ready),
        .aso_startofpacket(aso_sop),
        .aso_endofpacket(aso_eop),
        .aso_empty(),
        .aso_channel(),
        .status_depth(status_depth),
        .status_almost_full(status_almost_full),
        .status_full(status_full),
        .status_overflow(status_overflow)
    );

    always_ff @(posedge asi_clk) begin
        if (asi_rst)
            overflow_seen <= 1'b0;
        else if (status_overflow)
            overflow_seen <= 1'b1;
    end

    always_ff @(posedge aso_clk) begin : output_scoreboard
        int unsigned expected_value;
        logic expected_sop;
        logic expected_eop;

        if (aso_rst) begin
            received_count <= 0;
        end else if (aso_valid && aso_ready) begin
            if (received_count < 8) begin
                expected_value = 32 + received_count;
                expected_sop = (received_count == 0);
                expected_eop = (received_count == 7);
            end else begin
                expected_value = 64 + received_count - 8;
                expected_sop = (received_count == 8);
                expected_eop = (received_count == 13);
            end

            assert (aso_data == expected_value[7:0])
                else $fatal(1, "incorrect data after TX backpressure");
            assert (aso_sop == expected_sop)
                else $fatal(1, "incorrect SOP after TX backpressure");
            assert (aso_eop == expected_eop)
                else $fatal(1, "incorrect EOP after TX backpressure");
            received_count <= received_count + 1;
        end
    end

    task automatic send_beat(
        input int unsigned value,
        input logic sop,
        input logic eop
    );
        begin
            asi_data <= value[7:0];
            asi_sop <= sop;
            asi_eop <= eop;
            asi_valid <= 1'b1;
            do begin
                @(posedge asi_clk);
            end while (!asi_ready);
            asi_valid <= 1'b0;
            asi_sop <= 1'b0;
            asi_eop <= 1'b0;
        end
    endtask

    initial begin : stimulus
        #60ns;
        @(posedge asi_clk);
        asi_rst <= 1'b0;
        @(posedge aso_clk);
        aso_rst <= 1'b0;

        // While the output is stalled, one complete frame fills the entire RAM.
        send_beat(32, 1'b1, 1'b0);
        for (int i = 1; i <= 6; i++)
            send_beat(32 + i, 1'b0, 1'b0);
        send_beat(39, 1'b0, 1'b1);

        // The next SOP remains stable at the input while ready is deasserted.
        #1ns;
        asi_data <= 8'h40;
        asi_sop <= 1'b1;
        asi_eop <= 1'b0;
        asi_valid <= 1'b1;
        @(posedge asi_clk);
        assert (!asi_ready)
            else $fatal(1, "TX FIFO did not assert backpressure when full");

        aso_ready <= 1'b1;
        do begin
            @(posedge asi_clk);
            if (!asi_ready) begin
                assert ((asi_data == 8'h40) && asi_sop && !asi_eop)
                    else $fatal(1, "input did not remain stable during backpressure");
            end
        end while (!asi_ready);
        asi_valid <= 1'b0;
        asi_sop <= 1'b0;

        for (int i = 1; i <= 4; i++)
            send_beat(64 + i, 1'b0, 1'b0);
        send_beat(69, 1'b0, 1'b1);

        fork : receive_timeout
            begin
                wait (received_count == 14);
            end
            begin
                #10us;
            end
        join_any
        disable receive_timeout;

        assert (received_count == 14)
            else $fatal(1, "both complete frames were not transferred");
        assert (!overflow_seen)
            else $fatal(1, "TX backpressure unexpectedly dropped a frame");

        $display("avalon_st_async_fifo_backpressure_tb: PASS");
        $finish;
    end
endmodule
