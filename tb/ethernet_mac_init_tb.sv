// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

`resetall
`timescale 1ns / 1ps
`default_nettype none

module ethernet_mac_init_tb;
    localparam time CLK_PERIOD = 8ns;

    logic clk = 1'b0;
    logic reset = 1'b1;
    logic phy_int_n = 1'b1;
    logic [7:0] reg_addr;
    logic [31:0] reg_data_in;
    logic [31:0] reg_data_out;
    logic reg_rd;
    logic reg_wr;
    logic done;
    logic error;

    logic [15:0] phy_extended = 16'h0c60;
    logic [15:0] phy_basic = 16'h1140;
    logic [15:0] phy_advertisement = 16'h0de1;
    logic [15:0] phy_status = 16'hac00;
    logic [31:0] command_config = '0;
    logic forbidden_write_seen = 1'b0;

    always #(CLK_PERIOD / 2) clk = ~clk;

    ethernet_mac_init #(
        .MAC_ADDRESS(48'h020000000001),
        .PHY_ADDRESS(5'b10000)
    ) dut (
        .clk(clk),
        .reset(reset),
        .phy_int_n(phy_int_n),
        .reg_addr(reg_addr),
        .reg_data_in(reg_data_in),
        .reg_data_out(reg_data_out),
        .reg_rd(reg_rd),
        .reg_wr(reg_wr),
        .reg_busy(1'b0),
        .done(done),
        .error(error)
    );

    always_comb begin
        reg_data_out = '0;
        case (reg_addr)
            8'h02: reg_data_out = command_config;
            8'h80: reg_data_out[15:0] = phy_basic;
            8'h84: reg_data_out[15:0] = phy_advertisement;
            8'h91: reg_data_out[15:0] = phy_status;
            8'h93: reg_data_out[15:0] = 16'h0000;
            8'h94: reg_data_out[15:0] = phy_extended;
            default: ;
        endcase
    end

    always_ff @(posedge clk) begin : write_model
        logic [15:0] next_basic;
        logic [31:0] next_command_config;

        if (reset) begin
            phy_extended <= 16'h0c60;
            phy_basic <= 16'h1140;
            phy_advertisement <= 16'h0de1;
            command_config <= '0;
            forbidden_write_seen <= 1'b0;
        end else if (reg_wr) begin
            case (reg_addr)
                8'h02: begin
                    next_command_config = reg_data_in;
                    // Model automatic completion of the MAC software reset.
                    next_command_config[13] = 1'b0;
                    command_config <= next_command_config;
                end
                8'h80: begin
                    next_basic = reg_data_in[15:0];
                    // Model automatic completion of the PHY software reset.
                    next_basic[15] = 1'b0;
                    phy_basic <= next_basic;
                end
                8'h84: phy_advertisement <= reg_data_in[15:0];
                8'h94: phy_extended <= reg_data_in[15:0];
                8'h06, 8'h08, 8'h09, 8'h0a,
                8'h0b, 8'h0c, 8'h0d, 8'h0e:
                    forbidden_write_seen <= 1'b1;
                default: ;
            endcase
        end
    end

    initial begin : stimulus
        #(10 * CLK_PERIOD);
        @(posedge clk);
        reset <= 1'b0;

        fork : initialization_timeout
            begin
                wait (done);
            end
            begin
                #7ms;
            end
        join_any
        disable initialization_timeout;

        assert (done && !error)
            else $fatal(1, "initialization did not complete");
        assert (!forbidden_write_seen)
            else $fatal(1, "initializer wrote a flow-control/FIFO register");
        assert ((phy_advertisement & 16'h0c00) == 16'h0000)
            else $fatal(1, "PHY still advertises PAUSE capability");
        assert ((phy_extended & 16'h0082) == 16'h0082)
            else $fatal(1, "RGMII delay bits are not set");
        assert (command_config[1:0] == 2'b11)
            else $fatal(1, "MAC is not enabled");
        assert (command_config[8] && !command_config[7] &&
                !command_config[2] && !command_config[22] &&
                !command_config[23])
            else $fatal(1, "flow-control bits are not disabled");
        assert (command_config[3] && !command_config[25])
            else $fatal(1, "initial 1000 Mb/s mode is not configured");

        // Simulate a PHY interrupt and a new 100 Mb/s full-duplex link.
        phy_status <= 16'h6c00;
        phy_int_n <= 1'b0;
        #(20 * CLK_PERIOD);
        phy_int_n <= 1'b1;
        #25us;

        assert (!error)
            else $fatal(1, "media/speed change completed with an error");
        assert ((command_config[1:0] == 2'b11) &&
                !command_config[3] && !command_config[25])
            else $fatal(1, "100 Mb/s mode was not enabled after the PHY interrupt");
        assert (command_config[8] && !command_config[2] &&
                !command_config[22] && !command_config[23])
            else $fatal(1, "flow control was enabled after the speed change");

        $display("ethernet_mac_init_tb: PASS");
        $finish;
    end
endmodule

`resetall
