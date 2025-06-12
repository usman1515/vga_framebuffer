#!/bin/tclsh

source ./scripts/color_func.tcl -notrace

# get start time
print_blue "Run started at:     [clock format [clock seconds] -format "%d-%b-%Y - %I:%M:%S - %p"]"
set current_datetime [clock format [clock seconds] -format "%Y-%m-%d_%H:%M:%S"]

# * pwd
set prj_dir             [pwd]

# vars global - fpga and board part num - nexys a7 100t
set prj_name            "nexysa7_vga_frame_buffer"
set fpga_part_name      "xc7a100tcsg324-1"
set board_part_name     "digilentinc.com:nexys-a7-100t:part0:1.0"

# NOTE: these work in batch mode

# set top_module_rtl      "top_square_vga"
# set top_module_rtl      "top_ansi_color_palette_vga"
# set top_module_rtl      "top_color_gradient_vga"
# set top_module_rtl      "top_framebuffer_smpte_colorbars_monochrome"
# set top_module_rtl      "top_framebuffer_smpte_colorbars_grayscale"
# set top_module_rtl      "top_framebuffer_smpte_colorbars_tty16"
# set top_module_rtl      "top_framebuffer_phillips_pm5544_monochrome"
# set top_module_rtl      "top_framebuffer_phillips_pm5544_grayscale"
set top_module_rtl      "top_framebuffer_phillips_pm5544_tty16"


# NOTE: these dont work in batch mode

# set top_module_rtl      "top_framebuffer_david_monochrome_1bit"
# set top_module_rtl      "top_framebuffer_monalisa_gray_1bit"

# vars synthesis
set name_run_synth      "run_synthesis"
set name_chkp_synth     [lindex $argv 0]
set name_rpt_synth      "synthesis"

# vars implementation
# opt_design
set name_run_impl1      "run_impl1_opt_design"
set name_chkp_impl1     [lindex $argv 1]
set name_rpt_impl1      "impl1_opt_design"
# power_opt_design
set name_run_impl2      "run_impl2_power_opt_design"
set name_chkp_impl2     [lindex $argv 2]
set name_rpt_impl2      "impl2_power_opt_design"
# place_design
set name_run_impl3      "run_impl3_place_design"
set name_chkp_impl3     [lindex $argv 3]
set name_rpt_impl3      "impl3_place_design"
# phys_opt_design
set name_run_impl4      "run_impl4_phys_opt_design"
set name_chkp_impl4     [lindex $argv 4]
set name_rpt_impl4      "impl4_phys_opt_design"
# route_design
set name_run_impl5      "run_impl5_route_design"
set name_chkp_impl5     [lindex $argv 5]
set name_rpt_impl5      "impl5_route_design"
# vars bitstream
set name_run_bit        "run_bitstream"
set name_bitstream      [lindex $argv 6]
set name_rpt_bit        "bitstream"

# ----- PATHS for RTL, TB, constraints, binaries, reports, DCPs, logs
set dir_rtl             "${prj_dir}/rtl"
set dir_ip_srcs         "${prj_dir}/ip"
set dir_constraint      "${prj_dir}/constraints"
set dir_bin             "bin"
set dir_rpt             "${dir_bin}/reports"
set dir_chkp            "${dir_bin}/checkpoints"
set dir_logs            "${dir_bin}/logs"
set dir_testbench       "${dir_bin}/testbench"

# * create in memory project
# set fpga
set_part ${fpga_part_name}
# set board
set_property board_part ${board_part_name} [current_project]

# * set max threads for implementation phases 1-8
set_param general.maxThreads 8


# create output dir
if {![file isdirectory $dir_rpt]} {
    file mkdir -p $dir_rpt
    print_blue "\nDirectory created: $dir_rpt"
} else {
    print_blue "\nDirectory already exists: $dir_rpt"
}
# create checkpoints dir
if {![file isdirectory $dir_chkp]} {
    file mkdir -p $dir_chkp
    print_blue "\nDirectory created: $dir_chkp"
} else {
    print_blue "\nDirectory already exists: $dir_chkp"
}
# create logs dir
if {![file isdirectory $dir_logs]} {
    file mkdir -p $dir_logs
    print_blue "\nDirectory created: $dir_logs"
} else {
    print_blue "\nDirectory already exists: $dir_logs"
}
# create testbench dir
if {![file isdirectory $dir_testbench]} {
    file mkdir -p $dir_testbench
    print_blue "\nDirectory created: $dir_testbench"
} else {
    print_blue "\nDirectory already exists: $dir_testbench"
}

set_param messaging.defaultLimit 100
set msg_limit [get_param messaging.defaultLimit]
print_blue "\nMessages default limit: $msg_limit"

# read VHDL RTL files
print_yellow "reading VHDL rtl files"
set vhdl_files [glob -directory $dir_rtl -types f -join *.vhd]
read_vhdl -library xil_defaultlib -vhdl2008 -verbose $vhdl_files

# read constraint files
print_yellow "reading constraint file/s"
print_blue "reading constraint sources for Basys3"
# read_xdc ${dir_constraint}/io_basys3.xdc
read_xdc ${dir_constraint}/io_nexys_a7_100t.xdc

# set top module RTL
print_yellow "setting top module RTL and updating compilation order"
set_property top ${top_module_rtl} [current_fileset]

# update and report compilation order of RTL files
print_yellow "update_compile_order sources_1"
update_compile_order -fileset sources_1
print_yellow "report_compile_order sources_1"
report_compile_order -fileset sources_1

# print IP status for .xci files
print_yellow "print IP status for .xci files"
report_ip_status


# synthesis
print_yellow "running synthesis"
synth_design -name ${name_run_synth} -top ${top_module_rtl} -part ${fpga_part_name} -flatten_hierarchy rebuilt
print_yellow "writing checkpoint: ${name_chkp_synth}"
write_checkpoint -force ${dir_chkp}/${name_chkp_synth}.dcp

# opt_design
print_yellow "running implementation phase: opt_design"
# opt_design -directive Default -verbose -debug_log
opt_design -aggressive_remap -resynth_remap -verbose -debug_log
print_yellow "writing checkpoint: ${name_chkp_impl1}"
write_checkpoint -force ${dir_chkp}/${name_chkp_impl1}.dcp

# power_opt_design
print_yellow "running implementation phase: power_opt_design"
power_opt_design -verbose
print_yellow "writing checkpoint: ${name_chkp_impl2}"
write_checkpoint -force ${dir_chkp}/${name_chkp_impl2}.dcp

# place_design
print_yellow "running implementation phase: place_design"
# place_design -directive Default -verbose -debug_log
place_design -directive Auto_1 -verbose -debug_log
print_yellow "writing checkpoint: ${name_chkp_impl3}"
write_checkpoint -force ${dir_chkp}/${name_chkp_impl3}.dcp

# phys_opt_design
print_yellow "running implementation phase: phys_opt_design"
phys_opt_design -directive Default -verbose
print_yellow "writing checkpoint: ${name_chkp_impl4}"
write_checkpoint -force ${dir_chkp}/${name_chkp_impl4}.dcp

# route_design
print_yellow "running implementation phase: route_design"
# route_design -directive Default -tns_cleanup -verbose
route_design -directive AggressiveExplore -tns_cleanup -timing_summary -verbose
print_yellow "writing checkpoint: ${name_chkp_impl5}"
write_checkpoint -force ${dir_chkp}/${name_chkp_impl5}.dcp

print_blue "writing report_timing_summary"
report_timing_summary -check_timing_verbose -delay_type min_max -max_paths 10 -report_unconstrained -input_pins -routable_nets -file ${dir_rpt}/${name_rpt_impl5}_timing_summary.rpt
print_blue "writing report_methodology"
report_methodology -file ${dir_rpt}/${name_rpt_impl5}_methodology.rpt
print_blue "writing report_drc"
report_drc -ruledecks {default opt_checks placer_checks router_checks bitstream_checks incr_eco_checks eco_checks abs_checks} -file ${dir_rpt}/${name_rpt_impl5}_drc.rpt
print_blue "writing report_route_status"
report_route_status -show_all -file ${dir_rpt}/${name_rpt_impl5}_route_status.rpt
print_blue "writing report_utilization -hierarchical"
report_utilization -hierarchical -file ${dir_rpt}/${name_rpt_impl5}_utilization_hierarchical.rpt

# bitstream
print_yellow "generating bitstream"
# compress bitstream generation
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force -verbose ${prj_dir}/${name_bitstream}.bit


# copy current log generated to logs folder
file copy -force [file join $prj_dir vivado.log] [file join $dir_logs "vivado_${current_datetime}.log"]
print_blue "Log file copied to: [file join $dir_logs "vivado_${current_datetime}.log"]"

