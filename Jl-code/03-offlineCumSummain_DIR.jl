# export JULIA_NUM_THREADS=4
# set  JULIA_NUM_THREADS=4 

# include("03-OfflineApp.jl")
using Statistics
using Printf
using Dates
Base.MainInclude.include("./RawFileofflineProc/BaseLib.jl")
# Base.MainInclude.include("RawFileofflineProc/interface.jl") # 如果需要适配不同的算法来分析相应文件，需要修改 intrface.jl 中包含的算法库
Base.MainInclude.include("./fileFind/filesfind.jl")
Base.MainInclude.include( "./RawFileofflineProc/ReadFiberData.jl")

include( "./AlarmAnalyssys/AlarmPro/C01-RAW3AlgEntryRT.jl")
Base.@ccallable function julia_main_1(ARGS::Vector{String})::Cint
    # Main.getCfg(ARGS[1])
    # Main.baseGlbPath = pwd()
    # println( Main.baseGlbPath)
    println(@__DIR__ )
    rootdir=Main.rootdir
    startTime=  Main.startTime
    endTime = Main.endTime
    println(rootdir)
    files = Main.findAllFiles(rootdir,".RAW3",startTime,endTime)
    println("Total File Num is :",length(files) )
    @async Main.readinPTFiles(files )
    # @warn "---------------------cur time is :", Dates.now()
    Main.SegParaAlarmProc.RAW3AlgEntryC01(false) ##Offline
    # @warn "---------------------cur time is :", Dates.now()

    return 0
end 


Base.@ccallable function julia_main1(ARGS::Vector{String})::Cint
    global fileRawDataChannel 
    fileRawDataChannel = Channel(300)
    baseGlbPath = pwd()
    println( "Curpath is: ",baseGlbPath )

    cfgFilename =joinpath(baseGlbPath,"../Jl-Aux/glbCfg/OfflineAnaCfg.jl")
    println("cfg file is: ",cfgFilename)
    Main.getCfg(cfgFilename)

    rootdir=Main.rootdir

    startTime=  Main.startTime
    endTime = Main.endTime
    println(rootdir)
    files = Main.findAllFiles(rootdir,".RAW3",startTime,endTime)
    println("Total File Num is :",length(files) )
    @async Main.readinPTFiles(files )
    # @warn "---------------------cur time is :", Dates.now()
    Main.SegParaAlarmProc.RAW3AlgEntryC01(false) ##Offline
    # @warn "---------------------cur time is :", Dates.now()
    return 0
end 

###############################################################################################
julia_main1([""]) 
exit()
fileRawDataChannel = Channel(300)

# rootdir = "/data/xxxx号机4月4日~5日数据/xxxx-001-0512下午-RAW3大风期间下午"
# dt= "20190212"
# startTime = dt * "131813"
# endTime   =   dt * "134826"
# startTime = ""
# endTime   =  ""
julia_main1([""]) 
