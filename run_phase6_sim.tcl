# run_phase6_sim.tcl
open_project riscv_pipeline_offline/riscv_pipeline_offline.xpr
update_compile_order -fileset sim_1
set_property top tb_phase6 [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1
launch_simulation
run 3 ms
