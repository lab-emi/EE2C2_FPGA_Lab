## Generic Xilinx board template for adapting the LED FSM lab to another board.
## Replace each <...> placeholder with the correct package pin from your board.
##
## This template assumes a single-ended clock called clk. The active AUP-ZU3
## design uses a differential clock called clk_p/clk_n, so see
## constr/aup_zu3_4gb.xdc for the board-specific constraints used in this repo.

## Clock input, example 100 MHz.
# set_property PACKAGE_PIN <CLK_PIN> [get_ports clk]
# set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk [get_ports clk]

## Reset push button.
# set_property PACKAGE_PIN <RESET_BUTTON_PIN> [get_ports rst_btn]
# set_property IOSTANDARD LVCMOS33 [get_ports rst_btn]

## Eight switches. If your board has fewer switches, reduce sw width in top.sv.
# set_property PACKAGE_PIN <SW0_PIN> [get_ports {sw[0]}]
# set_property PACKAGE_PIN <SW1_PIN> [get_ports {sw[1]}]
# set_property PACKAGE_PIN <SW2_PIN> [get_ports {sw[2]}]
# set_property PACKAGE_PIN <SW3_PIN> [get_ports {sw[3]}]
# set_property PACKAGE_PIN <SW4_PIN> [get_ports {sw[4]}]
# set_property PACKAGE_PIN <SW5_PIN> [get_ports {sw[5]}]
# set_property PACKAGE_PIN <SW6_PIN> [get_ports {sw[6]}]
# set_property PACKAGE_PIN <SW7_PIN> [get_ports {sw[7]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[*]}]

## Single-color LEDs.
# set_property PACKAGE_PIN <LED0_PIN> [get_ports {led[0]}]
# set_property PACKAGE_PIN <LED1_PIN> [get_ports {led[1]}]
# set_property PACKAGE_PIN <LED2_PIN> [get_ports {led[2]}]
# set_property PACKAGE_PIN <LED3_PIN> [get_ports {led[3]}]
# set_property PACKAGE_PIN <LED4_PIN> [get_ports {led[4]}]
# set_property PACKAGE_PIN <LED5_PIN> [get_ports {led[5]}]
# set_property PACKAGE_PIN <LED6_PIN> [get_ports {led[6]}]
# set_property PACKAGE_PIN <LED7_PIN> [get_ports {led[7]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

## Optional RGB LEDs. Remove these ports from top.sv if your board lacks RGB LEDs.
# set_property PACKAGE_PIN <RGB0_R_PIN> [get_ports rgb0_r]
# set_property PACKAGE_PIN <RGB0_G_PIN> [get_ports rgb0_g]
# set_property PACKAGE_PIN <RGB0_B_PIN> [get_ports rgb0_b]
# set_property IOSTANDARD LVCMOS33 [get_ports {rgb0_r rgb0_g rgb0_b}]

## External human inputs are not synchronous to the FPGA clock.
# set_false_path -from [get_ports {sw[*]}]
# set_false_path -from [get_ports rst_btn]
