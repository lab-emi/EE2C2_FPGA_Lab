## Backward-compatible wrapper.
##
## The student flow now uses a prebuilt AUP-ZU3 rainbow bitstream so university
## PCs do not need XCZU3EG implementation support.

puts "INFO: program_rainbow_jtag.tcl now redirects to program_prebuilt_rainbow_jtag.tcl."

set script_dir [file dirname [file normalize [info script]]]
source [file normalize "$script_dir/program_prebuilt_rainbow_jtag.tcl"]
