// top_aup_zu3.sv
//
// Board-level top for the EE2C2 LED controller lab on the RealDigital
// AUP-ZU3-4GB. It reuses exactly the same lab RTL as the AC701 top
// (src/top.sv) --- one_hz_tick, comb_led_logic, and led_fsm --- but targets
// the AUP-ZU3's 100 MHz differential clock, eight switches, and eight
// single-colour LEDs.
//
//   sw[7]   : mode select, 0 = sequential FSM demo, 1 = combinational demo
//   sw[3:0] : combinational-logic inputs
//   led[7:0]: single-colour LED outputs

`timescale 1ns/1ps

module top_aup_zu3 (
    input  logic       clk_p,
    input  logic       clk_n,
    input  logic [7:0] sw,
    input  logic       rst_btn,
    output logic [7:0] led
);

    localparam int CLK_FREQ_HZ = 100_000_000;

    logic clk;

    IBUFDS u_clk_ibufds (
        .I  (clk_p),
        .IB (clk_n),
        .O  (clk)
    );

    // Synchronise the active-high reset button into the clock domain.
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
        .sw      (sw[3:0]),
        .btn     (rst_sync),
        .led_comb(led_comb)
    );

    logic [7:0] led_fsm_out;
    logic [2:0] state_dbg;

    led_fsm u_led_fsm (
        .clk      (clk),
        .rst      (rst_sync),
        .tick_1s  (tick_1s),
        .led_fsm  (led_fsm_out),
        .state_dbg(state_dbg)
    );

    // sw[7] selects which result is shown on the eight user LEDs:
    //   0 = FSM pattern, 1 = combinational logic.
    assign led = sw[7] ? led_comb : led_fsm_out;

endmodule
