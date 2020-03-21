using Base.Threads

function showResult(dtStr::String ,AlarmDynStatus::Array{Bool,1}, AlarmStaticStatus::Array{Bool,1},CumSumDataobj::spaceCumSumData )
    segid1= CumSumDataobj.startID 
    segid2= CumSumDataobj.endID 
    if true #segid1 > 1
        println( "$dtStr: Dyn, ")
        for a in AlarmDynStatus[1:end ]
            a == true ? print( "Y,") : print(",")
        end
        println()
        println( "$dtStr: Sta, ")
        for a in AlarmStaticStatus[1:end ]
            a == true ? print( "Y,") : print(",")
        end
        println()
    end
end
function AlarmCreditCalAna( CumSumDataobj::spaceCumSumData)
    temobj = CumSumDataobj
    rectsumObj =temobj.rectSum

    print("+$(temobj.dt[1:8]):$(temobj.dt[9:14]) , ")

    e =  temobj.AlrmProcEndtID-temobj.AlrmProcStartID +1

    a= temobj.AlrmProcStartID - temobj.startID  + 1
    b= temobj.AlrmProcEndtID  - temobj.startID  + 1
    viewa  = @view rectsumObj[ a: b] 
    # doesWinding( CumSumDataobj)
    # println("$a   $b   $(size(viewa ))")
    for k = 1 : e
        # print( rectsumObj[ k ] ,"," )
        if viewa[ k ] >= threshold
                print( viewa[ k ] ,"," )
        else
            　print(",")
        end
    end
    # println("-------")
end
include("../../../Jl-Aux/glbCfg/internalPara.jl")
function postProcFeatureData(dataObject::spaceCumSumData ,data::Array{UInt16,1} )
    # println("   ------------------       <?>            0     -------------         ",length(data ))        
    cumSumProc( dataObject,  data  )
    # println("   ------------------       <?>        1         -------------         ",length(data ))    

    vsc = glbvsc 
    vTcNum = glbvTcNum 

    # @info vsc, vTcNum
    arng = getSpaceLoopRng( dataObject )
    # println( "---------------",arng )
    # println("   ------------------       <?>        2         -------------         ",arng)    
   @threads for vpos = arng 
        # println("   ------------------       <?>        3         -------------         ",arng)    
        calRectSum( dataObject, vpos ,vsc ,vTcNum   ) 
        # println("   ------------------       <?>        3         -------------         ",arng) 
        CalDynmicTh( dataObject,  vpos )
    end
    # println("   ------------------       <?>        4         -------------         ",arng)    
    AlarmRTCalAna(dataObject) 
end