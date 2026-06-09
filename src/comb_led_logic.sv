// comb_led_logic.sv
//
// Small combinational logic examples for the EE2C2 FPGA lab.
// The outputs depend only on the current switch/button inputs.
// This infers gates, multiplexers, and simple decode logic.

`timescale 1ns/1ps

module comb_led_logic (
    input  logic [3:0] sw,
    input  logic       btn,
    output logic [7:0] led_comb,
    output logic [2:0] rgb_comb
);

    always_comb begin
        led_comb = 8'b0000_0000;

        led_comb[0] = sw[0];
        led_comb[1] = sw[0] & sw[1];
        led_comb[2] = sw[0] ^ sw[1];
        led_comb[3] = sw[2] ? sw[3] : sw[0];
        led_comb[4] = ~sw[0];
        led_comb[5] = btn;
        led_comb[6] = sw[2] | sw[3];
        led_comb[7] = &sw;

        // Simple RGB decode: {red, green, blue}.
        unique case (sw[1:0])
            2'b00: rgb_comb = 3'b000;
            2'b01: rgb_comb = 3'b100;
            2'b10: rgb_comb = 3'b010;
            2'b11: rgb_comb = 3'b001;
            default: rgb_comb = 3'b000;
        endcase
    end

endmodule
