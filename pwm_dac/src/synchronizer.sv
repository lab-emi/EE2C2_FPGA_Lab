// synchronizer.sv
//
// Two-flip-flop synchronizer for external asynchronous inputs.
// This reduces the probability that metastability propagates into the
// main synchronous design. It does not debounce a mechanical button.

`timescale 1ns/1ps

module synchronizer #(
    parameter int WIDTH = 1
) (
    input  logic             clk,
    input  logic [WIDTH-1:0] async_in,
    output logic [WIDTH-1:0] sync_out
);

    logic [WIDTH-1:0] sync_stage_1;

    always_ff @(posedge clk) begin
        sync_stage_1 <= async_in;
        sync_out     <= sync_stage_1;
    end

endmodule
