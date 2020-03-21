pushd ../b

$env:NeedFlowControl=1
$env:JULIA_NUM_THREADS=2
$env:EXEFOLDER=Resolve-Path "$PSScriptRoot/"
echo $env:JULIA_NUM_THREADS

$exist=test-path -path ../dataroot
if ( ! $exist ) {
        new-item -path ../dataroot   -ItemType directory
}

$exist=test-path -path ../log
if ( ! $exist ) {
        new-item -path ../log   -ItemType directory
}
$envs=$env:LD_LIBRARY_PATH
write-host $envs
if  (    ! $envs.contains("../Jl-Aux/dll" ) ) {
	$env:LD_LIBRARY_PATH="$env:LD_LIBRARY_PATH", "../Jl-Aux/dll"  -join ":"
}else{
    write-host "already contain the folder DLL"
}
$LOGFILE="../../run.log"

for(;;) {
    date >> $LOGFILE
    julia  ../Jl-code/31-OnlineClient.jl 
   echo "Julia Prog exited out "
    date >> $LOGFILE
    sleep 20
  break
}

popd
