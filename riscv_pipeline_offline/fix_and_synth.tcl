# Fix synthesis by adding missing Phase 12 sources and removing stale .dcp
open_project riscv_pipeline_offline.xpr

# 1) Add Phase 12 RTL files to sources_1 fileset (currently only in sim_1)
puts "Adding Phase 12 peripheral RTL to sources_1..."
add_files -fileset sources_1 -norecurse {
  riscv_pipeline_offline.srcs/sources_1/imports/src/btn_sw.sv
  riscv_pipeline_offline.srcs/sources_1/imports/src/led_ctrl.sv
  riscv_pipeline_offline.srcs/sources_1/imports/src/pwm.sv
}

# 2) Remove the stale .dcp reference from the project
set stale_dcp [get_files -quiet riscv_pipeline_offline.srcs/utils_1/imports/synth_1/fpga_top.dcp]
if {[llength $stale_dcp] > 0} {
  puts "Removing stale DCP reference..."
  remove_files $stale_dcp
}

# 3) Delete old broken synth_1 run and create fresh one
puts "Recreating synth_1 run..."
delete_run synth_1
create_run synth_1 -flow {Vivado Synthesis 2025} -strategy {Vivado Synthesis Defaults} -constrset constrs_1 -parent_run synth_1
set_property part xc7z020clg400-1 [current_project]

# 4) Launch synthesis
puts "Launching synthesis..."
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Report results
set status [get_property STATUS [get_runs synth_1]]
puts "Synthesis status: $status"
exit
