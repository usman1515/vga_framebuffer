#!/bin/tclsh

# Link: https://docs.amd.com/r/2021.2-English/ug895-vivado-system-level-design-entry/Creating-a-Project-Using-a-Tcl-Script
# Typical usage: vivado -mode tcl -source ./scripts/setup_prj_nexys_a7_100t.tcl

source ./scripts/color_func.tcl -notrace

# set project name and FPGA (Nexys A7 100T)
set prj_name "nexysa7_vga_frame_buffer"
set part "xc7a100tcsg324-1"
set board_part "digilentinc.com:nexys-a7-100t:part0:1.0"

# set language
set tb_lang "VHDL"
set rtl_lang "VHDL"
set default_lib "xil_defaultlib"

# for synthesis and implementation purposes
set top_module_rtl "top_square_vga"
# for testbench simulation purposes only
set top_module_tb "TOP_TB"

# create a new project
set prj_dir "./${prj_name}"
print_yellow "creating new project: ${prj_name}"
create_project -force $prj_name $prj_dir -part $part

# set the project parameters
print_yellow "setting project parameters"
set_property board_part $board_part [current_project]
set_property default_lib $default_lib [current_project]
set_property target_language $rtl_lang [current_project]
set_property simulator_language $tb_lang [current_project]

# add xilinx IP blocks
print_yellow "adding IP blocks"
# add_files -norecurse ./ip/xlnx_clk_gen_basys3_25mhz.xci
source ./scripts/create_macro_bram_sdp_ram_v1.tcl -notrace
source ./scripts/create_macro_bram_sdp_ram_v2.tcl -notrace

# add VHDL rtl source files to the project
print_yellow "adding RTL source files"
add_files -force -fileset sources_1 {
    ./rtl/rtl_components.vhd \
    ./rtl/macro_clk_xlnx.vhd \
    ./rtl/simple_vga.vhd \
    ./rtl/top_square_vga.vhd \
    ./rtl/top_ansi_color_palette_vga.vhd \
    ./rtl/top_color_gradient_vga.vhd \
    ./rtl/display_480p.vhd \
    ./rtl/top_framebuffer_david_monochrome_1bit.vhd \
    ./rtl/top_framebuffer_monalisa_monochrome_1bit.vhd \

    ./rtl/clut_color.vhd \
    ./rtl/clut_grayscale.vhd \

    ./rtl/top_framebuffer_smpte_color_bars_monochrome.vhd \
    ./rtl/ram_sdp_smpte_colorbars_monochrome.vhd \
    ./rtl/ram_init_smpte_color_bars_monochrome.vhd \

    ./rtl/top_framebuffer_smpte_color_bars_grayscale.vhd \
    ./rtl/ram_sdp_smpte_colorbars_grayscale.vhd \
    ./rtl/ram_init_smpte_color_bars_grayscale.vhd \

    ./rtl/top_framebuffer_smpte_color_bars_tty16.vhd \
    ./rtl/ram_sdp_smpte_colorbars_tty16.vhd \
    ./rtl/ram_init_smpte_color_bars_tty16.vhd
}

    # ./rtl/top_framebuffer_phillips_pm5544_1bit.vhd \
    # ./rtl/ram_sdp_phillips_pm5544_1bit.vhd \
    # ./rtl/ram_init_phillips_pm5544_depth1.vhd \

# convert all VHDL files to VHDL 2008 standard
print_yellow "converting all VHDL files to VHDL 2008 standard"
foreach file [get_files -filter {FILE_TYPE == VHDL}] {
    set_property file_type {VHDL 2008} $file
}

# add TB source files to the project
print_yellow "adding TB source files"
# add_files -force -fileset sim_1 {
#     ./tb/tb.sv
# }

# convert all VHDL files to VHDL 2008 standard
foreach file [get_files -filter {FILE_TYPE == VHDL}] {
    set_property file_type {VHDL 2008} $file
}

# set RTL top module - for design and implementation purposes
print_yellow "setting RTL top module"
set_property top ${top_module_rtl} [current_fileset]
# set TB top module - for testbench simulation purposes
print_yellow "setting TB top module"
set_property top ${top_module_tb} [current_fileset]

# add constraint files to the project
print_yellow "adding constraint files for IO, timing, etc"
# top level IO constraints
add_files -fileset constrs_1 ./constraints/io_nexys_a7_100t.xdc

# update to set top and file compile order
print_yellow "update compilation order"
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
update_compile_order -fileset constrs_1

# report compilation order
print_yellow "report compilation order"
report_compile_order -fileset sources_1
report_compile_order -fileset sim_1
report_compile_order -fileset constrs_1

# close the project
close_project

