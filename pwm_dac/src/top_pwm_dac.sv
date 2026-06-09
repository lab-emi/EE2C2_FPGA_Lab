// top_pwm_dac.sv
//
// EE2C2 FPGA Lab top level for the RealDigital AUP-ZU3-4GB board.
//
// Data path:
//   4 switches -> duty_select -> PWM comparator -> LED brightness
//
// The board clock is a 100 MHz differential LVDS clock. The IBUFDS primitive
// converts it to a single-ended clock for the synchronous RTL.

`timescale 1ns/1ps

module top_pwm_dac (
    input  logic       clk_p,
    input  logic       clk_n,
    input  logic       rst_btn,
    input  logic [3:0] sw,
    output logic [7:0] led
);

    logic clk;

    IBUFDS u_clk_ibufds (
        .I  (clk_p),
        .IB (clk_n),
        .O  (clk)
    );

    logic [0:0] rst_sync_vec;
    logic       rst_sync;
    logic [7:0] duty;
    logic       pwm_signal;

    synchronizer #(
        .WIDTH(1)
    ) u_rst_synchronizer (
        .clk     (clk),
        .async_in({rst_btn}),
        .sync_out(rst_sync_vec)
    );

    assign rst_sync = rst_sync_vec[0];

    duty_select u_duty_select (
        .sw  (sw),
        .duty(duty)
    );

    pwm #(
        .N(8)
    ) u_pwm (
        .clk    (clk),
        .rst    (rst_sync),
        .duty   (duty),
        .pwm_out(pwm_signal)
    );

    // LED0 shows the PWM brightness. LED4:LED1 mirror the switch value so
    // students can record the selected duty-cycle code from the board.
    // LED6:LED5 mirror two duty bits and LED7 shows the synchronized reset.
    assign led[0]   = pwm_signal;
    assign led[4:1] = sw;
    assign led[5]   = duty[5];
    assign led[6]   = duty[6];
    assign led[7]   = rst_sync;

endmodule
