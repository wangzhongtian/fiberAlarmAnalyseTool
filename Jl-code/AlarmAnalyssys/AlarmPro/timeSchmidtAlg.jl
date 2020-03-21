
using Printf
using Dates
using Base.Threads
#=
    记录、更新当前的最新实时状态，并记录当前状态的时间；
    如果是第一次调用此函数，则更新Lxtime、final_time到当前时间。
=#
function l0_handle(aobj::timeAnalsys ,curtime, reatime_eventOn::Bool,FrameCnt::UInt )
    # curtime = UInt( DT2UInt( dt ) )

    aobj.AvgValue = 0
    aobj.L0Status = reatime_eventOn

    # curtime = DT2UInt( dt ) 
    if aobj.L0time == UInt( 0 )
        # println( "-----",aobj.L0time ," DT:",dt )
        aobj.L0time = curtime
        aobj.L1time = curtime
        aobj.L2time = curtime
        aobj.final_time = curtime
        # aobj.FrameCnt

        aobj.L1Frame=FrameCnt
        aobj.L2Frame=FrameCnt
        aobj.L3Frame=FrameCnt
        aobj.L4Frame=FrameCnt
        # exit(-1)
    else
        aobj.L0time = curtime
        aobj.L0Frame=FrameCnt
        # println( "---Not Zero  --",aobj.L0time ," DT:",dt )
        # exit(1)
    end
# println( curtime ," ,,", aobj.final_time)
end
#=
    如果L1的状态与L0状态不同，则更新L1时间到L0时间，并同步更新L1状态
    L1 时间用于做后续的L1~ Lx、final处理
=#
function l1_handle( aobj::timeAnalsys ) 
    if aobj.L1Status  != aobj.L0Status
        # @debug  aobj.L1Status ,aobj.L0time  ,"l1_handle"
        aobj.L1time = aobj.L0time 
        aobj.L1Status  = aobj.L0Status
        aobj.L1Frame=aobj.L0Frame
    end
end

#=
    处理Micro时间的过滤、合并。主要处理对象为 L1 => L2 
    合并： 指在告警(L2 ==  true)为真时，在之后的某段时间：
       如果非告警状态(L1 == false )连续持续时间小于该合并时间,则认为告警状态一直持续，
       如果持续时间超过该时间，则认为告警停止。
    过滤：告警(L2 ==  true)为 否 时，在之后的某段时间：
       如果非告警状态(L1 == 真 )连续持续时间 大于 该过滤时间,则认为告警状态需要更新为 真，
        否则就不改变原L2状态
=#
function l2_handle( aobj::timeAnalsys ) 
    MergetimePeriod ,filterPeriod = getSegMicroTimeParaValue(glbSegAlarmParasDictObj,aobj.segID)
    L1_persistTime =  aobj.L0Frame - aobj.L1Frame 
    # 
    if aobj.L1Status == true  && L1_persistTime  >= filterPeriod 
        if aobj.L2Status == true
            ;
        else  ## L2 状态转换
            aobj.L2Status = true  
            aobj.L2time   = aobj.L1time  
            aobj.L2Frame=aobj.L1Frame
            aobj.L3Status = false # 解除向下发展态势  L3 状态和时间 代表了 L1 向下发展的状态和开始时间，
        end
    end

    if aobj.L1Status == false  && aobj.L2Status  == true # 向下发展态势 L3 状态和时间 代表了 L1 向下发展的状态和开始时间，
        if  aobj.L3Status == false
            aobj.L3Status = true
            aobj.L3time = aobj.L1time
            aobj.L3Frame=aobj.L1Frame
        end
    end

    willDownLastingTime  = aobj.L0time -  aobj.L3time   #L3 状态和时间 代表了 L1 向下发展的状态和开始时间，
    if willDownLastingTime >= MergetimePeriod ## 不再等待 Merge
        if aobj.L2Status == true  && aobj.L1Status == false  ## L2 状态转换
            aobj.L2Status = false  
            aobj.L2time   = aobj.L3time  
            aobj.L2Frame=aobj.L3Frame
        end
    end
end

#=  l3_handle:
 虚拟处理
=#
function l3_handle( aobj::timeAnalsys ) 
     # L3 状态和时间 代表了 L1 向下发展的状态和开始时间，
end

function finalStatu( aobj::timeAnalsys ) ##
    aobj.final_Status = aobj.L4Status
    aobj.final_time = aobj.L4time
    # $(Main.machineName),$(aobj.segID), $(aobj.L0time), $(aobj.L4time) ,$( aobj.L4time-aobj.L0time ) 
end

function Alarmhappened( aobj::timeAnalsys  )
    finalStatu( aobj )
    if aobj.segID > 1 && aobj.segID < 4096
        # @info "AlarmOn,$(UInt2DTStr(aobj.L0time)),$(Main.machineName),$(aobj.L0Frame),$(aobj.segID), $(aobj.L0time), $(aobj.L2time) ,$( aobj.L0time-aobj.L2time ) "
    end
end
function AlarmStopped( aobj::timeAnalsys  )
    finalStatu( aobj )
    # @debug  "AlarmOff,$(Main.machineName),$(aobj.segID), $(aobj.L0time)"
    # exit(-1)
end
#=  l4_handle:
    处理Macro时间的处理。主要处理对象为 L3 => L4 
    对于L3 为告警状态的： 
        如果L3告警状态持续超过 最小告警时间 ，而且小于最大告警时间，才更新L4为告警状态。
        否则L4为无告警状态
    对于L3为 无告警状态的，实时将L4同步为L3状态。
=#
function l4_handle(aobj::timeAnalsys ) 
    L2_persistTime =  aobj.L0Frame -aobj.L2Frame 
    # aobj.L3Frame=aobj.L1Frame
    # @info L2_persistTime , aobj.L2Status, aobj.L4Status
    if aobj.L2Status == true  
        maxTimePeriod ,minTimePeriod = getSegMacroTimeParaValue(glbSegAlarmParasDictObj,aobj.segID)
        if L2_persistTime <  minTimePeriod
            # aobj.L4Status = false
            # aobj.L4time =  aobj.L0time
           # EventL1.ReportEventL1(UInt(aobj.segID),UInt(aobj.segID), aobj.final_time ,aobj.L0Frame ,"MacroTimeShort")
        elseif L2_persistTime  >= minTimePeriod && L2_persistTime <= maxTimePeriod &&  aobj.L4Status == false ## report the Alarm
                aobj.L4Status = true
                aobj.L4time =  aobj.L0time
                aobj.L4Frame =  aobj.L0Frame
                # L1Frame
                Alarmhappened( aobj  )
        elseif L2_persistTime > maxTimePeriod  && aobj.L4Status == true   ## cancel the Alarm 
            aobj.L4Status = false
            aobj.L4time   = aobj.L0time
            aobj.L4Frame =  aobj.L0Frame
            
            AlarmStopped( aobj)
        elseif L2_persistTime > maxTimePeriod
            EventL1.ReportEventL1(UInt(aobj.segID),UInt(aobj.segID), aobj.final_time,aobj.L0Frame ,"MacroTimeLong") 
        end
    else #L2Status == false  
        if aobj.L4Status == true  ## stop the Alarm
            aobj.L4Status = false
            aobj.L4time   = aobj.L0time
            aobj.L4Frame =  aobj.L0Frame
            AlarmStopped( aobj )
        end
    end
end

function updateStatus(aobj::timeAnalsys,curtime,reatime_eventOn::Bool,FrameCnt::UInt )
    # @info " reatime_eventOn ",reatime_eventOn ,curDTStr
    l0_handle( aobj ,curtime, reatime_eventOn ,FrameCnt )
    l1_handle( aobj )
    l2_handle( aobj )
    l3_handle( aobj )
    l4_handle( aobj )
end

function ShowtimeSchmidt( timeAnalsysObj,dt)
    if timeAnalsysObj.final_Status == true
        # @debug ( timeAnalsysObj.final_Status ,timeAnalsysObj.final_time , dt,timeAnalsysObj.segID)
    end
end

# function proloop1(AlarmDynStatus,curAlarmsinSEG,FrameCnt,curtime)
#     maxl=  length( AlarmDynStatus )
#      @threads for segID = 1 : maxl
#           reatime_eventOn  = AlarmDynStatus[ segID ] 
#         timeAnalsysObj   = curAlarmsinSEG[ segID ] 
#         updateStatus( timeAnalsysObj, curtime , reatime_eventOn,FrameCnt   )
#      end
#  end
 function subproloop2(AlarmDynStatus,curAlarmsinSEG,FrameCnt,curtime,rng)
        for segID = rng
            reatime_eventOn  = AlarmDynStatus[ segID ] 
            timeAnalsysObj   = curAlarmsinSEG[ segID ] 
            updateStatus( timeAnalsysObj, curtime , reatime_eventOn,FrameCnt   )
        end
 end
 function proloop2(AlarmDynStatus,curAlarmsinSEG,FrameCnt,curtime)
    maxl=  length( AlarmDynStatus )
    parCnt = 4-1;
    loopmax =floor( Int, maxl/parCnt)

#    println( " spawn loope in  proloop2 ")
    rng1=1:loopmax
     a1=Base.Threads.@spawn subproloop2(AlarmDynStatus,curAlarmsinSEG,FrameCnt,curtime,rng1)

     rng2=1+loopmax : 2*loopmax
     #rng2=1+loopmax : 1+loopmax 
     a2=Base.Threads.@spawn subproloop2(AlarmDynStatus,curAlarmsinSEG,FrameCnt,curtime,rng2) 

     rng3=1+loopmax*2:3*loopmax
     a3=Base.Threads.@spawn subproloop2(AlarmDynStatus,curAlarmsinSEG,FrameCnt,curtime,rng3) 
    if maxl  >= (1+loopmax*3)
        rng4=1+loopmax*3:maxl
        a4=Base.Threads.@spawn subproloop2(AlarmDynStatus,curAlarmsinSEG,FrameCnt,curtime,rng4) 
        wait(a4);
    end

    #println("-----------------",rng1 ," ---",rng2," ",rng3," ",rng4)
     wait(a1);
     wait(a2);
     wait(a3);

 end
function FeaturetimeSchmidt( dt , FrameCnt::UInt)
    # @info "Enter into FeaturetimeSchmidt"
    curtime = UInt( DT2UInt( dt ) )
   
    curAlarmsinSEG[ 1 ].L0Frame = FrameCnt
    curAlarmsinSEG[ 1 ].L0time  = curtime
    # println( " spawn loope in  proloop2 ")
    # @time
      proloop2(AlarmDynStatus,curAlarmsinSEG,FrameCnt,curtime)
    
end
