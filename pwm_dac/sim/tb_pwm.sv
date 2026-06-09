// tb_pwm.sv
//
// Simple behavioral testbench for pwm.sv.
// This file is not synthesizable. The delays, $display, $error, and $finish
// statements are simulation-only constructs.

`timescale 1ns/1ps

module tb_pwm;

    localparam int N = 8;
    localparam int PERIOD_CYCLES = 1 << N;

    logic         clk;
    logic         rst;
    logic [N-1:0] duty;
    logic         pwm_out;
    int           test_count;
    int           error_count;

    pwm #(
        .N(N)
    ) dut (
        .clk    (clk),
        .rst    (rst),
        .duty   (duty),
        .pwm_out(pwm_out)
    );

    initial begin
        clk = 1'b0;
    end

    always #5 clk = ~clk;

    task automatic check_duty(input logic [N-1:0] test_duty);
        int high_count;
        int expected_count;
        begin
            test_count++;
            duty = test_duty;
            rst  = 1'b1;
            repeat (3) @(posedge clk);
            rst  = 1'b0;

            high_count = 0;
            repeat (PERIOD_CYCLES) begin
                @(posedge clk);
                #1;
                if (pwm_out) begin
                    high_count++;
                end
            end

            expected_count = int'(test_duty);
            $display("duty=%0d high_cycles=%0d expected=%0d",
                     expected_count, high_count, expected_count);

            if (high_count != expected_count) begin
                error_count++;
                $error("[FAIL] duty=%0d high_cycles=%0d expected=%0d",
                       expected_count, high_count, expected_count);
            end else begin
                $display("[PASS] duty=%0d high_cycles=%0d", expected_count, high_count);
            end
        end
    endtask

    initial begin
        test_count  = 0;
        error_count = 0;
        rst         = 1'b1;
        duty        = '0;

        check_duty(8'd0);
        check_duty(8'd1);
        check_duty(8'd64);
        check_duty(8'd128);
        check_duty(8'd192);
        check_duty(8'd240);
        check_duty(8'd255);

        if (error_count == 0) begin
            $display("PWM_STUDENT_TEST_PASS: all %0d duty-cycle checks passed.", test_count);
        end else begin
            $display("PWM_STUDENT_TEST_FAIL: %0d of %0d duty-cycle checks failed.",
                     error_count, test_count);
            $fatal(1, "PWM student implementation failed the required testbench.");
        end

        $finish;
    end

endmodule
