// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: AGPL-3.0-or-later

`resetall
`timescale 1ns / 1ps
`default_nettype none

// Cocotb wrapper around the complete ADASEC datapath. The external streaming
// channels are inactive; the CSR source and sink are looped back in adasec_top.
module adasec_top_tb;
    localparam int unsigned DATA_W = 8;
    localparam int unsigned AVALON_ADDR_W =
        csr_pkg::CSR_MIN_ADDR_WIDTH -
        $clog2(csr_pkg::CSR_DATA_WIDTH / 8);

    logic clk;
    logic rst;
    logic avalon_read;
    logic avalon_write;
    logic avalon_waitrequest;
    logic [AVALON_ADDR_W-1:0] avalon_address;
    logic [31:0] avalon_writedata;
    logic [3:0] avalon_byteenable;
    logic avalon_readdatavalid;
    logic avalon_writeresponsevalid;
    logic [31:0] avalon_readdata;
    logic [1:0] avalon_response;
    logic [31:0] test_input;
    logic [31:0] test_output;

    assign test_input = {test_output[31:28], 28'b0};

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
        .asi_ch0_data('0),
        .asi_ch0_valid(1'b0),
        .asi_ch0_sop(1'b0),
        .asi_ch0_eop(1'b0),
        .asi_ch0_empty('0),
        .asi_ch0_ready(),
        .aso_ch0_data(),
        .aso_ch0_valid(),
        .aso_ch0_sop(),
        .aso_ch0_eop(),
        .aso_ch0_empty(),
        .aso_ch0_ready(1'b0),
        .asi_ch1_data('0),
        .asi_ch1_valid(1'b0),
        .asi_ch1_sop(1'b0),
        .asi_ch1_eop(1'b0),
        .asi_ch1_empty('0),
        .asi_ch1_ready(),
        .aso_ch1_data(),
        .aso_ch1_valid(),
        .aso_ch1_sop(),
        .aso_ch1_eop(),
        .aso_ch1_empty(),
        .aso_ch1_ready(1'b0),
        .asi_ch2_data('0),
        .asi_ch2_valid(1'b0),
        .asi_ch2_sop(1'b0),
        .asi_ch2_eop(1'b0),
        .asi_ch2_empty('0),
        .asi_ch2_ready(),
        .aso_ch2_data(),
        .aso_ch2_valid(),
        .aso_ch2_sop(),
        .aso_ch2_eop(),
        .aso_ch2_empty(),
        .aso_ch2_ready(1'b0),
        .asi_ch3_data('0),
        .asi_ch3_valid(1'b0),
        .asi_ch3_sop(1'b0),
        .asi_ch3_eop(1'b0),
        .asi_ch3_empty('0),
        .asi_ch3_ready(),
        .aso_ch3_data(),
        .aso_ch3_valid(),
        .aso_ch3_sop(),
        .aso_ch3_eop(),
        .aso_ch3_empty(),
        .aso_ch3_ready(1'b0),
        .test_input(test_input),
        .test_output(test_output)
    );
endmodule

`resetall
