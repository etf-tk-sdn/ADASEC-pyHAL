// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

module ethernet_diag (
    input  logic       clk,
    input  logic       rst,
    input  logic [5:0] mac0_rx_error,
    input  logic       mac0_rx_ready,
    input  logic       mac0_rx_valid,
    input  logic [5:0] mac1_rx_error,
    input  logic       mac1_rx_ready,
    input  logic       mac1_rx_valid,
    input  logic       mac0_tx_underflow,
    input  logic       mac1_tx_underflow,
    output logic       mac0_rx_activity = 1'b0,
    output logic       mac1_rx_activity = 1'b0,
    output logic       stream_error_seen = 1'b0
);
    logic [5:0] mac0_error_sample = '0;
    logic [5:0] mac1_error_sample = '0;
    logic mac0_transfer_sample = 1'b0;
    logic mac1_transfer_sample = 1'b0;

    // Sticky flags make even brief traffic or errors visible without SignalTap.
    always_ff @(posedge clk) begin
        if (rst) begin
            mac0_rx_activity <= 1'b0;
            mac1_rx_activity <= 1'b0;
            stream_error_seen <= 1'b0;
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
                mac0_rx_activity <= 1'b1;
            if (mac1_rx_valid && mac1_rx_ready)
                mac1_rx_activity <= 1'b1;

            if ((mac0_transfer_sample && (mac0_error_sample != 6'b0)) ||
                (mac1_transfer_sample && (mac1_error_sample != 6'b0)) ||
                mac0_tx_underflow || mac1_tx_underflow)
                stream_error_seen <= 1'b1;
        end
    end
endmodule
