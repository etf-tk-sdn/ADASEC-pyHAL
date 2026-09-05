// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

`resetall
`timescale 1ns / 1ps
`default_nettype none

module ethernet_diag (
    input  wire logic       clk,
    input  wire logic       rst,
    input  wire logic [5:0] mac0_rx_error,
    input  wire logic       mac0_rx_ready,
    input  wire logic       mac0_rx_valid,
    input  wire logic [5:0] mac1_rx_error,
    input  wire logic       mac1_rx_ready,
    input  wire logic       mac1_rx_valid,
    input  wire logic       mac0_tx_underflow,
    input  wire logic       mac1_tx_underflow,
    output wire logic       mac0_rx_activity,
    output wire logic       mac1_rx_activity,
    output wire logic       stream_error_seen
);
    logic mac0_rx_activity_reg = 1'b0;
    logic mac1_rx_activity_reg = 1'b0;
    logic stream_error_seen_reg = 1'b0;
    logic [5:0] mac0_error_sample = '0;
    logic [5:0] mac1_error_sample = '0;
    logic mac0_transfer_sample = 1'b0;
    logic mac1_transfer_sample = 1'b0;

    assign mac0_rx_activity = mac0_rx_activity_reg;
    assign mac1_rx_activity = mac1_rx_activity_reg;
    assign stream_error_seen = stream_error_seen_reg;

    // Sticky flags make even brief traffic or errors visible without SignalTap.
    always_ff @(posedge clk) begin
        if (rst) begin
            mac0_rx_activity_reg <= 1'b0;
            mac1_rx_activity_reg <= 1'b0;
            stream_error_seen_reg <= 1'b0;
            mac0_error_sample <= '0;
            mac1_error_sample <= '0;
            mac0_transfer_sample <= 1'b0;
            mac1_transfer_sample <= 1'b0;
        end else begin
            mac0_error_sample <= mac0_rx_error;
            mac1_error_sample <= mac1_rx_error;
            mac0_transfer_sample <= mac0_rx_valid && mac0_rx_ready;
            mac1_transfer_sample <= mac1_rx_valid && mac1_rx_ready;

            if (mac0_rx_valid && mac0_rx_ready)
                mac0_rx_activity_reg <= 1'b1;
            if (mac1_rx_valid && mac1_rx_ready)
                mac1_rx_activity_reg <= 1'b1;

            if ((mac0_transfer_sample && (mac0_error_sample != 6'b0)) ||
                (mac1_transfer_sample && (mac1_error_sample != 6'b0)) ||
                mac0_tx_underflow || mac1_tx_underflow)
                stream_error_seen_reg <= 1'b1;
        end
    end
endmodule

`resetall
