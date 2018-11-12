# This script sets up a Vivado project with all ip references resolved.
close_project -quiet
file delete -force proj.xpr *.os *.jou *.log implement/* proj.srcs proj.cache proj.runs proj.sim proj.hw proj.ip_user_files ip
#
create_project -force proj 
#set_property board_part xilinx.com:kcu105:part0:1.3 [current_project]
set_property board_part xilinx.com:vc707:part0:1.3 [current_project]
set_property target_language Verilog [current_project]
set_property default_lib work [current_project]
#load_features ipintegrator
#tclapp::install ultrafast -quiet

# read in ip cores
#read_ip ../source/buf_capture/buf_capt_ila/buf_capt_ila.xci

#catch {upgrade_ip [get_ips *]}
#generate_target {all} [get_ips *]

# Recreate the Block Diagram of the processor system.
#source ../source/system.tcl
#generate_target {synthesis implementation} [get_files ./proj.srcs/sources_1/bd/system/system.bd]
#set_property synth_checkpoint_mode None [get_files ./proj.srcs/sources_1/bd/system/system.bd]
#write_hwdef -force  -file ./results/top.hdf

# Read in the hdl source.
read_verilog -sv ../source/mmcm_tb.sv

#read_xdc  ../source/top.xdc
#read_xdc ../source/top_late.xdc
#set_property used_in_synthesis false [get_files ../source/top_late.xdc]

close_project




