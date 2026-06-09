## Create the EE2C2_FPGA_Lab Vivado project without running implementation.
##
## The university lab PCs have AC701 / Artix-7 support installed by default.
## AUP-ZU3 board demos use prebuilt bitstreams and do not require Vivado to
## synthesize or implement the XCZU3EG device.
##
## Usage from the project root:
##   vivado -mode batch -source scripts/create_vivado_project.tcl

set script_dir [file dirname [file normalize [info script]]]
set project_root [file normalize "$script_dir/.."]
source "$script_dir/ac701_project.tcl"

set project_name "EE2C2_FPGA_Lab"
set build_dir [file normalize "$project_root/build"]

if {[file exists $build_dir]} {
    file delete -force $build_dir
}

ac701_create_project $project_name $build_dir

set rtl_files [lsort [glob -nocomplain "$project_root/src/*.sv"]]
## The AUP-ZU3 board top is built separately (build_aup_zu3.tcl); keep it out of
## the AC701 project so this project has a single top module.
set rtl_files [lsearch -all -inline -not -glob $rtl_files "*top_aup_zu3.sv"]
if {[llength $rtl_files] == 0} {
    puts "ERROR: No RTL files found under: $project_root/src"
    exit 1
}
add_files -norecurse $rtl_files
set_property file_type {SystemVerilog} [get_files -of_objects [get_filesets sources_1]]

set sim_files [lsort [glob -nocomplain "$project_root/sim/*.sv"]]
if {[llength $sim_files] > 0} {
    add_files -fileset sim_1 -norecurse $sim_files
    set_property file_type {SystemVerilog} [get_files -of_objects [get_filesets sim_1]]
    set_property top tb_led_fsm [get_filesets sim_1]
}

add_files -fileset constrs_1 -norecurse "$project_root/constr/ac701_lab.xdc"

set_property top top [get_filesets sources_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "INFO: Created project: $build_dir/$project_name.xpr"
