#!/bin/tclsh

source ./scripts/color_func.tcl -notrace


set prj_dir             [pwd]
set prj_name            "basys3_vga_frame_buffer"
set dir_ip_srcs         "${prj_dir}/ip"
set dir_image_srcs      "${prj_dir}/images"
set coe_file            "${dir_image_srcs}/mona_lisa_monochrome.coe"
set name_ip_blk         "macro_bram_sdp_monalisa_monochrome_1bit"

print_yellow "creating IP block: $name_ip_blk"
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name ${name_ip_blk}

print_blue "setting properties: $name_ip_blk"
set_property -dict [list \
    CONFIG.Component_Name $name_ip_blk \
    CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
    CONFIG.Write_Width_A {8} \
    CONFIG.Write_Depth_A {200000} \
    CONFIG.Read_Width_A {8} \
    CONFIG.Operating_Mode_A {NO_CHANGE} \
    CONFIG.Write_Width_B {8} \
    CONFIG.Read_Width_B {8} \
    CONFIG.Enable_B {Use_ENB_Pin} \
    CONFIG.Load_Init_File {true} \
    CONFIG.Coe_File $coe_file \
    CONFIG.Fill_Remaining_Memory_Locations {true} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
    CONFIG.Port_B_Clock {100} \
    CONFIG.Port_B_Enable_Rate {100} \
] [get_ips $name_ip_blk]

if {![file isdirectory $dir_ip_srcs]} {
    file mkdir -p $dir_ip_srcs
    print_blue "\nDirectory created: $dir_ip_srcs"
} else {
    print_blue "\nDirectory already exists: $dir_ip_srcs"
}

generate_target all [get_files $prj_dir/$prj_name/$prj_name.srcs/sources_1/ip/$name_ip_blk/$name_ip_blk.xci]
catch { config_ip_cache -export [get_ips -all $name_ip_blk] }
export_ip_user_files -of_objects [get_files ./$prj_name/$prj_name.srcs/sources_1/ip/$name_ip_blk/$name_ip_blk.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$prj_name/$prj_name.srcs/sources_1/ip/$name_ip_blk/$name_ip_blk.xci]
file copy ./$prj_name/$prj_name.srcs/sources_1/ip/$name_ip_blk/$name_ip_blk.xci $dir_ip_srcs/$name_ip_blk.xci
