# run_phase5_sim.tcl
open_project riscv_pipeline_offline/riscv_pipeline_offline.xpr
add_files -norecurse {
    riscv_pipeline_offline/riscv_pipeline_offline.srcs/sources_1/imports/src/csr_file.sv
    riscv_pipeline_offline/riscv_pipeline_offline.srcs/sources_1/imports/src/timer.sv
}
add_files -fileset sim_1 -norecurse {
    riscv_pipeline_offline/riscv_pipeline_offline.srcs/sim_1/imports/sim/tb_phase5.sv
    riscv_pipeline_offline/riscv_pipeline_offline.srcs/sim_1/imports/sim/tb_phase6.sv
}
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
set_property top tb_phase5 [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1
launch_simulation
run 3 ms
