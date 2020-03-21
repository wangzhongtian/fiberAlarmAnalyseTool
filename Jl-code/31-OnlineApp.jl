# my_julia_main.jl 
# include("my_code.jl") 
using Sockets
using Dates
using Base.Filesystem
using Libdl

#hsa121345
# # Base.MainInclude.
# ghDLLRawProc = Libdl.dlopen("RawProc.dll") 
Base.include(Main, "RawFileofflineProc/BaseLib.jl")

Base.MainInclude.include( "./RawFileofflineProc/ReadFiberData.jl")
Base.MainInclude.include( "./AlarmAnalyssys/AlarmPro/C01-RAW3AlgEntryRT.jl")
fileRawDataChannel = nothing


Base.@ccallable function julia_main(ARGS::Vector{String})::Cint 
    # @warn "hello"
   # return 0;
    global  fileRawDataChannel
    # ghDLLRawProc = Libdl.dlopen("RawProc.dll")
    Main.dllLoad( ) # baseLib.jl
    # Name = ghDLLRawProc
    # # baseGlbPath= replace(baseGlbPath,"\\"=>"/")
    # evs ="ghDLLRawProc = Libdl.dlopen(\"RawProc.dll\")"
    # reps = Base.Meta.parse( evs )
    # Core.eval( Main,reps )


    fileRawDataChannel = Channel(300)
    curpath = pwd()

    # println("::::--",curpath ," $ghDLLRawProc, $(Main.ghDLLRawProc)")
    # println("}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}")
    cfgfile = joinpath(curpath,"../Jl-Aux/glbCfg/baseCfg.jl")
    Main.getCfg( cfgfile )

    cfgObj = Main.cfgObj
    println()
    needFlowControl1 = 0 
    try
    needFlowControl1 = ENV["NeedFlowControl"]
    catch
    end
    if needFlowControl1 == 0 
        needFlowControl = false
    else
        needFlowControl = true
    end

    @async ClearExpiredFiles(cfgObj.RAW1MaxSpace, cfgObj.RAW2MaxSpace, cfgObj.RAW3MaxSpace, cfgObj.RAW4MaxSpace,cfgObj.Unit,cfgObj.folderA , cfgObj.folderB)
    while true
        try
            println("++++++++++++Init begin ")
            Main.Init(cfgObj.needSaveFile,cfgObj.needJuliaSend ,cfgObj.Logfolder,  cfgObj.folderA, cfgObj.folderB,needFlowControl)
            println("++++++++++++Init Ok")
            Main.InitIPAddressSvr(cfgObj.IpStr,cfgObj.Port ) ;
            println("++++++++++++InitIPAddressSvr Ok")
            Main.StartupMainThread()
            println("++++++++++++StartupMainThread Ok")
        catch(e)
            println("Exception: -------Init Svr Error :",e)
            break
        end

        try
            Main.SegParaAlarmProc.RAW3AlgEntryC01(true)
        catch(e)
            println("Exception: --------- Socket Receive data Error :",e)
            break
        end

        sleep(20)
    end
    return 0;
end 
# exit()
