## EE2C2_FPGA_Lab AC701 LED FSM Vivado project
##
## Intended tool: Vivado 2023.2
##
## Usage:
##   cd hw/EE2C2_FPGA_Lab
##   vivado -mode batch -source build.tcl
##
## Output:
##   build/EE2C2_FPGA_Lab.runs/impl_1/top.bit
##
## Note:
##   This script targets AC701 because the university PCs have AC701 / Artix-7
##   support installed by default. The physical AUP-ZU3 board demos are
##   programmed from prebuilt bitstreams under prebuilt_bitstreams/.

set script_dir [file dirname [file normalize [info script]]]
source "$script_dir/scripts/ac701_project.tcl"

set project_name "EE2C2_FPGA_Lab"
set build_dir [file normalize "$script_dir/build"]
set jobs 4

if {[catch {version -short} vivado_version] == 0} {
    if {![string match "*2023.2*" $vivado_version]} {
        puts "WARN: This project is intended for Vivado 2023.2; running Vivado $vivado_version."
    }
}

if {[file exists $build_dir]} {
    file delete -force $build_dir
}

ac701_create_project $project_name $build_dir

set rtl_files [lsort [glob -nocomplain "$script_dir/src/*.sv"]]
## The AUP-ZU3 board top is built separately (build_aup_zu3.tcl); keep it out of
## the AC701 project so this project has a single top module.
set rtl_files [lsearch -all -inline -not -glob $rtl_files "*top_aup_zu3.sv"]
if {[llength $rtl_files] == 0} {
    puts "ERROR: No SystemVerilog RTL files found under: $script_dir/src"
    exit 1
}
add_files -norecurse $rtl_files
set_property file_type {SystemVerilog} [get_files -of_objects [get_filesets sources_1]]

set sim_files [lsort [glob -nocomplain "$script_dir/sim/*.sv"]]
if {[llength $sim_files] > 0} {
    add_files -fileset sim_1 -norecurse $sim_files
    set_property file_type {SystemVerilog} [get_files -of_objects [get_filesets sim_1]]
    set_property top tb_led_fsm [get_filesets sim_1]
}

add_files -fileset constrs_1 -norecurse "$script_dir/constr/ac701_lab.xdc"

set_property top top [get_filesets sources_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "INFO: Starting synthesis..."
launch_runs synth_1 -jobs $jobs
wait_on_run synth_1

set synth_status [get_property STATUS [get_runs synth_1]]
if {$synth_status ne "synth_design Complete!"} {
    puts "ERROR: Synthesis failed: $synth_status"
    exit 1
}

puts "INFO: Starting implementation and bitstream generation..."
launch_runs impl_1 -to_step write_bitstream -jobs $jobs
wait_on_run impl_1

set impl_status [get_property STATUS [get_runs impl_1]]
if {$impl_status ne "write_bitstream Complete!"} {
    puts "ERROR: Implementation/bitstream failed: $impl_status"
    exit 1
}

set bit_file "$build_dir/$project_name.runs/impl_1/top.bit"
if {![file exists $bit_file]} {
    puts "ERROR: Expected bitstream was not generated: $bit_file"
    exit 1
}

puts "INFO: Bitstream generated at: $bit_file"
puts "INFO: Build complete."
