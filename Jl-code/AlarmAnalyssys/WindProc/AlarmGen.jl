include("../../RawFileofflineProc/dataStruct.jl")
include("WindIDen.jl")
using  Base.Threads
function CalDynmicTh(CumSumDataobj::spaceCumSumData, vPos)
    segID = getAbsPos(CumSumDataobj ,vPos)
    CalTimePeriod,calCFactor  = getSegDynParaValue( glbSegAlarmParasDictObj,segID )
    # curAlarmsinSEG[idx].DynTh    =  typemax(UInt ) # getSegStaticThPar
    vsc=1
    avg = calRectAvg(CumSumDataobj, vPos ,vsc,CalTimePeriod  ) 
    if calCFactor != typemax( UInt )
        curAlarmsinSEG[idx].DynTh    = avg * calCFactor
    else
        curAlarmsinSEG[idx].DynTh    = typemax( UInt )
    end
end

function postProcFeatureData(dataObject::spaceCumSumData ,data::Array{UInt16,1} )
    cumSumProc( dataObject,  data  )
    # println("          <?>                          ",length(data ))    
    vsc = 4 #dataObject.defaultSpaceCnt
    vTcNum = 20 #
    # vTcNum = dataObject.defaultTimeCnt
    ######### calRectSum( CumSumDataobj::spaceCumSumData, vPos ,vsc ,vTcNum   ) 
    arng =getSpaceLoopRng( dataObject )
    # println( "---------------",arng )

     @threads for vpos = arng 
        # println("vpos ,vsc ,vTcNum :$vpos ,$vsc ,$vTcNum   "  )
        calRectSum( dataObject, vpos ,vsc ,vTcNum   ) 
        # CalDynmicTh(CumSumDataobj, vPos)
    end

    AlarmCal(dataObject) 
end

function AlarmCal( CumSumDataobj::spaceCumSumData,threshold = 3000)
    chnID = CumSumDataobj.startID > 1 ? 2 : 1
    # println("-CHnID:-$chnID, $(CumSumDataobj.startID)----")
    return  doesWinding( CumSumDataobj) # in windIDen.jl
    # return  AlarmCalAna( CumSumDataobj,threshold)
end
