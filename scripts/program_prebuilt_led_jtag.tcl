## Program the prebuilt AUP-ZU3 main LED demo (sequential FSM + combinational
## logic, the same RTL used in Topics 1--4) over JTAG.
##
## Usage from the EE2C2_FPGA_Lab root:
##   vivado -mode batch -source scripts/program_prebuilt_led_jtag.tcl

set script_dir [file dirname [file normalize [info script]]]
set project_root [file normalize "$script_dir/.."]
set helper [file normalize "$project_root/scripts/program_prebuilt_jtag.tcl"]

if {![file exists $helper]} {
    puts "ERROR: Missing helper script: $helper"
    exit 1
}

set argv [list "prebuilt_bitstreams/aup_zu3_led_demo.bit"]
source $helper
