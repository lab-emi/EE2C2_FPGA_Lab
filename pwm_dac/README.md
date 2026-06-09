# Topic 8: PWM DAC / LED Brightness Controller

This folder contains the required PWM assignment for Topic 8 of the FPGA lab. Students complete the core PWM mechanism in `src/pwm.sv` and prove it with the testbench. The AUP-ZU3 board brightness demo is provided as a prebuilt bitstream because the university PCs may not include XCZU3EG implementation support.

## Files

```text
src/top_pwm_dac.sv
src/duty_select.sv
src/pwm.sv                  # student template with two TODO lines
src/synchronizer.sv
sim/tb_pwm.sv               # required pass/fail testbench
constr/aup_zu3_4gb_pwm.xdc  # retained for staff/prebuilt AUP-ZU3 builds
scripts/run_pwm_simulation.tcl
scripts/program_prebuilt_pwm_jtag.tcl
```

Instructor-only solution files are ignored by Git and should not be distributed to students.

## Required Student Flow

Open `src/pwm.sv` and fill in the two TODO lines:

1. Increment the N-bit PWM counter once per clock when reset is not asserted.
2. Drive `pwm_out` high when the counter is below the selected duty value.

Then run the student simulation from the repository root:

```powershell
vivado -mode batch -source pwm_dac\scripts\run_pwm_simulation.tcl
```

A correct implementation prints:

```text
PWM_STUDENT_TEST_PASS: all 7 duty-cycle checks passed.
```

Students should show that pass line to the responsible TA before answering the Topic 8 worksheet.

## Optional AUP-ZU3 Board Demo

After the AUP-ZU3 connection preflight in the main handout, program the prebuilt brightness demo:

```powershell
vivado -mode batch -source pwm_dac\scripts\program_prebuilt_pwm_jtag.tcl
```

This demo shows the expected hardware behavior, but it does not prove the student TODO lines are correct. The required proof is `PWM_STUDENT_TEST_PASS`.

## Board Behavior

- `sw[3:0]` selects one of 16 quantized duty-cycle values.
- `rst_btn` resets the PWM counter.
- `led[0]` shows PWM brightness.
- `led[4:1]` mirrors `sw[3:0]`.

The PWM frequency is:

```text
100 MHz / 2^8 = 390.625 kHz
```
