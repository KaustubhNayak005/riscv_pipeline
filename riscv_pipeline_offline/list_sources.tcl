open_project riscv_pipeline_offline.xpr
set src_files [get_files -filter {IS_ENABLED == 1 && USED_IN == {synthesis}}]
foreach f $src_files { puts $f }
exit
