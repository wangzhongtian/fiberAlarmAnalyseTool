
using Base.Threads

filesBuffer=Dict()
struct logfile
    fileLock::SpinLock 
    fileObj
    filename::String
    function logfile( name::String )
        global filesBuffer
        fileLock = SpinLock()
        fileObj = open( name,"w")
        filename =name
        new(fileLock,fileObj,filename  )
    end
end

function writeLog(logObj::logfile,str::String )
    lock(logObj.fileLock)
        print(logObj.fileObj,str )
        print(logObj.fileObj,"\r\n" )
        flush(logObj.fileObj )
    unlock(logObj.fileLock)
      @warn  str , Base.Threads.threadid()
end
