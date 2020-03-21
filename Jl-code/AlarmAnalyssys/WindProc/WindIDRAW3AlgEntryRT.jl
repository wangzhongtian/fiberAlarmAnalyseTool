module  WindID
using Statistics
using Printf
#External Alg Libray :
# AlfFileFolder="../AlarmAnalyssys/RAW3Alg-RTWind20190417/" #
# Base.MainInclude.include( "$(AlfFileFolder)cumSumAlg.jl")
# Base.MainInclude.include( "$(AlfFileFolder)AlarmGen.jl")
# Base.MainInclude.include( "$(AlfFileFolder)C01-RAW3AlgEntryRT.jl" )

include("../../RawFileofflineProc/BaseLib.jl")
##internal Use Libaray
# Base.include(Main, "ReadFiberData.jl")
include("../../RawFileofflineProc/dataStruct.jl")
# Base.MainInclude.
include( "../../RawFileofflineProc/ReadFiberData.jl")
# Base.MainInclude.
include("../../RawFileofflineProc/ConfigFileLib.jl")
# Base.MainInclude.
include("cumSumAlg.jl")
# Base.MainInclude.
include("AlarmGen.jl")

# @warn "OK？？？？？"
lastWriteDT= UInt(0)
# cfgObj = cfgStruct()
CalChn1Obj = spaceCumSumData( ) 
CalChn2Obj = spaceCumSumData( ) 
function Init( cfgObj )
    curpath = pwd()
    jlPath =joinpath(curpath ,"../Jl-Aux/glbCfg/WindIDCfg.jl")
    getCfg( Base.@__MODULE__,jlPath)
    # println("\n",windAlarmSwitchOFFMinTIME,"\n")

    InitObj(CalChn1Obj, Int(1),Int(cfgObj.chn2SegBegIdx-1), Int(1),Int(cfgObj.chn2SegBegIdx-1),-1 );
    InitObj(CalChn2Obj, Int(cfgObj.chn2SegBegIdx),Int( 8192) ,Int(cfgObj.chn2SegBegIdx), Int(8192),-1 );   
    CalChn1Obj.CfgInfoObj = cfgObj
    CalChn2Obj.CfgInfoObj = cfgObj
end
function WindProc(row,startDTStr,machineName)
    global lastWriteDT

    # a = String(startDTStr)
    # @warn  startDTStr,String(machineName) ,"-------->Wind------"
    CalChn1Obj.dt = startDTStr
    CalChn2Obj.dt = startDTStr
    # Name = getStringFromArray( machineName )
    # evs ="machineName =\"$Name\""
    # reps = Base.Meta.parse( evs )
    # Core.eval(Main,reps )
    postProcFeatureData(CalChn2Obj ,row ) #include("AlarmGen.jl")
    postProcFeatureData(CalChn1Obj ,row ) #include("AlarmGen.jl") 
    curDt = DT2UInt( startDTStr )
    a1 = showCurDT2File(lastWriteDT, curDt)
    a1 != 0 ?  lastWriteDT = UInt( a1 ) : 0 ;
end
end