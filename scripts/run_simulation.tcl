## Run behavioral simulation for one lab testbench.
##
## Usage from the project root:
##   vivado -mode batch -source scripts/run_simulation.tcl
##   vivado -mode batch -source scripts/run_simulation.tcl -tclargs tb_comb_led_logic
##   vivado -mode batch -source scripts/run_simulation.tcl -tclargs tb_led_fsm

set script_dir [file dirname [file normalize [info script]]]
set project_root [file normalize "$script_dir/.."]

set sim_top "tb_led_fsm"
if {$argc > 0} {
    set sim_top [lindex $argv 0]
}

switch -- $sim_top {
    tb_comb_led_logic {
        set rtl_files [list "$project_root/src/comb_led_logic.sv"]
    }
    tb_led_fsm {
        set rtl_files [list "$project_root/src/one_hz_tick.sv" "$project_root/src/led_fsm.sv"]
    }
    default {
        puts "ERROR: Unknown simulation top '$sim_top'. Expected tb_comb_led_logic or tb_led_fsm."
        exit 1
    }
}

set tb_file [file normalize "$project_root/sim/$sim_top.sv"]
if {![file exists $tb_file]} {
    puts "ERROR: Missing simulation testbench: $tb_file"
    exit 1
}

foreach rtl_file $rtl_files {
    set normalized [file normalize $rtl_file]
    if {![file exists $normalized]} {
        puts "ERROR: Missing RTL source: $normalized"
        exit 1
    }
}

proc find_vivado_bin {} {
    set candidates {}
    if {[info exists ::env(XILINX_VIVADO)]} {
        lappend candidates [file normalize "$::env(XILINX_VIVADO)/bin"]
    }

    set exe_dir [file normalize [file dirname [info nameofexecutable]]]
    lappend candidates $exe_dir
    lappend candidates [file normalize "$exe_dir/../.."]

    foreach candidate $candidates {
        if {[file exists [file join $candidate xvlog.bat]] || [file exists [file join $candidate xvlog]]} {
            return $candidate
        }
    }

    return ""
}

proc run_tool {tool args} {
    if {$::tcl_platform(platform) eq "windows"} {
        set cmd [concat [list cmd /c [file nativename $tool]] $args]
    } else {
        set cmd [concat [list $tool] $args]
    }

    puts "INFO: Running [file tail $tool] [join $args { }]"
    if {[catch {exec {*}$cmd} result]} {
        puts $result
        exit 1
    }
    if {$result ne ""} {
        puts $result
    }
}

set vivado_bin [find_vivado_bin]
if {$vivado_bin eq ""} {
    puts "ERROR: Could not locate Vivado XSim tools. Run this script through Vivado 2023.2."
    exit 1
}

set sim_dir [file normalize "$project_root/build/xsim_$sim_top"]
set snapshot "${sim_top}_behav"
file delete -force $sim_dir
file mkdir $sim_dir

set old_dir [pwd]
cd $sim_dir

set prj_file [file normalize "$sim_dir/${sim_top}_vlog.prj"]
set prj [open $prj_file w]
foreach rtl_file $rtl_files {
    puts $prj "sv xil_defaultlib \"[file normalize $rtl_file]\""
}
puts $prj "sv xil_defaultlib \"$tb_file\""
close $prj

set xvlog [file join $vivado_bin xvlog.bat]
set xelab [file join $vivado_bin xelab.bat]
set xsim  [file join $vivado_bin xsim.bat]
if {$::tcl_platform(platform) ne "windows"} {
    set xvlog [file join $vivado_bin xvlog]
    set xelab [file join $vivado_bin xelab]
    set xsim  [file join $vivado_bin xsim]
}

run_tool $xvlog --incr --relax -prj $prj_file -log xvlog.log
run_tool $xelab --incr --debug typical --relax --snapshot $snapshot xil_defaultlib.$sim_top -log xelab.log
run_tool $xsim $snapshot -runall -log xsim.log

cd $old_dir
puts "INFO: Behavioral simulation complete for $sim_top."
