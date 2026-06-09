## =============================================================================
## EE2C2_FPGA_Lab LED FSM Lab - AUP-ZU3-4GB Pin Constraints
##
## Target: xczu3eg-sfvc784-2-e
## Board:  RealDigital AUP-ZU3-4GB
##
## Pin assignments are taken from:
##   board-files/aup-zu3-4gb/1.0/part0_pins.xml
##
## The design uses:
##   clk_p/clk_n : 100 MHz differential PL clock
##   rst_btn     : push button 0, active high reset
##   sw[7]       : mode select, 0 = FSM demo, 1 = combinational demo
##   sw[3:0]     : combinational demo inputs
##   led[7:0]    : single-color LED outputs
##   rgb0..rgb3  : RGB LED outputs
## =============================================================================

## Clock: 100 MHz differential LVDS
set_property PACKAGE_PIN D7 [get_ports clk_p]
set_property PACKAGE_PIN D6 [get_ports clk_n]
set_property IOSTANDARD LVDS [get_ports clk_p]
set_property IOSTANDARD LVDS [get_ports clk_n]
create_clock -period 10.000 -name sys_clk [get_ports clk_p]

## Switches: active high, LVCMOS12
set_property PACKAGE_PIN AB1 [get_ports {sw[0]}]
set_property PACKAGE_PIN AF1 [get_ports {sw[1]}]
set_property PACKAGE_PIN AE3 [get_ports {sw[2]}]
set_property PACKAGE_PIN AC2 [get_ports {sw[3]}]
set_property PACKAGE_PIN AC1 [get_ports {sw[4]}]
set_property PACKAGE_PIN AD6 [get_ports {sw[5]}]
set_property PACKAGE_PIN AD1 [get_ports {sw[6]}]
set_property PACKAGE_PIN AD2 [get_ports {sw[7]}]
set_property IOSTANDARD LVCMOS12 [get_ports {sw[*]}]

## Reset push button: active high, LVCMOS12
set_property PACKAGE_PIN AB6 [get_ports rst_btn]
set_property IOSTANDARD LVCMOS12 [get_ports rst_btn]

## Single-color LEDs: active high, LVCMOS12
set_property PACKAGE_PIN AF5 [get_ports {led[0]}]
set_property PACKAGE_PIN AE7 [get_ports {led[1]}]
set_property PACKAGE_PIN AH2 [get_ports {led[2]}]
set_property PACKAGE_PIN AE5 [get_ports {led[3]}]
set_property PACKAGE_PIN AH1 [get_ports {led[4]}]
set_property PACKAGE_PIN AE4 [get_ports {led[5]}]
set_property PACKAGE_PIN AG1 [get_ports {led[6]}]
set_property PACKAGE_PIN AF2 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS12 [get_ports {led[*]}]

## RGB LEDs: active high, LVCMOS12
set_property PACKAGE_PIN AD7 [get_ports rgb0_r]
set_property PACKAGE_PIN AD9 [get_ports rgb0_g]
set_property PACKAGE_PIN AE9 [get_ports rgb0_b]

set_property PACKAGE_PIN AG9 [get_ports rgb1_r]
set_property PACKAGE_PIN AE8 [get_ports rgb1_g]
set_property PACKAGE_PIN AF8 [get_ports rgb1_b]

set_property PACKAGE_PIN AF7 [get_ports rgb2_r]
set_property PACKAGE_PIN AG8 [get_ports rgb2_g]
set_property PACKAGE_PIN AG6 [get_ports rgb2_b]

set_property PACKAGE_PIN AF6 [get_ports rgb3_r]
set_property PACKAGE_PIN AH6 [get_ports rgb3_g]
set_property PACKAGE_PIN AG5 [get_ports rgb3_b]

set_property IOSTANDARD LVCMOS12 [get_ports rgb*]

## Human-speed asynchronous inputs enter synchronous logic in RTL.
set_false_path -from [get_ports {sw[*]}]
set_false_path -from [get_ports rst_btn]
