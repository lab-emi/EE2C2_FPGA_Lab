//-----------------------------------------------------------------------------
// rgb_pwm.v — 3-channel 8-bit PWM generator for one RGB LED
//
// A free-running 8-bit counter increments every clock cycle. Each output
// goes HIGH when the counter value is less than the corresponding duty-cycle
// input. This produces a PWM signal whose duty cycle is duty/256.
//
// At 100 MHz clock: PWM frequency = 100 MHz / 256 ≈ 390 kHz (no visible flicker).
//
// Teaching points:
//   - PWM (Pulse Width Modulation) creates perceived analog brightness from
//     a digital on/off signal by switching faster than the eye can see.
//   - A higher duty value means the LED is ON for a larger fraction of each
//     cycle, so it appears brighter.
//   - duty = 0 → always OFF, duty = 255 → ON for 255/256 of the time.
//-----------------------------------------------------------------------------

module rgb_pwm (
    input  wire       clk,
    input  wire [7:0] red_duty,
    input  wire [7:0] green_duty,
    input  wire [7:0] blue_duty,
    output wire       red_out,
    output wire       green_out,
    output wire       blue_out
);

    // Free-running 8-bit counter — wraps naturally from 255 → 0
    reg [7:0] counter = 8'd0;

    always @(posedge clk) begin
        counter <= counter + 8'd1;
    end

    // Compare counter against duty cycle for each channel
    assign red_out   = (counter < red_duty);
    assign green_out = (counter < green_duty);
    assign blue_out  = (counter < blue_duty);

endmodule
