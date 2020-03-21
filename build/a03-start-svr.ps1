pushd ../b
out-host -inputobject $PSScriptRoot
$xroot= $MyInvocation.MyCommand.Definition
out-host -inputobject $xroot
$xroot=$PSScriptRoot
$env:fileReg="Data^Ver00^SJZ-004^20191117041823^ID00.RAW3"
$env:fileReg="Data^Ver00^GYYS-001^20190304230109^ID00.RAW3"
#$env:fileReg="Data^Ver00^GYYS-001^20190212131313^ID00.RAW3"
#$env:fileReg="Data^Ver00^GYYS-001^20191126033756^ID00.RAW3"

$env:fileReg="current.RAW3"
$env:baseFolder=Resolve-Path "$xroot/../sjz004/"
#$env:baseFolder=Resolve-Path "$xroot/../sjz004/高邑元氏20191126/"
out-host -inputobject $env:baseFolder 
$env:PT_ServerIP="0.0.0.0"
$env:PT_ServerPort="19998"
$env:SLEEPSeconds=330
# $env:JULIA_NUM_THREADS=4
# echo $env:JULIA_NUM_THREADS


$envs=$env:LD_LIBRARY_PATH
write-host $envs
if  (    ! $envs.contains("../Jl-Aux/dll" ) ) {
	$env:LD_LIBRARY_PATH="$env:LD_LIBRARY_PATH", "../Jl-Aux/dll"  -join ":"
}else{
    write-host "already contain the folder DLL"
}
$LOGFILE="../../svrrun.log"
for(;;) {
    date >> $LOGFILE
    julia  ../Jl-code/TestSvrBaseLib.jl
    date >> $LOGFILE
    break
    sleep 10
}
