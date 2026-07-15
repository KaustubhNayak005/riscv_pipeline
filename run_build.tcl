# =============================================================================
# run_build.tcl  —  Full flow: synthesis → implementation → bitstream
# Run from repo root:  vivado -mode batch -source run_build.tcl
# All file references are relative; no hardcoded paths.
# =============================================================================

set xpr_path "riscv_pipeline_offline/riscv_pipeline_offline.xpr"

if {![file exists $xpr_path]} {
    puts "No .xpr found — running create_project.tcl first"
    source [file join [file dirname [info script]] create_project.tcl]
} else {
    open_project $xpr_path
}

# ---------- Synthesis -------------------------------------------------------
reset_run  synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1

if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    puts "ERROR: SYNTHESIS FAILED"
    exit 1
}
puts "SYNTHESIS COMPLETE"

# ---------- Implementation --------------------------------------------------
launch_runs impl_1 -jobs 4
wait_on_run impl_1

if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    puts "ERROR: IMPLEMENTATION FAILED"
    exit 1
}
puts "IMPLEMENTATION COMPLETE"

# ---------- Reports ---------------------------------------------------------
open_run impl_1
report_timing_summary -file riscv_pipeline_offline/timing_report.txt
report_utilization    -file riscv_pipeline_offline/utilization_report.txt

puts "BUILD SUCCESS"
exit
