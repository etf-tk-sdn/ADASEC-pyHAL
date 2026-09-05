// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

`resetall
`timescale 1ns / 1ps
`default_nettype none

module avalon_st_fifo_adapter #(
    // FIFO depth expressed in beats of the wider Avalon-ST interface.
    parameter int unsigned DEPTH = 2048,
    parameter int unsigned S_DATA_W = 8,
    parameter int unsigned M_DATA_W = 8,
    parameter int unsigned CHANNEL_W = 0,
    parameter bit FRAME_FIFO = 1'b0,
    parameter bit DROP_OVERSIZE_FRAME = 1'b0,
    parameter bit DROP_WHEN_FULL = 1'b0,

    // Derived interface widths; do not override independently.
    parameter int unsigned PTR_W = $clog2(DEPTH) + 1,
    parameter int unsigned S_EMPTY_W = (S_DATA_W > 8) ?
        $clog2(S_DATA_W / 8) : 1,
    parameter int unsigned M_EMPTY_W = (M_DATA_W > 8) ?
        $clog2(M_DATA_W / 8) : 1,
    parameter int unsigned CHANNEL_PORT_W =
        (CHANNEL_W > 0) ? CHANNEL_W : 1
) (
    input  wire logic                       clk,
    input  wire logic                       rst,

    input  wire logic [S_DATA_W-1:0]        asi_data,
    input  wire logic                       asi_valid,
    output wire logic                       asi_ready,
    input  wire logic                       asi_startofpacket,
    input  wire logic                       asi_endofpacket,
    input  wire logic [S_EMPTY_W-1:0]       asi_empty,
    input  wire logic [CHANNEL_PORT_W-1:0]  asi_channel,

    output wire logic [M_DATA_W-1:0]        aso_data,
    output wire logic                       aso_valid,
    input  wire logic                       aso_ready,
    output wire logic                       aso_startofpacket,
    output wire logic                       aso_endofpacket,
    output wire logic [M_EMPTY_W-1:0]       aso_empty,
    output wire logic [CHANNEL_PORT_W-1:0]  aso_channel,

    output wire logic [PTR_W-1:0]           status_depth,
    output wire logic                       status_overflow
);
    localparam int unsigned FIFO_DATA_W =
        (M_DATA_W > S_DATA_W) ? M_DATA_W : S_DATA_W;
    localparam int unsigned FIFO_EMPTY_W = (FIFO_DATA_W > 8) ?
        $clog2(FIFO_DATA_W / 8) : 1;

    logic [FIFO_DATA_W-1:0] pre_fifo_data;
    logic pre_fifo_valid;
    logic pre_fifo_ready;
    logic pre_fifo_startofpacket;
    logic pre_fifo_endofpacket;
    logic [FIFO_EMPTY_W-1:0] pre_fifo_empty;
    logic [CHANNEL_PORT_W-1:0] pre_fifo_channel;

    logic [FIFO_DATA_W-1:0] post_fifo_data;
    logic post_fifo_valid;
    logic post_fifo_ready;
    logic post_fifo_startofpacket;
    logic post_fifo_endofpacket;
    logic [FIFO_EMPTY_W-1:0] post_fifo_empty;
    logic [CHANNEL_PORT_W-1:0] post_fifo_channel;

    initial begin : parameter_validation
        if (PTR_W != ($clog2(DEPTH) + 1))
            $fatal(1,
                "avalon_st_fifo_adapter: PTR_W must retain its derived value");
        if (S_EMPTY_W != ((S_DATA_W > 8) ?
            $clog2(S_DATA_W / 8) : 1))
            $fatal(1,
                "avalon_st_fifo_adapter: S_EMPTY_W must retain its derived value");
        if (M_EMPTY_W != ((M_DATA_W > 8) ?
            $clog2(M_DATA_W / 8) : 1))
            $fatal(1,
                "avalon_st_fifo_adapter: M_EMPTY_W must retain its derived value");
        if (CHANNEL_PORT_W != ((CHANNEL_W > 0) ? CHANNEL_W : 1))
            $fatal(1,
                "avalon_st_fifo_adapter: CHANNEL_PORT_W must retain its derived value");
    end

    generate
        if (M_DATA_W > S_DATA_W) begin : g_upsize_before_fifo
            avalon_st_adapter #(
                .S_DATA_W(S_DATA_W),
                .M_DATA_W(FIFO_DATA_W),
                .CHANNEL_W(CHANNEL_W)
            ) adapter_inst (
                .clk(clk),
                .rst(rst),
                .asi_data(asi_data),
                .asi_valid(asi_valid),
                .asi_ready(asi_ready),
                .asi_startofpacket(asi_startofpacket),
                .asi_endofpacket(asi_endofpacket),
                .asi_empty(asi_empty),
                .asi_channel(asi_channel),
                .aso_data(pre_fifo_data),
                .aso_valid(pre_fifo_valid),
                .aso_ready(pre_fifo_ready),
                .aso_startofpacket(pre_fifo_startofpacket),
                .aso_endofpacket(pre_fifo_endofpacket),
                .aso_empty(pre_fifo_empty),
                .aso_channel(pre_fifo_channel)
            );
        end else begin : g_input_bypass
            assign pre_fifo_data = asi_data;
            assign pre_fifo_valid = asi_valid;
            assign asi_ready = pre_fifo_ready;
            assign pre_fifo_startofpacket = asi_startofpacket;
            assign pre_fifo_endofpacket = asi_endofpacket;
            assign pre_fifo_empty = asi_empty;
            assign pre_fifo_channel = asi_channel;
        end
    endgenerate

    avalon_st_fifo #(
        .DEPTH(DEPTH),
        .DATA_W(FIFO_DATA_W),
        .CHANNEL_W(CHANNEL_W),
        .FRAME_FIFO(FRAME_FIFO),
        .DROP_OVERSIZE_FRAME(DROP_OVERSIZE_FRAME),
        .DROP_WHEN_FULL(DROP_WHEN_FULL)
    ) fifo_inst (
        .clk(clk),
        .rst(rst),
        .asi_data(pre_fifo_data),
        .asi_valid(pre_fifo_valid),
        .asi_ready(pre_fifo_ready),
        .asi_startofpacket(pre_fifo_startofpacket),
        .asi_endofpacket(pre_fifo_endofpacket),
        .asi_empty(pre_fifo_empty),
        .asi_channel(pre_fifo_channel),
        .aso_data(post_fifo_data),
        .aso_valid(post_fifo_valid),
        .aso_ready(post_fifo_ready),
        .aso_startofpacket(post_fifo_startofpacket),
        .aso_endofpacket(post_fifo_endofpacket),
        .aso_empty(post_fifo_empty),
        .aso_channel(post_fifo_channel),
        .status_depth(status_depth),
        .status_overflow(status_overflow)
    );

    generate
        if (M_DATA_W < S_DATA_W) begin : g_downsize_after_fifo
            avalon_st_adapter #(
                .S_DATA_W(FIFO_DATA_W),
                .M_DATA_W(M_DATA_W),
                .CHANNEL_W(CHANNEL_W)
            ) adapter_inst (
                .clk(clk),
                .rst(rst),
                .asi_data(post_fifo_data),
                .asi_valid(post_fifo_valid),
                .asi_ready(post_fifo_ready),
                .asi_startofpacket(post_fifo_startofpacket),
                .asi_endofpacket(post_fifo_endofpacket),
                .asi_empty(post_fifo_empty),
                .asi_channel(post_fifo_channel),
                .aso_data(aso_data),
                .aso_valid(aso_valid),
                .aso_ready(aso_ready),
                .aso_startofpacket(aso_startofpacket),
                .aso_endofpacket(aso_endofpacket),
                .aso_empty(aso_empty),
                .aso_channel(aso_channel)
            );
        end else begin : g_output_bypass
            assign aso_data = post_fifo_data;
            assign aso_valid = post_fifo_valid;
            assign post_fifo_ready = aso_ready;
            assign aso_startofpacket = post_fifo_startofpacket;
            assign aso_endofpacket = post_fifo_endofpacket;
            assign aso_empty = post_fifo_empty;
            assign aso_channel = post_fifo_channel;
        end
    endgenerate
endmodule

`resetall
