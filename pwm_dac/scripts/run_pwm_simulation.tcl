## Run behavioral simulation for the Topic 8 PWM DAC testbench.
##
## Usage from the EE2C2_FPGA_Lab root:
##   vivado -mode batch -source pwm_dac/scripts/run_pwm_simulation.tcl

set script_dir [file dirname [file normalize [info script]]]
set pwm_root [file normalize "$script_dir/.."]
set sim_dir [file normalize "$pwm_root/build_pwm_dac/xsim_pwm"]
set sim_top "tb_pwm"
set snapshot "${sim_top}_behav"

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

set pwm_file [file normalize "$pwm_root/src/pwm.sv"]
set tb_file [file normalize "$pwm_root/sim/$sim_top.sv"]
if {![file exists $pwm_file] || ![file exists $tb_file]} {
    puts "ERROR: Missing PWM simulation source(s). Expected:"
    puts "       $pwm_file"
    puts "       $tb_file"
    exit 1
}

set vivado_bin [find_vivado_bin]
if {$vivado_bin eq ""} {
    puts "ERROR: Could not locate Vivado XSim tools. Run this script through Vivado 2023.2."
    exit 1
}

file delete -force $sim_dir
file mkdir $sim_dir

set old_dir [pwd]
cd $sim_dir

set prj_file [file normalize "$sim_dir/${sim_top}_vlog.prj"]
set prj [open $prj_file w]
puts $prj "sv xil_defaultlib \"$pwm_file\""
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

set xsim_log [file normalize "$sim_dir/xsim.log"]
set log_data ""
if {[file exists $xsim_log]} {
    set fh [open $xsim_log r]
    set log_data [read $fh]
    close $fh
}

if {[string first "PWM_STUDENT_TEST_PASS" $log_data] >= 0} {
    puts "INFO: PWM_STUDENT_TEST_PASS found in xsim.log."
} else {
    puts "ERROR: PWM_STUDENT_TEST_PASS was not found in xsim.log."
    puts "ERROR: Complete the TODO lines in pwm_dac/src/pwm.sv, rerun the simulation, and show the pass line to your TA."
    exit 1
}

cd $old_dir
puts "INFO: Behavioral simulation complete for PWM DAC ($sim_top)."
