// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

`timescale 1ns/1ps

module avalon_st_async_fifo_tb;
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
    logic aso_ready = 1'b1;
    wire aso_sop;
    wire aso_eop;

    wire [3:0] status_depth;
    wire status_almost_full;
    wire status_full;
    wire status_overflow;
    logic overflow_seen = 1'b0;

    always #(ASI_PERIOD / 2) asi_clk = ~asi_clk;
    always #(ASO_PERIOD / 2) aso_clk = ~aso_clk;

    avalon_st_async_fifo #(
        .DEPTH(8),
        .DATA_W(8),
        .CHANNEL_W(0),
        .FRAME_FIFO(1'b1),
        .DROP_OVERSIZE_FRAME(1'b1),
        .DROP_WHEN_FULL(1'b1),
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

    task automatic receive_beat(
        input int unsigned value,
        input logic sop,
        input logic eop
    );
        begin
            do begin
                @(posedge aso_clk);
            end while (!(aso_valid && aso_ready));
            assert (aso_data == value[7:0])
                else $fatal(1, "incorrect output data");
            assert (aso_sop == sop)
                else $fatal(1, "incorrect output SOP");
            assert (aso_eop == eop)
                else $fatal(1, "incorrect output EOP");
        end
    endtask

    initial begin : stimulus
        logic [7:0] held_data;

        #60ns;
        @(posedge asi_clk);
        asi_rst <= 1'b0;
        @(posedge aso_clk);
        aso_rst <= 1'b0;

        // An incomplete frame must not cross the frame-commit boundary.
        send_beat(16, 1'b1, 1'b0);
        send_beat(17, 1'b0, 1'b0);
        send_beat(18, 1'b0, 1'b0);
        #(8 * ASO_PERIOD);
        assert (!aso_valid)
            else $fatal(1, "incomplete frame became visible");
        send_beat(19, 1'b0, 1'b1);

        receive_beat(16, 1'b1, 1'b0);
        receive_beat(17, 1'b0, 1'b0);
        receive_beat(18, 1'b0, 1'b0);
        receive_beat(19, 1'b0, 1'b1);
        #(4 * ASO_PERIOD);
        assert (!aso_valid)
            else $fatal(1, "unexpected beat after the first frame");

        // Exercise a pending commit while the first toggle/ack is in progress.
        send_beat(24, 1'b1, 1'b0);
        send_beat(25, 1'b0, 1'b1);
        send_beat(26, 1'b1, 1'b0);
        send_beat(27, 1'b0, 1'b1);
        receive_beat(24, 1'b1, 1'b0);
        receive_beat(25, 1'b0, 1'b1);
        receive_beat(26, 1'b1, 1'b0);
        receive_beat(27, 1'b0, 1'b1);

        // Fill the FIFO while stalled, then discard a second complete frame.
        aso_ready <= 1'b0;
        send_beat(32, 1'b1, 1'b0);
        for (int i = 1; i <= 4; i++)
            send_beat(32 + i, 1'b0, 1'b0);
        send_beat(37, 1'b0, 1'b1);

        do begin
            @(posedge aso_clk);
        end while (!aso_valid);
        held_data = aso_data;
        for (int i = 0; i <= 3; i++) begin
            @(posedge aso_clk);
            assert (aso_valid && (aso_data == held_data))
                else $fatal(1, "Avalon-ST output is not stable during backpressure");
        end

        for (int i = 0; i <= 7; i++) begin
            assert (asi_ready)
                else $fatal(1, "DROP_WHEN_FULL deasserted ready");
            if (i == 0)
                send_beat(64 + i, 1'b1, 1'b0);
            else if (i == 7)
                send_beat(64 + i, 1'b0, 1'b1);
            else
                send_beat(64 + i, 1'b0, 1'b0);
        end

        #(4 * ASI_PERIOD);
        assert (overflow_seen)
            else $fatal(1, "dropped frame did not report overflow");

        aso_ready <= 1'b1;
        receive_beat(32, 1'b1, 1'b0);
        for (int i = 1; i <= 4; i++)
            receive_beat(32 + i, 1'b0, 1'b0);
        receive_beat(37, 1'b0, 1'b1);

        #(12 * ASO_PERIOD);
        assert (!aso_valid)
            else $fatal(1, "part of a dropped frame appeared at the output");

        $display("avalon_st_async_fifo_tb: PASS");
        $finish;
    end
endmodule
