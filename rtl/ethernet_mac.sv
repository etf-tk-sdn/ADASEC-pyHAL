// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

`resetall
`timescale 1ns / 1ps
`default_nettype none

module ethernet_mac #(
    parameter logic [47:0] MAC_ADDRESS = 48'h020000000001,
    parameter logic [4:0] PHY_ADDRESS = 5'b10000,
    parameter int unsigned RX_ASYNC_FIFO_DEPTH = 2048,
    parameter int unsigned TX_ASYNC_FIFO_DEPTH = 16384,

    // Derived interface widths; do not override independently.
    parameter int unsigned RX_FIFO_PTR_W = $clog2(RX_ASYNC_FIFO_DEPTH) + 1,
    parameter int unsigned TX_FIFO_PTR_W = $clog2(TX_ASYNC_FIFO_DEPTH) + 1
) (
    // Shared control and external Avalon-ST clock domain.
    input  wire logic       clk,
    input  wire logic       rst,
    input  wire logic       clk_125,
    input  wire logic       clk_25,
    input  wire logic       clk_2p5,

    // Avalon-ST sink: frame to be transmitted over Ethernet.
    input  wire logic [7:0] asi_data,
    input  wire logic       asi_valid,
    input  wire logic       asi_sop,
    input  wire logic       asi_eop,
    output wire logic       asi_ready,
    input  wire logic [0:0] asi_channel,
    input  wire logic [0:0] asi_empty,

    // Avalon-ST source: frame received from Ethernet.
    output wire logic [7:0] aso_data,
    output wire logic       aso_valid,
    output wire logic       aso_sop,
    output wire logic       aso_eop,
    input  wire logic       aso_ready,
    output wire logic [0:0] aso_channel,
    output wire logic [0:0] aso_empty,

    // RGMII and PHY control signals.
    input  wire logic       rgmii_rx_clk,
    input  wire logic [3:0] rgmii_rx_data,
    input  wire logic       rgmii_rx_control,
    output wire logic       rgmii_tx_clk,
    output wire logic [3:0] rgmii_tx_data,
    output wire logic       rgmii_tx_control,
    output wire logic       phy_mdc,
    inout  wire logic       phy_mdio,
    input  wire logic       phy_int_n,
    output wire logic       phy_reset_n,

    // Status and sticky diagnostics.
    output wire logic status_init_done,
    output wire logic status_init_error,
    output wire logic status_eth_mode,
    output wire logic status_ena_10,
    output wire logic status_tx_clock,
    output wire logic status_tx_clock_toggle,
    output wire logic status_rx_activity,
    output wire logic status_tx_activity,
    output wire logic [4:0] status_rx_error,
    output wire logic status_rx_error_seen,
    output wire logic status_rx_overflow,
    output wire logic status_tx_overflow,
    output wire logic [RX_FIFO_PTR_W-1:0] status_rx_fifo_depth,
    output wire logic [TX_FIFO_PTR_W-1:0] status_tx_fifo_depth,
    output wire logic [4:0] status_pkt_class_data,
    output wire logic status_pkt_class_valid
);
    logic [7:0] reg_addr;
    logic [31:0] reg_data_in;
    logic [31:0] reg_data_out;
    logic reg_rd;
    logic reg_wr;
    logic reg_busy;

    logic eth_mode;
    logic ena_10;

    logic [2:0] tx_clock_candidates;
    logic [1:0] tx_clock_select;
    (* keep = 1 *) logic tx_clock_selected;
    logic [0:0] rgmii_tx_clock_ddio;

    logic mac_rx_stream_clk;
    logic mac_tx_stream_clk;

    logic [7:0] mac_rx_data;
    logic mac_rx_eop;
    logic [4:0] mac_rx_error;
    logic mac_rx_ready;
    logic mac_rx_sop;
    logic mac_rx_valid;

    logic [7:0] mac_tx_data;
    logic mac_tx_eop;
    logic mac_tx_ready;
    logic mac_tx_sop;
    logic mac_tx_valid;

    logic mdio_in;
    logic mdio_out;
    logic mdio_oen;

    logic [RX_FIFO_PTR_W-1:0] rx_fifo_depth;
    logic [TX_FIFO_PTR_W-1:0] tx_fifo_depth;
    logic rx_fifo_almost_full;
    logic rx_fifo_full;
    logic tx_fifo_almost_full;
    logic tx_fifo_full;
    logic rx_fifo_overflow;
    logic tx_fifo_overflow;
    logic [1:0] rx_afull_data;

    logic rx_activity_seen = 1'b0;
    logic tx_activity_seen = 1'b0;
    logic rx_error_seen = 1'b0;
    logic rx_overflow_seen = 1'b0;
    logic tx_overflow_seen = 1'b0;
    logic [24:0] tx_clock_counter = '0;

    // Asynchronous assertion and synchronous deassertion for RX diagnostics.
    (* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED; -name PRESERVE_REGISTER ON" *)
    logic [2:0] rx_diag_reset_pipe = '1;
    logic rx_diag_reset;

    initial begin : parameter_validation
        if (RX_FIFO_PTR_W != ($clog2(RX_ASYNC_FIFO_DEPTH) + 1))
            $fatal(1, "ethernet_mac: RX_FIFO_PTR_W must retain its derived value");
        if (TX_FIFO_PTR_W != ($clog2(TX_ASYNC_FIFO_DEPTH) + 1))
            $fatal(1, "ethernet_mac: TX_FIFO_PTR_W must retain its derived value");
    end

    assign phy_reset_n = ~rst;
    assign mdio_in = phy_mdio;
    assign phy_mdio = !mdio_oen ? mdio_out : 1'bz;
    assign rx_diag_reset = rx_diag_reset_pipe[2];

    assign status_eth_mode = eth_mode;
    assign status_ena_10 = ena_10;
    assign status_tx_clock = tx_clock_selected;
    assign status_rx_activity = rx_activity_seen;
    assign status_tx_activity = tx_activity_seen;
    assign status_rx_error = mac_rx_error;
    assign status_rx_error_seen = rx_error_seen;
    assign status_rx_overflow = rx_overflow_seen;
    assign status_tx_overflow = tx_overflow_seen;
    assign status_rx_fifo_depth = rx_fifo_depth;
    assign status_tx_fifo_depth = tx_fifo_depth;

    assign status_tx_clock_toggle = eth_mode ? tx_clock_counter[24] :
                                           (ena_10 ? tx_clock_counter[19] :
                                                     tx_clock_counter[22]);

    assign tx_clock_candidates[0] = clk_125;
    assign tx_clock_candidates[1] = clk_25;
    assign tx_clock_candidates[2] = clk_2p5;

    assign tx_clock_select = eth_mode ? 2'b00 : (ena_10 ? 2'b10 : 2'b01);

    // Glitch-free selection of the line-side TX clock for 1000/100/10 Mb/s.
    altclkctrl #(
        .clock_type("Global Clock"),
        .intended_device_family("Cyclone IV E"),
        .implement_in_les("ON"),
        .number_of_clocks(3),
        .use_glitch_free_switch_over_implementation("ON"),
        .width_clkselect(2)
    ) tx_clock_control (
        .clkselect(tx_clock_select),
        .ena(1'b1),
        .inclk(tx_clock_candidates),
        .outclk(tx_clock_selected)
    );

    altddio_out #(
        .extend_oe_disable("OFF"),
        .intended_device_family("Cyclone IV E"),
        .invert_output("OFF"),
        .lpm_hint("UNUSED"),
        .lpm_type("altddio_out"),
        .oe_reg("UNREGISTERED"),
        .power_up_high("OFF"),
        .width(1)
    ) rgmii_tx_clock_driver (
        .datain_h(1'b1),
        .datain_l(1'b0),
        .outclock(tx_clock_selected),
        .outclocken(1'b1),
        .aset(1'b0),
        .aclr(1'b0),
        .sset(1'b0),
        .sclr(1'b0),
        .oe(1'b1),
        .dataout(rgmii_tx_clock_ddio),
        .oe_out()
    );

    assign rgmii_tx_clk = rgmii_tx_clock_ddio[0];

    ethernet_mac_init #(
        .MAC_ADDRESS(MAC_ADDRESS),
        .PHY_ADDRESS(PHY_ADDRESS)
    ) init (
        .clk(clk),
        .reset(rst),
        .phy_int_n(phy_int_n),
        .reg_addr(reg_addr),
        .reg_data_in(reg_data_in),
        .reg_data_out(reg_data_out),
        .reg_rd(reg_rd),
        .reg_wr(reg_wr),
        .reg_busy(reg_busy),
        .done(status_init_done),
        .error(status_init_error)
    );

    // RX CDC: TSE receive clock to the shared Avalon-ST clock.
    avalon_st_async_fifo #(
        .DEPTH(RX_ASYNC_FIFO_DEPTH),
        .DATA_W(8),
        .CHANNEL_W(0),
        .FRAME_FIFO(1'b1),
        .DROP_OVERSIZE_FRAME(1'b1),
        .DROP_WHEN_FULL(1'b1),
        .ALMOST_FULL_THRESHOLD(
            RX_ASYNC_FIFO_DEPTH - (
                (RX_ASYNC_FIFO_DEPTH / 8 > 1) ?
                    RX_ASYNC_FIFO_DEPTH / 8 : 1
            )
        )
    ) rx_cdc_fifo (
        .asi_clk(mac_rx_stream_clk),
        .asi_rst(rst),
        .aso_clk(clk),
        .aso_rst(rst),
        .asi_data(mac_rx_data),
        .asi_valid(mac_rx_valid),
        .asi_ready(mac_rx_ready),
        .asi_startofpacket(mac_rx_sop),
        .asi_endofpacket(mac_rx_eop),
        .asi_empty(1'b0),
        .asi_channel(1'b0),
        .aso_data(aso_data),
        .aso_valid(aso_valid),
        .aso_ready(aso_ready),
        .aso_startofpacket(aso_sop),
        .aso_endofpacket(aso_eop),
        .aso_empty(aso_empty),
        .aso_channel(aso_channel),
        .status_depth(rx_fifo_depth),
        .status_almost_full(rx_fifo_almost_full),
        .status_full(rx_fifo_full),
        .status_overflow(rx_fifo_overflow)
    );

    // TX CDC: shared Avalon-ST clock to the TSE transmit clock. TX can return
    // backpressure; only a frame larger than the complete FIFO is discarded.
    avalon_st_async_fifo #(
        .DEPTH(TX_ASYNC_FIFO_DEPTH),
        .DATA_W(8),
        .CHANNEL_W(0),
        .FRAME_FIFO(1'b1),
        .DROP_OVERSIZE_FRAME(1'b1),
        .DROP_WHEN_FULL(1'b0),
        .ALMOST_FULL_THRESHOLD(
            TX_ASYNC_FIFO_DEPTH - (
                (TX_ASYNC_FIFO_DEPTH / 8 > 1) ?
                    TX_ASYNC_FIFO_DEPTH / 8 : 1
            )
        )
    ) tx_cdc_fifo (
        .asi_clk(clk),
        .asi_rst(rst),
        .aso_clk(mac_tx_stream_clk),
        .aso_rst(rst),
        .asi_data(asi_data),
        .asi_valid(asi_valid),
        .asi_ready(asi_ready),
        .asi_startofpacket(asi_sop),
        .asi_endofpacket(asi_eop),
        .asi_empty(asi_empty),
        .asi_channel(asi_channel),
        .aso_data(mac_tx_data),
        .aso_valid(mac_tx_valid),
        .aso_ready(mac_tx_ready),
        .aso_startofpacket(mac_tx_sop),
        .aso_endofpacket(mac_tx_eop),
        .aso_empty(),
        .aso_channel(),
        .status_depth(tx_fifo_depth),
        .status_almost_full(tx_fifo_almost_full),
        .status_full(tx_fifo_full),
        .status_overflow(tx_fifo_overflow)
    );

    // The FIFO-less TSE wrapper remains the generated Verilog IP variation.
    // Bit 1 of rx_afull_data is held low because RX uses DROP_WHEN_FULL.
    assign rx_afull_data[1] = 1'b0;
    assign rx_afull_data[0] = rx_fifo_full;

    altera_tse tse (
        .clk(clk),
        .reset(rst),
        .reg_data_out(reg_data_out),
        .reg_rd(reg_rd),
        .reg_data_in(reg_data_in),
        .reg_wr(reg_wr),
        .reg_busy(reg_busy),
        .reg_addr(reg_addr),
        .rx_afull_clk(mac_rx_stream_clk),
        .rx_afull_data(rx_afull_data),
        .rx_afull_valid(1'b1),
        .rx_afull_channel(1'b0),
        .mac_rx_clk_0(mac_rx_stream_clk),
        .mac_tx_clk_0(mac_tx_stream_clk),
        .data_rx_data_0(mac_rx_data),
        .data_rx_eop_0(mac_rx_eop),
        .data_rx_error_0(mac_rx_error),
        .data_rx_ready_0(mac_rx_ready),
        .data_rx_sop_0(mac_rx_sop),
        .data_rx_valid_0(mac_rx_valid),
        .data_tx_data_0(mac_tx_data),
        .data_tx_eop_0(mac_tx_eop),
        .data_tx_error_0(1'b0),
        .data_tx_ready_0(mac_tx_ready),
        .data_tx_sop_0(mac_tx_sop),
        .data_tx_valid_0(mac_tx_valid),
        .pkt_class_data_0(status_pkt_class_data),
        .pkt_class_valid_0(status_pkt_class_valid),
        .tx_crc_fwd_0(1'b0),
        .tx_clk_0(tx_clock_selected),
        .rx_clk_0(rgmii_rx_clk),
        .set_10_0(1'b0),
        .set_1000_0(1'b0),
        .eth_mode_0(eth_mode),
        .ena_10_0(ena_10),
        .rgmii_in_0(rgmii_rx_data),
        .rgmii_out_0(rgmii_tx_data),
        .rx_control_0(rgmii_rx_control),
        .tx_control_0(rgmii_tx_control),
        .mdc(phy_mdc),
        .mdio_in(mdio_in),
        .mdio_out(mdio_out),
        .mdio_oen(mdio_oen)
    );

    always_ff @(posedge mac_rx_stream_clk or posedge rst) begin
        if (rst)
            rx_diag_reset_pipe <= '1;
        else
            rx_diag_reset_pipe <= {rx_diag_reset_pipe[1:0], 1'b0};
    end

    always_ff @(posedge mac_rx_stream_clk) begin
        if (rx_diag_reset) begin
            rx_activity_seen <= 1'b0;
            rx_error_seen <= 1'b0;
            rx_overflow_seen <= 1'b0;
        end else begin
            if (mac_rx_valid && mac_rx_ready) begin
                rx_activity_seen <= 1'b1;
                if (mac_rx_eop && (mac_rx_error != 5'b0))
                    rx_error_seen <= 1'b1;
            end
            if (rx_fifo_overflow)
                rx_overflow_seen <= 1'b1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            tx_activity_seen <= 1'b0;
            tx_overflow_seen <= 1'b0;
        end else begin
            if (asi_valid && asi_ready)
                tx_activity_seen <= 1'b1;
            if (tx_fifo_overflow)
                tx_overflow_seen <= 1'b1;
        end
    end

    always_ff @(posedge tx_clock_selected) begin
        if (rst)
            tx_clock_counter <= '0;
        else
            tx_clock_counter <= tx_clock_counter + 1'b1;
    end
endmodule

`resetall
