# =============================================================================
# run_synthesis.tcl  —  Synthesis only
# Run from repo root:  vivado -mode batch -source run_synthesis.tcl
# All file references are relative; no hardcoded paths.
# =============================================================================

set xpr_path "riscv_pipeline_offline/riscv_pipeline_offline.xpr"

if {![file exists $xpr_path]} {
    puts "No .xpr found — running create_project.tcl first"
    source [file join [file dirname [info script]] create_project.tcl]
} else {
    open_project $xpr_path
}

set_property top fpga_top [current_fileset]

reset_run  synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1

if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    puts "ERROR: SYNTHESIS FAILED"
    exit 1
}
puts "SYNTHESIS COMPLETE"
