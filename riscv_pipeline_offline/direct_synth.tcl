# Direct synthesis — bypass broken run system
open_project riscv_pipeline_offline.xpr

# Add Phase 12 RTL to sources
add_files -fileset sources_1 -norecurse {
  riscv_pipeline_offline.srcs/sources_1/imports/src/btn_sw.sv
  riscv_pipeline_offline.srcs/sources_1/imports/src/led_ctrl.sv
  riscv_pipeline_offline.srcs/sources_1/imports/src/pwm.sv
}

# Remove stale DCP reference if present
set stale [get_files -quiet -all riscv_pipeline_offline.srcs/utils_1/imports/synth_1/fpga_top.dcp]
if {[llength $stale] > 0} { remove_files $stale }

update_compile_order -fileset sources_1

puts "Running synth_design ..."
synth_design -top fpga_top -part xc7z020clg400-1 -flatten_hierarchy none
puts "Synthesis complete."
exit
