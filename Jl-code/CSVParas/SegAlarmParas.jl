#=
  本文件配置个性化参数，具体参见 initAlarmSegparas! 中的注释
=#

function initParaTuple( ;segID::Int,StaticThreshold::Int , DynamicThreshold_CalTimePeriod::UInt,DynamicThresHold_calCFactor::Int,
                        microMergeTimePeriod::Int,
                        microFilterTimePeriod::Int,
                        microMergeSpaceLength::UInt,
                        microFilterSpaceLength::UInt,
                        macroMaxSpaceLength::UInt,
                        macroMinSpaceLength::UInt,
                        macroMaxTimeInterval::UInt,
                        macroMinTimeInterval::UInt,
            )


end


function initAlarmSegparas!(SegAlarmParasDictObj::Dict )   #####################
    SegParaNameTuple1 =  ( segID = 0 , microtime=Seg_MicroTimeParaStruct() ,
    microSpace=Seg_MicroSpaceParaStruct(),
    macroSpace= Seg_MacroSpaceParaStruct(),
    macroTime= Seg_MacroTimeParaStruct(),
    )
    # 静态阈值
    SegParaNameTuple1.microtime.StaticThreshold = Int(2200) # if equal to the typeMAxInt, the Static TH  does not be in  effect
    #动态阈值
    SegParaNameTuple1.microtime.DynamicThreshold_CalTimePeriod = UInt( 60 ) ## in 0.426 seconds  # calculated from Seconds.seconds ,may be any time period ,between 10seconds and the cached data period(about 10 minutes above )
    #= the  TH is: the Calculated Avg * factor / 100 
        如果动态阈值不适用该点，则DynamicThresHold_calCFactor = typemax(Int)
    =#
    SegParaNameTuple1.microtime.DynamicThresHold_calCFactor=Int( typemax(Int) )
    
    #微观过滤和合并 时间
    SegParaNameTuple1.microtime.microMergeTimePeriod  = Int(2) # in 0.426 seconds # calculated from :seconds * 0.426
    SegParaNameTuple1.microtime.microFilterTimePeriod = Int(2) # in 0.426 seconds # same as above 
    
    #微观过滤和合并 空间
    SegParaNameTuple1.microSpace.microMergeSpaceLength = UInt(1) # in Segment or  grain. Calculated from the space length and the segPermeters
    SegParaNameTuple1.microSpace.microFilterSpaceLength = UInt(3) # in Segment   or  grain
    
    #宏观 空间 限制范围
    SegParaNameTuple1.macroSpace.macroMaxSpaceLength = UInt(100)# in Segment or  grain. Calculated from the space length and the segPermeters
    SegParaNameTuple1.macroSpace.macroMinSpaceLength = UInt(4)# in Segment   or  grain
    #宏观 时间  限制范围
    SegParaNameTuple1.macroTime.macroMaxTimeInterval = UInt(30) # in 0.426 seconds
    SegParaNameTuple1.macroTime.macroMinTimeInterval = UInt(15) # in  0.426 seconds

    SegAlarmParasDictObj[SegParaNameTuple1.segID ] = SegParaNameTuple1
end