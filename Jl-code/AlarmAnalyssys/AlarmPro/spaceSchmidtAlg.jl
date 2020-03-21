
using Printf
using Dates
using Base.Threads

const ENDProc =UInt(0)
const MERGEDProc =UInt(1)
const TERMINATEDProc =UInt(2)
#=
 fffTffffffff TTTT fffff TTTTTTT ....
=#
#=
    按照空间 ，即光程从1 到光缆末端进行空间上的合并、过滤，超限处理检查。
    1、过滤： 在合并前，如果 连续告警的区域的空间长度小于 “过滤长度”，则认为该区域为 无效报警区域。
    2、合并： 在两个告警区域之间的 非报警区域 的长度，如果小于 合并间隔，则认为两个告警区域是联通的。
    3、告警的上下限： 在处理完告警的过滤、合并之后，如果连续的告警区域的长度不在 告警上下限之间，则认为属于无效告警。

    输入数据来自于 timeSchmidt的输出，即每段上的报警状态： curAlarmsinSEG,defined in init.jl
    告警参数配置来自于： glbSegAlarmParasDictObj
    输出数据保存在：
        NameTuple ( fiberSegID  ,t0Uint,persistTime)
        # CurAlarmsInSpace = Array{ NamedTupe, 1}
    简化实现：
    
=#
alarmTuple = NamedTuple{(:fiberSegID ,:t0Uint,:persistTime),Tuple{Int,UInt,UInt} }
historyAlarms = Dict{ UInt,alarmTuple} 

function getchn2BegID()
    return UInt( CalChn1_2Obj.CfgInfoObj.chn2SegBegIdx );
    # Chn2Seg2 = UInt(cfgObj.SegNumber) ) 
    # return 4097)
end
function getSegNUmbers()
    return UInt( CalChn1_2Obj.CfgInfoObj.SegNumber  )    #UInt(8192)
end
mutable struct AlarmPerSeg
    curdtUInt::UInt 
    curFrame::UInt
    chan2BegID::UInt
    SegNumbers::UInt
    alarmStatus_1::Array{Bool} 
    alarmStatus_2::Array{Bool} 
    function AlarmPerSeg()
        curdtUInt=UInt(0)
        chan2BegID = getchn2BegID() 
        SegNumbers = getSegNUmbers() 
        alarmStatus_1 = Array{Bool}(undef,SegNumbers)
        alarmStatus_1 .= false
        alarmStatus_2 = Array{Bool}(undef,SegNumbers)
        alarmStatus_2 .= false        
        new(curdtUInt,0,chan2BegID, SegNumbers,alarmStatus_1,alarmStatus_2 )
    end
end
SegAlarms = nothing 
function InitSegAlarms()
    global SegAlarms
    SegAlarms = AlarmPerSeg()
end
#=
    将报警状态拷贝到本段的缓冲中
=#
function l0_handle(  )
    SegAlarms.curdtUInt = curAlarmsinSEG[1].L0time
    SegAlarms.curFrame= curAlarmsinSEG[1].L0Frame
   
    for i = 1: length( curAlarmsinSEG )
        alr = curAlarmsinSEG[ i ]
        SegAlarms.alarmStatus_1[i] = alr.final_Status
    end
end

function getNextAlarmReg( nextSegAlrs,seg1::UInt,segEnd::UInt)
    s1=UInt(0)
    s2=UInt(0)
    s3=UInt(0)
    if  seg1 >= segEnd || seg1  == 0
        return (s1,s2,s3 )
    end
    for i::UInt = seg1 :segEnd
        isAlr = nextSegAlrs[i] 
        # @info isAlr,"-------"
        if isAlr == true 
            if s1 == UInt(0)
                s1 = i
                s2 = i
            else 
                s2 = i
            end
        end
        if s1 != 0 && isAlr == false # 找到了下一 连续告警区域的末端
            s3 = i 
            break
        end
    end
    # @info s1,s2 ,seg1 ,segEnd,"-----------------------------------"
    return (s1,s2,s3) # ( 入侵区域起点，入侵区域终点，下一探测区域的起点:0 表示结束了，其它表示有效的下标) 
end


#=
    进行过滤处理
    lastAlrSegReg 包括上一区域的起点、终点 SegID.

    如果本段的下一告警区域与 lastAlrSegReg相隔
        1 超过 合并间隔， 则认为上一区域的告警为一 独立告警区域，返回
            （ Merge = false,)+lastAlrSegReg
        2 未超过 合并间隔， 则认为上一区域的告警与本区域告警合并，返回
        （ Merge = true,)+lastAlrSegReg
    
=#
function l10_handle( s1::UInt,s2::UInt,s3::UInt,lastSegBeg,lastSegEnd ,mergeL0) 
    # 以下进行可否 合并 两个区域的计算。
    # 1、 如果 s0 处的 过滤长度，大于s2-s1,则进行过滤，不能合并。
    mergeL0,FilterL0 = getSegMicroSpaceParaValue( glbSegAlarmParasDictObj , Int(s1) )
        lastmergeL,lastFilterL = getSegMicroSpaceParaValue( glbSegAlarmParasDictObj , Int(lastSegEnd ) )
        intervalSegNum = s1 - lastSegEnd
        # 2、 如果 s0 处的 合并长度，或者 lastSegEnd 的合并长度，大于 两个段间的间隔，则可进行合并，返回合并后的区域。
        #    否则不能合并 
        if  intervalSegNum  < mergeL0 || intervalSegNum < lastmergeL 
            return ( MERGEDProc ,lastSegBeg , s2, s3 )
        else
            return ( TERMINATEDProc, lastSegBeg, lastSegEnd,s3 )
        end
end
function l1_handle( nextSegAlrs,seg1::UInt,segEnd::UInt,lastAlrSegReg::Tuple ) 
    lastSegEnd = lastAlrSegReg[2] # 上一区域的终点SegID。
    lastSegBeg =  lastAlrSegReg[1]
    while true 
        s1 , s2 , s3 = getNextAlarmReg( nextSegAlrs,seg1,segEnd)
        if s1 == 0  ### 处理结束，到达颗粒的末端了
            return (ENDProc ,lastAlrSegReg[1],lastAlrSegReg[2],s3 )
        end
        mergeL0,FilterL0 = getSegMicroSpaceParaValue( glbSegAlarmParasDictObj , Int(s1) )
        if s2-s1 > FilterL0 # 是一个连续的新报警区域
            if lastSegEnd == 0 || lastSegBeg == 0 # 一个全新的区域
            # 执行至此，已经找到了下一告警区域、或者已经遍历nextSegAlrs，但未找到发生报警区域。
                return ( MERGEDProc ,s1, s2, s3 )
            else
                return l10_handle(s1,s2,s3,lastSegBeg,lastSegEnd,mergeL0)
            end
        else
            seg1 = s3
            continue
        end
    end
    #  end
end


function AlarmRegAna( s_1::UInt ,s_2::UInt )
    maxWidth1 ,minWidth1 = getSegMacroSpaceParaValue(glbSegAlarmParasDictObj, Int( s_1)) 
    maxWidth2, minWidth2 = getSegMacroSpaceParaValue(glbSegAlarmParasDictObj, Int( s_2)) 
    minwidth = floor( UInt,(minWidth1+minWidth2) /2 )
    maxwidth = floor( UInt,(maxWidth1+maxWidth2) /2 )
    width = UInt(s_2 -s_1 +1)
    # @warn "$minwidth , $maxwidth $width" 
    if width >= minwidth &&  width <= maxwidth
        if true #WindID.isinWindRng(s_1,s_2  ) == false 
            AlarmMerge.mergeProc(s_1,s_2,SegAlarms.curdtUInt) ## 进行大尺度空间、时间合并，产生上报的报警
            EventL1.ReportEventL1(s_1,s_2, SegAlarms.curdtUInt,SegAlarms.curFrame ,"Windoff")
        else
            EventL1.ReportEventL1(s_1,s_2, SegAlarms.curdtUInt,SegAlarms.curFrame ,"Windon")
            @warn "filterted by wind : $s_1,$s_2"
        end
    else
        if width < minwidth 
            #EventL1.ReportEventL1(s_1,s_2, SegAlarms.curdtUInt,SegAlarms.curFrame ,"RNGNarrow")
        elseif width > maxwidth
            EventL1.ReportEventL1(s_1,s_2, SegAlarms.curdtUInt,SegAlarms.curFrame ,"RNGWide")
        end

    end
end
#=

=#
function l2_handle(segID0::UInt,SegID1::UInt ) 
    nextSegAlrs = SegAlarms.alarmStatus_1
    seg1 = UInt( segID0 )
    segEnd = UInt( SegID1 )
    # @info "$segEnd,-------------"
    # nextSegAlrs = alarms
    s_1 ,s_2 ,s_3  = getNextAlarmReg( nextSegAlrs,seg1,segEnd)
    s1 = s_1
    s2 = s_2
    seg1 =s_3
    if s1 == 0 && s2 == 0
        return  # 未见报警
    end
    doesMerged = TERMINATEDProc
    while true #开始处理过滤、合并
        # if s3 != 0 ## 到了末端，不需要 继续 
        # @info "$doesMerged ,$s_1 ,$s_2 ,$s_3 "
        doesMerged ,s_1 ,s_2 ,s_3 = l1_handle( nextSegAlrs,seg1,segEnd,(s1,s2) ) 
        # end 
        if doesMerged == ENDProc
            if  s_1 != 0
                AlarmRegAna( UInt(s_1) ,UInt(s_2) )
                break 
            elseif s_1 == 0
                break
            end
        elseif doesMerged == TERMINATEDProc  && s_1 != 0 ## 一个独立的报警区域已经识别到位，保存在s_1 S_2中
            AlarmRegAna( UInt(s_1) ,UInt(s_2) )
            # s1 = 0
            # s2 = 0
            if s_3 == 0
                break
            end
            seg1 =s_3
            s_1 ,s_2 ,s_3 = getNextAlarmReg( nextSegAlrs,seg1,segEnd)
            s1 = s_1
            s2 = s_2
            seg1 =s_3
            # @info doesMerged ,s_1 ,s_2 ,s_3 
        elseif doesMerged == MERGEDProc ## 已经合并了一个新区域，需要继续合并下一个区域
            s1 = s_1
            s2 = s_2
            seg1 = s_3
            # @info doesMerged ,s_1 ,s_2 ,s_3 
        end
    end
    # @info "end space "
    return 
end

function updateSpaceStatus( )
    l0_handle( )

    segID0 = UInt(1); segID1 = SegAlarms.chan2BegID -1 ;

    # @info  "$segID0,$segID1"

    segID2 = segID1 +1 ; segID3 = SegAlarms.SegNumbers ;

    a= Base.Threads.@spawn   l2_handle(segID0,segID1 )
    b= Base.Threads.@spawn  l2_handle(segID2,segID3 )
    wait(a)
    wait(b)


end
