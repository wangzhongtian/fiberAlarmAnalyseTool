#! /usr/bin/bash
# export JULIA_NUM_THREADS=4

$env:PT_ServerIP="0.0.0.0"
$env:PT_ServerPort="19998"
$env:fileReg="Data^Ver00^SJZ-004^20191117041823^ID00.RAW3"
$env:baseFolder="/home/wang/data/app/fiberproc/sjz004/"

while true ;do
    date >> svrrun.log
    julia  ../Jl-code/TestSvrBaseLib.jl

    date >> svrrun.log
    sleep 6
done




