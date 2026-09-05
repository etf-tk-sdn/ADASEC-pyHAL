// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

`resetall
`timescale 1ns / 1ps
`default_nettype none

module adasec_top_tb;
    localparam int unsigned DATA_W = 8;
    localparam int unsigned EMPTY_W = 1;
    localparam int unsigned AVALON_ADDR_W =
        csr_pkg::CSR_MIN_ADDR_WIDTH -
        $clog2(csr_pkg::CSR_DATA_WIDTH / 8);

    logic clk = 1'b0;
    logic rst = 1'b1;

    logic avalon_read = 1'b0;
    logic avalon_write = 1'b0;
    logic avalon_waitrequest;
    logic [AVALON_ADDR_W-1:0] avalon_address = '0;
    logic [31:0] avalon_writedata = '0;
    logic [3:0] avalon_byteenable = '1;
    logic avalon_readdatavalid;
    logic avalon_writeresponsevalid;
    logic [31:0] avalon_readdata;
    logic [1:0] avalon_response;

    logic [DATA_W-1:0] asi_ch0_data = '0;
    logic asi_ch0_valid = 1'b0;
    logic asi_ch0_sop = 1'b0;
    logic asi_ch0_eop = 1'b0;
    logic [EMPTY_W-1:0] asi_ch0_empty = '0;
    logic asi_ch0_ready;
    logic [DATA_W-1:0] aso_ch0_data;
    logic aso_ch0_valid;
    logic aso_ch0_sop;
    logic aso_ch0_eop;
    logic [EMPTY_W-1:0] aso_ch0_empty;
    logic aso_ch0_ready = 1'b0;

    logic [DATA_W-1:0] asi_ch1_data = '0;
    logic asi_ch1_valid = 1'b0;
    logic asi_ch1_sop = 1'b0;
    logic asi_ch1_eop = 1'b0;
    logic [EMPTY_W-1:0] asi_ch1_empty = '0;
    logic asi_ch1_ready;
    logic [DATA_W-1:0] aso_ch1_data;
    logic aso_ch1_valid;
    logic aso_ch1_sop;
    logic aso_ch1_eop;
    logic [EMPTY_W-1:0] aso_ch1_empty;
    logic aso_ch1_ready = 1'b0;

    logic [DATA_W-1:0] asi_ch2_data = '0;
    logic asi_ch2_valid = 1'b0;
    logic asi_ch2_sop = 1'b0;
    logic asi_ch2_eop = 1'b0;
    logic [EMPTY_W-1:0] asi_ch2_empty = '0;
    logic asi_ch2_ready;
    logic [DATA_W-1:0] aso_ch2_data;
    logic aso_ch2_valid;
    logic aso_ch2_sop;
    logic aso_ch2_eop;
    logic [EMPTY_W-1:0] aso_ch2_empty;
    logic aso_ch2_ready = 1'b0;

    logic [DATA_W-1:0] asi_ch3_data = '0;
    logic asi_ch3_valid = 1'b0;
    logic asi_ch3_sop = 1'b0;
    logic asi_ch3_eop = 1'b0;
    logic [EMPTY_W-1:0] asi_ch3_empty = '0;
    logic asi_ch3_ready;
    logic [DATA_W-1:0] aso_ch3_data;
    logic aso_ch3_valid;
    logic aso_ch3_sop;
    logic aso_ch3_eop;
    logic [EMPTY_W-1:0] aso_ch3_empty;
    logic aso_ch3_ready = 1'b0;

    logic [31:0] test_input = '0;
    logic [31:0] test_output;

    always #5 clk = ~clk;

    adasec_top #(
        .DATA_W(DATA_W)
    ) dut (
        .clk(clk),
        .rst(rst),
        .avalon_read(avalon_read),
        .avalon_write(avalon_write),
        .avalon_waitrequest(avalon_waitrequest),
        .avalon_address(avalon_address),
        .avalon_writedata(avalon_writedata),
        .avalon_byteenable(avalon_byteenable),
        .avalon_readdatavalid(avalon_readdatavalid),
        .avalon_writeresponsevalid(avalon_writeresponsevalid),
        .avalon_readdata(avalon_readdata),
        .avalon_response(avalon_response),
        .asi_ch0_data(asi_ch0_data),
        .asi_ch0_valid(asi_ch0_valid),
        .asi_ch0_sop(asi_ch0_sop),
        .asi_ch0_eop(asi_ch0_eop),
        .asi_ch0_empty(asi_ch0_empty),
        .asi_ch0_ready(asi_ch0_ready),
        .aso_ch0_data(aso_ch0_data),
        .aso_ch0_valid(aso_ch0_valid),
        .aso_ch0_sop(aso_ch0_sop),
        .aso_ch0_eop(aso_ch0_eop),
        .aso_ch0_empty(aso_ch0_empty),
        .aso_ch0_ready(aso_ch0_ready),
        .asi_ch1_data(asi_ch1_data),
        .asi_ch1_valid(asi_ch1_valid),
        .asi_ch1_sop(asi_ch1_sop),
        .asi_ch1_eop(asi_ch1_eop),
        .asi_ch1_empty(asi_ch1_empty),
        .asi_ch1_ready(asi_ch1_ready),
        .aso_ch1_data(aso_ch1_data),
        .aso_ch1_valid(aso_ch1_valid),
        .aso_ch1_sop(aso_ch1_sop),
        .aso_ch1_eop(aso_ch1_eop),
        .aso_ch1_empty(aso_ch1_empty),
        .aso_ch1_ready(aso_ch1_ready),
        .asi_ch2_data(asi_ch2_data),
        .asi_ch2_valid(asi_ch2_valid),
        .asi_ch2_sop(asi_ch2_sop),
        .asi_ch2_eop(asi_ch2_eop),
        .asi_ch2_empty(asi_ch2_empty),
        .asi_ch2_ready(asi_ch2_ready),
        .aso_ch2_data(aso_ch2_data),
        .aso_ch2_valid(aso_ch2_valid),
        .aso_ch2_sop(aso_ch2_sop),
        .aso_ch2_eop(aso_ch2_eop),
        .aso_ch2_empty(aso_ch2_empty),
        .aso_ch2_ready(aso_ch2_ready),
        .asi_ch3_data(asi_ch3_data),
        .asi_ch3_valid(asi_ch3_valid),
        .asi_ch3_sop(asi_ch3_sop),
        .asi_ch3_eop(asi_ch3_eop),
        .asi_ch3_empty(asi_ch3_empty),
        .asi_ch3_ready(asi_ch3_ready),
        .aso_ch3_data(aso_ch3_data),
        .aso_ch3_valid(aso_ch3_valid),
        .aso_ch3_sop(aso_ch3_sop),
        .aso_ch3_eop(aso_ch3_eop),
        .aso_ch3_empty(aso_ch3_empty),
        .aso_ch3_ready(aso_ch3_ready),
        .test_input(test_input),
        .test_output(test_output)
    );

    task automatic csr_write(
        input logic [AVALON_ADDR_W-1:0] address,
        input logic [31:0] data
    );
        begin
            @(negedge clk);
            avalon_address = address;
            avalon_writedata = data;
            avalon_write = 1'b1;
            @(posedge clk);
            #1;
            if (avalon_waitrequest !== 1'b0 ||
                avalon_writeresponsevalid !== 1'b1 ||
                avalon_response !== 2'b00)
                $fatal(1, "Avalon-MM write failed at word address %0d", address);
            @(negedge clk);
            avalon_write = 1'b0;
            avalon_writedata = '0;
        end
    endtask

    task automatic csr_read(
        input logic [AVALON_ADDR_W-1:0] address,
        output logic [31:0] data
    );
        begin
            @(negedge clk);
            avalon_address = address;
            avalon_read = 1'b1;
            @(posedge clk);
            #1;
            if (avalon_waitrequest !== 1'b0 ||
                avalon_readdatavalid !== 1'b1 ||
                avalon_response !== 2'b00)
                $fatal(1, "Avalon-MM read failed at word address %0d", address);
            data = avalon_readdata;
            @(negedge clk);
            avalon_read = 1'b0;
        end
    endtask

    task automatic wait_for_sink_valid(output logic [31:0] status);
        begin
            for (int unsigned attempt = 0; attempt < 64; attempt++) begin
                csr_read(4'd6, status);
                if (status[0])
                    return;
            end

            $fatal(1, "Timed out waiting for the CSR loopback frame");
        end
    endtask

    initial begin : test_proc
        logic [31:0] read_data;

        repeat (4) @(posedge clk);
        rst = 1'b0;
        @(posedge clk);

        // Channel 0 is connected to channel 1, in both directions.
        asi_ch0_data = 8'ha5;
        asi_ch0_valid = 1'b1;
        asi_ch0_sop = 1'b1;
        asi_ch0_eop = 1'b0;
        asi_ch0_empty = 1'b0;
        aso_ch1_ready = 1'b1;
        asi_ch1_data = 8'h3c;
        asi_ch1_valid = 1'b1;
        asi_ch1_sop = 1'b0;
        asi_ch1_eop = 1'b1;
        asi_ch1_empty = 1'b1;
        aso_ch0_ready = 1'b0;
        #1;
        if ({aso_ch1_data, aso_ch1_valid, aso_ch1_sop, aso_ch1_eop,
             aso_ch1_empty, asi_ch0_ready} !==
            {8'ha5, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1})
            $fatal(1, "Channel 0 to channel 1 cross-connect failed");
        if ({aso_ch0_data, aso_ch0_valid, aso_ch0_sop, aso_ch0_eop,
             aso_ch0_empty, asi_ch1_ready} !==
            {8'h3c, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0})
            $fatal(1, "Channel 1 to channel 0 cross-connect failed");

        // Channel 2 is connected to channel 3, in both directions.
        asi_ch2_data = 8'h96;
        asi_ch2_valid = 1'b1;
        asi_ch2_sop = 1'b1;
        asi_ch2_eop = 1'b1;
        asi_ch2_empty = 1'b1;
        aso_ch3_ready = 1'b0;
        asi_ch3_data = 8'h69;
        asi_ch3_valid = 1'b0;
        asi_ch3_sop = 1'b0;
        asi_ch3_eop = 1'b0;
        asi_ch3_empty = 1'b0;
        aso_ch2_ready = 1'b1;
        #1;
        if ({aso_ch3_data, aso_ch3_valid, aso_ch3_sop, aso_ch3_eop,
             aso_ch3_empty, asi_ch2_ready} !==
            {8'h96, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0})
            $fatal(1, "Channel 2 to channel 3 cross-connect failed");
        if ({aso_ch2_data, aso_ch2_valid, aso_ch2_sop, aso_ch2_eop,
             aso_ch2_empty, asi_ch3_ready} !==
            {8'h69, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1})
            $fatal(1, "Channel 3 to channel 2 cross-connect failed");

        test_input = 32'h1234_abcd;
        csr_read(4'd7, read_data);
        if (read_data !== test_input)
            $fatal(1, "CSR test_input connection failed");

        csr_write(4'd8, 32'hfeed_cafe);
        if (test_output !== 32'hfeed_cafe)
            $fatal(1, "CSR test_output connection failed");

        // Ready must remain set until the sink performs a transfer.
        csr_write(4'd5, 32'h0000_0001);
        repeat (3) @(posedge clk);
        csr_read(4'd5, read_data);
        if (read_data[0] !== 1'b1)
            $fatal(1, "Sink ready cleared without a transfer");
        csr_write(4'd5, 32'h0000_0000);

        // Send one complete 32-bit frame through the 32->8->32 loopback.
        csr_read(4'd2, read_data);
        if (read_data[0] !== 1'b1)
            $fatal(1, "CSR Tx FIFO did not report source ready");
        csr_write(4'd0, 32'hdeaf_beef);
        csr_write(4'd1, 32'h0001_0101);
        repeat (2) @(posedge clk);

        csr_read(4'd1, read_data);
        if (read_data[0] !== 1'b0)
            $fatal(1, "Source valid was not cleared after transfer");

        wait_for_sink_valid(read_data);
        if ({read_data[25:24], read_data[16], read_data[8], read_data[0]} !==
            {2'b00, 1'b1, 1'b1, 1'b1})
            $fatal(1, "CSR loopback sink status is incorrect");
        csr_read(4'd4, read_data);
        if (read_data !== 32'hdeaf_beef)
            $fatal(1, "CSR loopback data is incorrect");

        // Accept the FIFO output; sink.ready must clear on that handshake.
        csr_write(4'd5, 32'h0000_0001);
        repeat (2) @(posedge clk);
        csr_read(4'd5, read_data);
        if (read_data[0] !== 1'b0)
            $fatal(1, "Sink ready was not cleared after transfer");
        csr_read(4'd6, read_data);
        if (read_data[0] !== 1'b0)
            $fatal(1, "CSR loopback valid remained set after transfer");

        // Repeat with a three-byte frame to verify empty conversion as well.
        csr_write(4'd0, 32'h1234_5678);
        csr_write(4'd1, 32'h0101_0101);
        repeat (2) @(posedge clk);

        csr_read(4'd1, read_data);
        if (read_data[0] !== 1'b0)
            $fatal(1, "Partial-frame source valid was not cleared");

        wait_for_sink_valid(read_data);
        if ({read_data[25:24], read_data[16], read_data[8], read_data[0]} !==
            {2'b01, 1'b1, 1'b1, 1'b1})
            $fatal(1, "Partial-frame loopback status is incorrect");
        csr_read(4'd4, read_data);
        if (read_data[23:0] !== 24'h34_5678)
            $fatal(1, "Partial-frame loopback data is incorrect");

        csr_write(4'd5, 32'h0000_0001);
        repeat (2) @(posedge clk);
        csr_read(4'd5, read_data);
        if (read_data[0] !== 1'b0)
            $fatal(1, "Partial-frame sink ready was not cleared");

        $display("adasec_top_tb: PASS");
        $finish;
    end
endmodule

`resetall
