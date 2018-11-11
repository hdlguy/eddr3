# This script sets up a Vivado project with all ip references resolved.
close_project -quiet
file delete -force proj.xpr *.os *.jou *.log proj.srcs proj.cache proj.runs
#
create_project -force proj 
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
set_property target_language Verilog [current_project]
set_property default_lib work [current_project]
load_features ipintegrator
tclapp::install ultrafast -quiet

file delete -force ./ip
file mkdir ./ip

#read_ip ../stim_bram_core/stim_bram_core.xci
#upgrade_ip -quiet  [get_ips *]
#generate_target {all} [get_ips *]

# Read in the hdl source.
#add_files -norecurse ../2048Mb_ddr3_parameters.vh
#add_files -norecurse ../8192Mb_ddr3_parameters.vh
#add_files -norecurse ../4096Mb_ddr3_parameters.vh 
add_files -norecurse ../1024Mb_ddr3_parameters.vh

read_verilog  -sv ../ddr3.v
read_verilog  ../tb.v

add_files -fileset sim_1 -norecurse ./tb_behav.wcfg

close_project


