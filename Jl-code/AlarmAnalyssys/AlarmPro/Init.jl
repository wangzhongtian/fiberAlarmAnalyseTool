##########################
using Base.Threads
mutable struct timeAnalsys
    frameCnt::UInt
    segID::Int
    staticTh ::Int
    DynTh::Int
    AvgValue::UInt

    L0Status::Bool
    L0time::UInt
    L0Frame::UInt

    L1Status::Bool
    L1time::UInt
    L1Frame::UInt

    L2Status::Bool
    L2time::UInt
    L2Frame::UInt

    L3Status::Bool
    L3time::UInt
    L3Frame::UInt

    L4Status::Bool
    L4time::UInt
    L4Frame::UInt

    final_Status::Bool
    final_time::UInt # the new Alarm Start Time
    Last_finalTime::UInt ## Last Alarm start TIme
    # Last_finalTimeFrame::UInt
    Switched ::Bool
    function timeAnalsys()
        new()
    end
end

function init(  aObj::timeAnalsys)::timeAnalsys
    # dtValue=0;
    aObj.segID =0
    aObj.staticTh =0
    aObj.DynTh = 0
    aObj.AvgValue =0;
    aObj.L0Status=false
    aObj.L0time=0
    aObj.L0Frame=0

    aObj.L1Status=false
    aObj.L1time=0
    aObj.L1Frame=0
    aObj.L2Status=false
    aObj.L2time=0
    aObj.L2Frame=0
    aObj.L3Status=false
    aObj.L3time=0
    aObj.L3Frame=0    
    aObj.L4Status=false
    aObj.L4time=0
    aObj.L4Frame=0
    aObj.final_Status=false
    aObj.final_time=0

    Switched =false
    return aObj
end

##########################################
mutable struct spaceAnalsys
    AvgValue::UInt

    L0Status::Bool
    L0Seg::UInt

    L1Status::Bool
    L1Seg::UInt

    L2Status::Bool
    L2Seg::UInt

    final_Status::Bool
    final_Seg::UInt # the new Alarm Start Time
    Last_finalSeg::UInt ## Last Alarm start TIme
    Switched ::Bool
    function spaceAnalsys()
        new()
    end
end

function init(  aObj::spaceAnalsys)::spaceAnalsys
    # dtValue=0;
    aObj.AvgValue =0;
    aObj.L0Status=false
    aObj.L0Seg=0

    aObj.L1Status=false
    aObj.L1Seg=0

    aObj.L2Status=false
    aObj.L2Seg=0

    aObj.final_Status=false
    aObj.final_Seg=0

    Switched =false
    return aObj
end

#glbSegAlarmParasDictObj = Dict() #NamedTuple 
glbSegAlarmParasDictObj = Array{NamedTuple}(undef,8193) # 
AlarmStaticStatus = nothing
AlarmDynStatus = nothing
curAlarmsinSEG = nothing
const glbAlarmParasdictLock=SpinLock()
#=
 保存经过空间合并、过滤处理后的空间每段上的报警。
=#

#############################
function INIT( cfgObj  )
    global glbSegAlarmParasDictObj ,curAlarmsinSEG,AlarmStaticStatus, AlarmDynStatus #, glbFrameCnt
    # glbSegAlarmParasDictObj =  
    # initAlarmSegparas!(glbSegAlarmParasDictObj)  #Dict
    Name = Main.machineName
    # println("Machine name is $Name,-----")
    # println( Name," ",  cfgObj.meterperSeg ," ", Int(cfgObj.chn2SegBegIdx-1)," ", Int(cfgObj.chn2SegBegIdx)," ", Int(cfgObj.SegNumber) )

  ParaDIctobj = MainCfgPara(machine友好名0 = Main.machineName, metersPerSeg1 = cfgObj.meterperSeg ,
            timeUnit1 = 0.426,Chn1Seg1 = 1,Chn1Seg2 = Int(cfgObj.chn2SegBegIdx-1), 
            Chn2Seg1 = Int(cfgObj.chn2SegBegIdx), Chn2Seg2 = Int(cfgObj.SegNumber) ) ## 读入配置文件 。CSV中的分段报警参数，并将标牌坐标转换成Seg坐标，将时间、距离的国际坐标转换成内部用的 Seg、0.426 单位
    println( " Read in the Machine's Alarm para and name to Regular ID ok--------------------------------")

 


    initAlarmSegparas!(glbSegAlarmParasDictObj ,ParaDIctobj )   ## 导入到内部的坐标中
    # initAlarmSegparas1!(glbSegAlarmParasDictObj ,ParaDIctobj )   ## 导入到内部的坐标中
    # showSegDictData(glbSegAlarmParasDictObj)

    curAlarmsinSEG  = Array{timeAnalsys,1 }( undef,cfgObj.SegNumber) # time history for per Segment
    for idx = 1: length( curAlarmsinSEG )
        curAlarmsinSEG[ idx ] = init( timeAnalsys() )
        curAlarmsinSEG[idx].segID    = idx
        curAlarmsinSEG[idx].staticTh = typemax(Int ) #
        # curAlarmsinSEG[idx].staticTh =  getSegStaticThPara(glbSegAlarmParasDictObj,idx )
        # curAlarmsinSEG[idx].DynTh    =  typemax(Int ) # getSegStaticThPara(glbSegAlarmParasDictObj,idx)
    end
  AlarmStaticStatus = Array{Bool,1 }( undef,cfgObj.SegNumber) 
  AlarmDynStatus = Array{Bool,1 }( undef,cfgObj.SegNumber) 
end
