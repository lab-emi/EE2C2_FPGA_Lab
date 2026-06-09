## AUP-ZU3-4GB constraints for the optional rainbow RTL demo.

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

## Pushbuttons: active high, LVCMOS12
set_property PACKAGE_PIN AB6 [get_ports {btn[0]}]
set_property PACKAGE_PIN AB7 [get_ports {btn[1]}]
set_property PACKAGE_PIN AB2 [get_ports {btn[2]}]
set_property PACKAGE_PIN AC6 [get_ports {btn[3]}]
set_property IOSTANDARD LVCMOS12 [get_ports {btn[*]}]

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
set_false_path -from [get_ports {btn[*]}]
