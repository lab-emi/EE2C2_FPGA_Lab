## Build the AUP-ZU3 main LED demo bitstream (sequential FSM + combinational
## logic) from the same lab RTL used in Topics 1--4.
##
## Output:
##   prebuilt_bitstreams/aup_zu3_led_demo.bit
##
## Student flow:
##   Do not run this on university PCs. Program the prebuilt bitstream with
##   scripts/program_prebuilt_led_jtag.tcl instead.
##
## Staff-only rebuild:
##   Set EE2C2_ALLOW_AUP_ZU3_BUILD=1 first. Vivado must include XCZU3EG device
##   support.
##     vivado -mode batch -source build_aup_zu3.tcl

if {![info exists ::env(EE2C2_ALLOW_AUP_ZU3_BUILD)] || $::env(EE2C2_ALLOW_AUP_ZU3_BUILD) ne "1"} {
    puts "ERROR: This AUP-ZU3 build script is staff-only and requires XCZU3EG Vivado device support."
    puts "ERROR: Students should run: vivado -mode batch -source scripts/program_prebuilt_led_jtag.tcl"
    puts "ERROR: Staff can set EE2C2_ALLOW_AUP_ZU3_BUILD=1 to rebuild the prebuilt bitstream."
    exit 1
}

set project_root [file dirname [file normalize [info script]]]
source "$project_root/scripts/aup_zu3_project.tcl"

set project_name "aup_zu3_led_demo"
set build_dir [file normalize "$project_root/build_aup_zu3"]
set jobs 4

if {[file exists $build_dir]} {
    file delete -force $build_dir
}

aup_zu3_create_project $project_name $build_dir $project_root

## The AUP-ZU3 demo reuses the shared lab modules plus its own board top.
set rtl_files [list \
    "$project_root/src/one_hz_tick.sv" \
    "$project_root/src/comb_led_logic.sv" \
    "$project_root/src/led_fsm.sv" \
    "$project_root/src/top_aup_zu3.sv" \
]
foreach f $rtl_files {
    if {![file exists $f]} {
        puts "ERROR: Required RTL file missing: $f"
        exit 1
    }
}
add_files -norecurse $rtl_files
set_property file_type {SystemVerilog} [get_files -of_objects [get_filesets sources_1]]

add_files -fileset constrs_1 -norecurse "$project_root/constr/aup_zu3_4gb.xdc"

set_property top top_aup_zu3 [get_filesets sources_1]
update_compile_order -fileset sources_1

puts "INFO: Starting synthesis..."
launch_runs synth_1 -jobs $jobs
wait_on_run synth_1
set synth_status [get_property STATUS [get_runs synth_1]]
if {[string first "Complete" $synth_status] < 0} {
    puts "ERROR: AUP-ZU3 synthesis did not complete: $synth_status"
    exit 1
}

puts "INFO: Starting implementation and bitstream generation..."
launch_runs impl_1 -to_step write_bitstream -jobs $jobs
wait_on_run impl_1
set impl_status [get_property STATUS [get_runs impl_1]]
if {[string first "Complete" $impl_status] < 0} {
    puts "ERROR: AUP-ZU3 implementation/bitstream did not complete: $impl_status"
    exit 1
}

set bit_src "$build_dir/$project_name.runs/impl_1/top_aup_zu3.bit"
if {![file exists $bit_src]} {
    puts "ERROR: Expected bitstream was not generated: $bit_src"
    exit 1
}

set bit_dst "$project_root/prebuilt_bitstreams/aup_zu3_led_demo.bit"
file copy -force $bit_src $bit_dst
puts "INFO: Prebuilt bitstream updated: $bit_dst"
puts "INFO: Build complete."
close_project
