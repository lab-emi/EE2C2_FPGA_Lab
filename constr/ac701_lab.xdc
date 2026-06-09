## EE2C2 FPGA Lab - AC701 implementation constraints
##
## Target board: Xilinx Artix-7 AC701 Evaluation Platform
## Board part:   xilinx.com:ac701:part0:1.4
## FPGA part:    xc7a200tfbg676-2
##
## These pins come from Vivado 2023.2's installed AC701 board metadata:
## data/xhub/boards/XilinxBoardStore/boards/Xilinx/ac701/1.4/part0_pins.xml

## AC701 system differential clock: 200 MHz LVDS oscillator.
set_property PACKAGE_PIN R3 [get_ports clk_p]
set_property PACKAGE_PIN P3 [get_ports clk_n]
set_property IOSTANDARD LVDS_25 [get_ports clk_p]
set_property IOSTANDARD LVDS_25 [get_ports clk_n]
create_clock -period 5.000 -name sys_clk [get_ports clk_p]

## Four AC701 DIP switches.
set_property PACKAGE_PIN R8 [get_ports {sw[0]}]
set_property PACKAGE_PIN P8 [get_ports {sw[1]}]
set_property PACKAGE_PIN R7 [get_ports {sw[2]}]
set_property PACKAGE_PIN R6 [get_ports {sw[3]}]
set_property IOSTANDARD SSTL15 [get_ports {sw[*]}]

## AC701 reset push button.
set_property PACKAGE_PIN U4 [get_ports rst_btn]
set_property IOSTANDARD LVCMOS15 [get_ports rst_btn]

## Four AC701 user LEDs, active high.
set_property PACKAGE_PIN M26 [get_ports {led[0]}]
set_property PACKAGE_PIN T24 [get_ports {led[1]}]
set_property PACKAGE_PIN T25 [get_ports {led[2]}]
set_property PACKAGE_PIN R26 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

## Human-speed asynchronous inputs enter synchronous logic in RTL.
set_false_path -from [get_ports {sw[*]}]
set_false_path -from [get_ports rst_btn]
