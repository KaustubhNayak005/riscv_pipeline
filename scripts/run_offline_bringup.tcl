# Offline Vivado bring-up for the PYNQ Z2 RV32I pipeline demo.
# Run with:
# vivado -mode batch -source scripts/run_offline_bringup.tcl

set script_dir [file dirname [file normalize [info script]]]
set project_root [file normalize [file join $script_dir ..]]
set project_name riscv_pipeline_offline
set build_root [file normalize [file join $project_root build vivado_offline]]
set reports_dir [file join $build_root reports]
set part_name xc7z020clg400-1
set jobs 8

set vivado_bin ""
set vivado_bin_candidates {}
if {[info exists ::env(XILINX_VIVADO)]} {
    lappend vivado_bin_candidates [file normalize [file join $::env(XILINX_VIVADO) bin]]
}
lappend vivado_bin_candidates [file dirname [file normalize [info nameofexecutable]]]
lappend vivado_bin_candidates [file normalize [file join [file dirname [file normalize [info nameofexecutable]]] .. ..]]
foreach candidate $vivado_bin_candidates {
    if {[file exists [file join $candidate xvlog.bat]] || [file exists [file join $candidate xvlog.exe]]} {
        set vivado_bin $candidate
        break
    }
}
if {$vivado_bin eq ""} {
    error "Could not locate Vivado bin directory for xvlog/xelab/xsim"
}
if {[info exists ::env(Path)]} {
    set ::env(Path) "$vivado_bin;$::env(Path)"
}
if {[info exists ::env(PATH)]} {
    set ::env(PATH) "$vivado_bin;$::env(PATH)"
} else {
    set ::env(PATH) $vivado_bin
}
puts "INFO: Vivado bin: $vivado_bin"

proc find_logs {dir} {
    set logs {}
    foreach item [glob -nocomplain -directory $dir *] {
        if {[file isdirectory $item]} {
            lappend logs {*}[find_logs $item]
        } elseif {[string match *.log [file tail $item]]} {
            lappend logs $item
        }
    }
    return $logs
}

proc require_log_text {root pattern label} {
    foreach log_file [find_logs $root] {
        set fd [open $log_file r]
        set text [read $fd]
        close $fd
        if {[string first $pattern $text] >= 0} {
            puts "INFO: Found '$pattern' in $log_file"
            return
        }
    }
    error "$label did not print required text: $pattern"
}

proc require_run_ok {run_name} {
    set run_obj [get_runs $run_name]
    set status [get_property STATUS $run_obj]
    puts "INFO: $run_name status: $status"
    if {[regexp -nocase {error|fail|cancel} $status]} {
        error "$run_name did not complete successfully: $status"
    }
    if {![regexp -nocase {complete|finished} $status]} {
        error "$run_name ended in unexpected status: $status"
    }
}

proc run_batch_script {script_name} {
    puts "INFO: Running $script_name"
    if {[catch {exec cmd /d /c ".\\$script_name" 2>@1} output]} {
        puts $output
        error "$script_name failed"
    }
    puts $output
}

if {[file exists $build_root]} {
    file delete -force $build_root
}
file mkdir $build_root
file mkdir $reports_dir

puts "INFO: Project root: $project_root"
puts "INFO: Build root: $build_root"

create_project $project_name $build_root -part $part_name -force
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

set src_files [glob -nocomplain [file join $project_root src *.sv]]
if {[llength $src_files] == 0} {
    error "No SystemVerilog source files found under $project_root/src"
}
add_files -fileset sources_1 $src_files
foreach src_file $src_files {
    set_property file_type SystemVerilog [get_files [file normalize $src_file]]
}

set xdc_file [file join $project_root constraints pynq_z2.xdc]
add_files -fileset constrs_1 $xdc_file
set_property target_constrs_file [get_files [file normalize $xdc_file]] [get_filesets constrs_1]

set tb_file [file join $project_root sim tb_top.sv]
set program_mem [file normalize [file join $project_root mem program.mem]]
add_files -fileset sim_1 $tb_file
add_files -fileset sim_1 $program_mem
set_property file_type SystemVerilog [get_files [file normalize $tb_file]]

set_property top fpga_top [get_filesets sources_1]
set_property top tb_top [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "INFO: Running behavioral simulation..."
launch_simulation -simset sim_1 -mode behavioral -scripts_only
set sim_dir [file join $build_root ${project_name}.sim sim_1 behav xsim]
set sim_tcl [file join $sim_dir tb_top.tcl]
set fd [open $sim_tcl a]
puts $fd "quit"
close $fd
set old_dir [pwd]
cd $sim_dir
run_batch_script compile.bat
run_batch_script elaborate.bat
run_batch_script simulate.bat
cd $old_dir
require_log_text $build_root "ALL TESTS PASSED" "Behavioral simulation"

puts "INFO: Running synthesis..."
launch_runs synth_1 -jobs $jobs
wait_on_run synth_1
require_run_ok synth_1

puts "INFO: Running implementation and bitstream generation..."
launch_runs impl_1 -to_step write_bitstream -jobs $jobs
wait_on_run impl_1
require_run_ok impl_1

open_run impl_1
report_timing_summary -max_paths 10 -report_unconstrained -file [file join $reports_dir timing_summary.rpt]
report_utilization -file [file join $reports_dir utilization.rpt]
report_drc -file [file join $reports_dir drc.rpt]
report_power -file [file join $reports_dir power.rpt]
report_clocks -file [file join $reports_dir clocks.rpt]

set timing_paths [get_timing_paths -max_paths 1 -setup]
if {[llength $timing_paths] == 0} {
    error "No setup timing path was reported"
}
set wns [get_property SLACK [lindex $timing_paths 0]]
puts "INFO: Worst setup slack: $wns ns"
if {$wns < 0.0} {
    error "Implementation timing failed with WNS=$wns ns"
}

set bit_candidates [glob -nocomplain [file join $build_root ${project_name}.runs impl_1 *.bit]]
if {[llength $bit_candidates] == 0} {
    error "Bitstream was not generated"
}
puts "INFO: Bitstream: [lindex $bit_candidates 0]"
puts "INFO: Reports: $reports_dir"
puts "OFFLINE BRINGUP PASSED"

close_project
exit
