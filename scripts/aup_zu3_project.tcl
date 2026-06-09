## Shared AUP-ZU3 Vivado project setup helpers.
##
## Source this file from build/create scripts, then call:
##   aup_zu3_create_project $project_name $build_dir $project_root

set AUP_ZU3_CANONICAL_PART "xczu3eg-sfvc784-2-e"
set AUP_ZU3_BOARD_PART "realdigital.org:aup-zu3-4gb:part0:1.0"
set AUP_ZU3_PART_CANDIDATES [list \
    "xczu3eg-sfvc784-2-e" \
    "xczu3eg-sfvc784-1-e" \
]

proc aup_zu3_die {msg} {
    puts "ERROR: $msg"
    exit 1
}

proc aup_zu3_configure_board_repo {project_root} {
    set board_repo [file normalize "$project_root/board-files"]
    set board_dir [file normalize "$board_repo/aup-zu3-4gb/1.0"]

    foreach required_file [list \
        "$board_dir/board.xml" \
        "$board_dir/part0_pins.xml" \
        "$board_dir/preset.xml" \
        "$board_dir/xitem.json" \
    ] {
        if {![file exists $required_file]} {
            aup_zu3_die "Local AUP-ZU3 board file missing: $required_file. Re-clone or update the repository; the lab expects board-files/aup-zu3-4gb/1.0 to be present."
        }
    }

    set repo_paths [list $board_repo]
    foreach existing_path [get_param board.repoPaths] {
        set normalized_path [file normalize $existing_path]
        if {$normalized_path ne $board_repo} {
            lappend repo_paths $normalized_path
        }
    }
    set_param board.repoPaths $repo_paths
    puts "INFO: Using local AUP-ZU3 board repository: $board_repo"
    return $board_repo
}

proc aup_zu3_select_part {} {
    global AUP_ZU3_CANONICAL_PART
    global AUP_ZU3_PART_CANDIDATES

    foreach candidate $AUP_ZU3_PART_CANDIDATES {
        if {[llength [get_parts -quiet $candidate]] > 0} {
            if {$candidate ne $AUP_ZU3_CANONICAL_PART} {
                puts "WARN: Vivado does not list canonical part $AUP_ZU3_CANONICAL_PART; using compatible fallback part $candidate."
                puts "WARN: The fallback keeps the same XCZU3EG/SFVC784 device/package and uses a conservative timing model."
            } else {
                puts "INFO: Using FPGA part: $candidate"
            }
            return $candidate
        }
    }

    set package_matches [lsort [get_parts -quiet "xczu3eg-sfvc784*"]]
    if {[llength $package_matches] > 0} {
        set fallback [lindex $package_matches 0]
        puts "WARN: Canonical AUP-ZU3 part $AUP_ZU3_CANONICAL_PART was not found; using available same-package part $fallback."
        return $fallback
    }

    puts "ERROR: Vivado cannot find any xczu3eg-sfvc784 device part."
    puts "ERROR: This usually means the Vivado installation is missing Zynq UltraScale+ MPSoC / XCZU3EG device support."
    puts "ERROR: Re-run the Vivado 2023.2 installer in Modify mode and install Zynq UltraScale+ MPSoC device support."
    exit 1
}

proc aup_zu3_apply_board_part {selected_part} {
    global AUP_ZU3_CANONICAL_PART
    global AUP_ZU3_BOARD_PART

    set board_part_count [llength [get_board_parts -quiet $AUP_ZU3_BOARD_PART]]

    if {$selected_part eq $AUP_ZU3_CANONICAL_PART && $board_part_count == 0} {
        aup_zu3_die "Board part '$AUP_ZU3_BOARD_PART' was not found after adding the local board repository."
    }

    if {$selected_part eq $AUP_ZU3_CANONICAL_PART} {
        set_property board_part $AUP_ZU3_BOARD_PART [current_project]
        puts "INFO: Applied board part: $AUP_ZU3_BOARD_PART"
    } elseif {$board_part_count == 0} {
        puts "WARN: Board part '$AUP_ZU3_BOARD_PART' is not visible with selected fallback part $selected_part."
        puts "WARN: Continuing with the selected FPGA part and the lab XDC pin constraints."
    } else {
        puts "WARN: Skipping board_part property because the local board file declares $AUP_ZU3_CANONICAL_PART but this Vivado install selected $selected_part."
        puts "WARN: The project will still use the lab XDC pin constraints under constr/ or the topic-specific constraint folder."
    }
}

proc aup_zu3_create_project {project_name build_dir project_root} {
    aup_zu3_configure_board_repo $project_root
    set selected_part [aup_zu3_select_part]
    create_project $project_name $build_dir -part $selected_part -force
    aup_zu3_apply_board_part $selected_part
    return $selected_part
}
