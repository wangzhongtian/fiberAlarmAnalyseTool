export JULIA_NUM_THREADS=$1
echo $JULIA_NUM_THREADS
cd  ../execs

while true ;do
    date >> run.log
    ./31-OnlineApp
    sleep 10
    date >> run.log
done
cd build
