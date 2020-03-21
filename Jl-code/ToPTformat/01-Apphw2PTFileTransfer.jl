#CFg File : .\glbCfg\hw2PTCfg.jl
Base.MainInclude.include("../RawFileofflineProc/BaseLib.jl")
Base.MainInclude.include( "transfer.jl")
function getmachineID()
    return machineID
end


rootdir = "/home/share/"
machineID ="SJZ-004"
startTime = ""
endTime = ""


Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    #Main.getCfg("../Jl-Aux/glbCfg/hw2PTCfg.jl")
    # machineID = Main.machineID
    println( Main.rootdir,Main.startTime, Main.startTime)
    Main.transFiles(Main.rootdir,Main.startTime, Main.startTime )
    # exit(1)
    return 0;
end 
