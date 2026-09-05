// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

module ethernet_top (
    // Board clock, user controls, and LED indicators.
    input  logic        CLOCK_50,
    input  logic [3:0]  KEY,
    input  logic [17:0] SW,
    output wire [17:0]  LEDR,
    output wire [8:0]   LEDG,

    // RGMII and control signals for the first Ethernet PHY.
    output wire       ENET0_GTX_CLK,
    output wire       ENET0_MDC,
    inout  wire       ENET0_MDIO,
    input  logic      ENET0_INT_N,
    output wire       ENET0_RESET_N,
    input  logic      ENET0_RX_CLK,
    input  logic [3:0] ENET0_RX_DATA,
    input  logic      ENET0_RX_DV,
    output wire [3:0] ENET0_TX_DATA,
    output wire       ENET0_TX_EN,

    // RGMII and control signals for the second Ethernet PHY.
    output wire       ENET1_GTX_CLK,
    output wire       ENET1_MDC,
    inout  wire       ENET1_MDIO,
    input  logic      ENET1_INT_N,
    output wire       ENET1_RESET_N,
    input  logic      ENET1_RX_CLK,
    input  logic [3:0] ENET1_RX_DATA,
    input  logic      ENET1_RX_DV,
    output wire [3:0] ENET1_TX_DATA,
    output wire       ENET1_TX_EN
);
    // Shared system and RGMII clocks, PLL status, and system reset.
    wire clock_125;
    wire rgmii_clock_125;
    wire rgmii_clock_25;
    wire rgmii_clock_2p5;
    wire pll_locked;
    wire system_reset;

    // MAC0 Avalon-ST interfaces to and from user-defined RTL.
    wire [7:0] aso_mac0_data;
    wire aso_mac0_valid;
    wire aso_mac0_sop;
    wire aso_mac0_eop;
    wire aso_mac0_ready;
    wire [0:0] aso_mac0_channel;
    wire [0:0] aso_mac0_empty;
    wire [7:0] asi_mac0_data;
    wire asi_mac0_valid;
    wire asi_mac0_sop;
    wire asi_mac0_eop;
    wire asi_mac0_ready;
    wire [0:0] asi_mac0_channel;
    wire [0:0] asi_mac0_empty;

    // MAC1 Avalon-ST interfaces to and from user-defined RTL.
    wire [7:0] aso_mac1_data;
    wire aso_mac1_valid;
    wire aso_mac1_sop;
    wire aso_mac1_eop;
    wire aso_mac1_ready;
    wire [0:0] aso_mac1_channel;
    wire [0:0] aso_mac1_empty;
    wire [7:0] asi_mac1_data;
    wire asi_mac1_valid;
    wire asi_mac1_sop;
    wire asi_mac1_eop;
    wire asi_mac1_ready;
    wire [0:0] asi_mac1_channel;
    wire [0:0] asi_mac1_empty;

    // Status and diagnostic signals from MAC0.
    wire mac0_init_done;
    wire mac0_init_error;
    wire mac0_eth_mode;
    wire mac0_ena_10;
    (* keep = 1 *) wire mac0_tx_clock;
    wire mac0_tx_clock_toggle;
    wire mac0_rx_activity;
    wire mac0_tx_activity;
    wire [4:0] mac0_rx_error;
    wire mac0_rx_error_seen;
    wire mac0_rx_overflow;
    wire mac0_tx_overflow;
    wire [12:0] mac0_rx_fifo_depth;
    wire [16:0] mac0_tx_fifo_depth;

    // Status and diagnostic signals from MAC1.
    wire mac1_init_done;
    wire mac1_init_error;
    wire mac1_eth_mode;
    wire mac1_ena_10;
    (* keep = 1 *) wire mac1_tx_clock;
    wire mac1_tx_clock_toggle;
    wire mac1_rx_activity;
    wire mac1_tx_activity;
    wire [4:0] mac1_rx_error;
    wire mac1_rx_error_seen;
    wire mac1_rx_overflow;
    wire mac1_tx_overflow;
    wire [12:0] mac1_rx_fifo_depth;
    wire [16:0] mac1_tx_fifo_depth;

    wire [17:0] debug_leds;
    wire any_stream_error;

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

    // User-defined RTL insertion point. The two streams are cross-connected.
    assign asi_mac0_data = aso_mac1_data;
    assign asi_mac0_valid = aso_mac1_valid;
    assign asi_mac0_sop = aso_mac1_sop;
    assign asi_mac0_eop = aso_mac1_eop;
    assign asi_mac0_channel = aso_mac1_channel;
    assign asi_mac0_empty = aso_mac1_empty;
    assign aso_mac1_ready = asi_mac0_ready;

    assign asi_mac1_data = aso_mac0_data;
    assign asi_mac1_valid = aso_mac0_valid;
    assign asi_mac1_sop = aso_mac0_sop;
    assign asi_mac1_eop = aso_mac0_eop;
    assign asi_mac1_channel = aso_mac0_channel;
    assign asi_mac1_empty = aso_mac0_empty;
    assign aso_mac0_ready = asi_mac1_ready;

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

    assign LEDR = !SW[17] ? SW : debug_leds;
endmodule
