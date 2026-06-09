// one_hz_tick.sv
//
// Sequential logic example: a counter that creates a one-clock-cycle
// clock-enable pulse. It does not generate a new clock.

`timescale 1ns/1ps

module one_hz_tick #(
    parameter int CLK_FREQ_HZ  = 100_000_000,
    parameter int COUNTER_WIDTH = (CLK_FREQ_HZ <= 1) ? 1 : $clog2(CLK_FREQ_HZ)
) (
    input  logic                     clk,
    input  logic                     rst,
    output logic                     tick_1s,
    output logic [COUNTER_WIDTH-1:0] count_value
);

    localparam logic [COUNTER_WIDTH-1:0] TERMINAL_COUNT_VALUE = CLK_FREQ_HZ - 1;

    always_ff @(posedge clk) begin
        if (rst) begin
            count_value <= '0;
            tick_1s     <= 1'b0;
        end else if (count_value == TERMINAL_COUNT_VALUE) begin
            count_value <= '0;
            tick_1s     <= 1'b1;
        end else begin
            count_value <= count_value + {{(COUNTER_WIDTH-1){1'b0}}, 1'b1};
            tick_1s     <= 1'b0;
        end
    end

endmodule
