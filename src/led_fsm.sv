// led_fsm.sv
//
// Simple finite state machine for visible LED patterns.
// The state register is sequential logic. Next-state and output decode
// are combinational logic.

`timescale 1ns/1ps

module led_fsm (
    input  logic       clk,
    input  logic       rst,
    input  logic       tick_1s,
    output logic [7:0] led_fsm,
    output logic [3:0] rgb_r,
    output logic [3:0] rgb_g,
    output logic [3:0] rgb_b,
    output logic [2:0] state_dbg
);

    typedef enum logic [2:0] {
        IDLE,
        MONO_LED_0,
        MONO_LED_1,
        MONO_LED_2,
        RGB_RED,
        RGB_GREEN,
        RGB_BLUE,
        ALL_OFF
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;

        if (tick_1s) begin
            unique case (state)
                IDLE:       next_state = MONO_LED_0;
                MONO_LED_0: next_state = MONO_LED_1;
                MONO_LED_1: next_state = MONO_LED_2;
                MONO_LED_2: next_state = RGB_RED;
                RGB_RED:    next_state = RGB_GREEN;
                RGB_GREEN:  next_state = RGB_BLUE;
                RGB_BLUE:   next_state = ALL_OFF;
                ALL_OFF:    next_state = IDLE;
                default:    next_state = IDLE;
            endcase
        end
    end

    always_comb begin
        led_fsm = 8'b0000_0000;
        rgb_r   = 4'b0000;
        rgb_g   = 4'b0000;
        rgb_b   = 4'b0000;

        unique case (state)
            IDLE: begin
                led_fsm = 8'b0000_0001;
            end

            MONO_LED_0: begin
                led_fsm = 8'b0000_0010;
            end

            MONO_LED_1: begin
                led_fsm = 8'b0000_0100;
            end

            MONO_LED_2: begin
                led_fsm = 8'b0000_1000;
            end

            RGB_RED: begin
                rgb_r = 4'b1111;
            end

            RGB_GREEN: begin
                rgb_g = 4'b1111;
            end

            RGB_BLUE: begin
                rgb_b = 4'b1111;
            end

            ALL_OFF: begin
                led_fsm = 8'b0000_0000;
            end

            default: begin
                led_fsm = 8'b0000_0001;
            end
        endcase
    end

    assign state_dbg = state;

endmodule
