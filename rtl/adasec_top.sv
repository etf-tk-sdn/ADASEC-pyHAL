// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

`resetall
`timescale 1ns / 1ps
`default_nettype none

module adasec_top #(
    parameter int unsigned DATA_W = 8,
    parameter int unsigned EMPTY_W = (DATA_W > 8) ?
        $clog2(DATA_W / 8) : 1
) (
    input  wire logic               clk,
    input  wire logic               rst,

    // Avalon-MM interface for CSR access.
    input  wire logic               avalon_read,
    input  wire logic               avalon_write,
    output wire logic               avalon_waitrequest,
    input  wire logic [csr_pkg::CSR_MIN_ADDR_WIDTH - $clog2(csr_pkg::CSR_DATA_WIDTH / 8) - 1:0]
                                    avalon_address,
    input  wire logic [31:0]        avalon_writedata,
    input  wire logic [3:0]         avalon_byteenable,
    output wire logic               avalon_readdatavalid,
    output wire logic               avalon_writeresponsevalid,
    output wire logic [31:0]        avalon_readdata,
    output wire logic [1:0]         avalon_response,

    // Avalon-ST sink and source for channel 0.
    input  wire logic [DATA_W-1:0]  asi_ch0_data,
    input  wire logic               asi_ch0_valid,
    input  wire logic               asi_ch0_sop,
    input  wire logic               asi_ch0_eop,
    input  wire logic [EMPTY_W-1:0] asi_ch0_empty,
    output wire logic               asi_ch0_ready,

    output wire logic [DATA_W-1:0]  aso_ch0_data,
    output wire logic               aso_ch0_valid,
    output wire logic               aso_ch0_sop,
    output wire logic               aso_ch0_eop,
    output wire logic [EMPTY_W-1:0] aso_ch0_empty,
    input  wire logic               aso_ch0_ready,

    // Avalon-ST sink and source for channel 1.
    input  wire logic [DATA_W-1:0]  asi_ch1_data,
    input  wire logic               asi_ch1_valid,
    input  wire logic               asi_ch1_sop,
    input  wire logic               asi_ch1_eop,
    input  wire logic [EMPTY_W-1:0] asi_ch1_empty,
    output wire logic               asi_ch1_ready,

    output wire logic [DATA_W-1:0]  aso_ch1_data,
    output wire logic               aso_ch1_valid,
    output wire logic               aso_ch1_sop,
    output wire logic               aso_ch1_eop,
    output wire logic [EMPTY_W-1:0] aso_ch1_empty,
    input  wire logic               aso_ch1_ready,

    // Avalon-ST sink and source for channel 2.
    input  wire logic [DATA_W-1:0]  asi_ch2_data,
    input  wire logic               asi_ch2_valid,
    input  wire logic               asi_ch2_sop,
    input  wire logic               asi_ch2_eop,
    input  wire logic [EMPTY_W-1:0] asi_ch2_empty,
    output wire logic               asi_ch2_ready,

    output wire logic [DATA_W-1:0]  aso_ch2_data,
    output wire logic               aso_ch2_valid,
    output wire logic               aso_ch2_sop,
    output wire logic               aso_ch2_eop,
    output wire logic [EMPTY_W-1:0] aso_ch2_empty,
    input  wire logic               aso_ch2_ready,

    // Avalon-ST sink and source for channel 3.
    input  wire logic [DATA_W-1:0]  asi_ch3_data,
    input  wire logic               asi_ch3_valid,
    input  wire logic               asi_ch3_sop,
    input  wire logic               asi_ch3_eop,
    input  wire logic [EMPTY_W-1:0] asi_ch3_empty,
    output wire logic               asi_ch3_ready,

    output wire logic [DATA_W-1:0]  aso_ch3_data,
    output wire logic               aso_ch3_valid,
    output wire logic               aso_ch3_sop,
    output wire logic               aso_ch3_eop,
    output wire logic [EMPTY_W-1:0] aso_ch3_empty,
    input  wire logic               aso_ch3_ready,

    // Test input and output.
    input  wire logic [31:0]        test_input,
    output wire logic [31:0]        test_output
);
    localparam int unsigned CSR_DATA_W = csr_pkg::CSR_DATA_WIDTH;
    localparam int unsigned CSR_EMPTY_W = (CSR_DATA_W > 8) ?
        $clog2(CSR_DATA_W / 8) : 1;
    localparam int unsigned CSR_LINK_DATA_W = 8;
    localparam int unsigned CSR_LINK_EMPTY_W = (CSR_LINK_DATA_W > 8) ?
        $clog2(CSR_LINK_DATA_W / 8) : 1;

    csr_pkg::csr__in_t csr_hwif_in;
    csr_pkg::csr__out_t csr_hwif_out;

    logic                           csr_tx_ready;
    logic [CSR_LINK_DATA_W-1:0]     csr_link_data;
    logic                           csr_link_valid;
    logic                           csr_link_ready;
    logic                           csr_link_sop;
    logic                           csr_link_eop;
    logic [CSR_LINK_EMPTY_W-1:0]    csr_link_empty;
    logic                           csr_link_channel;
    logic [CSR_DATA_W-1:0]          csr_rx_data;
    logic                           csr_rx_valid;
    logic                           csr_rx_sop;
    logic                           csr_rx_eop;
    logic [CSR_EMPTY_W-1:0]         csr_rx_empty;

    initial begin : parameter_validation
        if (EMPTY_W != ((DATA_W > 8) ?
            $clog2(DATA_W / 8) : 1))
            $fatal(1, "adasec_top: EMPTY_W must retain its derived value");
    end

    csr csr_inst (
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
        .hwif_in(csr_hwif_in),
        .hwif_out(csr_hwif_out)
    );

    avalon_st_fifo_adapter #(
        .S_DATA_W(CSR_DATA_W),
        .M_DATA_W(CSR_LINK_DATA_W),
        .FRAME_FIFO(1'b1),
        .DROP_OVERSIZE_FRAME(1'b1),
        .DROP_WHEN_FULL(1'b1)
    ) csr_tx_fifo_inst (
        .clk(clk),
        .rst(rst),
        .asi_data(csr_hwif_out.avalon_st_if.source.data.word.value),
        .asi_valid(csr_hwif_out.avalon_st_if.source.control.valid.value),
        .asi_ready(csr_tx_ready),
        .asi_startofpacket(csr_hwif_out.avalon_st_if.source.control.sop.value),
        .asi_endofpacket(csr_hwif_out.avalon_st_if.source.control.eop.value),
        .asi_empty(csr_hwif_out.avalon_st_if.source.control.empty.value),
        .asi_channel('0),
        .aso_data(csr_link_data),
        .aso_valid(csr_link_valid),
        .aso_ready(csr_link_ready),
        .aso_startofpacket(csr_link_sop),
        .aso_endofpacket(csr_link_eop),
        .aso_empty(csr_link_empty),
        .aso_channel(csr_link_channel),
        .status_depth(),
        .status_overflow()
    );

    avalon_st_fifo_adapter #(
        .S_DATA_W(CSR_LINK_DATA_W),
        .M_DATA_W(CSR_DATA_W),
        .FRAME_FIFO(1'b1),
        .DROP_OVERSIZE_FRAME(1'b1),
        .DROP_WHEN_FULL(1'b1)
    ) csr_rx_fifo_inst (
        .clk(clk),
        .rst(rst),
        .asi_data(csr_link_data),
        .asi_valid(csr_link_valid),
        .asi_ready(csr_link_ready),
        .asi_startofpacket(csr_link_sop),
        .asi_endofpacket(csr_link_eop),
        .asi_empty(csr_link_empty),
        .asi_channel(csr_link_channel),
        .aso_data(csr_rx_data),
        .aso_valid(csr_rx_valid),
        .aso_ready(csr_hwif_out.avalon_st_if.sink.control.ready.value),
        .aso_startofpacket(csr_rx_sop),
        .aso_endofpacket(csr_rx_eop),
        .aso_empty(csr_rx_empty),
        .aso_channel(),
        .status_depth(),
        .status_overflow()
    );

    always_comb begin : csr_hwif_input_proc
        csr_hwif_in.avalon_st_if.source.control.valid.hwclr =
            csr_hwif_out.avalon_st_if.source.control.valid.value &&
            csr_tx_ready;
        csr_hwif_in.avalon_st_if.source.status.ready.next =
            csr_tx_ready;

        csr_hwif_in.avalon_st_if.sink.data.word.next = csr_rx_data;
        csr_hwif_in.avalon_st_if.sink.control.ready.hwclr =
            csr_hwif_out.avalon_st_if.sink.control.ready.value &&
            csr_rx_valid;
        csr_hwif_in.avalon_st_if.sink.status.valid.next = csr_rx_valid;
        csr_hwif_in.avalon_st_if.sink.status.sop.next = csr_rx_sop;
        csr_hwif_in.avalon_st_if.sink.status.eop.next = csr_rx_eop;
        csr_hwif_in.avalon_st_if.sink.status.empty.next = csr_rx_empty;

        csr_hwif_in.test_input.word.next = test_input;
    end

    assign test_output = csr_hwif_out.test_output.word.value;

    // Cross-connect channels 0 and 1.
    assign aso_ch0_data = asi_ch1_data;
    assign aso_ch0_valid = asi_ch1_valid;
    assign aso_ch0_sop = asi_ch1_sop;
    assign aso_ch0_eop = asi_ch1_eop;
    assign aso_ch0_empty = asi_ch1_empty;
    assign asi_ch1_ready = aso_ch0_ready;

    assign aso_ch1_data = asi_ch0_data;
    assign aso_ch1_valid = asi_ch0_valid;
    assign aso_ch1_sop = asi_ch0_sop;
    assign aso_ch1_eop = asi_ch0_eop;
    assign aso_ch1_empty = asi_ch0_empty;
    assign asi_ch0_ready = aso_ch1_ready;

    // Cross-connect channels 2 and 3.
    assign aso_ch2_data = asi_ch3_data;
    assign aso_ch2_valid = asi_ch3_valid;
    assign aso_ch2_sop = asi_ch3_sop;
    assign aso_ch2_eop = asi_ch3_eop;
    assign aso_ch2_empty = asi_ch3_empty;
    assign asi_ch3_ready = aso_ch2_ready;

    assign aso_ch3_data = asi_ch2_data;
    assign aso_ch3_valid = asi_ch2_valid;
    assign aso_ch3_sop = asi_ch2_sop;
    assign aso_ch3_eop = asi_ch2_eop;
    assign aso_ch3_empty = asi_ch2_empty;
    assign asi_ch2_ready = aso_ch3_ready;

endmodule

`resetall
