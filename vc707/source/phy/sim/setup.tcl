# This file sets up the simulation environment.
create_project -force proj 
set_property board_part em.avnet.com:microzed_7020:part0:1.1 [current_project]
set_property target_language Verilog [current_project]
set_property "default_lib" "work" [current_project]
create_fileset -simset simset

#read_ip ../sensor_rom/sensor_rom.xci
#generate_target {all} [get_ips *]

read_verilog -sv ../dram_io.sv
read_verilog -sv ../dram_io_tb.sv

current_fileset -simset [ get_filesets simset ]

set_property -name {xsim.elaborate.debug_level} -value {all} -objects [current_fileset -simset]
set_property -name {xsim.simulate.runtime} -value {1000ns} -objects [current_fileset -simset]

close_project


