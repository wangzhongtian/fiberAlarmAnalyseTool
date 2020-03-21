using Base.Threads
mutable struct Seg_MicroTimeParaStruct 
    StaticThreshold::Int # if equal to the typeMAxInt, the Static TH  does not be in  effect
    DynamicThreshold_CalTimePeriod::UInt ## in data Numbers # calculated from Seconds.seconds ,may be any time period ,between 10seconds and the cached data period(about 10 minutes above )

    DynamicThresHold_calCFactor::Int 
    minTh::Int
    maxTh::Int
    microMergeTimePeriod::Int # in 0.426 seconds # calculated from :seconds * 0.426
    microFilterTimePeriod::Int # in 0.426 seconds # same as above 
    function Seg_MicroTimeParaStruct()
        StaticThreshold= UInt( 0 )
        DynamicThreshold_CalTimePeriod=UInt(2*60) # about 1Minutes
        DynamicThresHold_calCFactor = 130 # about 1.3
        # dynamic_RTThreshold = Int(1500)
        microMergeTimePeriod = UInt(1 )
        microFilterTimePeriod = UInt(1)
        minTh=Int( 1000)
        maxTh=Int( 1000)
        new(StaticThreshold,DynamicThreshold_CalTimePeriod,DynamicThresHold_calCFactor, minTh,maxTh,
            microMergeTimePeriod, microFilterTimePeriod)
    end
end 

mutable struct  Seg_MicroSpaceParaStruct 
    microMergeSpaceLength::UInt # in Segment or  grain. Calculated from the space length and the segPermeters
    microFilterSpaceLength::UInt # in Segment   or  grain
    function Seg_MicroSpaceParaStruct()
        microMergeSpaceLength = UInt( 1 )
        microFilterSpaceLength = UInt( 2 ) 
        new(microMergeSpaceLength, microFilterSpaceLength)
    end    
end 

mutable struct  Seg_MacroSpaceParaStruct 
    macroMaxSpaceLength::UInt # in Segment or  grain. Calculated from the space length and the segPermeters
    macroMinSpaceLength::UInt # in Segment   or  grain

    function Seg_MacroSpaceParaStruct()
        macroMaxSpaceLength = UInt( 100 )
        macroMinSpaceLength = UInt(2) #
        new(macroMaxSpaceLength, macroMinSpaceLength)
    end    
end 

mutable struct Seg_MacroTimeParaStruct 
    macroMaxTimeInterval::UInt # in dataFrames 
    macroMinTimeInterval::UInt # in  dataFrames
    function Seg_MacroTimeParaStruct()
        macroMaxTimeInterval= Int( 7 )
        macroMinTimeInterval=Int(3) 
        new(macroMaxTimeInterval, macroMinTimeInterval)
    end  
end 



function getSegAlarmPara( SegAlarmParasDict::Array, SegID::Int)::NamedTuple
    try 
        len1=length(SegAlarmParasDict )
        
        ret = SegAlarmParasDict[ SegID ];
        # println("---",SegID ," $len1 ,$ret ")
        return ret 
    catch e
        println(":::$e===\r\n")
        println("-Error: SEgidout of range returned(1:8192) --",SegID )
	    exit();
       # return SegAlarmParasDict[0]
    end
end

function getSegStaticThPara(SegAlarmParasDict::Array, SegID::Int ) ::Int
 #   lock(glbAlarmParasdictLock)
    d1 = getSegAlarmPara( SegAlarmParasDict, SegID)
  #  unlock(glbAlarmParasdictLock)
    return d1.microtime.StaticThreshold
end

function getSegDynParaValue(SegAlarmParasDict::Array, SegID::Int )::Tuple
   # lock(glbAlarmParasdictLock)
        d1 = getSegAlarmPara( SegAlarmParasDict, SegID)
        a = (d1.microtime.DynamicThreshold_CalTimePeriod,d1.microtime.DynamicThresHold_calCFactor,d1.microtime.minTh,  d1.microtime.maxTh  )
   # unlock(glbAlarmParasdictLock)
    return a
end

function getSegMicroTimeParaValue(SegAlarmParasDict::Array, SegID::Int )::Tuple
  #  lock(glbAlarmParasdictLock)
        d1 = getSegAlarmPara( SegAlarmParasDict, SegID)
        a= (d1.microtime.microMergeTimePeriod, d1.microtime.microFilterTimePeriod)
    #unlock(glbAlarmParasdictLock)
    return a

end

function getSegMicroSpaceParaValue(SegAlarmParasDict::Array, SegID::Int ) ::Tuple
   # lock(glbAlarmParasdictLock)
        d1 = getSegAlarmPara( SegAlarmParasDict, SegID)
        a= (d1.microSpace.microMergeSpaceLength, d1.microSpace.microFilterSpaceLength)
   # unlock(glbAlarmParasdictLock)
    return a
end

function getSegMacroSpaceParaValue(SegAlarmParasDict::Array, SegID::Int ) ::Tuple
    #lock(glbAlarmParasdictLock)
        d1 = getSegAlarmPara( SegAlarmParasDict, SegID)
        a= (d1.macroSpace.macroMaxSpaceLength, d1.macroSpace.macroMinSpaceLength,)
    #unlock(glbAlarmParasdictLock)
    return a
end


function getSegMacroTimeParaValue(SegAlarmParasDict::Array, SegID::Int ) ::Tuple
    #lock(glbAlarmParasdictLock)
        d1 = getSegAlarmPara( SegAlarmParasDict, SegID)
        a= (d1.macroTime.macroMaxTimeInterval, d1.macroTime.macroMinTimeInterval,)
   # unlock(glbAlarmParasdictLock)
    return a
end

include("SegAlarmParas.jl")

