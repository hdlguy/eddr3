# This script sets up a Vivado project with all ip references resolved.
close_project -quiet
file delete -force proj.xpr *.os *.jou *.log proj.srcs proj.cache proj.runs
#
create_project -force proj 
#set_property board_part xilinx.com:vc707:part0:1.3 [current_project]
set_property board_part xilinx.com:kcu105:part0:1.3 [current_project]
set_property target_language Verilog [current_project]
set_property default_lib work [current_project]
load_features ipintegrator

#read_ip ../source/matinv_ram/matinv_ram.xci
#upgrade_ip -quiet  [get_ips *]
#generate_target {all} [get_ips *]

# make the block diagram
source ../../source/vc707/system.tcl
generate_target {synthesis implementation} [get_files ./proj.srcs/sources_1/bd/system/system.bd]
set_property synth_checkpoint_mode None    [get_files ./proj.srcs/sources_1/bd/system/system.bd]

# Read in the hdl source.
read_verilog ../../util_modules/fifo_same_clock.v
read_verilog ../../util_modules/dly01_16.v
read_verilog ../../util_modules/fifo_cross_clocks.v
read_verilog ../../phy/phy_top.v
read_verilog ../../phy/cmd_addr.v
read_verilog ../../phy/ddrc_sequencer.v
read_verilog ../../phy/dq_single.v
read_verilog ../../phy/byte_lane.v
read_verilog ../../phy/dqs_single.v
read_verilog ../../phy/dm_single.v
read_verilog ../../phy/cmda_single.v
read_verilog ../../phy/phy_cmd.v
read_verilog ../../wrap/idelay_fine_pipe.v
read_verilog ../../wrap/pll_base.v
read_verilog ../../wrap/idelay_ctrl.v
read_verilog ../../wrap/mmcm_phase_cntr.v
read_verilog ../../wrap/iserdes_mem.v
read_verilog ../../wrap/oddr_ds.v
read_verilog ../../wrap/oserdes_mem.v
read_verilog ../../wrap/dci_reset.v
read_verilog ../../wrap/oddr.v
read_verilog ../../wrap/ram_1kx32w_512x64r.v
read_verilog ../../wrap/obuf.v
read_verilog ../../wrap/ram_1kx32_1kx32.v
read_verilog ../../wrap/ram_512x64w_1kx32r.v
read_verilog ../../wrap/odelay_fine_pipe.v
read_verilog ../../ddrc_status.v
read_verilog ../../ddrc_control.v
read_verilog ../../ddr_refresh.v
read_verilog ../../axi/axibram_read.v
read_verilog ../../axi/axibram_write.v

read_verilog -sv ../../source/vc707/top.sv

read_xdc ../../source/vc707/top.xdc

#set_property used_in_synthesis false [get_files ../source/top.xdc]

close_project

#########################

