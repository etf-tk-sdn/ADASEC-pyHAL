# SPDX-FileCopyrightText: 2026 Enio Kaljic
# SPDX-License-Identifier: CERN-OHL-S-2.0

# Base clock and all four outputs of the shared PLL.
create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]
derive_pll_clocks

# CDC paths in avalon_st_async_fifo. Gray pointers have bounded net delay and
# skew to the first synchronization register. The frame-commit snapshot remains
# stable during the toggle/ack handshake and is constrained in the same way.
proc constrain_async_fifo_bus {source_name destination_name max_net_delay max_skew} {
    set source_zero [get_registers -nowarn "*|avalon_st_async_fifo:*|${source_name}\[0\]"]

    foreach_in_collection source_zero_node $source_zero {
        set source_zero_name [get_node_info -name $source_zero_node]
        set instance_path [string range $source_zero_name 0 [string last "|" $source_zero_name]]
        set source_regs [get_registers "${instance_path}${source_name}\[*\]"]
        set destination_regs [get_registers "${instance_path}${destination_name}\[*\]"]

        set_net_delay \
            -from [get_pins -compatibility_mode "${instance_path}${source_name}\[*\]|q"] \
            -to $destination_regs -max $max_net_delay

        if {[string equal "quartus_sta" $::TimeQuestInfo(nameofexecutable)]} {
            set_max_skew -from $source_regs -to $destination_regs $max_skew
            set_max_delay -from $source_regs -to $destination_regs 100ns
            set_min_delay -from $source_regs -to $destination_regs -100ns
        } else {
            set_max_delay -from $source_regs -to $destination_regs 8ns
            set_min_delay -from $source_regs -to $destination_regs -100ns
        }
    }
}

proc constrain_async_fifo_toggle {source_name destination_name max_net_delay} {
    set source_nodes [get_registers -nowarn "*|avalon_st_async_fifo:*|${source_name}"]

    foreach_in_collection source_node $source_nodes {
        set source_node_name [get_node_info -name $source_node]
        set instance_path [string range $source_node_name 0 [string last "|" $source_node_name]]
        set source_reg [get_registers "${instance_path}${source_name}"]
        set destination_reg [get_registers "${instance_path}${destination_name}"]

        set_net_delay \
            -from [get_pins -compatibility_mode "${instance_path}${source_name}|q"] \
            -to $destination_reg -max $max_net_delay

        if {[string equal "quartus_sta" $::TimeQuestInfo(nameofexecutable)]} {
            set_max_delay -from $source_reg -to $destination_reg 100ns
            set_min_delay -from $source_reg -to $destination_reg -100ns
        } else {
            set_max_delay -from $source_reg -to $destination_reg 8ns
            set_min_delay -from $source_reg -to $destination_reg -100ns
        }
    }
}

constrain_async_fifo_bus wr_ptr_gray wr_ptr_gray_sync1 6ns 7.5ns
constrain_async_fifo_bus rd_ptr_gray rd_ptr_gray_sync1 6ns 7.5ns
constrain_async_fifo_bus wr_commit_snapshot rd_commit_ptr 4ns 7.5ns
constrain_async_fifo_toggle wr_commit_toggle wr_commit_toggle_sync1 6ns
constrain_async_fifo_toggle wr_commit_toggle_seen wr_commit_ack_sync1 6ns

# Only the first stage of each local reset synchronizer receives asynchronous
# reset. The remaining FIFO logic exits reset synchronously to its clock domain.
set_false_path -to [get_pins -compatibility_mode \
    {*|avalon_st_async_fifo:*|asi_reset_pipe[*]|clrn}]
set_false_path -to [get_pins -compatibility_mode \
    {*|avalon_st_async_fifo:*|aso_reset_pipe[*]|clrn}]

# Each MAC's RX diagnostics use a local async-assert/sync-deassert reset chain
# because mac_rx_stream_clk is independent of the 125 MHz control clock.
set_false_path -to [get_pins -compatibility_mode \
    {*|rx_diag_reset_pipe[*]|clrn}]

# The 88E1111 delays RGMII RX_CLK by approximately 2 ns relative to the data.
# Each PHY independently supplies 125, 25, or 2.5 MHz, so all three modes are
# described for each port.
create_clock -name ENET0_RX_SOURCE_1000 -period 8.000
create_clock -name ENET0_RX_SOURCE_100  -period 40.000
create_clock -name ENET0_RX_SOURCE_10   -period 400.000
create_clock -name ENET1_RX_SOURCE_1000 -period 8.000
create_clock -name ENET1_RX_SOURCE_100  -period 40.000
create_clock -name ENET1_RX_SOURCE_10   -period 400.000

create_clock -name ENET0_RX_CLK_1000 -period 8.000   -waveform {2.000 6.000}   [get_ports {ENET0_RX_CLK}]
create_clock -name ENET0_RX_CLK_100  -period 40.000  -waveform {2.000 22.000}  -add [get_ports {ENET0_RX_CLK}]
create_clock -name ENET0_RX_CLK_10   -period 400.000 -waveform {2.000 202.000} -add [get_ports {ENET0_RX_CLK}]
create_clock -name ENET1_RX_CLK_1000 -period 8.000   -waveform {2.000 6.000}   [get_ports {ENET1_RX_CLK}]
create_clock -name ENET1_RX_CLK_100  -period 40.000  -waveform {2.000 22.000}  -add [get_ports {ENET1_RX_CLK}]
create_clock -name ENET1_RX_CLK_10   -period 400.000 -waveform {2.000 202.000} -add [get_ports {ENET1_RX_CLK}]

set enet0_rx_ports [get_ports {ENET0_RX_DATA[*] ENET0_RX_DV}]
set enet1_rx_ports [get_ports {ENET1_RX_DATA[*] ENET1_RX_DV}]

foreach source_clock {ENET0_RX_SOURCE_1000 ENET0_RX_SOURCE_100 ENET0_RX_SOURCE_10} {
    set_input_delay -clock [get_clocks $source_clock] -max 0.800 -add_delay $enet0_rx_ports
    set_input_delay -clock [get_clocks $source_clock] -min -0.800 -add_delay $enet0_rx_ports
    set_input_delay -clock [get_clocks $source_clock] -clock_fall -max 0.800 -add_delay $enet0_rx_ports
    set_input_delay -clock [get_clocks $source_clock] -clock_fall -min -0.800 -add_delay $enet0_rx_ports
}

foreach source_clock {ENET1_RX_SOURCE_1000 ENET1_RX_SOURCE_100 ENET1_RX_SOURCE_10} {
    set_input_delay -clock [get_clocks $source_clock] -max 0.800 -add_delay $enet1_rx_ports
    set_input_delay -clock [get_clocks $source_clock] -min -0.800 -add_delay $enet1_rx_ports
    set_input_delay -clock [get_clocks $source_clock] -clock_fall -max 0.800 -add_delay $enet1_rx_ports
    set_input_delay -clock [get_clocks $source_clock] -clock_fall -min -0.800 -add_delay $enet1_rx_ports
}

foreach {source_clock rx_clock} {
    ENET0_RX_SOURCE_1000 ENET0_RX_CLK_1000
    ENET0_RX_SOURCE_100  ENET0_RX_CLK_100
    ENET0_RX_SOURCE_10   ENET0_RX_CLK_10
    ENET1_RX_SOURCE_1000 ENET1_RX_CLK_1000
    ENET1_RX_SOURCE_100  ENET1_RX_CLK_100
    ENET1_RX_SOURCE_10   ENET1_RX_CLK_10
} {
    set_false_path -fall_from [get_clocks $source_clock] -rise_to [get_clocks $rx_clock] -setup
    set_false_path -rise_from [get_clocks $source_clock] -fall_to [get_clocks $rx_clock] -setup
    set_false_path -fall_from [get_clocks $source_clock] -fall_to [get_clocks $rx_clock] -hold
    set_false_path -rise_from [get_clocks $source_clock] -rise_to [get_clocks $rx_clock] -hold
}

set_clock_groups -logically_exclusive \
    -group [get_clocks {ENET0_RX_SOURCE_1000 ENET0_RX_CLK_1000}] \
    -group [get_clocks {ENET0_RX_SOURCE_100 ENET0_RX_CLK_100}] \
    -group [get_clocks {ENET0_RX_SOURCE_10 ENET0_RX_CLK_10}]
set_clock_groups -logically_exclusive \
    -group [get_clocks {ENET1_RX_SOURCE_1000 ENET1_RX_CLK_1000}] \
    -group [get_clocks {ENET1_RX_SOURCE_100 ENET1_RX_CLK_100}] \
    -group [get_clocks {ENET1_RX_SOURCE_10 ENET1_RX_CLK_10}]

# TX data and the forwarded GTX_CLK are driven by the same port-specific
# ALTCLKCTRL. A corresponding output clock is created for every possible PLL master.
set tx_data_clock_1000 [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}]
set tx_data_clock_100  [get_clocks {pll|altpll_component|auto_generated|pll1|clk[2]}]
set tx_data_clock_10   [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}]
set tx_clock_source_1000 [get_pins {pll|altpll_component|auto_generated|pll1|clk[1]}]
set tx_clock_source_100  [get_pins {pll|altpll_component|auto_generated|pll1|clk[2]}]
set tx_clock_source_10   [get_pins {pll|altpll_component|auto_generated|pll1|clk[3]}]
set mac0_tx_clock_target [get_nets {mac0|tx_clock_selected}]
set mac1_tx_clock_target [get_nets {mac1|tx_clock_selected}]

# Clocks at the output of the LE clock-control logic break the combinational
# clock path and let TimeQuest track only the selected PLL master for each port.
create_generated_clock -name MAC0_TX_CLK_1000 -source $tx_clock_source_1000 -master_clock $tx_data_clock_1000 $mac0_tx_clock_target
create_generated_clock -name MAC0_TX_CLK_100  -source $tx_clock_source_100  -master_clock $tx_data_clock_100  -add $mac0_tx_clock_target
create_generated_clock -name MAC0_TX_CLK_10   -source $tx_clock_source_10   -master_clock $tx_data_clock_10   -add $mac0_tx_clock_target
create_generated_clock -name MAC1_TX_CLK_1000 -source $tx_clock_source_1000 -master_clock $tx_data_clock_1000 $mac1_tx_clock_target
create_generated_clock -name MAC1_TX_CLK_100  -source $tx_clock_source_100  -master_clock $tx_data_clock_100  -add $mac1_tx_clock_target
create_generated_clock -name MAC1_TX_CLK_10   -source $tx_clock_source_10   -master_clock $tx_data_clock_10   -add $mac1_tx_clock_target

create_generated_clock -name ENET0_TX_CLK_1000 -source $mac0_tx_clock_target -master_clock [get_clocks {MAC0_TX_CLK_1000}] [get_ports {ENET0_GTX_CLK}]
create_generated_clock -name ENET0_TX_CLK_100  -source $mac0_tx_clock_target -master_clock [get_clocks {MAC0_TX_CLK_100}]  -add [get_ports {ENET0_GTX_CLK}]
create_generated_clock -name ENET0_TX_CLK_10   -source $mac0_tx_clock_target -master_clock [get_clocks {MAC0_TX_CLK_10}]   -add [get_ports {ENET0_GTX_CLK}]
create_generated_clock -name ENET1_TX_CLK_1000 -source $mac1_tx_clock_target -master_clock [get_clocks {MAC1_TX_CLK_1000}] [get_ports {ENET1_GTX_CLK}]
create_generated_clock -name ENET1_TX_CLK_100  -source $mac1_tx_clock_target -master_clock [get_clocks {MAC1_TX_CLK_100}]  -add [get_ports {ENET1_GTX_CLK}]
create_generated_clock -name ENET1_TX_CLK_10   -source $mac1_tx_clock_target -master_clock [get_clocks {MAC1_TX_CLK_10}]   -add [get_ports {ENET1_GTX_CLK}]

set enet0_tx_ports [get_ports {ENET0_TX_DATA[*] ENET0_TX_EN}]
set enet1_tx_ports [get_ports {ENET1_TX_DATA[*] ENET1_TX_EN}]

foreach tx_output_clock {ENET0_TX_CLK_1000 ENET0_TX_CLK_100 ENET0_TX_CLK_10} {
    set_output_delay -clock [get_clocks $tx_output_clock] -max -0.900 -add_delay $enet0_tx_ports
    set_output_delay -clock [get_clocks $tx_output_clock] -min -2.700 -add_delay $enet0_tx_ports
    set_output_delay -clock [get_clocks $tx_output_clock] -clock_fall -max -0.900 -add_delay $enet0_tx_ports
    set_output_delay -clock [get_clocks $tx_output_clock] -clock_fall -min -2.700 -add_delay $enet0_tx_ports
}

foreach tx_output_clock {ENET1_TX_CLK_1000 ENET1_TX_CLK_100 ENET1_TX_CLK_10} {
    set_output_delay -clock [get_clocks $tx_output_clock] -max -0.900 -add_delay $enet1_tx_ports
    set_output_delay -clock [get_clocks $tx_output_clock] -min -2.700 -add_delay $enet1_tx_ports
    set_output_delay -clock [get_clocks $tx_output_clock] -clock_fall -max -0.900 -add_delay $enet1_tx_ports
    set_output_delay -clock [get_clocks $tx_output_clock] -clock_fall -min -2.700 -add_delay $enet1_tx_ports
}

foreach {tx_data_clock tx_output_clock} {
    MAC0_TX_CLK_1000 ENET0_TX_CLK_1000
    MAC0_TX_CLK_100  ENET0_TX_CLK_100
    MAC0_TX_CLK_10   ENET0_TX_CLK_10
    MAC1_TX_CLK_1000 ENET1_TX_CLK_1000
    MAC1_TX_CLK_100  ENET1_TX_CLK_100
    MAC1_TX_CLK_10   ENET1_TX_CLK_10
} {
    set_multicycle_path 0 -setup -end -rise_from [get_clocks $tx_data_clock] -rise_to [get_clocks $tx_output_clock]
    set_multicycle_path 0 -setup -end -fall_from [get_clocks $tx_data_clock] -fall_to [get_clocks $tx_output_clock]
    set_false_path -fall_from [get_clocks $tx_data_clock] -rise_to [get_clocks $tx_output_clock] -setup
    set_false_path -rise_from [get_clocks $tx_data_clock] -fall_to [get_clocks $tx_output_clock] -setup
    set_false_path -fall_from [get_clocks $tx_data_clock] -fall_to [get_clocks $tx_output_clock] -hold
    set_false_path -rise_from [get_clocks $tx_data_clock] -rise_to [get_clocks $tx_output_clock] -hold
}

set_clock_groups -logically_exclusive \
    -group [get_clocks {MAC0_TX_CLK_1000 ENET0_TX_CLK_1000}] \
    -group [get_clocks {MAC0_TX_CLK_100 ENET0_TX_CLK_100}] \
    -group [get_clocks {MAC0_TX_CLK_10 ENET0_TX_CLK_10}]
set_clock_groups -logically_exclusive \
    -group [get_clocks {MAC1_TX_CLK_1000 ENET1_TX_CLK_1000}] \
    -group [get_clocks {MAC1_TX_CLK_100 ENET1_TX_CLK_100}] \
    -group [get_clocks {MAC1_TX_CLK_10 ENET1_TX_CLK_10}]

# Slow or asynchronous control and diagnostic pins are not RGMII timing paths.
set_false_path -from [get_ports {KEY[*] SW[*] ENET0_INT_N ENET1_INT_N}]
set_false_path -to [get_ports {LEDR[*] LEDG[*] ENET0_RESET_N ENET1_RESET_N}]
set_false_path -from [get_ports {ENET0_MDIO ENET1_MDIO}]
set_false_path -to [get_ports {ENET0_MDC ENET1_MDC ENET0_MDIO ENET1_MDIO}]

# The device's dedicated JTAG pins belong to Quartus' internal JTAG interface,
# not to the user timing interface, so external I/O delays do not apply.
set_false_path -from [get_ports {altera_reserved_tdi altera_reserved_tms}]
set_false_path -to [get_ports {altera_reserved_tdo}]

derive_clock_uncertainty
