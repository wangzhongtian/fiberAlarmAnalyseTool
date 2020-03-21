$env:JULIA_NUM_THREADS=4
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

$env:LD_LIBRARY_PATH="$env:LD_LIBRARY_PATH", "../Jl-Aux/dll"  -join ":"
$LOGFILE="../../run.log"
for(;;) {
    date >> $LOGFILE
    julia  ../Jl-code/31-OnlineClient.jl 
    date >> $LOGFILE
    sleep 20
}