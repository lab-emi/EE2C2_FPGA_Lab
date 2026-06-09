## Shared AC701 Vivado project setup helpers.
##
## The university PCs have the Artix-7 AC701 board/device support installed by
## default. Use this target for student synthesis, implementation, timing, and
## power-report work. AUP-ZU3 hardware demos are programmed from prebuilt
## bitstreams and do not use this helper.

set AC701_PART "xc7a200tfbg676-2"
set AC701_BOARD_PART "xilinx.com:ac701:part0:1.4"
set AC701_PART_CANDIDATES [list \
    "xc7a200tfbg676-2" \
    "xc7a200tfbg676-1" \
]

proc ac701_die {msg} {
    puts "ERROR: $msg"
    exit 1
}

proc ac701_create_project {project_name build_dir} {
    global AC701_PART
    global AC701_BOARD_PART
    global AC701_PART_CANDIDATES

    set selected_part ""
    foreach candidate $AC701_PART_CANDIDATES {
        if {[llength [get_parts -quiet $candidate]] > 0} {
            set selected_part $candidate
            break
        }
    }

    if {$selected_part eq ""} {
        set package_matches [lsort [get_parts -quiet "xc7a200tfbg676*"]]
        if {[llength $package_matches] > 0} {
            set selected_part [lindex $package_matches 0]
            puts "WARN: Canonical AC701 part $AC701_PART was not found; using available same-package part $selected_part."
        }
    }

    if {$selected_part eq ""} {
        puts "ERROR: Vivado cannot find AC701 FPGA part '$AC701_PART' or any xc7a200tfbg676* part."
        puts "ERROR: This lab expects the standard AC701 / Artix-7 device support installed on the university PCs."
        exit 1
    }

    puts "INFO: Using AC701 implementation part: $selected_part"
    create_project $project_name $build_dir -part $selected_part -force

    if {$selected_part eq $AC701_PART && [llength [get_board_parts -quiet $AC701_BOARD_PART]] > 0} {
        set_property board_part $AC701_BOARD_PART [current_project]
        puts "INFO: Applied AC701 board part: $AC701_BOARD_PART"
    } elseif {[llength [get_board_parts -quiet $AC701_BOARD_PART]] > 0} {
        puts "WARN: Skipping AC701 board_part property because selected part $selected_part differs from canonical $AC701_PART."
        puts "WARN: Continuing with the selected FPGA part and lab XDC constraints."
    } else {
        puts "WARN: AC701 board part '$AC701_BOARD_PART' was not visible; continuing with part-only project and lab XDC constraints."
    }

    return $selected_part
}
