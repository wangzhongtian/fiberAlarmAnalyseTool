include("../fileFind/filesfind.jl")
include("../RawFileofflineProc/ReadFiberData.jl")
# using Base.write
include("baseTransferLib.jl")
###########################################################

# endtime = ""
function transFiles(rootdir,startTIme, endtime )
    println()
    files = findAllFiles(rootdir,".conf",startTIme,endtime)
    for t in files
        println( t )
    end
    confgfilename = files[1]
    println( "Selected config file: ",confgfilename )
    println()

    files = findAllFiles(rootdir,".energy",startTIme,endtime)
    transferfiles( files,confgfilename,".RAW4" )
    
    files = findAllFiles(rootdir,".LC",startTIme,endtime)
    transferfiles( files,confgfilename,".RAW3" )
    
    println()
    files = findAllFiles(rootdir,".RAW",startTIme,endtime)
    transferfiles( files,confgfilename,".RAW1" )
end
 