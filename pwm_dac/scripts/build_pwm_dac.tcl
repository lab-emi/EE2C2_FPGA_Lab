## Build the Topic 8 PWM DAC project.
##
## Usage from the EE2C2_FPGA_Lab root:
##   vivado -mode batch -source pwm_dac/scripts/build_pwm_dac.tcl
##
## Student flow:
##   Do not run this on university PCs. Complete pwm_dac/src/pwm.sv and run
##   pwm_dac/scripts/run_pwm_simulation.tcl. The AUP-ZU3 board demo uses the
##   prebuilt bitstream programmed by program_prebuilt_pwm_jtag.tcl.
##
## Staff-only rebuild:
##   Set EE2C2_ALLOW_AUP_ZU3_BUILD=1 before running this script. Vivado must
##   include XCZU3EG device support.

if {![info exists ::env(EE2C2_ALLOW_AUP_ZU3_BUILD)] || $::env(EE2C2_ALLOW_AUP_ZU3_BUILD) ne "1"} {
    puts "ERROR: This AUP-ZU3 build script is staff-only and requires XCZU3EG Vivado device support."
    puts "ERROR: Students should run: vivado -mode batch -source pwm_dac/scripts/run_pwm_simulation.tcl"
    puts "ERROR: For the optional board demo, run: vivado -mode batch -source pwm_dac/scripts/program_prebuilt_pwm_jtag.tcl"
    puts "ERROR: Staff can set EE2C2_ALLOW_AUP_ZU3_BUILD=1 to rebuild the prebuilt bitstream."
    exit 1
}

set script_dir [file dirname [file normalize [info script]]]
set pwm_root [file normalize "$script_dir/.."]
set project_root [file normalize "$pwm_root/.."]
source "$project_root/scripts/aup_zu3_project.tcl"

set project_name "pwm_dac_lab"
set build_dir [file normalize "$pwm_root/build_pwm_dac"]
set jobs 4

if {[file exists $build_dir]} {
    file delete -force $build_dir
}

aup_zu3_create_project $project_name $build_dir $project_root

set rtl_files [lsort [glob -nocomplain "$pwm_root/src/*.sv"]]
add_files -norecurse $rtl_files
set_property file_type {SystemVerilog} [get_files -of_objects [get_filesets sources_1]]

set sim_files [lsort [glob -nocomplain "$pwm_root/sim/*.sv"]]
if {[llength $sim_files] > 0} {
    add_files -fileset sim_1 -norecurse $sim_files
    set_property file_type {SystemVerilog} [get_files -of_objects [get_filesets sim_1]]
    set_property top tb_pwm [get_filesets sim_1]
}

add_files -fileset constrs_1 -norecurse "$pwm_root/constr/aup_zu3_4gb_pwm.xdc"

set_property top top_pwm_dac [get_filesets sources_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "INFO: Starting PWM DAC synthesis..."
launch_runs synth_1 -jobs $jobs
wait_on_run synth_1

set synth_status [get_property STATUS [get_runs synth_1]]
if {$synth_status ne "synth_design Complete!"} {
    puts "ERROR: Synthesis failed: $synth_status"
    exit 1
}

puts "INFO: Starting PWM DAC implementation..."
launch_runs impl_1 -to_step write_bitstream -jobs $jobs
wait_on_run impl_1

set impl_status [get_property STATUS [get_runs impl_1]]
if {$impl_status ne "write_bitstream Complete!"} {
    puts "ERROR: Implementation/bitstream failed: $impl_status"
    exit 1
}

puts "INFO: PWM DAC bitstream generated under: $build_dir/$project_name.runs/impl_1"
