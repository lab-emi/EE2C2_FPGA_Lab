## Program the AUP-ZU3 PL over JTAG with the generated LED FSM lab bitstream.
##
## Usage:
##   vivado -mode batch -source program_jtag.tcl

set script_dir [file dirname [file normalize [info script]]]
set bit_file [file normalize "$script_dir/build/EE2C2_FPGA_Lab.runs/impl_1/top.bit"]

if {![file exists $bit_file]} {
    puts "ERROR: Bitstream not found: $bit_file"
    exit 1
}

puts "INFO: Opening hardware manager..."
open_hw_manager

puts "INFO: Connecting to local hardware server..."
connect_hw_server -allow_non_jtag

puts "INFO: Opening hardware target..."
open_hw_target

set devices [get_hw_devices]
puts "INFO: Hardware devices detected:"
foreach device $devices {
    puts "INFO:   [get_property PART $device] ($device)"
}

set target_device {}
foreach device $devices {
    set part [string tolower [get_property PART $device]]
    if {[string match "*xczu3eg*" $part] || [string match "*xczu3*" $part]} {
        set target_device $device
        break
    }
}

if {$target_device eq ""} {
    puts "ERROR: No xczu3/xczu3eg JTAG device found."
    close_hw_manager
    exit 1
}

current_hw_device $target_device
refresh_hw_device $target_device

puts "INFO: Programming [get_property PART $target_device] with $bit_file"
set_property PROGRAM.FILE $bit_file $target_device
program_hw_devices $target_device
refresh_hw_device $target_device

puts "INFO: Programmed device: [get_property PART $target_device] ($target_device)"
if {[lsearch -exact [list_property $target_device] PROGRAM.HW_CFGMEM_DONE] >= 0} {
    puts "INFO: DONE status: [get_property PROGRAM.HW_CFGMEM_DONE $target_device]"
}

close_hw_target
close_hw_manager
puts "INFO: JTAG programming complete."
