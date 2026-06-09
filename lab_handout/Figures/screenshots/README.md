# Figure shot list - FPGA lab handout

This folder holds the annotated figure images referenced by the lab handout
(`lab_handout/EE2C2_Lab3_Handout.tex`).

## How the figure files work

- **LaTeX (`EE2C2_Lab3_Handout.tex`):** every figure is a normal `figure` environment with an
  explicit `\includegraphics[width=0.85\linewidth]{Figures/screenshots/<file>}`
  line. Edit that width or add a height option on each individual figure when
  you tune the PDF layout.
- Captions use normal LaTeX numbering, so the compiled PDF labels them
  **Figure 1**, **Figure 2**, and so on.
- Missing captures have placeholder PNG files at the required paths. Replace
  each placeholder PNG with the real annotated capture using the exact same
  filename.
- **Markdown (`lab_handout.md`):** each placeholder is a block naming the same
  file. Replace the block with `![caption](Figures/screenshots/<file>)` once the
  capture is ready, or keep the note and attach the image alongside.

## Capture tips

- Use Windows Snipping Tool (`Win`+`Shift`+`S`) for window or region captures;
  save as PNG with the exact name below into this folder.
- Annotate with boxes, arrows, and labels as described. The annotation is what
  makes these teaching figures useful.
- Keep images legible: crop tightly to the relevant panel; about 1200 px wide is
  usually enough.

| # | Filename | Topic | What to capture | Key annotations |
|---|----------|-------|-----------------|-----------------|
| 0.1 | `t0_01_board_overview.png` | 0 | Top-down photo of the AUP-ZU3-4GB board | **PROG UART** and **EXT PWR** USB-C ports, **BOOT** switch, `rst_btn`, single-color LEDs, RGB LEDs |
| 0.2 | `t0_02_powershell_setup.png` | 0 | PowerShell after `git clone`, `cd EE2C2_FPGA_Lab`, `dir`, `vivado -version` | Clone output; lab files; the `Vivado v2023.2` line |
| 0.3 | `t0_03_create_project.png` | 0 | Tail of `create_vivado_project.tcl` output | The AC701 part message and `INFO: Created project:` line |
| 0.4 | `t0_04_vivado_main_window.png` | 0 | The Vivado window after the project opens | Boxes around Flow Navigator, Sources, Tcl Console, Messages |
| 0.5 | `t0_05_sources_panel.png` | 0 | Sources panel fully expanded | Labels: Design Sources, Constraints, Simulation Sources |
| 1.1 | `t1_01_comb_source.png` | 1 | `comb_led_logic.sv` in the editor | Box the `always_comb`; arrows to AND, XOR, and mux lines |
| 1.2 | `t1_02_set_as_top.png` | 1 | Right-click menu on `tb_comb_led_logic` | Highlight **Set as Top** |
| 1.3 | `t1_03_comb_waveform.png` | 1 | `tb_comb_led_logic` behavioral waveform | Input change to output change at the same timestamp |
| 2.1 | `t2_01_tick_source.png` | 2 | `one_hz_tick.sv` in the editor | Box `always_ff`; point at `count_value` and the `tick_1s` pulse line |
| 2.2 | `t2_02_counter_tick_waveform.png` | 2 | `tb_led_fsm` waveform, zoomed on the counter | Counter wrap `7->0`; one-cycle-wide `tick_1s` |
| 3.1 | `t3_01_fsm_state_diagram.png` | 3 | A drawn FSM state diagram | 8 state bubbles; arrows labelled `tick_1s=1`; output per state |
| 3.2 | `t3_02_fsm_source.png` | 3 | `led_fsm.sv` in the editor | Box and label: state register, next-state logic, output decode |
| 3.3 | `t3_03_fsm_waveform.png` | 3 | `tb_led_fsm` waveform | Reset region; arrows from 3 ticks to 3 `state_dbg` transitions |
| 4.1 | `t4_01_flow_navigator.png` | 4 | The Flow Navigator column | Box Run Synthesis, Run Implementation, Generate Bitstream; number them 1-2-3 |
| 4.2 | `t4_02_runs_complete.png` | 4 | Design Runs tab after a clean build | Circle green checks on `synth_1` and `impl_1` |
| 5.1 | `t5_01_board_connected.png` | 5 | Powered board with both USB-C cables attached | Label **PROG UART** (to PC), **EXT PWR** (to PD adapter), **BOOT**=JTAG, power LED, DONE LED |
| 5.2 | `t5_02_program_device.png` | 5 | Program Device dialog or PowerShell success for a prebuilt demo | Prebuilt bitstream path; FPGA device `xczu3` / `xczu3eg` |
| 5.3 | `t5_03_board_fsm_mode.png` | 5 | No longer required | Retained only if instructors want an old main-design demo photo |
| 5.4 | `t5_04_board_comb_mode.png` | 5 | No longer required | Retained only if instructors want an old main-design demo photo |
| 5.5 | `t5_05_hw_detected.png` | 5 | Hardware Manager after Auto Connect or `get_hw_devices` output | Circle the detected `xczu3` / `xczu3eg` FPGA device |
| 6.1 | `t6_01_timing_summary.png` | 6 | Design Timing Summary panel | Box WNS, TNS, WHS, THS; "constraints are met" message |
| 6.2 | `t6_02_worst_path.png` | 6 | Worst setup path and Path Properties | Source, Destination, slack |
| 6.3 | `t6_03_critical_path_schematic.png` | 6 | Schematic of the critical path | Launch FF, logic in between, capture FF |
| 7.1 | `t7_01_power_summary.png` | 7 | Power Summary panel | Total on-chip; static vs dynamic; largest category |
| 8.1 | `t8_01_pwm_datapath.png` | 8 | Drawn PWM data-path block diagram | `duty_select`, PWM counter and comparator, `led[0]`, PWM TODOs |
| 8.2 | `t8_02_pwm_waveform.png` | 8 | `tb_pwm` waveform or console output | Required pass token: `PWM_STUDENT_TEST_PASS`; optional waveform can mark one period |
| 8.3 | `t8_03_board_brightness.png` | 8 | Optional prebuilt AUP-ZU3 PWM demo | `led[0]` at low vs high duty; `sw[3:0]` code under each |
| 9.1 | - | 9 | Optional prebuilt rainbow RTL demo | No required report screenshot |
