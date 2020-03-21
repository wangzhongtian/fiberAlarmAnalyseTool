
function get防区编号和FL(sc,t0)
   global    CalChn1_2Obj
    meters    =  CalChn1_2Obj.CfgInfoObj.meterperSeg
   segIDChn2 =  CalChn1_2Obj.CfgInfoObj.chn2SegBegIdx
   chnid = 1
   fl = 0
   segid = floor(Int, sc/10)
   if segid >= segIDChn2 
        chnid =2 
        fl = (segid - segIDChn2 )  * meters
    else
        chnid = 1
        fl = (segid )  * meters
    end
    return ( chnid,fl , UInt2DTStr( t0 ))
# @info "----SegParaAlarmProc.CalChn1_2Obj.CfgInfoObj.meterperSeg-- ???:",SegParaAlarmProc.CalChn1_2Obj.CfgInfoObj.meterperSeg
end