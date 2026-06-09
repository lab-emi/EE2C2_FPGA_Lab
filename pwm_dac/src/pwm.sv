// pwm.sv
//
// Parameterized PWM generator.
// The counter is sequential logic implemented with flip-flops.
// The comparison count < duty is combinational comparator logic.
// One complete PWM period lasts 2^N clock cycles.

`timescale 1ns/1ps

module pwm #(
    parameter int N = 8
) (
    input  logic         clk,
    input  logic         rst,
    input  logic [N-1:0] duty,
    output logic         pwm_out
);

    logic [N-1:0] count;

    always_ff @(posedge clk) begin
        if (rst) begin
            count <= '0;
        end else begin
            // TODO 1: update the PWM counter once per clock.
            // Hint: add one to count. Let the N-bit register wrap naturally.
            count <= // TODO 1
        end
    end

    // TODO 2: drive pwm_out high during the first "duty" counts of the period.
    // Hint: compare the current counter value against duty.
    assign pwm_out = // TODO 2

endmodule
