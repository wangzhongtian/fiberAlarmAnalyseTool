using Printf
using Dates

# const WindThreshold=800
# const windSpaceMin = 500#meters
# const windIdStartPos = 0#meters
# const aboveThresholdPercent= 50

# const WindingChangeTimeMaxInterval = 2 #seconds

# const windAlarmSwitchONMinTIME = 1*60/2
# const windAlarmSwitchOFFMinTIME = 1*60/2

const baseDatetime ="20170211"*"000000"
include("../../common/windLogLst.jl")  


# println(Base.@__MODULE__ )
include("../../common/common.jl")
# curpath = pwd()

# jlPath =joinpath(curpath ,"../Jl-Aux/glbCfg/WindIDCfg.jl")

# getCfg( Base.@__MODULE__,jlPath)
# println("\n",windAlarmSwitchOFFMinTIME,"\n")
mutable struct Analsys
    
    SegID1::UInt
    SegID2::UInt
    
    AvgValue::UInt

    L0Status::Bool
    L0time::UInt

    L1Status::Bool
    L1time::UInt

    L2Status::Bool
    L2time::UInt

    final_Status::Bool
    final_time::UInt # the new Alarm Start Time
    Last_finalTime::UInt ## Last Alarm start TIme
    Switched ::Bool
    function Analsys()
        new()
    end
end

function l0_handle(aobj::Analsys ,dt::String, reatime_eventOn::Bool ,avg::UInt )
    aobj.AvgValue= avg
    aobj.L0Status = reatime_eventOn
    curtime =  DT2UInt( dt ) 
    if aobj.L0time == UInt( 0 )
        # println( "-----",aobj.L0time ," DT:",dt )
        aobj.L0time = curtime
        aobj.L1time = curtime
        aobj.L2time = curtime
        aobj.final_time = curtime
        # exit(-1)
    else
        # println( "---Not Zero  --",aobj.L0time ," DT:",dt )
        aobj.L0time = curtime
        # exit(1)
    end
#    println( curtime ," ,,", aobj.final_time)
end

function l1_handle(aobj::Analsys ) 
    if aobj.L1Status  != aobj.L0Status
        aobj.L1time = aobj.L0time 
        aobj.L1Status  = aobj.L0Status
    end
end

function l2_handle(aobj::Analsys ) 
    L1_persistTime =  aobj.L0time -aobj.L1time 
    if L1_persistTime > WindingChangeTimeMaxInterval
        if  aobj.L2Status != aobj.L1Status
            aobj.L2Status = aobj.L1Status
            aobj.L2time  = aobj.L1time  
        end
    end
end

function final_handle(aobj::Analsys ) 
    L2_persistTime =  aobj.L0time - aobj.L2time 
    if   true == aobj.L2Status  && L2_persistTime > windAlarmSwitchONMinTIME
        if aobj.final_Status != aobj.L2Status
            aobj.final_Status = aobj.L2Status
            aobj.Last_finalTime = aobj.final_time
            aobj.final_time = aobj.L2time
            aobj.Switched =true
            return 
        end
    end

    if  false == aobj.L2Status  && L2_persistTime > windAlarmSwitchOFFMinTIME
        if aobj.final_Status != aobj.L2Status
            aobj.final_Status = aobj.L2Status
            aobj.Last_finalTime = aobj.final_time
            aobj.final_time = aobj.L2time
            aobj.Switched = true
            return 
        end
    end 
    aobj.Switched = false
end

function init(  aObj::Analsys)
    # aObj.chnID =0
    aObj.SegID1=aObj.SegID2 =0x00;
    # dtValue=0;
    aObj.AvgValue =0;
    aObj.L0Status=false
    aObj.L0time=0

    aObj.L1Status=false
    aObj.L1time=0

    aObj.L2Status=false
    aObj.L2time=0

    aObj.final_Status=false
    aObj.final_time=0

    Switched =false
end

# global SpaceSegs = []#::Array{UInt,1}
# global WindAlarmSegs = []#::Array{Analsys,1  }

function init!(SpaceSegs,mertersPerSeg::Float64 ,beginID::UInt16,endID::UInt16 )
    println( "windSpaceMin=$windSpaceMin")
    step = floor(Int,windSpaceMin/mertersPerSeg)
    start = floor(Int,windIdStartPos/mertersPerSeg) +beginID
    maxSegID = min(  floor(Int,50*1000/mertersPerSeg)  , endID)

    for pos = start : step : maxSegID
        append!(SpaceSegs,[ pos,min(pos+step, maxSegID) ] )
    end
    #  println(start , " :",step," :",maxSegID ," ---:",beginID, " ",endID)
end

function init!(WindAlarmSegs,SpaceSegs )
    for idx = 1: 2 : length(SpaceSegs )
        aobj = Analsys()
        init(  aobj )
        aobj.SegID1 = SpaceSegs[idx]
        aobj.SegID2 = SpaceSegs[idx+1]    
        # println( ":",SpaceSegs[idx]," --  ",SpaceSegs[idx+1]  )##############
        append!(WindAlarmSegs,[aobj])
    end
end


function isin( es1::UInt ,es2::UInt  ,a )
    len1 = length(a)
    for i = 1: len1
        aobj = a[i]
        as1 = aobj.SegID1
        as2 = aobj.SegID2
        inrng = ( es2 >= as1 && es2 <= as2 ) ||
            ( es1 >= as1 && es1 <= as2 ) ||
            (es1 < as1 && es2 > as2 )
        if inrng == true
            isWind = aobj.final_Status  ### 获取大风的状态，final_Status
            return isWind 
        end
    end
    println( es1," ~ ",es2," not found winding on ")
    return false
end

function isinWindRng(es1::UInt ,es2::UInt  )
    if  es1 >= CalChn2Obj.startID || es2 >= CalChn2Obj.startID
        # println("Chnid =2 ",CalChn2Obj.startID)
        return isin( es1,es2, CalChn2Obj.WindAlarmSegs )
    else
        # println("Chnid =1")
        return isin( es1,es2, CalChn1Obj.WindAlarmSegs ) 
    end
end
function isinWindRng_1(es1::UInt ,es2::UInt  )
    inwind = isin( es1,es2, CalChn1Obj.WindAlarmSegs ) 
    if inwind == nothing  ## 未发现该区段
         inwind = isin( es1,es2, CalChn2Obj.WindAlarmSegs )
         if inwind == nothing 
                 return false 
         else
                return false
         end

    else
        return inwind
    end
end

################################################


function showAlarmWindingSwitch(winding::Analsys )
    # return 
    if winding.Switched == true 
        persisttime = winding.L0time -  winding.final_time 
        if winding.final_Status == 1
            windStr = "1"
        else
            windStr = "0"
        end
        dtstr = UInt2DTStr( winding.L0time ) 
        info1 = @sprintf( "%llu,ID=%04u:%04u,EventFirsttime：%llu,L0time:%s, Winding: %s\r\n",
        winding.L0time,winding.SegID1,winding.SegID2,
           winding.final_time, dtstr, windStr)
        fileLog_wind.LogEvent(info1);

    end
end

const title1 = "curtime,SegRange,Winding,StartTime,EndTime,LastingTime,CurDateTime\r\n"



function showAlarmWinding(winding::Analsys )
    # return 
    persisttime =winding.L0time -  winding.final_time 
    @printf( "From ID:%04u,To ID:%04u,time:%s,L0time：%s,persistTIme:%llu,Winding:%u\n",
    winding.SegID1,winding.SegID2,
        UInt2DTStr(winding.final_time), UInt2DTStr( winding.L0time ), persisttime,winding.final_Status)
end

function showAlarmWinding(winding::Analsys )
    # return 
    persisttime =winding.L0time -  winding.final_time 
    @printf( "From ID:%04u,To ID:%04u,time:%s,L0time：%s,persistTIme:%llu,Winding:%u\n",
    winding.SegID1,winding.SegID2,
        UInt2DTStr(winding.final_time), UInt2DTStr( winding.L0time ), persisttime,winding.final_Status)
end

function showAlarmWindingL1(winding::Analsys )
    # return 
    persisttime =winding.L0time -  winding.L1time 
    @printf( "From ID:%04u,To ID:%04u,time:%s,persistTIme:%llu,Winding:%u\n",
    winding.SegID1,winding.SegID2,
        UInt2DTStr(winding.L1time), persisttime,winding.L1Status)
end

function showAlarmWindingL2(winding::Analsys )
    # return 
    persisttime =winding.L0time -  winding.L2time 
    @printf( "From ID:%04u,To ID:%04u,time:%s,persistTIme:%llu,Winding:%u\n",
    winding.SegID1,winding.SegID2,
        UInt2DTStr(winding.L2time), persisttime,winding.L2Status)
end
function updateWinding(aobj::Analsys,curDTStr::String,reatime_eventOn::Bool ,curAvgValue::UInt  )
    l0_handle( aobj ,curDTStr, reatime_eventOn ,curAvgValue )
    l1_handle( aobj   )
    l2_handle( aobj   )
    final_handle( aobj )
    showAlarmWindingSwitch(aobj )
    return
    # showAlarmWinding( aobj )  
    # println( winding.isWind ,"---$(winding.status)-----------$(winding.lastOntime)---------------")
end

function FeatureAnal(a ,windingObject ,dt)
    cnt =0
    val =0
    segNum = length( a )
    for val0 in a 
        val+=  val0 
        if val0  > WindThreshold
            cnt +=1
            end
    end
    # avg=0
    # ratio=10
    # try
        avg = floor( UInt,val / segNum )
        ratio = floor( UInt32,cnt / (1*segNum) *100 ) 
    # return
    
    # print(  UInt(avg) ," ,",ratio ,"---")
    if (ratio > aboveThresholdPercent)
        updateWinding(windingObject , dt , true ,UInt(avg) )
        # return true 
    else
        updateWinding(windingObject ,dt , false ,UInt(avg)  )
        # return false;
    end

end

