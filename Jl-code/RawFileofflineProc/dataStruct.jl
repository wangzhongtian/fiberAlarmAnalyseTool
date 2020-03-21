
mutable struct cfgStruct
    meterperSeg::Float64
    chn2SegBegIdx::UInt16
    reflectorFactor::Float64
    attenutionFactor::Float64
    scanrate::UInt16
    calSamples::UInt16
    SegNumber::UInt16
    function cfgStruct()
        new(0)
    end #cfgStruct
end

mutable struct  CfgDataStruct  
        SpatialResolution::Float64 ;
        Refractivity::Float64 ;
        OffsetM::Float64 ;
        ATT::Float64 ;
        ScanRate::Float64 ;
        EnergyCnt ::UInt 
        LcLimitHigh::Float64 ;
        LcLimitLow::Float64 ;
        StartCh1::UInt 
        LenCh1::UInt 
        StartCh2::UInt 
        LenCh2::UInt 
        function CfgDataStruct()
            new(0)
        end #CfgDataStruct

end         #mutable struct  CfgDataStruct  


mutable struct RNG
    AlrmProcStartID::Int
    AlrmProcEndtID1::Int
    startID1::Int
    endID1::Int

    chnid::Int
    ProtectSpaceWidth::Int
    function RNG()
        new(0)
    end
end



mutable struct spaceCumSumData 
    m1::Matrix{UInt32 }  ##振动数据
    curRow::Int
    maxTimeCnt::Int
    # rectSum::Array{ UInt64}
    dt::String
    
    ################################
    startID::Int #保存数据的起点 
    endID::Int  #  保存数据的终点
    
    AlrmProcStartID::Int
    AlrmProcEndtID::Int

    defaultSpaceCnt::Int
    defaultTimeCnt::Int
    CfgInfoObj

    rectSum::Array{ UInt64}
    WindAlarmSegs
    SpaceSegs
    isInit 
    function  spaceCumSumData()
        new()
    end
end # spaceCumSumData