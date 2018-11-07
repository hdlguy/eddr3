# Script to compile the FPGA with zynq processor system all the way to bit file.
close_project -quiet
open_project proj.xpr

update_compile_order -fileset sources_1

reset_run synth_1
launch_runs synth_1 -jobs 6
wait_on_run synth_1
open_run synth_1
report_drc                  -file ./results/post_synth_drc.rpt

launch_runs impl_1 -to_step route_design -jobs 6
wait_on_run impl_1

open_run impl_1

write_checkpoint -force ./results/post_route.dcp

write_debug_probes -force ./results/ila1.ltx
report_timing_summary       -file ./results/post_route_timing_summary.rpt
report_utilization          -file ./results/post_route_util.rpt

set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property BITSTREAM.Config.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

write_bitstream -verbose -force ./results/top.bit

close_project

write_cfgmem -force -format MCS -size 256 -interface SPIx4 -loadbit "up 0x0 ./results/top.bit" -verbose ./results/top.mcs

