//-----------------------------------------------------------------------------
// hsv_to_rgb.v — Combinational HSV-to-RGB converter (hue only)
//
// Converts an 8-bit hue value (0–255) to 8-bit R, G, B outputs.
// Saturation and Value are fixed at maximum (fully saturated, full brightness).
//
// The hue wheel is divided into 6 sectors of ~43 values each:
//   Sector 0 (hue   0– 42): Red=255,    Green=rising, Blue=0
//   Sector 1 (hue  43– 85): Red=falling, Green=255,   Blue=0
//   Sector 2 (hue  86–127): Red=0,       Green=255,   Blue=rising
//   Sector 3 (hue 128–170): Red=0,       Green=falling,Blue=255
//   Sector 4 (hue 171–213): Red=rising,  Green=0,      Blue=255
//   Sector 5 (hue 214–255): Red=255,     Green=0,      Blue=falling
//
// "Rising" means the channel ramps linearly from 0 to 255 across the sector.
// "Falling" means it ramps from 255 down to 0.
//
// The interpolation uses: value = (position_within_sector * 255) / sector_width
// which is approximated as: (position * 6) clamped to 255.
//
// Teaching points:
//   - Combinational logic: outputs depend only on current inputs, no clock needed
//   - case statements for multi-way decisions
//   - How colors are represented numerically (HSV vs RGB color models)
//   - Integer arithmetic in hardware (multiply + shift for division)
//-----------------------------------------------------------------------------

module hsv_to_rgb (
    input  wire [7:0] hue,
    output reg  [7:0] red,
    output reg  [7:0] green,
    output reg  [7:0] blue
);

    // Sector number (0–5) and position within sector
    wire [2:0] sector;
    wire [7:0] pos;       // position within current sector (0–42)
    wire [7:0] rising;    // ramp from 0 → ~255 across sector
    wire [7:0] falling;   // ramp from 255 → ~0 across sector

    // Each sector spans ~43 hue values (256/6 ≈ 42.67)
    // Divide hue by 43 to get sector. Use: sector = hue / 43
    // For synthesis-friendly division: hue * 6 / 256 = hue * 6 >> 8
    // This gives sector 0–5 (sector 5 covers the remainder)
    wire [10:0] hue_x6 = hue * 11'd6;
    assign sector = (hue_x6[10:8] > 3'd5) ? 3'd5 : hue_x6[10:8];

    // Position within sector: (hue - sector * 43), but we compute via modular arithmetic
    // pos = hue - sector * 43 (approximate; sector * 43 ≈ sector * 42.67)
    wire [7:0] sector_start;
    assign sector_start = (sector == 3'd0) ? 8'd0   :
                          (sector == 3'd1) ? 8'd43  :
                          (sector == 3'd2) ? 8'd86  :
                          (sector == 3'd3) ? 8'd128 :
                          (sector == 3'd4) ? 8'd171 :
                                             8'd214;

    assign pos = hue - sector_start;

    // Width of each sector for interpolation
    wire [7:0] sector_width;
    assign sector_width = (sector == 3'd5) ? 8'd42 : // 255 - 214 + 1 = 42
                          (sector == 3'd2) ? 8'd42 : // 127 - 86 + 1 = 42
                          (sector == 3'd3) ? 8'd43 : // 170 - 128 + 1 = 43
                                             8'd43;

    // Interpolation: rising = pos * 255 / sector_width
    // Approximation: pos * 6, clamped to 255
    wire [10:0] interp = pos * 11'd6;
    assign rising  = (interp > 11'd255) ? 8'd255 : interp[7:0];
    assign falling = 8'd255 - rising;

    // Map sector to RGB channels
    always @(*) begin
        case (sector)
            3'd0: begin red = 8'd255;  green = rising;  blue = 8'd0;    end
            3'd1: begin red = falling; green = 8'd255;  blue = 8'd0;    end
            3'd2: begin red = 8'd0;    green = 8'd255;  blue = rising;  end
            3'd3: begin red = 8'd0;    green = falling; blue = 8'd255;  end
            3'd4: begin red = rising;  green = 8'd0;    blue = 8'd255;  end
            3'd5: begin red = 8'd255;  green = 8'd0;    blue = falling; end
            default: begin red = 8'd0; green = 8'd0;    blue = 8'd0;    end
        endcase
    end

endmodule
