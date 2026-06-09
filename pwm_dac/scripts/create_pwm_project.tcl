## Create the PWM DAC Vivado project for code editing and behavioral simulation.
##
## This project is for inspecting/completing pwm_dac/src/pwm.sv and running the
## behavioral simulation only. You do NOT synthesize or implement it: the board
## demo in Step 7.4 uses a prebuilt AUP-ZU3 bitstream. A standard AC701 part is
## used so the project opens on the university PCs; behavioral simulation does
## not depend on the chosen part.
##
## Usage from the repository root:
##   vivado -mode batch -source pwm_dac/scripts/create_pwm_project.tcl
##   vivado pwm_dac/build_pwm_project/pwm_dac_lab.xpr   (open in the GUI)

set script_dir [file dirname [file normalize [info script]]]
set pwm_root [file normalize "$script_dir/.."]
set project_root [file normalize "$pwm_root/.."]
source "$project_root/scripts/ac701_project.tcl"

set project_name "pwm_dac_lab"
set build_dir [file normalize "$pwm_root/build_pwm_project"]

if {[file exists $build_dir]} {
    file delete -force $build_dir
}

ac701_create_project $project_name $build_dir

set rtl_files [lsort [glob -nocomplain "$pwm_root/src/*.sv"]]
if {[llength $rtl_files] == 0} {
    puts "ERROR: No PWM RTL files found under: $pwm_root/src"
    exit 1
}
add_files -norecurse $rtl_files
set_property file_type {SystemVerilog} [get_files -of_objects [get_filesets sources_1]]
set_property top top_pwm_dac [get_filesets sources_1]

set sim_files [lsort [glob -nocomplain "$pwm_root/sim/*.sv"]]
if {[llength $sim_files] > 0} {
    add_files -fileset sim_1 -norecurse $sim_files
    set_property file_type {SystemVerilog} [get_files -of_objects [get_filesets sim_1]]
    set_property top tb_pwm [get_filesets sim_1]
}

catch {update_compile_order -fileset sources_1}
catch {update_compile_order -fileset sim_1}

puts "INFO: Created PWM project: $build_dir/$project_name.xpr"
puts "INFO: Open it with: vivado pwm_dac/build_pwm_project/pwm_dac_lab.xpr"
