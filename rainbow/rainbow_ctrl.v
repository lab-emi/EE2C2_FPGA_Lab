//-----------------------------------------------------------------------------
// rainbow_ctrl.v — Hue generator with interactive controls
//
// Generates NUM_LEDS hue values that cycle through the color spectrum.
// A base_hue register is incremented (or decremented) at a rate controlled
// by a prescaler. Each LED's hue is offset from base_hue by a configurable
// phase amount, creating a flowing rainbow effect.
//
// Button controls (active-high single-cycle pulses from debouncer):
//   speed_up     — decrease prescaler divisor → faster color cycling
//   speed_down   — increase prescaler divisor → slower color cycling
//   reverse      — toggle direction (increment ↔ decrement)
//   phase_change — cycle through phase offset presets
//
// Parameters:
//   NUM_LEDS — number of hue outputs (default: 4)
//
// Speed table (prescaler thresholds at 100 MHz):
//   Index 0: 2^19 =    524,288 → ~5.2 ms/step  → full rainbow in ~1.3 s
//   Index 1: 2^20 =  1,048,576 → ~10.5 ms/step → full rainbow in ~2.7 s
//   Index 2: 2^21 =  2,097,152 → ~21 ms/step   → full rainbow in ~5.4 s
//   Index 3: 2^22 =  4,194,304 → ~42 ms/step   → full rainbow in ~10.7 s
//   Index 4: 2^23 =  8,388,608 → ~84 ms/step   → full rainbow in ~21.5 s (default)
//   Index 5: 2^24 = 16,777,216 → ~168 ms/step  → full rainbow in ~42.9 s
//   Index 6: 2^25 = 33,554,432 → ~336 ms/step  → full rainbow in ~85.9 s
//   Index 7: 2^26 = 67,108,864 → ~671 ms/step  → full rainbow in ~171.8 s
//
// Phase offset presets:
//   Index 0: offset =   0 → all LEDs show same color
//   Index 1: offset =  32 → slight spread (~45° on hue wheel)
//   Index 2: offset =  64 → quarter spread (~90°, default)
//   Index 3: offset =  85 → third spread (~120°, triadic)
//   Index 4: offset = 128 → half spread (~180°, complementary)
//
// Teaching points:
//   - Prescaler counters for variable-rate timing
//   - Lookup tables implemented with case statements
//   - Button-driven state changes (toggle, cycle, clamp)
//   - Parameterized output generation using generate/loop
//-----------------------------------------------------------------------------

module rainbow_ctrl #(
    parameter NUM_LEDS = 4
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       speed_up,
    input  wire       speed_down,
    input  wire       reverse,
    input  wire       phase_change,
    output wire [8*NUM_LEDS-1:0] hue_out  // packed: hue_out[7:0] = LED0, [15:8] = LED1, etc.
);

    // ---- Speed control ----
    reg [2:0] speed_idx = 3'd4;  // default: index 4

    always @(posedge clk) begin
        if (!rst_n)
            speed_idx <= 3'd4;
        else if (speed_up && speed_idx > 3'd0)
            speed_idx <= speed_idx - 3'd1;
        else if (speed_down && speed_idx < 3'd7)
            speed_idx <= speed_idx + 3'd1;
    end

    // Prescaler threshold lookup
    reg [26:0] prescale_max;
    always @(*) begin
        case (speed_idx)
            3'd0: prescale_max = 27'd524287;     // 2^19 - 1
            3'd1: prescale_max = 27'd1048575;    // 2^20 - 1
            3'd2: prescale_max = 27'd2097151;    // 2^21 - 1
            3'd3: prescale_max = 27'd4194303;    // 2^22 - 1
            3'd4: prescale_max = 27'd8388607;    // 2^23 - 1
            3'd5: prescale_max = 27'd16777215;   // 2^24 - 1
            3'd6: prescale_max = 27'd33554431;   // 2^25 - 1
            3'd7: prescale_max = 27'd67108863;   // 2^26 - 1
            default: prescale_max = 27'd8388607;
        endcase
    end

    // ---- Prescaler counter ----
    reg [26:0] prescaler = 27'd0;
    wire hue_tick = (prescaler >= prescale_max);

    always @(posedge clk) begin
        if (!rst_n)
            prescaler <= 27'd0;
        else if (hue_tick)
            prescaler <= 27'd0;
        else
            prescaler <= prescaler + 27'd1;
    end

    // ---- Direction control ----
    reg direction = 1'b0;  // 0 = forward (increment), 1 = reverse (decrement)

    always @(posedge clk) begin
        if (!rst_n)
            direction <= 1'b0;
        else if (reverse)
            direction <= ~direction;
    end

    // ---- Base hue counter ----
    reg [7:0] base_hue = 8'd0;

    always @(posedge clk) begin
        if (!rst_n)
            base_hue <= 8'd0;
        else if (hue_tick) begin
            if (direction)
                base_hue <= base_hue - 8'd1;
            else
                base_hue <= base_hue + 8'd1;
        end
    end

    // ---- Phase offset control ----
    reg [2:0] phase_idx = 3'd2;  // default: index 2 (offset=64)

    always @(posedge clk) begin
        if (!rst_n)
            phase_idx <= 3'd2;
        else if (phase_change) begin
            if (phase_idx == 3'd7)
                phase_idx <= 3'd0;
            else
                phase_idx <= phase_idx + 3'd1;
        end
    end

    // Phase offset lookup
    reg [7:0] phase_offset;
    always @(*) begin
        case (phase_idx)
            3'd0: phase_offset = 8'd0;     // all LEDs same color
            3'd1: phase_offset = 8'd32;    // ~45° spread
            3'd2: phase_offset = 8'd64;    // ~90° spread (default)
            3'd3: phase_offset = 8'd85;    // ~120° triadic
            3'd4: phase_offset = 8'd128;   // ~180° complementary
            3'd5: phase_offset = 8'd160;   // ~225° spread
            3'd6: phase_offset = 8'd192;   // ~270° spread
            3'd7: phase_offset = 8'd224;   // ~315° spread
            default: phase_offset = 8'd64;
        endcase
    end

    // ---- Generate hue outputs ----
    // Each LED gets: base_hue + i * phase_offset
    // 8-bit addition naturally wraps around (mod 256), which maps to the circular hue wheel.
    genvar i;
    generate
        for (i = 0; i < NUM_LEDS; i = i + 1) begin : hue_gen
            assign hue_out[8*i +: 8] = base_hue + (i * phase_offset);
        end
    endgenerate

endmodule
