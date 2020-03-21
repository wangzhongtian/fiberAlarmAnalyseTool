#! /usr/bin/bash
# export JULIA_NUM_THREADS=4
while true ;do
    date >> svrrun.log
    julia  ../Jl-code/TestSvrBaseLib.jl

    date >> svrrun.log
    sleep 6
done




