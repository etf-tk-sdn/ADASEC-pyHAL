// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

`resetall
`timescale 1ns / 1ps
`default_nettype none

module ethernet_mac_init #(
    parameter logic [47:0] MAC_ADDRESS = 48'h020000000001,
    parameter logic [4:0] PHY_ADDRESS = 5'b10000
) (
    input  wire logic        clk,
    input  wire logic        reset,
    input  wire logic        phy_int_n,
    output wire logic [7:0]  reg_addr,
    output wire logic [31:0] reg_data_in,
    input  wire logic [31:0] reg_data_out,
    output wire logic        reg_rd,
    output wire logic        reg_wr,
    input  wire logic        reg_busy,
    output wire logic        done,
    output wire logic        error
);
    typedef enum logic [4:0] {
        WAIT_FOR_PHY,
        WRITE_MAC_REGISTER,
        WRITE_PHY_ADDRESS,
        READ_PHY_EXTENDED_CONTROL,
        WRITE_PHY_EXTENDED_CONTROL,
        VERIFY_PHY_EXTENDED_CONTROL_BEFORE_RESET,
        READ_PHY_BASIC_CONTROL,
        WRITE_PHY_SOFTWARE_RESET,
        POLL_PHY_RESET_GAP,
        POLL_PHY_RESET,
        VERIFY_PHY_EXTENDED_CONTROL_AFTER_RESET,
        READ_PHY_AUTONEG_ADVERTISEMENT,
        WRITE_PHY_AUTONEG_ADVERTISEMENT,
        READ_PHY_BASIC_CONTROL_FOR_RESTART,
        WRITE_PHY_AUTONEG_RESTART,
        WRITE_PHY_INTERRUPT_ENABLE,
        CLEAR_PHY_INTERRUPT_STATUS,
        WAIT_INITIAL_LINK_GAP,
        READ_INITIAL_PHY_STATUS,
        WRITE_MAC_SOFTWARE_RESET,
        POLL_MAC_SOFTWARE_RESET_GAP,
        POLL_MAC_SOFTWARE_RESET,
        WRITE_INITIAL_MAC_MODE,
        WAIT_INITIAL_CLOCK_SWITCH,
        WRITE_INITIAL_MAC_ENABLE,
        RUNNING,
        READ_RUNTIME_INTERRUPT_STATUS,
        READ_RUNTIME_PHY_STATUS,
        WRITE_RUNTIME_MAC_MODE,
        WAIT_RUNTIME_CLOCK_SWITCH,
        WRITE_RUNTIME_MAC_ENABLE,
        FAILED
    } state_t;

    // All counters are calculated for a 125 MHz control clock.
    localparam int unsigned PHY_STARTUP_COUNTER_MAX = 624999; // 5 ms
    localparam int unsigned LINK_POLL_COUNTER_MAX = 124999; // 1 ms
    localparam int unsigned PHY_RESET_POLL_LIMIT = 32767;
    localparam int unsigned MAC_RESET_POLL_LIMIT = 32767;
    localparam int unsigned CLOCK_SWITCH_COUNTER_MAX = 2499; // 20 us
    localparam int unsigned PHY_STARTUP_COUNTER_W =
        $clog2(PHY_STARTUP_COUNTER_MAX + 1);
    localparam int unsigned LINK_POLL_COUNTER_W =
        $clog2(LINK_POLL_COUNTER_MAX + 1);
    localparam int unsigned PHY_RESET_POLL_W =
        $clog2(PHY_RESET_POLL_LIMIT + 1);
    localparam int unsigned MAC_RESET_POLL_W =
        $clog2(MAC_RESET_POLL_LIMIT + 1);
    localparam int unsigned CLOCK_SWITCH_COUNTER_W =
        $clog2(CLOCK_SWITCH_COUNTER_MAX + 1);

    localparam int unsigned MAC_WRITE_COUNT = 5;
    localparam int unsigned MAC_WRITE_INDEX_W = $clog2(MAC_WRITE_COUNT);
    localparam logic [7:0] MAC_WRITE_ADDRESSES [0:MAC_WRITE_COUNT-1] = '{
        8'h02, // command_config
        8'h03, // mac_0
        8'h04, // mac_1
        8'h05, // frm_length
        8'h17  // tx_ipg_length
    };
    localparam logic [31:0] MAC_WRITE_DATA [0:MAC_WRITE_COUNT-1] = '{
        32'h00000100,                    // TX/RX disabled; PAUSE ignored
        MAC_ADDRESS[31:0],
        {16'h0000, MAC_ADDRESS[47:32]},
        32'h000005ee,                    // standard frame: 1518 B
        32'h0000000c                     // Ethernet IPG: 12 B
    };

    localparam logic [7:0] COMMAND_CONFIG_REGISTER = 8'h02;
    localparam logic [7:0] MDIO_ADDRESS_0_REGISTER = 8'h0f;
    localparam logic [7:0] PHY_BASIC_CONTROL = 8'h80;
    localparam logic [7:0] PHY_AUTONEG_ADVERTISEMENT = 8'h84;
    localparam logic [7:0] PHY_SPECIFIC_STATUS = 8'h91;
    localparam logic [7:0] PHY_INTERRUPT_ENABLE = 8'h92;
    localparam logic [7:0] PHY_INTERRUPT_STATUS = 8'h93;
    localparam logic [7:0] PHY_EXTENDED_CONTROL = 8'h94;

    localparam logic [15:0] RGMII_DELAY_MASK = 16'h0082;
    localparam logic [15:0] PHY_INTERRUPT_ENABLE_MASK = 16'h6c00;
    localparam logic [15:0] PHY_PAUSE_CAPABILITY_MASK = 16'h0c00;

    function automatic logic [31:0] make_command_config(
        input logic [1:0] speed,
        input logic full_duplex,
        input logic enable_mac
    );
        logic [31:0] value;
        begin
            // RX_ERR_DISC, PAUSE_IGNORE, PAD_EN, and PROMIS_EN. Flow-control
            // generation and forwarding remain disabled.
            value = 32'h04000130;
            if (enable_mac)
                value[1:0] = 2'b11; // RX_ENA, TX_ENA

            case (speed)
                2'b10: value[3] = 1'b1;  // ETH_SPEED / 1000 M
                2'b00: value[25] = 1'b1; // ENA_10 / 10 M
                default: ;                // 100 M
            endcase

            if (!full_duplex)
                value[10] = 1'b1; // HD_ENA
            return value;
        end
    endfunction

    state_t state = WAIT_FOR_PHY;
    state_t next_state = WAIT_FOR_PHY;

    logic [MAC_WRITE_INDEX_W-1:0] mac_write_index = '0;
    logic [PHY_STARTUP_COUNTER_W-1:0] startup_counter = '0;
    logic [LINK_POLL_COUNTER_W-1:0] link_poll_counter = '0;
    logic [PHY_RESET_POLL_W-1:0] phy_reset_poll_counter = '0;
    logic [MAC_RESET_POLL_W-1:0] mac_reset_poll_counter = '0;
    logic [CLOCK_SWITCH_COUNTER_W-1:0] clock_switch_counter = '0;

    logic phy_int_meta = 1'b1;
    logic phy_int_sync = 1'b1;
    logic [15:0] phy_extended_value = '0;
    logic [15:0] phy_advertisement_value = '0;
    logic [15:0] phy_basic_value = '0;
    logic [1:0] negotiated_speed = 2'b10;
    logic negotiated_full_duplex = 1'b1;
    logic [1:0] active_speed = 2'b10;
    logic active_full_duplex = 1'b1;
    logic initialization_done = 1'b0;
    logic [7:0] reg_addr_reg;
    logic [31:0] reg_data_in_reg;
    logic reg_rd_reg;
    logic reg_wr_reg;

    assign reg_addr = reg_addr_reg;
    assign reg_data_in = reg_data_in_reg;
    assign reg_rd = reg_rd_reg;
    assign reg_wr = reg_wr_reg;
    assign done = initialization_done;
    assign error = (state == FAILED);

    // Moore FSM next-state logic.
    always_comb begin
        next_state = state;

        case (state)
            WAIT_FOR_PHY: begin
                if (startup_counter == PHY_STARTUP_COUNTER_MAX)
                    next_state = WRITE_MAC_REGISTER;
            end

            WRITE_MAC_REGISTER: begin
                if (!reg_busy && (mac_write_index == MAC_WRITE_COUNT-1))
                    next_state = WRITE_PHY_ADDRESS;
            end

            WRITE_PHY_ADDRESS: begin
                if (!reg_busy)
                    next_state = READ_PHY_EXTENDED_CONTROL;
            end

            READ_PHY_EXTENDED_CONTROL: begin
                if (!reg_busy) begin
                    if ((reg_data_out[15:0] == 16'hffff) ||
                        (reg_data_out[15:0] == 16'h0000))
                        next_state = FAILED;
                    else
                        next_state = WRITE_PHY_EXTENDED_CONTROL;
                end
            end

            WRITE_PHY_EXTENDED_CONTROL: begin
                if (!reg_busy)
                    next_state = VERIFY_PHY_EXTENDED_CONTROL_BEFORE_RESET;
            end

            VERIFY_PHY_EXTENDED_CONTROL_BEFORE_RESET,
            VERIFY_PHY_EXTENDED_CONTROL_AFTER_RESET: begin
                if (!reg_busy) begin
                    if ((reg_data_out[15:0] == 16'hffff) ||
                        ((reg_data_out[15:0] & RGMII_DELAY_MASK) != RGMII_DELAY_MASK)) begin
                        next_state = FAILED;
                    end else if (state == VERIFY_PHY_EXTENDED_CONTROL_BEFORE_RESET) begin
                        next_state = READ_PHY_BASIC_CONTROL;
                    end else begin
                        next_state = READ_PHY_AUTONEG_ADVERTISEMENT;
                    end
                end
            end

            READ_PHY_BASIC_CONTROL: begin
                if (!reg_busy) begin
                    if (reg_data_out[15:0] == 16'hffff)
                        next_state = FAILED;
                    else
                        next_state = WRITE_PHY_SOFTWARE_RESET;
                end
            end

            WRITE_PHY_SOFTWARE_RESET: begin
                if (!reg_busy)
                    next_state = POLL_PHY_RESET_GAP;
            end

            POLL_PHY_RESET_GAP: next_state = POLL_PHY_RESET;

            POLL_PHY_RESET: begin
                if (!reg_busy) begin
                    if ((reg_data_out[15:0] == 16'hffff) ||
                        (phy_reset_poll_counter == PHY_RESET_POLL_LIMIT))
                        next_state = FAILED;
                    else if (!reg_data_out[15])
                        next_state = VERIFY_PHY_EXTENDED_CONTROL_AFTER_RESET;
                    else
                        next_state = POLL_PHY_RESET_GAP;
                end
            end

            READ_PHY_AUTONEG_ADVERTISEMENT: begin
                if (!reg_busy) begin
                    if ((reg_data_out[15:0] == 16'hffff) ||
                        (reg_data_out[15:0] == 16'h0000))
                        next_state = FAILED;
                    else
                        next_state = WRITE_PHY_AUTONEG_ADVERTISEMENT;
                end
            end

            WRITE_PHY_AUTONEG_ADVERTISEMENT: begin
                if (!reg_busy)
                    next_state = READ_PHY_BASIC_CONTROL_FOR_RESTART;
            end

            READ_PHY_BASIC_CONTROL_FOR_RESTART: begin
                if (!reg_busy) begin
                    if (reg_data_out[15:0] == 16'hffff)
                        next_state = FAILED;
                    else
                        next_state = WRITE_PHY_AUTONEG_RESTART;
                end
            end

            WRITE_PHY_AUTONEG_RESTART: begin
                if (!reg_busy)
                    next_state = WRITE_PHY_INTERRUPT_ENABLE;
            end

            WRITE_PHY_INTERRUPT_ENABLE: begin
                if (!reg_busy)
                    next_state = CLEAR_PHY_INTERRUPT_STATUS;
            end

            CLEAR_PHY_INTERRUPT_STATUS: begin
                if (!reg_busy) begin
                    if (reg_data_out[15:0] == 16'hffff)
                        next_state = FAILED;
                    else
                        next_state = WAIT_INITIAL_LINK_GAP;
                end
            end

            WAIT_INITIAL_LINK_GAP: begin
                if (link_poll_counter == LINK_POLL_COUNTER_MAX)
                    next_state = READ_INITIAL_PHY_STATUS;
            end

            READ_INITIAL_PHY_STATUS: begin
                if (!reg_busy) begin
                    if (reg_data_out[15:0] == 16'hffff) begin
                        next_state = FAILED;
                    end else if (reg_data_out[10] && reg_data_out[11] &&
                                 (reg_data_out[15:14] != 2'b11)) begin
                        next_state = WRITE_MAC_SOFTWARE_RESET;
                    end else begin
                        next_state = WAIT_INITIAL_LINK_GAP;
                    end
                end
            end

            WRITE_MAC_SOFTWARE_RESET: begin
                if (!reg_busy)
                    next_state = POLL_MAC_SOFTWARE_RESET_GAP;
            end

            POLL_MAC_SOFTWARE_RESET_GAP: next_state = POLL_MAC_SOFTWARE_RESET;

            POLL_MAC_SOFTWARE_RESET: begin
                if (!reg_busy) begin
                    if ((reg_data_out == 32'hffffffff) ||
                        (mac_reset_poll_counter == MAC_RESET_POLL_LIMIT)) begin
                        next_state = FAILED;
                    end else if (!reg_data_out[13]) begin
                        if (!initialization_done)
                            next_state = WRITE_INITIAL_MAC_MODE;
                        else
                            next_state = WRITE_RUNTIME_MAC_MODE;
                    end else begin
                        next_state = POLL_MAC_SOFTWARE_RESET_GAP;
                    end
                end
            end

            WRITE_INITIAL_MAC_MODE: begin
                if (!reg_busy)
                    next_state = WAIT_INITIAL_CLOCK_SWITCH;
            end

            WAIT_INITIAL_CLOCK_SWITCH: begin
                if (clock_switch_counter == CLOCK_SWITCH_COUNTER_MAX)
                    next_state = WRITE_INITIAL_MAC_ENABLE;
            end

            WRITE_INITIAL_MAC_ENABLE: begin
                if (!reg_busy)
                    next_state = RUNNING;
            end

            RUNNING: begin
                if (!phy_int_sync)
                    next_state = READ_RUNTIME_INTERRUPT_STATUS;
            end

            READ_RUNTIME_INTERRUPT_STATUS: begin
                if (!reg_busy) begin
                    if (reg_data_out[15:0] == 16'hffff)
                        next_state = FAILED;
                    else
                        next_state = READ_RUNTIME_PHY_STATUS;
                end
            end

            READ_RUNTIME_PHY_STATUS: begin
                if (!reg_busy) begin
                    if (reg_data_out[15:0] == 16'hffff) begin
                        next_state = FAILED;
                    end else if (reg_data_out[10] && reg_data_out[11] &&
                                 (reg_data_out[15:14] != 2'b11) &&
                                 ((reg_data_out[15:14] != active_speed) ||
                                  (reg_data_out[13] != active_full_duplex))) begin
                        next_state = WRITE_MAC_SOFTWARE_RESET;
                    end else begin
                        next_state = RUNNING;
                    end
                end
            end

            WRITE_RUNTIME_MAC_MODE: begin
                if (!reg_busy)
                    next_state = WAIT_RUNTIME_CLOCK_SWITCH;
            end

            WAIT_RUNTIME_CLOCK_SWITCH: begin
                if (clock_switch_counter == CLOCK_SWITCH_COUNTER_MAX)
                    next_state = WRITE_RUNTIME_MAC_ENABLE;
            end

            WRITE_RUNTIME_MAC_ENABLE: begin
                if (!reg_busy)
                    next_state = RUNNING;
            end

            FAILED: next_state = FAILED;
            default: next_state = FAILED;
        endcase
    end

    // Moore FSM state and datapath registers.
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= WAIT_FOR_PHY;
            mac_write_index <= '0;
            startup_counter <= '0;
            link_poll_counter <= '0;
            phy_reset_poll_counter <= '0;
            mac_reset_poll_counter <= '0;
            clock_switch_counter <= '0;
            phy_int_meta <= 1'b1;
            phy_int_sync <= 1'b1;
            phy_extended_value <= '0;
            phy_advertisement_value <= '0;
            phy_basic_value <= '0;
            negotiated_speed <= 2'b10;
            negotiated_full_duplex <= 1'b1;
            active_speed <= 2'b10;
            active_full_duplex <= 1'b1;
            initialization_done <= 1'b0;
        end else begin
            state <= next_state;
            phy_int_meta <= phy_int_n;
            phy_int_sync <= phy_int_meta;

            if ((state == WAIT_FOR_PHY) &&
                (startup_counter < PHY_STARTUP_COUNTER_MAX))
                startup_counter <= startup_counter + 1'b1;

            if ((state == WRITE_MAC_REGISTER) && !reg_busy &&
                (mac_write_index < MAC_WRITE_COUNT-1))
                mac_write_index <= mac_write_index + 1'b1;

            if ((state == READ_PHY_EXTENDED_CONTROL) && !reg_busy &&
                (reg_data_out[15:0] != 16'hffff) &&
                (reg_data_out[15:0] != 16'h0000))
                phy_extended_value <= reg_data_out[15:0] | RGMII_DELAY_MASK;

            if ((state == READ_PHY_BASIC_CONTROL) && !reg_busy &&
                (reg_data_out[15:0] != 16'hffff)) begin
                phy_basic_value <= reg_data_out[15:0] | 16'h8000;
            end else if ((state == READ_PHY_BASIC_CONTROL_FOR_RESTART) &&
                         !reg_busy && (reg_data_out[15:0] != 16'hffff)) begin
                phy_basic_value <= reg_data_out[15:0] | 16'h1200;
            end

            if ((state == READ_PHY_AUTONEG_ADVERTISEMENT) && !reg_busy &&
                (reg_data_out[15:0] != 16'hffff) &&
                (reg_data_out[15:0] != 16'h0000)) begin
                // Do not advertise symmetric or asymmetric PAUSE capability.
                phy_advertisement_value <=
                    reg_data_out[15:0] & ~PHY_PAUSE_CAPABILITY_MASK;
            end

            if ((state == WRITE_PHY_SOFTWARE_RESET) && !reg_busy) begin
                phy_reset_poll_counter <= '0;
            end else if ((state == POLL_PHY_RESET) && !reg_busy &&
                         reg_data_out[15] &&
                         (phy_reset_poll_counter < PHY_RESET_POLL_LIMIT)) begin
                phy_reset_poll_counter <= phy_reset_poll_counter + 1'b1;
            end

            if (state == WAIT_INITIAL_LINK_GAP) begin
                if (link_poll_counter < LINK_POLL_COUNTER_MAX)
                    link_poll_counter <= link_poll_counter + 1'b1;
            end else begin
                link_poll_counter <= '0;
            end

            if (((state == READ_INITIAL_PHY_STATUS) ||
                 (state == READ_RUNTIME_PHY_STATUS)) && !reg_busy &&
                (reg_data_out[15:0] != 16'hffff) && reg_data_out[10] &&
                reg_data_out[11] && (reg_data_out[15:14] != 2'b11)) begin
                negotiated_speed <= reg_data_out[15:14];
                negotiated_full_duplex <= reg_data_out[13];
            end

            if ((state == WRITE_MAC_SOFTWARE_RESET) && !reg_busy) begin
                mac_reset_poll_counter <= '0;
            end else if ((state == POLL_MAC_SOFTWARE_RESET) && !reg_busy &&
                         reg_data_out[13] &&
                         (mac_reset_poll_counter < MAC_RESET_POLL_LIMIT)) begin
                mac_reset_poll_counter <= mac_reset_poll_counter + 1'b1;
            end

            if ((state == WAIT_INITIAL_CLOCK_SWITCH) ||
                (state == WAIT_RUNTIME_CLOCK_SWITCH)) begin
                if (clock_switch_counter < CLOCK_SWITCH_COUNTER_MAX)
                    clock_switch_counter <= clock_switch_counter + 1'b1;
            end else begin
                clock_switch_counter <= '0;
            end

            if ((state == WRITE_INITIAL_MAC_ENABLE) && !reg_busy) begin
                active_speed <= negotiated_speed;
                active_full_duplex <= negotiated_full_duplex;
                initialization_done <= 1'b1;
            end else if ((state == WRITE_RUNTIME_MAC_ENABLE) && !reg_busy) begin
                active_speed <= negotiated_speed;
                active_full_duplex <= negotiated_full_duplex;
            end
        end
    end

    // Moore FSM output logic.
    always_comb begin
        reg_addr_reg = '0;
        reg_data_in_reg = '0;
        reg_rd_reg = 1'b0;
        reg_wr_reg = 1'b0;

        case (state)
            WRITE_MAC_REGISTER: begin
                reg_addr_reg = MAC_WRITE_ADDRESSES[mac_write_index];
                reg_data_in_reg = MAC_WRITE_DATA[mac_write_index];
                reg_wr_reg = 1'b1;
            end

            WRITE_PHY_ADDRESS: begin
                reg_addr_reg = MDIO_ADDRESS_0_REGISTER;
                reg_data_in_reg[4:0] = PHY_ADDRESS;
                reg_wr_reg = 1'b1;
            end

            READ_PHY_EXTENDED_CONTROL,
            VERIFY_PHY_EXTENDED_CONTROL_BEFORE_RESET,
            VERIFY_PHY_EXTENDED_CONTROL_AFTER_RESET: begin
                reg_addr_reg = PHY_EXTENDED_CONTROL;
                reg_rd_reg = 1'b1;
            end

            WRITE_PHY_EXTENDED_CONTROL: begin
                reg_addr_reg = PHY_EXTENDED_CONTROL;
                reg_data_in_reg[15:0] = phy_extended_value;
                reg_wr_reg = 1'b1;
            end

            READ_PHY_BASIC_CONTROL,
            READ_PHY_BASIC_CONTROL_FOR_RESTART,
            POLL_PHY_RESET: begin
                reg_addr_reg = PHY_BASIC_CONTROL;
                reg_rd_reg = 1'b1;
            end

            WRITE_PHY_SOFTWARE_RESET,
            WRITE_PHY_AUTONEG_RESTART: begin
                reg_addr_reg = PHY_BASIC_CONTROL;
                reg_data_in_reg[15:0] = phy_basic_value;
                reg_wr_reg = 1'b1;
            end

            READ_PHY_AUTONEG_ADVERTISEMENT: begin
                reg_addr_reg = PHY_AUTONEG_ADVERTISEMENT;
                reg_rd_reg = 1'b1;
            end

            WRITE_PHY_AUTONEG_ADVERTISEMENT: begin
                reg_addr_reg = PHY_AUTONEG_ADVERTISEMENT;
                reg_data_in_reg[15:0] = phy_advertisement_value;
                reg_wr_reg = 1'b1;
            end

            WRITE_PHY_INTERRUPT_ENABLE: begin
                reg_addr_reg = PHY_INTERRUPT_ENABLE;
                reg_data_in_reg[15:0] = PHY_INTERRUPT_ENABLE_MASK;
                reg_wr_reg = 1'b1;
            end

            CLEAR_PHY_INTERRUPT_STATUS,
            READ_RUNTIME_INTERRUPT_STATUS: begin
                reg_addr_reg = PHY_INTERRUPT_STATUS;
                reg_rd_reg = 1'b1;
            end

            READ_INITIAL_PHY_STATUS,
            READ_RUNTIME_PHY_STATUS: begin
                reg_addr_reg = PHY_SPECIFIC_STATUS;
                reg_rd_reg = 1'b1;
            end

            WRITE_MAC_SOFTWARE_RESET: begin
                reg_addr_reg = COMMAND_CONFIG_REGISTER;
                if (!initialization_done) begin
                    reg_data_in_reg = make_command_config(
                        negotiated_speed, negotiated_full_duplex, 1'b0
                    ) | 32'h00002000;
                end else begin
                    reg_data_in_reg = make_command_config(
                        active_speed, active_full_duplex, 1'b0
                    ) | 32'h00002000;
                end
                reg_wr_reg = 1'b1;
            end

            POLL_MAC_SOFTWARE_RESET: begin
                reg_addr_reg = COMMAND_CONFIG_REGISTER;
                reg_rd_reg = 1'b1;
            end

            WRITE_INITIAL_MAC_MODE,
            WRITE_RUNTIME_MAC_MODE: begin
                reg_addr_reg = COMMAND_CONFIG_REGISTER;
                reg_data_in_reg = make_command_config(
                    negotiated_speed, negotiated_full_duplex, 1'b0
                );
                reg_wr_reg = 1'b1;
            end

            WRITE_INITIAL_MAC_ENABLE,
            WRITE_RUNTIME_MAC_ENABLE: begin
                reg_addr_reg = COMMAND_CONFIG_REGISTER;
                reg_data_in_reg = make_command_config(
                    negotiated_speed, negotiated_full_duplex, 1'b1
                );
                reg_wr_reg = 1'b1;
            end

            default: ;
        endcase
    end
endmodule

`resetall
