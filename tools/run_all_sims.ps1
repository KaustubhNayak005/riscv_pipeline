$ErrorActionPreference = "Stop"
$vivado_bin = "C:\AMDDesignTools\2025.2\Vivado\bin"
$tests = @("tb_bht", "tb_phase5", "tb_phase6", "tb_phase9", "tb_c_program", "tb_top", "tb_fpga_top", "tb_memory_map")

Set-Location "C:\Users\sriji\projects\riscv32-processor\riscv_pipeline_offline\riscv_pipeline_offline.sim\sim_1\behav\xsim"

foreach ($tb in $tests) {
    Write-Host "============================================="
    Write-Host "Running $tb"
    Write-Host "============================================="
    
    $cmd_xvlog = "& `"$vivado_bin\xvlog.bat`" --incr --relax -L uvm -prj ${tb}_vlog.prj -log xvlog_${tb}.log"
    Write-Host $cmd_xvlog
    & "$vivado_bin\xvlog.bat" --incr --relax -L uvm -prj ${tb}_vlog.prj -log xvlog_${tb}.log
    
    $cmd_xelab = "& `"$vivado_bin\xelab.bat`" --incr --relax -L uvm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -s ${tb}_sim xil_defaultlib.${tb} xil_defaultlib.glbl -log xelab_${tb}.log"
    Write-Host $cmd_xelab
    & "$vivado_bin\xelab.bat" --incr --relax -L uvm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -s ${tb}_sim xil_defaultlib.${tb} xil_defaultlib.glbl -log xelab_${tb}.log

    $cmd_xsim = "& `"$vivado_bin\xsim.bat`" ${tb}_sim -R -log xsim_${tb}.log"
    Write-Host $cmd_xsim
    & "$vivado_bin\xsim.bat" ${tb}_sim -R -log xsim_${tb}.log
}

Write-Host "All simulations completed."
