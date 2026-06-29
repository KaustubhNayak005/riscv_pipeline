open_project riscv_pipeline_offline.xpr
# Delete the stale synth run that references a missing DCP
delete_run synth_1
# Create a fresh synthesis run
create_run synth_1 -flow {Vivado Synthesis 2025} -strategy {Vivado Synthesis Defaults} -constrset constrs_1
set_property part xc7z020clg400-1 [current_project]
launch_runs synth_1 -jobs 4
wait_on_run synth_1
exit
