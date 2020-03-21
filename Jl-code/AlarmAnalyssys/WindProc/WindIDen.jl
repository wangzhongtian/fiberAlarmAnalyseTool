
include("SchmidtAlg.jl")
# global isInit= false
using Base.Threads
function doesWinding( CumSumDataobj::spaceCumSumData )
    # global isInit
    temobj = CumSumDataobj
    rectsumObj = temobj.rectSum
    cfgdata = temobj.CfgInfoObj
    chnid = temobj.startID >1 ? 2 : 1 
    if CumSumDataobj.isInit == false 
        # println("??" , )
        SpaceSegs1= [] 
        WindAlarmSegs1=[]
        id1=CumSumDataobj.startID
        id2=CumSumDataobj.endID
        init!(SpaceSegs1 ,cfgdata.meterperSeg,UInt16(id1) ,UInt16(id2))
        init!(WindAlarmSegs1,SpaceSegs1 )
        CumSumDataobj.WindAlarmSegs  = WindAlarmSegs1 
        CumSumDataobj.SpaceSegs = SpaceSegs1
        CumSumDataobj.isInit  = true
    end
     WindAlarmSegs  = CumSumDataobj.WindAlarmSegs  
     SpaceSegs = CumSumDataobj.SpaceSegs
    # curPos = 2
    # for idx = curPos:curPos #test only

    l1 = length( WindAlarmSegs )
    @threads for idx = 1:l1
        # println( idx ," ",length( WindAlarmSegs ))
        windingObject = WindAlarmSegs[idx]
        if chnid ==2 
            offset = cfgdata.chn2SegBegIdx-1
        else 
            offset =0
        end
        windStartSegID = windingObject.SegID1 - offset
        windEndsegID = windingObject.SegID2 - offset
        SegNum = windEndsegID - windStartSegID

        # println( chnid ,":" ,windStartSegID ,"---" , windEndsegID,"; "," $(cfgdata.chn2SegBegIdx)  ",length( rectsumObj ))
        # println("-----------------------------------------------------------------------------")
        @views a = rectsumObj[ windStartSegID : windEndsegID  ] 
        # try
            FeatureAnal(a ,windingObject ,temobj.dt)
        # catch(e)

            # println(e)
        # end
    end

end
