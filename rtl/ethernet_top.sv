// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

`resetall
`timescale 1ns / 1ps
`default_nettype none

module ethernet_top (
    // Board clock, user controls, and LED indicators.
    input  wire logic        CLOCK_50,
    input  wire logic [3:0]  KEY,
    input  wire logic [17:0] SW,
    output wire logic [17:0] LEDR,
    output wire logic [8:0]  LEDG,

    // RGMII and control signals for the first Ethernet PHY.
    output wire logic        ENET0_GTX_CLK,
    output wire logic        ENET0_MDC,
    inout  wire logic        ENET0_MDIO,
    input  wire logic        ENET0_INT_N,
    output wire logic        ENET0_RESET_N,
    input  wire logic        ENET0_RX_CLK,
    input  wire logic [3:0]  ENET0_RX_DATA,
    input  wire logic        ENET0_RX_DV,
    output wire logic [3:0]  ENET0_TX_DATA,
    output wire logic        ENET0_TX_EN,

    // RGMII and control signals for the second Ethernet PHY.
    output wire logic        ENET1_GTX_CLK,
    output wire logic        ENET1_MDC,
    inout  wire logic        ENET1_MDIO,
    input  wire logic        ENET1_INT_N,
    output wire logic        ENET1_RESET_N,
    input  wire logic        ENET1_RX_CLK,
    input  wire logic [3:0]  ENET1_RX_DATA,
    input  wire logic        ENET1_RX_DV,
    output wire logic [3:0]  ENET1_TX_DATA,
    output wire logic        ENET1_TX_EN
);
    localparam int unsigned CSR_ADDR_W = csr_pkg::CSR_MIN_ADDR_WIDTH;

    // Shared system and RGMII clocks, PLL status, and system reset.
    logic clock_125;
    logic rgmii_clock_125;
    logic rgmii_clock_25;
    logic rgmii_clock_2p5;
    logic pll_locked;
    logic system_reset;

    // JTAG-to-Avalon-MM master interface for CSR access.
    logic [31:0] jtag_master_address;
    logic [31:0] jtag_master_readdata;
    logic jtag_master_read;
    logic jtag_master_write;
    logic [31:0] jtag_master_writedata;
    logic jtag_master_waitrequest;
    logic jtag_master_readdatavalid;
    logic [3:0] jtag_master_byteenable;
    logic [31:0] test_input;
    logic [31:0] test_output;

    // MAC0 Avalon-ST interfaces to and from user-defined RTL.
    logic [7:0] aso_mac0_data;
    logic aso_mac0_valid;
    logic aso_mac0_sop;
    logic aso_mac0_eop;
    logic aso_mac0_ready;
    logic [0:0] aso_mac0_channel;
    logic [0:0] aso_mac0_empty;
    logic [7:0] asi_mac0_data;
    logic asi_mac0_valid;
    logic asi_mac0_sop;
    logic asi_mac0_eop;
    logic asi_mac0_ready;
    logic [0:0] asi_mac0_channel;
    logic [0:0] asi_mac0_empty;

    // MAC1 Avalon-ST interfaces to and from user-defined RTL.
    logic [7:0] aso_mac1_data;
    logic aso_mac1_valid;
    logic aso_mac1_sop;
    logic aso_mac1_eop;
    logic aso_mac1_ready;
    logic [0:0] aso_mac1_channel;
    logic [0:0] aso_mac1_empty;
    logic [7:0] asi_mac1_data;
    logic asi_mac1_valid;
    logic asi_mac1_sop;
    logic asi_mac1_eop;
    logic asi_mac1_ready;
    logic [0:0] asi_mac1_channel;
    logic [0:0] asi_mac1_empty;

    // Status and diagnostic signals from MAC0.
    logic mac0_init_done;
    logic mac0_init_error;
    logic mac0_eth_mode;
    logic mac0_ena_10;
    (* keep = 1 *) logic mac0_tx_clock;
    logic mac0_tx_clock_toggle;
    logic mac0_rx_activity;
    logic mac0_tx_activity;
    logic [4:0] mac0_rx_error;
    logic mac0_rx_error_seen;
    logic mac0_rx_overflow;
    logic mac0_tx_overflow;
    logic [12:0] mac0_rx_fifo_depth;
    logic [16:0] mac0_tx_fifo_depth;

    // Status and diagnostic signals from MAC1.
    logic mac1_init_done;
    logic mac1_init_error;
    logic mac1_eth_mode;
    logic mac1_ena_10;
    (* keep = 1 *) logic mac1_tx_clock;
    logic mac1_tx_clock_toggle;
    logic mac1_rx_activity;
    logic mac1_tx_activity;
    logic [4:0] mac1_rx_error;
    logic mac1_rx_error_seen;
    logic mac1_rx_overflow;
    logic mac1_tx_overflow;
    logic [12:0] mac1_rx_fifo_depth;
    logic [16:0] mac1_tx_fifo_depth;

    logic [17:0] debug_leds;
    logic any_stream_error;

    // The generated PLL variation remains Verilog.
    ethernet_pll pll (
        .inclk0(CLOCK_50),
        .areset(~KEY[0]),
        .c0(clock_125),
        .c1(rgmii_clock_125),
        .c2(rgmii_clock_25),
        .c3(rgmii_clock_2p5),
        .locked(pll_locked)
    );

    ethernet_reset reset_generator (
        .clk(clock_125),
        .rst_n(KEY[0]),
        .pll_locked(pll_locked),
        .system_reset(system_reset)
    );

    ethernet_mac #(
        .MAC_ADDRESS(48'h020000000001),
        .PHY_ADDRESS(5'b10000),
        .RX_ASYNC_FIFO_DEPTH(4096),
        .TX_ASYNC_FIFO_DEPTH(65536)
    ) mac0 (
        .clk(clock_125),
        .rst(system_reset),
        .clk_125(rgmii_clock_125),
        .clk_25(rgmii_clock_25),
        .clk_2p5(rgmii_clock_2p5),
        .asi_data(asi_mac0_data),
        .asi_valid(asi_mac0_valid),
        .asi_sop(asi_mac0_sop),
        .asi_eop(asi_mac0_eop),
        .asi_ready(asi_mac0_ready),
        .asi_channel(asi_mac0_channel),
        .asi_empty(asi_mac0_empty),
        .aso_data(aso_mac0_data),
        .aso_valid(aso_mac0_valid),
        .aso_sop(aso_mac0_sop),
        .aso_eop(aso_mac0_eop),
        .aso_ready(aso_mac0_ready),
        .aso_channel(aso_mac0_channel),
        .aso_empty(aso_mac0_empty),
        .rgmii_rx_clk(ENET0_RX_CLK),
        .rgmii_rx_data(ENET0_RX_DATA),
        .rgmii_rx_control(ENET0_RX_DV),
        .rgmii_tx_clk(ENET0_GTX_CLK),
        .rgmii_tx_data(ENET0_TX_DATA),
        .rgmii_tx_control(ENET0_TX_EN),
        .phy_mdc(ENET0_MDC),
        .phy_mdio(ENET0_MDIO),
        .phy_int_n(ENET0_INT_N),
        .phy_reset_n(ENET0_RESET_N),
        .status_init_done(mac0_init_done),
        .status_init_error(mac0_init_error),
        .status_eth_mode(mac0_eth_mode),
        .status_ena_10(mac0_ena_10),
        .status_tx_clock(mac0_tx_clock),
        .status_tx_clock_toggle(mac0_tx_clock_toggle),
        .status_rx_activity(mac0_rx_activity),
        .status_tx_activity(mac0_tx_activity),
        .status_rx_error(mac0_rx_error),
        .status_rx_error_seen(mac0_rx_error_seen),
        .status_rx_overflow(mac0_rx_overflow),
        .status_tx_overflow(mac0_tx_overflow),
        .status_rx_fifo_depth(mac0_rx_fifo_depth),
        .status_tx_fifo_depth(mac0_tx_fifo_depth),
        .status_pkt_class_data(),
        .status_pkt_class_valid()
    );

    ethernet_mac #(
        .MAC_ADDRESS(48'h020000000002),
        .PHY_ADDRESS(5'b10001),
        .RX_ASYNC_FIFO_DEPTH(4096),
        .TX_ASYNC_FIFO_DEPTH(65536)
    ) mac1 (
        .clk(clock_125),
        .rst(system_reset),
        .clk_125(rgmii_clock_125),
        .clk_25(rgmii_clock_25),
        .clk_2p5(rgmii_clock_2p5),
        .asi_data(asi_mac1_data),
        .asi_valid(asi_mac1_valid),
        .asi_sop(asi_mac1_sop),
        .asi_eop(asi_mac1_eop),
        .asi_ready(asi_mac1_ready),
        .asi_channel(asi_mac1_channel),
        .asi_empty(asi_mac1_empty),
        .aso_data(aso_mac1_data),
        .aso_valid(aso_mac1_valid),
        .aso_sop(aso_mac1_sop),
        .aso_eop(aso_mac1_eop),
        .aso_ready(aso_mac1_ready),
        .aso_channel(aso_mac1_channel),
        .aso_empty(aso_mac1_empty),
        .rgmii_rx_clk(ENET1_RX_CLK),
        .rgmii_rx_data(ENET1_RX_DATA),
        .rgmii_rx_control(ENET1_RX_DV),
        .rgmii_tx_clk(ENET1_GTX_CLK),
        .rgmii_tx_data(ENET1_TX_DATA),
        .rgmii_tx_control(ENET1_TX_EN),
        .phy_mdc(ENET1_MDC),
        .phy_mdio(ENET1_MDIO),
        .phy_int_n(ENET1_INT_N),
        .phy_reset_n(ENET1_RESET_N),
        .status_init_done(mac1_init_done),
        .status_init_error(mac1_init_error),
        .status_eth_mode(mac1_eth_mode),
        .status_ena_10(mac1_ena_10),
        .status_tx_clock(mac1_tx_clock),
        .status_tx_clock_toggle(mac1_tx_clock_toggle),
        .status_rx_activity(mac1_rx_activity),
        .status_tx_activity(mac1_tx_activity),
        .status_rx_error(mac1_rx_error),
        .status_rx_error_seen(mac1_rx_error_seen),
        .status_rx_overflow(mac1_rx_overflow),
        .status_tx_overflow(mac1_tx_overflow),
        .status_rx_fifo_depth(mac1_rx_fifo_depth),
        .status_tx_fifo_depth(mac1_tx_fifo_depth),
        .status_pkt_class_data(),
        .status_pkt_class_valid()
    );

    // The CSR consumes word addresses, so byte-address bits [1:0]
    // are removed at the adasec_top connection below.
    jtag_avalon_master_master_0 jtag_master (
        .clk_clk(clock_125),
        .clk_reset_reset(system_reset),
        .master_address(jtag_master_address),
        .master_readdata(jtag_master_readdata),
        .master_read(jtag_master_read),
        .master_write(jtag_master_write),
        .master_writedata(jtag_master_writedata),
        .master_waitrequest(jtag_master_waitrequest),
        .master_readdatavalid(jtag_master_readdatavalid),
        .master_byteenable(jtag_master_byteenable),
        .master_reset_reset()
    );

    adasec_top adasec (
        .clk(clock_125),
        .rst(system_reset),
        .avalon_read(jtag_master_read),
        .avalon_write(jtag_master_write),
        .avalon_waitrequest(jtag_master_waitrequest),
        .avalon_address(jtag_master_address[CSR_ADDR_W-1:2]),
        .avalon_writedata(jtag_master_writedata),
        .avalon_byteenable(jtag_master_byteenable),
        .avalon_readdatavalid(jtag_master_readdatavalid),
        .avalon_writeresponsevalid(),
        .avalon_readdata(jtag_master_readdata),
        .avalon_response(),
        .asi_ch0_data(aso_mac0_data),
        .asi_ch0_valid(aso_mac0_valid),
        .asi_ch0_sop(aso_mac0_sop),
        .asi_ch0_eop(aso_mac0_eop),
        .asi_ch0_empty(aso_mac0_empty),
        .asi_ch0_ready(aso_mac0_ready),
        .aso_ch0_data(asi_mac0_data),
        .aso_ch0_valid(asi_mac0_valid),
        .aso_ch0_sop(asi_mac0_sop),
        .aso_ch0_eop(asi_mac0_eop),
        .aso_ch0_empty(asi_mac0_empty),
        .aso_ch0_ready(asi_mac0_ready),
        .asi_ch1_data(aso_mac1_data),
        .asi_ch1_valid(aso_mac1_valid),
        .asi_ch1_sop(aso_mac1_sop),
        .asi_ch1_eop(aso_mac1_eop),
        .asi_ch1_empty(aso_mac1_empty),
        .asi_ch1_ready(aso_mac1_ready),
        .aso_ch1_data(asi_mac1_data),
        .aso_ch1_valid(asi_mac1_valid),
        .aso_ch1_sop(asi_mac1_sop),
        .aso_ch1_eop(asi_mac1_eop),
        .aso_ch1_empty(asi_mac1_empty),
        .aso_ch1_ready(asi_mac1_ready),
        .asi_ch2_data(),
        .asi_ch2_valid(),
        .asi_ch2_sop(),
        .asi_ch2_eop(),
        .asi_ch2_empty(),
        .asi_ch2_ready(),
        .aso_ch2_data(),
        .aso_ch2_valid(),
        .aso_ch2_sop(),
        .aso_ch2_eop(),
        .aso_ch2_empty(),
        .aso_ch2_ready(),
        .asi_ch3_data(),
        .asi_ch3_valid(),
        .asi_ch3_sop(),
        .asi_ch3_eop(),
        .asi_ch3_empty(),
        .asi_ch3_ready(),
        .aso_ch3_data(),
        .aso_ch3_valid(),
        .aso_ch3_sop(),
        .aso_ch3_eop(),
        .aso_ch3_empty(),
        .aso_ch3_ready(),
        .test_input(test_input),
        .test_output(test_output)
    );

    assign asi_mac0_channel = '0;
    assign asi_mac1_channel = '0;
    assign test_input = {test_output[31:28], ~KEY, 6'b0, ~SW};

    assign any_stream_error = mac0_init_error || mac1_init_error ||
                              mac0_rx_error_seen || mac1_rx_error_seen ||
                              mac0_rx_overflow || mac1_rx_overflow ||
                              mac0_tx_overflow || mac1_tx_overflow;

    assign LEDG[0] = pll_locked;
    assign LEDG[1] = ~system_reset;
    assign LEDG[2] = mac0_init_done;
    assign LEDG[3] = mac1_init_done;
    assign LEDG[4] = mac0_rx_activity;
    assign LEDG[5] = mac1_rx_activity;
    assign LEDG[6] = mac0_tx_activity;
    assign LEDG[7] = mac1_tx_activity;
    assign LEDG[8] = any_stream_error;

    assign debug_leds[0] = mac0_eth_mode;
    assign debug_leds[1] = mac0_ena_10;
    assign debug_leds[2] = mac1_eth_mode;
    assign debug_leds[3] = mac1_ena_10;
    assign debug_leds[4] = mac0_tx_clock_toggle;
    assign debug_leds[5] = mac1_tx_clock_toggle;
    assign debug_leds[6] = mac0_rx_activity;
    assign debug_leds[7] = mac1_rx_activity;
    assign debug_leds[8] = mac0_rx_overflow;
    assign debug_leds[9] = mac1_rx_overflow;
    assign debug_leds[10] = mac0_tx_overflow;
    assign debug_leds[11] = mac1_tx_overflow;
    // Assert when at least half of the 64-KiB TX FIFO is occupied.
    assign debug_leds[12] = mac0_tx_fifo_depth[16] || mac0_tx_fifo_depth[15];
    assign debug_leds[13] = mac1_tx_fifo_depth[16] || mac1_tx_fifo_depth[15];
    assign debug_leds[14] = mac0_rx_error_seen;
    assign debug_leds[15] = mac1_rx_error_seen;
    assign debug_leds[16] = mac0_init_error || mac1_init_error;
    assign debug_leds[17] = 1'b1;

    assign LEDR = !SW[17] ? test_output[17:0] : debug_leds;
endmodule

`resetall
