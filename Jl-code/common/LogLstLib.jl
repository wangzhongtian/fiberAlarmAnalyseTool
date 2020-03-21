using  Dates
using  Base.Threads
using  Printf
    function __GenFilename(typeStr::String,td::DateTime )
        curpath = abspath( pwd()* "/../") #"/../Jl-Aux/"
        minuts  =0;#Dates.minute(td)÷30 *30
        windStatuFileName = @sprintf("%s/log/%s-%s-%02d-%02d-%02d-%02d.lst",curpath,Main.machineName,typeStr,Dates.month(td), Dates.day(td),Dates.hour(td),Dates.minute(td) ) 
        #println(windStatuFileName);println();
        return windStatuFileName,Dates.hour(td)
    end    

    mutable struct __logfile
        fileLock::SpinLock 
        fileObj
        fileType::String
        switchTime::Int
        function __logfile( fileType1::String )
            # global filesBuffer
            fileLock = SpinLock()
            td1 = Dates.now()
            name,hour1 = __GenFilename(fileType1,td1)
            fileObj = open( name,"w")
            # fileType = fileType1
            switchTime = hour1
            new(fileLock,fileObj,fileType1,switchTime  )
        end
    end
    function __switchFile( logfileObj , td1 )
        close( logfileObj.fileObj)
        name,hour1 = __GenFilename(logfileObj.fileType,td1)
        logfileObj.fileObj = open( name,"w")
        # fileType = fileType1
        logfileObj.switchTime = Dates.hour(td1)
    end

    logfileObj = nothing

    function Init( fileType::String)
        global  logfileObj
        logfileObj= __logfile( fileType)
    end

    function LogEvent(info1)
        # return ;########### test only 
        td1 = Dates.now()
        lock(logfileObj.fileLock)
            if Dates.hour( td1 ) != logfileObj.switchTime 
                __switchFile( logfileObj , td1 )
            end
                # f1 = open( windStatuFileName,"a+")
            write( logfileObj.fileObj,info1 )
            flush(logfileObj.fileObj )
                # close( f1 )
            # @warn  info1 
        unlock(logfileObj.fileLock)

    end

