// tb_led_fsm.sv
//
// Simulation-only testbench for the one-second tick and LED FSM.
// The tick generator uses a small CLK_FREQ_HZ value so the FSM advances
// every few simulated clock cycles instead of after a real second.

`timescale 1ns/1ps

module tb_led_fsm;

    localparam int SIM_CLK_FREQ_HZ = 8;

    logic clk = 1'b0;
    logic rst;
    logic tick_1s;
    logic [$clog2(SIM_CLK_FREQ_HZ)-1:0] count_value;
    logic [7:0] led_fsm_out;
    logic [3:0] rgb_r;
    logic [3:0] rgb_g;
    logic [3:0] rgb_b;
    logic [2:0] state_dbg;

    one_hz_tick #(
        .CLK_FREQ_HZ(SIM_CLK_FREQ_HZ)
    ) u_tick (
        .clk        (clk),
        .rst        (rst),
        .tick_1s    (tick_1s),
        .count_value(count_value)
    );

    led_fsm u_fsm (
        .clk      (clk),
        .rst      (rst),
        .tick_1s  (tick_1s),
        .led_fsm  (led_fsm_out),
        .rgb_r    (rgb_r),
        .rgb_g    (rgb_g),
        .rgb_b    (rgb_b),
        .state_dbg(state_dbg)
    );

    initial begin
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1'b1;
        repeat (3) @(posedge clk);
        rst = 1'b0;

        repeat (80) begin
            @(posedge clk);
            if (tick_1s) begin
                #1;
                $display("time=%0t state=%0d led=%b rgb_r=%b rgb_g=%b rgb_b=%b",
                         $time, state_dbg, led_fsm_out, rgb_r, rgb_g, rgb_b);
            end
        end

        $display("tb_led_fsm completed.");
        $finish;
    end

    initial begin
        #950;
        $fatal(1, "tb_led_fsm timeout: expected the FSM simulation to finish earlier.");
    end

endmodule
