#! /usr/bin/julia
#! /mnt/d/p/Julia/juliaLinux/bin/julia
#PATH=/mnt/d/p/Julia/juliaLinux/bin:$PATH
using Statistics
using Printf
using Dates
Base.MainInclude.include("./RawFileofflineProc/BaseLib.jl")
# Base.MainInclude.include("RawFileofflineProc/interface.jl") # 如果需要适配不同的算法来分析相应文件，需要修改 intrface.jl 中包含的算法库
Base.MainInclude.include("./fileFind/filesfind.jl")
Base.MainInclude.include( "./RawFileofflineProc/ReadFiberData.jl")

Base.MainInclude.include( "./AlarmAnalyssys/AlarmPro/C01-RAW3AlgEntryRT.jl")
#####################Cfgs ##################################################
fileRawDataChannel = Channel(300)
rootdir = "../tem/cTemdata"

# rootdir = "\\tem\\cTemdata\\" #windows
rootdir = "./cTemdata" # linux

dt= "20190212"
startTime = dt * "131813"
endTime   =   dt * "134826"
startTime = ""
endTime   =  ""
##################### ##################################################

Base.@ccallable function julia_main1(ARGS::Vector{String})::Cint
    global fileRawDataChannel 
    fileRawDataChannel = Channel(300)
    baseGlbPath = pwd()
    println( "Curpath is: ",baseGlbPath )

    # Name = getStringFromArray( fdobj.machineName )
    # baseGlbPath= replace(baseGlbPath,"\\"=>"/")
    # evs ="cfgRootfolder =\"$baseGlbPath\""
    # reps = Base.Meta.parse( evs )
    # Core.eval( Main,reps )

    # Name = getStringFromArray( fdobj.machineName )
    # evs ="machineName =\"$Name\""
    # reps = Base.Meta.parse( evs )
    # Core.eval( Main,reps )
 
    # println( "Curpath is: ",Main.cfgRootfolder )
    cfgFilename =joinpath(baseGlbPath,"../Jl-Aux/glbCfg/OfflineAnaCfg.jl")
    @warn "cfg file is: ",cfgFilename
    Main.getCfg(cfgFilename)

    rootdir=Main.rootdir
    @warn rootdir
    startTime=  Main.startTime
    endTime = Main.endTime
    # println(rootdir)
    # files = Main.findAllFiles(rootdir,".RAW3",startTime,endTime)
    # println("Total File Num is :",length(files) )
    # @async Main.readinPTFiles(files )
    @warn "------RAW3AlgEntryC01--------cur time is :", Dates.now()
    Main.SegParaAlarmProc.RAW3AlgEntryC01(false) ##Offline
    @warn "---------------------cur time is :", Dates.now()
    return 0
end 
Base.@ccallable function julia_main_2(ARGS::Vector{String})::Cint
    global fileRawDataChannel 
    fileRawDataChannel = Channel(300)
    baseGlbPath = pwd()
    println( baseGlbPath )
    Main.getCfg("../Jl-Aux/glbCfg/OfflineAnaCfg.jl")
    #Main.baseGlbPath = pwd()
    #println( Main.baseGlbPath)
    # println(@__DIR__ )
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

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    try
        return julia_main1(ARGS)
    catch e
        print(e)
    end

end
