# pushd ../b

$env:NeedFlowControl=1
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
$envs=$env:LD_LIBRARY_PATH
write-host $envs

$SelfDllFolder=Resolve-Path "../Jl-Aux/dll"
out-host  -inputobject $SelfDllFolder
if  (    ! $envs.contains($SelfDllFolder ) ) {
	$env:LD_LIBRARY_PATH="$env:LD_LIBRARY_PATH", "$SelfDllFolder"  -join ":"
}else{
    write-host "already contain the folder DLL"
}
$LOGFILE="run.log"


for(;;) {
    echo "startup MainProg" >> $LOGFILE
    date >> $LOGFILE
   # julia  ../Jl-code/31-OnlineClient.jl 
   ../exec/31-OnlineApp
   echo "Julia Prog exited out "
 echo "cmpleted MainProg" >> $LOGFILE
    date >> $LOGFILE

    sleep 20
    # break
}
