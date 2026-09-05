// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

`resetall
`timescale 1ns / 1ps
`default_nettype none

module ethernet_reset (
    input  wire logic clk,
    input  wire logic rst_n,
    input  wire logic pll_locked,
    output wire logic system_reset
);
    // PHY RESET_N must remain asserted for at least 10 ms. Counting 2,621,440
    // periods of the 125 MHz system clock keeps reset active for about 20.97 ms.
    localparam logic [21:0] RESET_COUNTER_MAX = 22'd2621439;

    logic [21:0] reset_counter = '0;
    logic system_reset_value = 1'b1;

    assign system_reset = system_reset_value;

    // RST_N is connected to active-low push button KEY(0). The power-up
    // sequence begins only after the button is released and the PLL is stable.
    always_ff @(posedge clk) begin
        if (!rst_n || !pll_locked) begin
            reset_counter <= '0;
            system_reset_value <= 1'b1;
        end else if (reset_counter != RESET_COUNTER_MAX) begin
            reset_counter <= reset_counter + 1'b1;
            system_reset_value <= 1'b1;
        end else begin
            system_reset_value <= 1'b0;
        end
    end
endmodule

`resetall
