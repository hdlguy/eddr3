# This script sets up a Vivado project with all ip references resolved.
close_project -quiet
file delete -force proj.xpr *.os *.jou *.log proj.srcs proj.cache proj.runs
#
create_project -force proj 
set_property part xc7z030fbg484-2 [current_project]
set_property target_language Verilog [current_project]
set_property default_lib work [current_project]
load_features ipintegrator

#read_ip ../source/matinv_ram/matinv_ram.xci
#upgrade_ip -quiet  [get_ips *]
#generate_target {all} [get_ips *]

# Read in the hdl source.
read_verilog ../../util_modules/fifo_same_clock.v
read_verilog ../../util_modules/dly01_16.v
read_verilog ../../util_modules/fifo_cross_clocks.v
#read_verilog ../../phy/test_dqs04.v
read_verilog ../../phy/phy_top.v
read_verilog ../../phy/cmd_addr.v
#read_verilog ../../phy/test_dqs06.v
#read_verilog ../../phy/test_dqs01.v
read_verilog ../../phy/ddrc_sequencer.v
#read_verilog ../../phy/test_dqs03.v
#read_verilog ../../phy/test_dqs.v
read_verilog ../../phy/dq_single.v
#read_verilog ../../phy/dqs_single_nofine.v
read_verilog ../../phy/byte_lane.v
read_verilog ../../phy/dqs_single.v
#read_verilog ../../phy/test_dqs02.v
read_verilog ../../phy/dm_single.v
read_verilog ../../phy/cmda_single.v
read_verilog ../../phy/phy_cmd.v
#read_verilog ../../phy/test_dqs07.v
#read_verilog ../../phy/test_dqs05.v
read_verilog ../../ddrc_test01.v
#read_verilog ../../ddr3/ddr3.v
#read_verilog ../../simulation_modules/simul_axi_master_rdaddr.v
#read_verilog ../../simulation_modules/simul_axi_master_wraddr.v
#read_verilog ../../simulation_modules/simul_axi_fifo_out.v
#read_verilog ../../simulation_modules/simul_fifo.v
#read_verilog ../../simulation_modules/simul_axi_read.v
#read_verilog ../../simulation_modules/simul_axi_master_wdata.v
#read_verilog ../../simulation_modules/simul_axi_slow_ready.v
read_verilog ../../wrap/idelay_fine_pipe.v
#read_verilog ../../wrap/idelay_nofine.v
read_verilog ../../wrap/pll_base.v
read_verilog ../../wrap/idelay_ctrl.v
read_verilog ../../wrap/mmcm_phase_cntr.v
read_verilog ../../wrap/iserdes_mem.v
read_verilog ../../wrap/oddr_ds.v
read_verilog ../../wrap/oserdes_mem.v
#read_verilog ../../wrap/odelay_pipe.v
read_verilog ../../wrap/dci_reset.v
read_verilog ../../wrap/oddr.v
read_verilog ../../wrap/ram_1kx32w_512x64r.v
read_verilog ../../wrap/obuf.v
#read_verilog ../../wrap/mmcm_adv.v
read_verilog ../../wrap/ram_1kx32_1kx32.v
read_verilog ../../wrap/ram_512x64w_1kx32r.v
read_verilog ../../wrap/odelay_fine_pipe.v
read_verilog ../../ddrc_status.v
read_verilog ../../ddrc_control.v
#read_verilog ../../glbl.v
read_verilog ../../ddr_refresh.v
read_verilog ../../axi/axibram_read.v
#read_verilog ../../axi/macros393.v
#read_verilog ../../axi/axibram.v
read_verilog ../../axi/axibram_write.v

read_xdc ../../ddrc_test01.xdc

#set_property used_in_synthesis false [get_files ../source/top.xdc]

close_project

#########################

