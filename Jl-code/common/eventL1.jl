module EventL1

    include("../RawFileofflineProc/BaseLib.jl")
    include( "LogLstLib.jl")
    using ..SegParaAlarmProc
    function ReportEventL1(s_1::UInt,s_2::UInt, curTime::UInt,curFrame ,filterinfo="NoWind")
        posStr = @sprintf("%04u:%04u,%04u", s_1,s_2,s_2-s_1)
        a = ("intrusion",posStr, curTime , UInt2DTStr( curTime ),curFrame,filterinfo )
        a1= join(a,",")*"\r\n"
        LogEvent(a1)
    end


end
