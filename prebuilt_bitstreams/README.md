# Prebuilt AUP-ZU3 Bitstreams

These bitstreams are for the RealDigital AUP-ZU3-4GB board only. They are included so the physical board demos can still be shown on university PCs whose Vivado installation has AC701 / Artix-7 support but does not include XCZU3EG implementation support.

The required synthesis, implementation, timing, and power-report work in this lab targets the AC701 board. The AUP-ZU3 bitstreams here are programming-only demo files; they are not part of the graded Vivado implementation flow.

| File | Demo | Expected behavior |
| --- | --- | --- |
| `aup_zu3_led_demo.bit` | Topic 6 LED demo (FSM + combinational) | The same `one_hz_tick`, `comb_led_logic`, and `led_fsm` RTL from Topics 1–2, built for the AUP-ZU3 by `src/top_aup_zu3.sv`. `sw[7]=0`: the lower LEDs step through the FSM pattern one state per second (`rst_btn` returns to `IDLE`). `sw[7]=1`: `led[7:0]` show the combinational functions of `sw[3:0]` live. |
| `aup_zu3_pwm_led_demo.bit` | Topic 7 PWM LED brightness | `sw[3:0]` selects duty cycle, `led[0]` changes brightness, `led[4:1]` mirrors the switch code, and `rst_btn` resets the PWM counter. |
| `aup_zu3_rainbow_demo.bit` | Topic 8 rainbow demo | RGB LEDs cycle through colors; switches mirror to LEDs and pushbuttons control the demo behavior as described in the handout. |

Program them from the repository root:

```powershell
vivado -mode batch -source scripts\program_prebuilt_led_jtag.tcl
vivado -mode batch -source pwm_dac\scripts\program_prebuilt_pwm_jtag.tcl
vivado -mode batch -source rainbow\scripts\program_prebuilt_rainbow_jtag.tcl
```

The `aup_zu3_led_demo.bit` file is rebuilt by staff with `build_aup_zu3.tcl` (set `EE2C2_ALLOW_AUP_ZU3_BUILD=1`).
