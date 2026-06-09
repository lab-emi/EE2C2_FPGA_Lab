// tb_comb_led_logic.sv
//
// Simulation-only testbench for the combinational logic module.
// # delays and initial blocks are allowed here because this is not hardware.

`timescale 1ns/1ps

module tb_comb_led_logic;

    logic [3:0] sw;
    logic       btn;
    logic [7:0] led_comb;
    logic [2:0] rgb_comb;

    comb_led_logic dut (
        .sw      (sw),
        .btn     (btn),
        .led_comb(led_comb),
        .rgb_comb(rgb_comb)
    );

    task automatic apply_and_print(input logic [3:0] sw_value, input logic btn_value);
        begin
            sw  = sw_value;
            btn = btn_value;
            #10;
            $display("sw=%b btn=%b led_comb=%b rgb_comb=%b",
                     sw, btn, led_comb, rgb_comb);
        end
    endtask

    initial begin
        apply_and_print(4'b0000, 1'b0);
        apply_and_print(4'b0001, 1'b0);
        apply_and_print(4'b0011, 1'b0);
        apply_and_print(4'b1010, 1'b1);
        apply_and_print(4'b1111, 1'b0);

        if (led_comb[7] !== 1'b1) begin
            $fatal(1, "Expected led_comb[7] to be high when all switch bits are high.");
        end

        $display("tb_comb_led_logic completed.");
        $finish;
    end

endmodule
