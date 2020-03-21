# set JULIA_NUM_THREADS=8
using Base.Threads
using Printf
using Dates
fout = open("test.log","w")
flock = Threads.SpinLock()
idxlock = Threads.SpinLock()
glbidx  =1 
function getIdxGlb( )
global glbidx 
    i=0
    lock( idxlock )
    i = glbidx 
    glbidx = glbidx +1
    unlock( idxlock )
    return i
end

function writefile( fout,id ,flock)
    lock(flock )
    a=Dates.now()
    b=string(hour(a),":",minute(a),":",second(a),".",millisecond(a) )
    strTest = @sprintf( "%06d,%u,%06d,%18s\r\n",id,Threads.threadid(),getIdxGlb(),b )
    write(fout, strTest )
    unlock( flock )
end
@threads for idx = 1:100000
    writefile( fout,idx ,flock)
end
close(fout)
