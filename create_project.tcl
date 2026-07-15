# =============================================================================
# create_project.tcl
# Recreates the Vivado project from sources already on disk.
# Because all .sv / .xdc / .mem files live INSIDE riscv_pipeline_offline/,
# Vivado stores every path as $PPRDIR-relative — no absolute paths, ever.
#
# Usage (from repo root):
#   vivado -mode batch -source create_project.tcl
# Or in the Vivado Tcl Console after cd-ing to the repo root:
#   source create_project.tcl
# =============================================================================

set script_dir [file normalize [file dirname [info script]]]
set proj_name  "riscv_pipeline_offline"
set proj_dir   [file join $script_dir $proj_name]
set srcs_root  [file join $proj_dir   "${proj_name}.srcs"]
set part       "xc7z020clg400-1"

# --------------------------------------------------------------------------
# 1. Create project  (-force wipes any stale .xpr / .cache in one shot)
# --------------------------------------------------------------------------
create_project $proj_name $proj_dir -part $part -force

set_property target_language  SystemVerilog [current_project]
set_property simulator_language Mixed        [current_project]
set_property default_lib       work          [current_project]

# --------------------------------------------------------------------------
# 2. RTL sources
#    Vivado imports mean the .sv files are already inside .srcs/; they will
#    be recorded as $PPRDIR-relative — portable across clones and renames.
# --------------------------------------------------------------------------
set src_dir [file join $srcs_root "sources_1" "imports" "src"]

if {![file isdirectory $src_dir]} {
    error "RTL source directory not found:\n  $src_dir\nVerify that .sv files exist under riscv_pipeline_offline/riscv_pipeline_offline.srcs/sources_1/imports/src/"
}

set sv_files [lsort [glob -nocomplain [file join $src_dir "*.sv"]]]
if {[llength $sv_files] == 0} {
    error "No .sv files found in $src_dir"
}

add_files -norecurse $sv_files
set_property file_type {SystemVerilog} [get_files *.sv]
update_compile_order -fileset sources_1

# --------------------------------------------------------------------------
# 3. Design top
# --------------------------------------------------------------------------
set_property top fpga_top [get_filesets sources_1]

# --------------------------------------------------------------------------
# 4. Constraints  (searches both canonical locations)
# --------------------------------------------------------------------------
set xdc_candidates [list \
    [file join $srcs_root "constrs_1" "imports" "constraints"] \
    [file join $srcs_root "constrs_1" "new"                  ] \
]

set found_xdc 0
foreach xdc_dir $xdc_candidates {
    if {[file isdirectory $xdc_dir]} {
        set xdc_files [glob -nocomplain [file join $xdc_dir "*.xdc"]]
        if {[llength $xdc_files] > 0} {
            add_files -fileset constrs_1 -norecurse $xdc_files
            puts "Constraints: added [llength $xdc_files] .xdc file(s) from [file tail $xdc_dir]"
            set found_xdc 1
            break
        }
    }
}
if {!$found_xdc} {
    puts "WARNING: No .xdc constraint files found — add them later via add_files -fileset constrs_1"
}

# --------------------------------------------------------------------------
# 5. Simulation / testbench files
# --------------------------------------------------------------------------
set sim_dir [file join $srcs_root "sim_1" "imports" "sim"]

if {[file isdirectory $sim_dir]} {
    set tb_files [lsort [glob -nocomplain [file join $sim_dir "tb_*.sv"]]]
    if {[llength $tb_files] > 0} {
        add_files -fileset sim_1 -norecurse $tb_files
        # Default sim top to the most recent phase testbench
        set latest_tb [lindex $tb_files end]
        set tb_name   [file rootname [file tail $latest_tb]]
        set_property top $tb_name [get_filesets sim_1]
        puts "Simulation:  added [llength $tb_files] testbench(es); default top = $tb_name"
    }
}

# --------------------------------------------------------------------------
# 6. Run strategies
# --------------------------------------------------------------------------
set_property strategy "Vivado Synthesis Defaults"           [get_runs synth_1]
set_property strategy "Performance_ExplorePostRoutePhysOpt" [get_runs impl_1]

# --------------------------------------------------------------------------
# 7. Summary
# --------------------------------------------------------------------------
puts ""
puts "============================================================"
puts " Project :  ${proj_dir}/${proj_name}.xpr"
puts " Part    :  $part"
puts " RTL     :  [llength $sv_files] .sv files"
puts " Top     :  fpga_top"
puts " Paths   :  all stored as \$PPRDIR-relative"
puts "============================================================"
puts " Next:"
puts "   source run_synthesis.tcl   ; # synthesis only"
puts "   source run_build.tcl       ; # full build + bitstream"
puts "============================================================"
