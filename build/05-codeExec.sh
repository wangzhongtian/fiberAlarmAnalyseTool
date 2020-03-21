
export JULIA_NUM_THREADS=$1
echo $JULIA_NUM_THREADS




.   ./setEnv.sh
echo $LD_LIBRARY_PATH
exitPAth=$PWD
# export JULIA_NUM_THREADS=$1
# echo $JULIA_NUM_THREADS
cd  bin/Jl-code
LOGFILE=../../run.log
while true ;do
    date >> $LOGFILE
    julia  31-OnlineClient.jl
    #sleep 10
    date >> $LOGFILE
    break
done
cd $exitPAth