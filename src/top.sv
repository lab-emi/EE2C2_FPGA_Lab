// top.sv
//
// AC701 wrapper used for synthesis, implementation, timing, and power reports
// on university PCs. It reuses the lab RTL but exposes only the AC701's
// built-in 4 DIP switches, reset button, 200 MHz differential clock, and
// 4 single-colour LEDs.

`timescale 1ns/1ps

module top (
    input  logic       clk_p,
    input  logic       clk_n,
    input  logic [3:0] sw,
    input  logic       rst_btn,
    output logic [3:0] led
);

    localparam int CLK_FREQ_HZ = 200_000_000;

    logic clk;

    IBUFDS u_clk_ibufds (
        .I  (clk_p),
        .IB (clk_n),
        .O  (clk)
    );

    logic rst_meta;
    logic rst_sync;

    always_ff @(posedge clk) begin
        rst_meta <= rst_btn;
        rst_sync <= rst_meta;
    end

    logic tick_1s;
    logic [$clog2(CLK_FREQ_HZ)-1:0] tick_count;

    one_hz_tick #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ)
    ) u_tick (
        .clk        (clk),
        .rst        (rst_sync),
        .tick_1s    (tick_1s),
        .count_value(tick_count)
    );

    logic [7:0] led_comb;

    comb_led_logic u_comb_led_logic (
        .sw      (sw),
        .btn     (rst_sync),
        .led_comb(led_comb)
    );

    logic [7:0] led_fsm;
    logic [2:0] state_dbg;

    led_fsm u_led_fsm (
        .clk      (clk),
        .rst      (rst_sync),
        .tick_1s  (tick_1s),
        .led_fsm  (led_fsm),
        .state_dbg(state_dbg)
    );

    // AC701 has four user LEDs. DIP switch 3 selects which lab mode is visible:
    //   0 = FSM lower four LEDs, 1 = combinational lower four LEDs.
    assign led = sw[3] ? led_comb[3:0] : led_fsm[3:0];

endmodule
