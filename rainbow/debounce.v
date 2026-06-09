//-----------------------------------------------------------------------------
// debounce.v — Button debouncer with rising-edge detection
//
// Mechanical pushbuttons "bounce" when pressed — the electrical contact
// opens and closes rapidly for a few milliseconds, producing a noisy signal.
// This module filters out that noise by sampling the button input at a slow
// rate (~10 ms intervals) and only updating the output after seeing the same
// value for several consecutive samples.
//
// How it works:
//   1. A prescaler counter counts clock cycles. Every SAMPLE_TICKS cycles
//      (about 10 ms at 100 MHz), we take a sample.
//   2. A 4-bit shift register stores the last 4 samples.
//   3. Only when all 4 samples agree (all 1s or all 0s) do we update btn_out.
//   4. btn_rise produces a single-cycle HIGH pulse on the 0→1 transition
//      of btn_out — this is what downstream logic uses to detect a button press.
//
// Parameters:
//   CLK_FREQ    — clock frequency in Hz (default: 100 MHz)
//   DEBOUNCE_MS — sampling interval in milliseconds (default: 10 ms)
//
// Teaching points:
//   - Metastability: async inputs must be synchronized to the clock domain
//   - Shift registers for history tracking
//   - Prescaler counters for creating slower time bases from a fast clock
//   - Edge detection using a delayed copy of the signal
//-----------------------------------------------------------------------------

module debounce #(
    parameter CLK_FREQ    = 100_000_000,
    parameter DEBOUNCE_MS = 10
) (
    input  wire clk,
    input  wire rst_n,
    input  wire btn_in,
    output reg  btn_out,
    output wire btn_rise
);

    // Number of clock ticks per sample interval
    localparam SAMPLE_TICKS = (CLK_FREQ / 1000) * DEBOUNCE_MS;
    // Bit width needed for the prescaler counter
    localparam CNT_WIDTH = $clog2(SAMPLE_TICKS);

    // Synchronizer: two flip-flops to cross from async input to clock domain
    reg sync_0, sync_1;
    always @(posedge clk) begin
        sync_0 <= btn_in;
        sync_1 <= sync_0;
    end

    // Prescaler counter: generates a tick every SAMPLE_TICKS clock cycles
    reg [CNT_WIDTH-1:0] prescaler = 0;
    wire sample_tick = (prescaler == SAMPLE_TICKS - 1);

    always @(posedge clk) begin
        if (!rst_n)
            prescaler <= 0;
        else if (sample_tick)
            prescaler <= 0;
        else
            prescaler <= prescaler + 1;
    end

    // 4-bit shift register: stores last 4 samples of the synchronized input
    reg [3:0] shift_reg = 4'b0000;

    always @(posedge clk) begin
        if (!rst_n)
            shift_reg <= 4'b0000;
        else if (sample_tick)
            shift_reg <= {shift_reg[2:0], sync_1};
    end

    // Update output only when all 4 samples agree
    always @(posedge clk) begin
        if (!rst_n)
            btn_out <= 1'b0;
        else if (shift_reg == 4'b1111)
            btn_out <= 1'b1;
        else if (shift_reg == 4'b0000)
            btn_out <= 1'b0;
        // else: keep previous value (still bouncing)
    end

    // Rising-edge detection: one-cycle pulse when btn_out goes 0 → 1
    reg btn_out_prev = 1'b0;
    always @(posedge clk) begin
        if (!rst_n)
            btn_out_prev <= 1'b0;
        else
            btn_out_prev <= btn_out;
    end

    assign btn_rise = btn_out & ~btn_out_prev;

endmodule
