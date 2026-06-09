## PWM DAC Topic 8 constraints for the AUP-ZU3-4GB board.
## This file is separate from the LED FSM constraints because Topic 8 builds a
## separate top-level design.

## Clock: 100 MHz differential LVDS
set_property PACKAGE_PIN D7 [get_ports clk_p]
set_property PACKAGE_PIN D6 [get_ports clk_n]
set_property IOSTANDARD LVDS [get_ports clk_p]
set_property IOSTANDARD LVDS [get_ports clk_n]
create_clock -period 10.000 -name sys_clk [get_ports clk_p]

## Switches used as the 4-bit duty selector
set_property PACKAGE_PIN AB1 [get_ports {sw[0]}]
set_property PACKAGE_PIN AF1 [get_ports {sw[1]}]
set_property PACKAGE_PIN AE3 [get_ports {sw[2]}]
set_property PACKAGE_PIN AC2 [get_ports {sw[3]}]
set_property IOSTANDARD LVCMOS12 [get_ports {sw[*]}]

## Reset push button: active high
set_property PACKAGE_PIN AB6 [get_ports rst_btn]
set_property IOSTANDARD LVCMOS12 [get_ports rst_btn]

## Single-color LEDs
set_property PACKAGE_PIN AF5 [get_ports {led[0]}]
set_property PACKAGE_PIN AE7 [get_ports {led[1]}]
set_property PACKAGE_PIN AH2 [get_ports {led[2]}]
set_property PACKAGE_PIN AE5 [get_ports {led[3]}]
set_property PACKAGE_PIN AH1 [get_ports {led[4]}]
set_property PACKAGE_PIN AE4 [get_ports {led[5]}]
set_property PACKAGE_PIN AG1 [get_ports {led[6]}]
set_property PACKAGE_PIN AF2 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS12 [get_ports {led[*]}]

set_false_path -from [get_ports {sw[*]}]
set_false_path -from [get_ports rst_btn]
