// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

`resetall
`timescale 1ns / 1ps
`default_nettype none

module avalon_st_adapter #(
    parameter int unsigned S_DATA_W = 8,
    parameter int unsigned M_DATA_W = 8,
    parameter int unsigned CHANNEL_W = 0,

    // Derived interface widths; do not override independently.
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
    output wire logic [CHANNEL_PORT_W-1:0]  aso_channel
);
    localparam int unsigned S_BYTE_COUNT = S_DATA_W / 8;
    localparam int unsigned M_BYTE_COUNT = M_DATA_W / 8;

    initial begin : parameter_validation
        if (S_DATA_W < 8 || M_DATA_W < 8)
            $fatal(1,
                "avalon_st_adapter: data widths must be at least 8 bits");
        if ((S_DATA_W % 8) != 0 || (M_DATA_W % 8) != 0)
            $fatal(1,
                "avalon_st_adapter: data widths must be multiples of 8 bits");
        if (((S_DATA_W % M_DATA_W) != 0) &&
            ((M_DATA_W % S_DATA_W) != 0))
            $fatal(1,
                "avalon_st_adapter: one data width must divide the other");
        if (S_EMPTY_W != ((S_DATA_W > 8) ?
            $clog2(S_DATA_W / 8) : 1))
            $fatal(1,
                "avalon_st_adapter: S_EMPTY_W must retain its derived value");
        if (M_EMPTY_W != ((M_DATA_W > 8) ?
            $clog2(M_DATA_W / 8) : 1))
            $fatal(1,
                "avalon_st_adapter: M_EMPTY_W must retain its derived value");
        if (CHANNEL_PORT_W != ((CHANNEL_W > 0) ? CHANNEL_W : 1))
            $fatal(1,
                "avalon_st_adapter: CHANNEL_PORT_W must retain its derived value");
    end

    generate
        if (M_DATA_W == S_DATA_W) begin : g_bypass
            assign asi_ready = aso_ready;
            assign aso_data = asi_data;
            assign aso_valid = asi_valid;
            assign aso_startofpacket = asi_startofpacket;
            assign aso_endofpacket = asi_endofpacket;
            assign aso_empty = asi_empty;
            assign aso_channel = asi_channel;
        end else if (M_DATA_W > S_DATA_W) begin : g_upsize
            localparam int unsigned SEGMENT_COUNT = M_DATA_W / S_DATA_W;
            localparam int unsigned SEGMENT_W =
                (SEGMENT_COUNT > 1) ? $clog2(SEGMENT_COUNT) : 1;

            typedef logic [SEGMENT_W-1:0] segment_t;
            typedef logic [M_EMPTY_W-1:0] m_empty_t;

            logic [M_DATA_W-1:0] data_reg;
            logic valid_reg;
            logic startofpacket_reg;
            logic endofpacket_reg;
            logic [M_EMPTY_W-1:0] empty_reg;
            logic [CHANNEL_PORT_W-1:0] channel_reg;
            logic [SEGMENT_W-1:0] segment_reg;

            assign asi_ready = !valid_reg;
            assign aso_data = data_reg;
            assign aso_valid = valid_reg;
            assign aso_startofpacket = startofpacket_reg;
            assign aso_endofpacket = endofpacket_reg;
            assign aso_empty = empty_reg;
            assign aso_channel = channel_reg;

            always_ff @(posedge clk) begin : upsize_proc
                if (valid_reg && aso_ready) begin
                    data_reg <= '0;
                    valid_reg <= 1'b0;
                    startofpacket_reg <= 1'b0;
                    endofpacket_reg <= 1'b0;
                    empty_reg <= '0;
                    channel_reg <= '0;
                end

                if (asi_valid && asi_ready) begin
                    data_reg[segment_reg*S_DATA_W +: S_DATA_W] <= asi_data;

                    if (segment_reg == 0) begin
                        startofpacket_reg <= asi_startofpacket;
                        channel_reg <= asi_channel;
                    end

                    if (asi_endofpacket ||
                        (segment_reg == segment_t'(SEGMENT_COUNT-1))) begin
                        valid_reg <= 1'b1;
                        endofpacket_reg <= asi_endofpacket;
                        segment_reg <= '0;

                        if (asi_endofpacket) begin
                            empty_reg <= m_empty_t'(
                                (SEGMENT_COUNT-1-int'(segment_reg))*S_BYTE_COUNT +
                                int'(asi_empty)
                            );
                        end else begin
                            empty_reg <= '0;
                        end
                    end else begin
                        segment_reg <= segment_reg + 1'b1;
                    end
                end

                if (rst) begin
                    data_reg <= '0;
                    valid_reg <= 1'b0;
                    startofpacket_reg <= 1'b0;
                    endofpacket_reg <= 1'b0;
                    empty_reg <= '0;
                    channel_reg <= '0;
                    segment_reg <= '0;
                end
            end
        end else begin : g_downsize
            localparam int unsigned SEGMENT_COUNT = S_DATA_W / M_DATA_W;
            localparam int unsigned SEGMENT_W =
                (SEGMENT_COUNT > 1) ? $clog2(SEGMENT_COUNT) : 1;

            typedef logic [SEGMENT_W-1:0] segment_t;
            typedef logic [M_EMPTY_W-1:0] m_empty_t;

            logic [S_DATA_W-1:0] data_reg;
            logic valid_reg;
            logic startofpacket_reg;
            logic endofpacket_reg;
            logic [M_EMPTY_W-1:0] last_empty_reg;
            logic [CHANNEL_PORT_W-1:0] channel_reg;
            logic [SEGMENT_W-1:0] segment_reg;
            logic [SEGMENT_W-1:0] last_segment_reg;

            function automatic logic [SEGMENT_W-1:0]
                calculate_last_segment(
                    input logic [S_EMPTY_W-1:0] empty
                );
                int unsigned valid_byte_count;
                logic [SEGMENT_W-1:0] result;
                begin
                    valid_byte_count = S_BYTE_COUNT - int'(empty);
                    result = segment_t'(
                        (valid_byte_count-1) / M_BYTE_COUNT
                    );
                    return result;
                end
            endfunction

            function automatic logic [M_EMPTY_W-1:0]
                calculate_last_empty(
                    input logic [S_EMPTY_W-1:0] empty
                );
                int unsigned valid_byte_count;
                int unsigned remainder;
                logic [M_EMPTY_W-1:0] result;
                begin
                    valid_byte_count = S_BYTE_COUNT - int'(empty);
                    remainder = valid_byte_count % M_BYTE_COUNT;
                    if (remainder == 0)
                        result = '0;
                    else
                        result = m_empty_t'(M_BYTE_COUNT-remainder);
                    return result;
                end
            endfunction

            assign asi_ready = !valid_reg;
            assign aso_data =
                data_reg[segment_reg*M_DATA_W +: M_DATA_W];
            assign aso_valid = valid_reg;
            assign aso_startofpacket =
                startofpacket_reg && (segment_reg == 0);
            assign aso_endofpacket =
                endofpacket_reg && (segment_reg == last_segment_reg);
            assign aso_empty = aso_endofpacket ? last_empty_reg : '0;
            assign aso_channel = channel_reg;

            always_ff @(posedge clk) begin : downsize_proc
                if (aso_valid && aso_ready) begin
                    if (segment_reg == last_segment_reg) begin
                        valid_reg <= 1'b0;
                        segment_reg <= '0;
                    end else begin
                        segment_reg <= segment_reg + 1'b1;
                    end
                end

                if (asi_valid && asi_ready) begin
                    data_reg <= asi_data;
                    valid_reg <= 1'b1;
                    startofpacket_reg <= asi_startofpacket;
                    endofpacket_reg <= asi_endofpacket;
                    channel_reg <= asi_channel;
                    segment_reg <= '0;

                    if (asi_endofpacket) begin
                        last_segment_reg <=
                            calculate_last_segment(asi_empty);
                        last_empty_reg <= calculate_last_empty(asi_empty);
                    end else begin
                        last_segment_reg <= segment_t'(SEGMENT_COUNT-1);
                        last_empty_reg <= '0;
                    end
                end

                if (rst) begin
                    data_reg <= '0;
                    valid_reg <= 1'b0;
                    startofpacket_reg <= 1'b0;
                    endofpacket_reg <= 1'b0;
                    last_empty_reg <= '0;
                    channel_reg <= '0;
                    segment_reg <= '0;
                    last_segment_reg <= '0;
                end
            end
        end
    endgenerate
endmodule

`resetall
