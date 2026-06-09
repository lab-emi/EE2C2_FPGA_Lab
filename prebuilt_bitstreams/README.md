# Prebuilt AUP-ZU3 Bitstreams

These bitstreams are for the RealDigital AUP-ZU3-4GB board only. They are included so the physical board demos can still be shown on university PCs whose Vivado installation has AC701 / Artix-7 support but does not include XCZU3EG implementation support.

The required synthesis, implementation, timing, and power-report work in this lab targets the AC701 board. The AUP-ZU3 bitstreams here are programming-only demo files; they are not part of the graded Vivado implementation flow.

| File | Demo | Expected behavior |
| --- | --- | --- |
| `aup_zu3_pwm_led_demo.bit` | Topic 8 PWM LED brightness | `sw[3:0]` selects duty cycle, `led[0]` changes brightness, `led[4:1]` mirrors the switch code, and `rst_btn` resets the PWM counter. |
| `aup_zu3_rainbow_demo.bit` | Topic 9 rainbow demo | RGB LEDs cycle through colors; switches mirror to LEDs and pushbuttons control the demo behavior as described in the handout. |

Program them from the repository root:

```powershell
vivado -mode batch -source pwm_dac\scripts\program_prebuilt_pwm_jtag.tcl
vivado -mode batch -source rainbow\scripts\program_prebuilt_rainbow_jtag.tcl
```
