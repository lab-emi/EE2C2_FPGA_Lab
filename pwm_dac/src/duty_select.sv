// duty_select.sv
//
// Combinational 4-bit to 8-bit duty-cycle selector.
// The 16 switch settings are mapped to 16 quantized PWM levels.
// The maximum switch value maps to 8'hF0, not 8'hFF, so the output
// never reaches a true 100% duty cycle in this basic version.

`timescale 1ns/1ps

module duty_select (
    input  logic [3:0] sw,
    output logic [7:0] duty
);

    always_comb begin
        duty = {sw, 4'b0000};
    end

endmodule
