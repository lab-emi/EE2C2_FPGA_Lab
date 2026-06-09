// top.sv
//
// Board-level top for the EE2C2 LED controller lab.
// sw[7] selects the visible mode:
//   0 = sequential FSM demo
//   1 = combinational logic demo

`timescale 1ns/1ps

module top (
    input  logic       clk_p,
    input  logic       clk_n,
    input  logic [7:0] sw,
    input  logic       rst_btn,
    output logic [7:0] led,
    output logic       rgb0_r, rgb0_g, rgb0_b,
    output logic       rgb1_r, rgb1_g, rgb1_b,
    output logic       rgb2_r, rgb2_g, rgb2_b,
    output logic       rgb3_r, rgb3_g, rgb3_b
);

    localparam int CLK_FREQ_HZ = 100_000_000;

    logic clk;

    IBUFDS u_clk_ibufds (
        .I  (clk_p),
        .IB (clk_n),
        .O  (clk)
    );

    // Synchronize the active-high reset button into the FPGA clock domain.
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
    logic [2:0] rgb_comb;

    comb_led_logic u_comb_led_logic (
        .sw      (sw[3:0]),
        .btn     (rst_sync),
        .led_comb(led_comb),
        .rgb_comb(rgb_comb)
    );

    logic [7:0] led_fsm;
    logic [3:0] fsm_r;
    logic [3:0] fsm_g;
    logic [3:0] fsm_b;
    logic [2:0] state_dbg;

    led_fsm u_led_fsm (
        .clk      (clk),
        .rst      (rst_sync),
        .tick_1s  (tick_1s),
        .led_fsm  (led_fsm),
        .rgb_r    (fsm_r),
        .rgb_g    (fsm_g),
        .rgb_b    (fsm_b),
        .state_dbg(state_dbg)
    );

    logic comb_mode;
    assign comb_mode = sw[7];

    always_comb begin
        if (comb_mode) begin
            led    = led_comb;
            // Mirror spare switches so every constrained switch has a visible load.
            led[6:4] = sw[6:4];
            rgb0_r = rgb_comb[2];
            rgb0_g = rgb_comb[1];
            rgb0_b = rgb_comb[0];
            rgb1_r = 1'b0;
            rgb1_g = 1'b0;
            rgb1_b = 1'b0;
            rgb2_r = 1'b0;
            rgb2_g = 1'b0;
            rgb2_b = 1'b0;
            rgb3_r = 1'b0;
            rgb3_g = 1'b0;
            rgb3_b = 1'b0;
        end else begin
            led    = led_fsm;
            rgb0_r = fsm_r[0];
            rgb0_g = fsm_g[0];
            rgb0_b = fsm_b[0];
            rgb1_r = fsm_r[1];
            rgb1_g = fsm_g[1];
            rgb1_b = fsm_b[1];
            rgb2_r = fsm_r[2];
            rgb2_g = fsm_g[2];
            rgb2_b = fsm_b[2];
            rgb3_r = fsm_r[3];
            rgb3_g = fsm_g[3];
            rgb3_b = fsm_b[3];
        end
    end

endmodule
