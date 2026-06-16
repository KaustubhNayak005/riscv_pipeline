set script_dir [file dirname [info script]]

# Only open the project if no project is currently open
if {[current_project -quiet] eq ""} {
    open_project $script_dir/riscv_pipeline_offline/riscv_pipeline_offline.xpr
}

# Add the new BHT files in case they aren't added yet
add_files -quiet -norecurse $script_dir/riscv_pipeline_offline/riscv_pipeline_offline.srcs/sources_1/imports/src/bht.sv
add_files -quiet -fileset sim_1 -norecurse $script_dir/riscv_pipeline_offline/riscv_pipeline_offline.srcs/sim_1/imports/sim/tb_bht.sv
update_compile_order -fileset sources_1

# Setup Simulation
set_property top tb_c_program [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

# Set the memory initialization parameter
set_property -name {xsim.simulate.xsim.more_options} -value "-testplusarg PROGRAM_MEM=$script_dir/sw/benchmark.mem" -objects [get_filesets sim_1]

launch_simulation
run 3 ms
