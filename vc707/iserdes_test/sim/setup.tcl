# This script sets up a Vivado project
close_project -quiet
file delete -force proj.xpr *.os *.jou *.log implement/* proj.srcs proj.cache proj.runs proj.sim proj.hw proj.ip_user_files ip
#
create_project -force proj 
set_property board_part xilinx.com:vc707:part0:1.3 [current_project]
set_property target_language Verilog [current_project]
set_property default_lib work [current_project]

read_verilog -sv ../iserdes_tb.sv

add_files -fileset sim_1 -norecurse ./iserdes_tb_behav.wcfg

set_property -name {xsim.elaborate.debug_level} -value {all} -objects [current_fileset -simset]
set_property -name {xsim.simulate.runtime} -value {1000ns} -objects [current_fileset -simset]

close_project




