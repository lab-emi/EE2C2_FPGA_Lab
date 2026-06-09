## Build the optional AUP-ZU3 rainbow RTL demo bitstream.
##
## Usage from the repository root:
##   vivado -mode batch -source rainbow/scripts/build_rainbow.tcl
##
## Student flow:
##   Do not run this on university PCs. Use the prebuilt bitstream programmed by
##   rainbow/scripts/program_prebuilt_rainbow_jtag.tcl.
##
## Staff-only rebuild:
##   Set EE2C2_ALLOW_AUP_ZU3_BUILD=1 before running this script. Vivado must
##   include XCZU3EG device support.

if {![info exists ::env(EE2C2_ALLOW_AUP_ZU3_BUILD)] || $::env(EE2C2_ALLOW_AUP_ZU3_BUILD) ne "1"} {
    puts "ERROR: This AUP-ZU3 build script is staff-only and requires XCZU3EG Vivado device support."
    puts "ERROR: Students should run: vivado -mode batch -source rainbow/scripts/program_prebuilt_rainbow_jtag.tcl"
    puts "ERROR: Staff can set EE2C2_ALLOW_AUP_ZU3_BUILD=1 to rebuild the prebuilt bitstream."
    exit 1
}

set script_dir [file dirname [file normalize [info script]]]
set rainbow_dir [file normalize "$script_dir/.."]
set project_root [file normalize "$rainbow_dir/.."]
source "$project_root/scripts/aup_zu3_project.tcl"

set project_name "rainbow_demo"
set build_dir [file normalize "$rainbow_dir/build_rainbow"]

if {[file exists $build_dir]} {
    file delete -force $build_dir
}

aup_zu3_create_project $project_name $build_dir $project_root

set rtl_files [lsort [glob -nocomplain "$rainbow_dir/*.v"]]
if {[llength $rtl_files] == 0} {
    puts "ERROR: No rainbow RTL files found under: $rainbow_dir"
    exit 1
}

add_files -norecurse $rtl_files
add_files -fileset constrs_1 -norecurse "$rainbow_dir/constr/aup_zu3_4gb_rainbow.xdc"
set_property top top [get_filesets sources_1]
update_compile_order -fileset sources_1

puts "INFO: Starting rainbow synthesis..."
launch_runs synth_1 -jobs 4
wait_on_run synth_1
set synth_status [get_property STATUS [get_runs synth_1]]
puts "INFO: synth_1 status: $synth_status"
if {[string first "Complete" $synth_status] < 0} {
    puts "ERROR: Rainbow synthesis did not complete successfully."
    exit 1
}

puts "INFO: Starting rainbow implementation and bitstream generation..."
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
set impl_status [get_property STATUS [get_runs impl_1]]
puts "INFO: impl_1 status: $impl_status"
if {[string first "Complete" $impl_status] < 0} {
    puts "ERROR: Rainbow implementation/bitstream did not complete successfully."
    exit 1
}

set bit_path [file normalize "$build_dir/$project_name.runs/impl_1/top.bit"]
puts "INFO: Rainbow bitstream created: $bit_path"
close_project
