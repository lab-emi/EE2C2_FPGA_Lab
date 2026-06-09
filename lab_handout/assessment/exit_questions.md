# Exit Questions with Expected Answers

1. What is the difference between combinational and sequential logic?

Expected answer: Combinational outputs depend only on current inputs. Sequential logic stores state in flip-flops or registers, so it can depend on previous values.

2. Which module in this lab mainly demonstrates combinational logic?

Expected answer: `comb_led_logic.sv`.

3. Which module in this lab mainly demonstrates sequential logic?

Expected answer: `one_hz_tick.sv` demonstrates the counter. `led_fsm.sv` also demonstrates sequential logic through the state register.

4. What hardware structure is inferred by `always_ff @(posedge clk)`?

Expected answer: Edge-triggered flip-flops or registers.

5. Why should we generate `tick_1s` as a clock-enable pulse instead of creating a new slow clock?

Expected answer: A clock enable keeps the design in one clock domain. Fabric-generated clocks can create routing, clock-domain, and timing-analysis problems.

6. In the FSM waveform, suppose one `tick_1s` pulse changes the state from `MONO_LED_2` to `RGB_RED`. Which FSM block stores that new state, which block chose it, and which block drives the RGB output afterward?

Expected answer: The state register (`always_ff`) stores `RGB_RED` on the clock edge. The next-state combinational logic chose `RGB_RED` because the current state was `MONO_LED_2` and `tick_1s` was high. The output-decode combinational logic then drives the RGB red output for the current state.

7. Why does the simulation use a smaller clock-frequency parameter than the FPGA build?

Expected answer: It makes ticks and state transitions visible quickly without simulating millions of clock cycles.

8. What does positive WNS mean?

Expected answer: The worst setup path has timing margin and setup timing is met if WNS is zero or positive.

9. Why does this lab use AC701 for implementation reports but prebuilt bitstreams for AUP-ZU3 demos?

Expected answer: The university PCs have AC701 / Artix-7 support installed by default, but may not include XCZU3EG implementation support. AC701 is therefore used for synthesis, implementation, timing, and power reports, while the connected AUP-ZU3 can still be shown by programming already-built bitstreams. An AC701 bitstream must not be programmed onto an AUP-ZU3 because it targets a different FPGA family and pinout.

10. What is a critical path?

Expected answer: The path with the smallest slack; it is closest to violating timing.

11. What are static and dynamic power?

Expected answer: Static power is consumed even when the device is not switching. Dynamic power is consumed due to switching activity in clocks, logic, routing, and IO.

12. What assumptions affect Vivado's power report, and does it perfectly measure board power?

Expected answer: It depends on configuration, clocks, constraints, voltage/temperature assumptions, and switching activity. No, it is not a physical board-power measurement and may not include external loads such as LED current accurately.

13. For a 100 MHz clock and an 8-bit PWM counter, what is the PWM frequency?

Expected answer: `100 MHz / 2^8 = 100,000,000 / 256 = 390,625 Hz`, or about 390.625 kHz.

14. Why does changing PWM duty cycle change apparent LED brightness?

Expected answer: The LED switches faster than the eye can follow, so the eye perceives the time average. A larger duty cycle means more on-time per period and therefore a brighter LED.

15. In the PWM assignment, which TODO line describes sequential logic and which describes combinational logic?

Expected answer: The counter update inside `always_ff @(posedge clk)` is sequential logic. The `assign pwm_out = (count < duty);` line is combinational comparator logic.

16. Why does `sw[3:0] = 1111` not produce a true 100% duty cycle in this selector?

Expected answer: The selector maps `sw[3:0]` to `{sw, 4'b0000}`. For `1111`, the duty is `8'hF0 = 240`, so the duty cycle is `240/256 = 93.75%`, not 100%.
