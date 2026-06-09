# EE2C2_FPGA_Lab: LED Controller FSM in Vivado

**Repository:** <https://github.com/lab-emi/EE2C2_FPGA_Lab>

This repository contains a self-contained FPGA lab for the TU Delft EE2C2 digital module. The active lab is a Vivado tutorial on combinational logic, sequential logic, a simple finite state machine, simulation, synthesis, implementation, timing reports, schematic inspection, power reports, a required PWM LED-dimming assignment under `pwm_dac/`, and an optional just-for-fun rainbow RTL demo under `rainbow/`.

## Hardware Targets

The lab intentionally uses two targets:

- Required Vivado build/report flow: Xilinx AC701 / Artix-7.
  - Board part: `xilinx.com:ac701:part0:1.4`
  - FPGA part: `xc7a200tfbg676-2`
  - Differential system clock: 200 MHz on `SYSCLK_P/SYSCLK_N`
- Physical show-and-tell demos: RealDigital AUP-ZU3-4GB.
  - Board part: `realdigital.org:aup-zu3-4gb:part0:1.0`
  - FPGA part used to generate the prebuilt files: `xczu3eg-sfvc784-2-e`
  - Prebuilt bitstreams: `prebuilt_bitstreams/aup_zu3_pwm_led_demo.bit` and `prebuilt_bitstreams/aup_zu3_rainbow_demo.bit`

The university PCs have AC701 / Artix-7 support installed by default. Some do not include XCZU3EG implementation support, so the required synthesis, implementation, timing, and power work targets AC701. The AUP-ZU3 board demos are programmed from prebuilt bitstreams and do not require Vivado to create an XCZU3EG project.

## AUP-ZU3 Demo Connection Preflight

For the optional AUP-ZU3 prebuilt demos:

1. With the board powered off, set the **BOOT** mode switch near the microSD slot to **USB-JTAG/JTAG**, not SD.
2. Plug a USB-C **PD power adapter** into **EXT PWR** and confirm the board power LED turns on. The **PROG UART** cable does not power the board.
3. Plug a data-capable USB-C cable from the PC directly into **PROG UART**. Avoid charge-only cables and USB hubs when debugging JTAG.
4. In Vivado Hardware Manager, `get_hw_devices` should show the FPGA as `xczu3` or `xczu3eg`, and may also show `arm_dap`. Program the `xczu3` / `xczu3eg` FPGA device, not `arm_dap`.

## Lab Handout and Worksheet

The student materials under `lab_handout/` are organized into topics. Each topic starts with a short **Background** and is followed by a hands-on, step-by-step **Lab**. Every action is given in up to three interchangeable forms: a Vivado **GUI** click-path, a **Windows PowerShell** command, and a **Vivado Tcl Console** command. The handout uses normal LaTeX figures with `\includegraphics` paths under `lab_handout/Figures/screenshots/`.

```text
lab_handout/EE2C2_Lab3_Handout.tex          Student tutorial
lab_handout/EE2C2_Lab3_Report_Template.tex  Student worksheet
lab_handout/instructor_notes.md             Instructor schedule, prep, adaptation
```

Topics: 0 Getting started, 1 Combinational logic, 2 Sequential logic, 3 Finite state machines, 4 Synthesis and implementation, 5 Hardware targets and AUP-ZU3 connection, 6 Static timing analysis, 7 Power analysis, 8 PWM DAC / LED brightness assignment, 9 optional rainbow RTL demo.

## Quick Start

Clone the repository into your home folder or use **Code -> Download ZIP** on GitHub, then work from inside it:

```powershell
cd ~
git clone https://github.com/lab-emi/EE2C2_FPGA_Lab.git
cd EE2C2_FPGA_Lab
```

Open the student tutorial first:

```text
lab_handout/EE2C2_Lab3_Handout.tex
lab_handout/EE2C2_Lab3_Report_Template.tex
```

Add Vivado and Vitis to PATH for the current PowerShell window:

```powershell
$env:Path += ";C:\Xilinx\Vivado\2023.2\bin"
$env:Path += ";C:\Xilinx\Vitis\2023.2\bin"
vivado -version
```

Create the AC701 Vivado project without running implementation:

```powershell
vivado -mode batch -source scripts\create_vivado_project.tcl
```

Run the combinational logic simulation:

```powershell
vivado -mode batch -source scripts\run_simulation.tcl -tclargs tb_comb_led_logic
```

Run the FSM simulation:

```powershell
vivado -mode batch -source scripts\run_simulation.tcl -tclargs tb_led_fsm
```

Build the AC701 bitstream:

```powershell
vivado -mode batch -source build.tcl
```

Output bitstream for reports:

```text
build/EE2C2_FPGA_Lab.runs/impl_1/top_ac701.bit
```

Complete and test the required PWM assignment:

```powershell
vivado -mode batch -source pwm_dac\scripts\run_pwm_simulation.tcl
```

A correct student implementation prints `PWM_STUDENT_TEST_PASS`.

Program the optional prebuilt AUP-ZU3 demos after completing the connection preflight:

```powershell
vivado -mode batch -source pwm_dac\scripts\program_prebuilt_pwm_jtag.tcl
vivado -mode batch -source rainbow\scripts\program_prebuilt_rainbow_jtag.tcl
```

## Active Lab Contents

```text
prebuilt_bitstreams/
board-files/aup-zu3-4gb/1.0/
constr/ac701_lab.xdc
constraints/board_template.xdc
src/comb_led_logic.sv
src/one_hz_tick.sv
src/led_fsm.sv
src/top_ac701.sv
src/top.sv
sim/tb_comb_led_logic.sv
sim/tb_led_fsm.sv
scripts/ac701_project.tcl
scripts/create_vivado_project.tcl
scripts/run_simulation.tcl
lab_handout/
pwm_dac/
rainbow/
build.tcl
```

The longer XADC/UART voltage-monitor topic is kept as a backup LaTeX snippet in `lab_handout/topic9_voltage_monitor_backup.tex`; its support files remain under `xadc_voltage_monitor/` for future reuse, but it is not part of the active student handout.

## Troubleshooting Setup

- If `vivado` is not recognized, rerun the PATH commands above. If Vivado is installed somewhere else, replace the path with that installation's `bin` folder.
- If Vivado says `Specified part could not be found` for `xczu3eg-sfvc784`, you ran an old AUP-ZU3 build script. Use `build.tcl` for the required AC701 implementation and the prebuilt programming scripts for AUP-ZU3 board demos.
- If the PWM simulation does not print `PWM_STUDENT_TEST_PASS`, complete the TODO lines in `pwm_dac/src/pwm.sv` and rerun `pwm_dac\scripts\run_pwm_simulation.tcl`.
- If Hardware Manager does not detect the AUP-ZU3, check EXT PWR, BOOT=JTAG, the PROG UART data cable, and whether another Vivado/Vitis session is using JTAG.

## AC701 Build Assumptions

- `rst_btn` is treated as an active-high push-button reset.
- `sw[3]` selects the compact AC701 demo mode in `top_ac701.sv`: `0` for FSM LEDs, `1` for combinational LEDs.
- `sw[3:0]` are the main combinational demo inputs.
- The AC701 single-color LEDs are treated as active high.

If using another Xilinx board, start from `constraints/board_template.xdc`, update the package pins and I/O standards, and adapt the relevant top-level wrapper.
