# Clean synthesis run - uses project sources directly
open_project riscv_pipeline_offline.xpr

# Check what source files the project actually has
puts "=== Source files ==="
set all_src [get_files -of_objects [get_filesets sources_1]]
foreach f $all_src { puts "  SRC: $f" }

puts "=== Constraint files ==="
set all_xdc [get_files -of_objects [get_filesets constrs_1]]
foreach f $all_xdc { puts "  XDC: $f" }

puts "=== Sim files ==="
set all_sim [get_files -of_objects [get_filesets sim_1]]
foreach f $all_sim { puts "  SIM: $f" }

exit
