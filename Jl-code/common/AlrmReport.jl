module AlarmReport
    include( "LogLstLib.jl")

    using Printf
    using ...SegParaAlarmProc
    function LogAlarm(alrmobj,isNew::Bool=false)
        chnid , fl,DTStr = SegParaAlarmProc.get防区编号和FL(alrmobj.SC ,  alrmobj.t0 )
        a= @sprintf( "%s,%04u,%04u,%05u,%014u,%014u,%014u,%01u,%06u,%s\r\n",alrmobj.AlarmID,
        alrmobj.S1 ,
        alrmobj.S2,
        alrmobj.SC ,
        alrmobj.t0 ,
        alrmobj.tfresh,
        alrmobj.Tc,
        chnid,
        fl    ,
        DTStr
        )
        # @info "----SegParaAlarmProc.CalChn1_2Obj.CfgInfoObj.meterperSeg-- ???:",SegParaAlarmProc.CalChn1_2Obj.CfgInfoObj.meterperSeg
        if isNew == true
            # a[1]=
            LogEvent( "N"*a[2:end] )
        else
            LogEvent( a  )
        end

    end
end
