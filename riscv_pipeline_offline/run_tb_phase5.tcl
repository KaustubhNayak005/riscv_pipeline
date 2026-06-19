open_project riscv_pipeline_offline.xpr
set_property top tb_phase5 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse {riscv_pipeline_offline.srcs/sim_1/imports/sim/tb_phase5.sv}
update_compile_order -fileset sim_1
launch_simulation -simset sim_1 -mode behavioral
run all
exit
