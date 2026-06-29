# Re-run synthesis after led fix
open_project riscv_pipeline_offline.xpr

# Remove stale DCP if still there
set stale [get_files -quiet -all riscv_pipeline_offline.srcs/utils_1/imports/synth_1/fpga_top.dcp]
if {[llength $stale] > 0} { remove_files $stale }

update_compile_order -fileset sources_1

puts "Running synth_design (clean)..."
synth_design -top fpga_top -part xc7z020clg400-1 -flatten_hierarchy none
puts "Synthesis complete."
exit
