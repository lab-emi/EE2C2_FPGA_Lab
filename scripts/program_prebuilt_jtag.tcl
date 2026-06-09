## Program an already-built AUP-ZU3 bitstream over JTAG.
##
## Usage from the repository root:
##   vivado -mode batch -source scripts/program_prebuilt_jtag.tcl -tclargs prebuilt_bitstreams/aup_zu3_pwm_led_demo.bit
##
## This script intentionally does not create a Vivado project. It only opens
## Hardware Manager and downloads a .bit file to the connected FPGA, so it can
## still be used on PCs that cannot synthesize/implement the XCZU3EG part.

set script_dir [file dirname [file normalize [info script]]]
set project_root [file normalize "$script_dir/.."]

if {[llength $argv] != 1} {
    puts "ERROR: Expected one bitstream argument."
    puts "Usage: vivado -mode batch -source scripts/program_prebuilt_jtag.tcl -tclargs prebuilt_bitstreams/aup_zu3_pwm_led_demo.bit"
    exit 1
}

set bit_arg [lindex $argv 0]
if {[file pathtype $bit_arg] eq "relative"} {
    set bit_file [file normalize "$project_root/$bit_arg"]
} else {
    set bit_file [file normalize $bit_arg]
}

if {![file exists $bit_file]} {
    puts "ERROR: Bitstream not found: $bit_file"
    exit 1
}

proc device_score {device} {
    set part [string tolower [get_property PART $device]]
    set name [string tolower [get_property NAME $device]]

    if {[string match "*arm_dap*" $part] || [string match "*arm_dap*" $name] ||
        [string match "*dap*" $part] || [string match "*dap*" $name]} {
        return -1
    }

    if {[string match "*xczu3eg*" $part] || [string match "*xczu3eg*" $name]} {
        return 100
    }
    if {[string match "*xczu3*" $part] || [string match "*xczu3*" $name]} {
        return 90
    }
    if {[string match "*xczu*" $part] || [string match "*xczu*" $name]} {
        return 80
    }

    return 10
}

puts "INFO: Opening Vivado Hardware Manager..."
open_hw_manager

puts "INFO: Connecting to local hardware server..."
connect_hw_server -allow_non_jtag

puts "INFO: Opening hardware target..."
open_hw_target

set devices [get_hw_devices]
if {[llength $devices] == 0} {
    puts "ERROR: No JTAG hardware devices were detected."
    close_hw_manager
    exit 1
}

puts "INFO: Hardware devices detected:"
foreach device $devices {
    puts "INFO:   [get_property NAME $device] ([get_property PART $device])"
}

set target_device ""
set best_score -1
foreach device $devices {
    set score [device_score $device]
    if {$score > $best_score} {
        set best_score $score
        set target_device $device
    }
}

if {$target_device eq "" || $best_score < 0} {
    puts "ERROR: No programmable FPGA device found. The list may contain only ARM DAP/debug entries."
    close_hw_manager
    exit 1
}

if {$best_score < 80} {
    puts "WARN: No xczu3/xczu3eg-named device was found. Attempting the first non-DAP FPGA-like device:"
    puts "WARN:   [get_property NAME $target_device] ([get_property PART $target_device])"
}

current_hw_device $target_device
refresh_hw_device $target_device

puts "INFO: Programming [get_property NAME $target_device] ([get_property PART $target_device])"
puts "INFO: Bitstream: $bit_file"
set_property PROGRAM.FILE $bit_file $target_device
program_hw_devices $target_device
refresh_hw_device $target_device

puts "INFO: Programmed device: [get_property NAME $target_device] ([get_property PART $target_device])"
if {[lsearch -exact [list_property $target_device] PROGRAM.HW_CFGMEM_DONE] >= 0} {
    puts "INFO: DONE status: [get_property PROGRAM.HW_CFGMEM_DONE $target_device]"
}

close_hw_target
close_hw_manager
puts "INFO: Prebuilt AUP-ZU3 bitstream programming complete."
