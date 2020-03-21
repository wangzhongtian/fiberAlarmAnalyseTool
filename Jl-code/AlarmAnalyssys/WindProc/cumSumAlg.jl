# module fiberDataProcLib 
# export  CalDatainFile
using Statistics
using Printf
using Dates
include("../../RawFileofflineProc/dataStruct.jl")

function getRelPos(CumSumDataobj::spaceCumSumData ,vPos::Int )
    return vPos- CumSumDataobj.startID +1

end
function getAbsPos(CumSumDataobj::spaceCumSumData ,vPos::Int )
    return vPos- CumSumDataobj.startID +1

end
function getSpaceLoopRng(spaceCumSumDataObj::spaceCumSumData)
    # println("RNG:  $(spaceCumSumDataObj.startID) : $(spaceCumSumDataObj.endID) " )
    return spaceCumSumDataObj.startID : spaceCumSumDataObj.endID 
end 

function InitObj(spaceCumSumDataObj::spaceCumSumData , AlrmProcStartID1::Int,AlrmProcEndtID1::Int , startID1::Int ,endID1::Int,maxTimeCnt1::Int= 100 )
    spaceCumSumDataObj.startID= startID1
    spaceCumSumDataObj.endID =endID1
    SegdataNum = endID1-startID1+1

    spaceCumSumDataObj.AlrmProcStartID=AlrmProcStartID1
    spaceCumSumDataObj.AlrmProcEndtID=AlrmProcEndtID1  

    spaceCumSumDataObj.maxTimeCnt=maxTimeCnt1

    spaceCumSumDataObj.defaultSpaceCnt =10
    spaceCumSumDataObj.defaultTimeCnt = 1000

    spaceCumSumDataObj.m1 = Array{UInt32}(undef,spaceCumSumDataObj.defaultTimeCnt,SegdataNum)
    spaceCumSumDataObj.m1 .= 0
    spaceCumSumDataObj.rectSum = Array{UInt64}(undef,SegdataNum)
    spaceCumSumDataObj.curRow = 0
    spaceCumSumDataObj.dt= ""
    spaceCumSumDataObj.isInit = false

end

######################## 
#计算当前的行号
###########################
function getCurRowCnt(  temobj::spaceCumSumData)
    idx = temobj.curRow +1
    dataCnt =  length( @view temobj.m1[:,1] )
    temobj.curRow = idx %dataCnt 
    # @printf( "====%d === %d==============\n" , idx ,dataCnt  )
    return idx
 end

###########  计算做累加计算需要的 矩阵 的时间累加时  的  下标，
###因为 矩阵的数据结构为 循环填写有效数据，所以一共有两对   时间下标，没对包含起点、终点     
####################
function getTimeRng(tcMax,curtc,vTcNum ) # time is Row 
        if curtc < 1 ;curtc = tcMax ;end
        if curtc > tcMax ;curtc = tcMax ;end
        if vTcNum > tcMax; vTcNum =tcMax;end

        tctop1=0;tcbottom1 =0
        tctop2=0;tcbottom2 = 0

        tctop1= curtc
        tcbottom1  = tctop1-  vTcNum+1
        if tcbottom1  <  1; 
            tcbottom1 =1;
            cnt =  ( tctop1- tcbottom1)+1
            if  cnt < vTcNum;
                tctop2= tcMax
                tcbottom2 = tctop2- (vTcNum-cnt-1)
            end
            # @printf( "%d,%d,%d----,%d,%d,%d---%d\n",  tctop2,tcbottom2,(tc-cnt),  tctop1,tcbottom1, cnt  ,tc )
        end

      (  (  tctop1,tcbottom1), (tctop2,tcbottom2,) )
end

#############################
# 根据光缆空间位置的 中心位置 vspacePos ,以及计算累加的总空间点数vsc,计算出  累加计算的两个下标位置。
# 当 vsc为偶数时，调整为单数。
##############

function getSpaceRng( cumsumObj::spaceCumSumData, vspacePos,vsc)
        vsideMax =cumsumObj.endID 
        vsideMin = cumsumObj.startID

        if vspacePos <  vsideMin || vspacePos  >  vsideMax ;
            error("vspacePos 越界  ")
        end

        if vsc % 2 ==0 
            vsc+=1
        end
        left = vsideMin ;
        right = vsideMax;
        halfsc = trunc(Int,vsc/2) 

        left = vspacePos-halfsc-1 ;
        right =vspacePos+halfsc;
        if left < vsideMin ; 
            left=0; 
        end
        if  right >vsideMax ; 
            right =vsideMax;
        end
       return  (left ,right)
end

function getRelativeSpaceRng( cumsumObj::spaceCumSumData, vposIndex,vsc)
    vsideMax =cumsumObj.endID 
    vsideMin = cumsumObj.startID

    if vposIndex <  0 || vposIndex  >  vsideMax ;
        error("vspacePos 越界  ")
    end

    if vsc % 2 ==0 
        vsc+=1
    end
    left = 0 ;
    right = vsideMax;
    halfsc = trunc(Int,vsc/2) 

    left = vposIndex-halfsc-1 ;
    right =vposIndex+halfsc;
    if left < 0 ; 
        left=0; 
    end
    if  right >vsideMax  ; 
        right =vsideMax;
    end
   return (left ,right)
end

######################
# vsc  计算均值时的 空间点颗粒 的 个数
# vTcNum  计算均值时的 时间点的 个数
# vPos  当前计算点的空间 位置，空间索引点 ，对应本结构下的 rectSum的下标位置,不是光缆的绝对参考 颗粒号
###############
function calRectSum( CumSumDataobj::spaceCumSumData, vPos ,vsc ,vTcNum   ) 
    temobj = CumSumDataobj
    rectsumObj =temobj.rectSum

    vsideMax  = length( rectsumObj )  #？

    timeRngMax1 = length(　temobj.m1[:,1])　 #？

    curtcIdx = temobj.curRow
    # (left,right )=getSpaceRng( vPos, vsideMax,vsc)
    (absleft1,absright1 )=getSpaceRng( temobj,vPos,vsc)
    a = getTimeRng(timeRngMax1,curtcIdx,vTcNum )
    # println(  "time rng : $a " )
    right = getRelPos(CumSumDataobj ,absright1 ) 
    if absleft1 != 0; 
        left = getRelPos(CumSumDataobj ,absleft1 )  
    else
        left=0 
    end

    numbercnt =0
    rows=0;
    cols=0
    if   left == 0 ;
        cols =  right
    else
        cols = right-left
    end

    # left = absleft1###########
    # right= absright1 ##########
    # println(size( temobj.m1 ))
    sumv =0
    for ( top1,bottom1) in a;  ## time range loop
        # println( "absleft1,absright1,left,right,bottom1,top1::$absleft1,$absright1,$left,$right, $bottom1, $top1 ")
            # println( "VPos,absleft1,absright1,left,right,bottom1,top1::$vPos  :$absleft1,$absright1,$left,$right, $bottom1, $top1 ")
            if top1 == 0; 
                continue;
            end

            rows += top1 - bottom1+1

            v1 = @view temobj.m1[ bottom1:top1,right  ] 
            sum1= sum( v1)
            # println( sum1 )
            
            sum0=0 ;
            if left != 0; 
                v0 =@view temobj.m1[bottom1:top1,left  ]
                sum0 = sum(  v0)
            end

            sumv += sum1-sum0

    end   # for ( top1,bottom1) in a;

        numbercnt =rows*cols
        if vTcNum*vsc != numbercnt
            # error(  "Logic Error vTcNum != numbercnt " )
            # println( "Logic Error vTcNum*vsc != numbercnt :$vTcNum * $vsc  != $numbercnt" )
        end
        # println( "(left,right):($left,$right)")
        curtcIdx = getRelPos(CumSumDataobj ,vPos )
        # numbercnt =1
        avg = round( UInt,sumv /numbercnt)
        rectsumObj[ curtcIdx ]  = avg
        # println( "curtcIdx:$curtcIdx,sumv:$sumv ,avg:$avg ")
        # println( "numbercnt,sumv ,sumv /numbercnt : $numbercnt,$sumv ,$avg:  "  )
        # rectsumObj[ vPos  ] =  round( UInt,sumv /numbercnt)
end    

function AlarmCal( CumSumDataobj::spaceCumSumData,threshold= 4000)
    println("Nothing to do  in AlarmCal")
    return 
end

########### 计算空间距离上的累加数据，并保存到对应的数组中。
function cumSumProc(spaceCumSumDataobj::spaceCumSumData ,featuredata::Array{UInt16,1} )
    temobj = spaceCumSumDataobj
    idx = getCurRowCnt(  temobj)
    va = @view temobj.m1[idx , : ]  #  
    pieceData = @view featuredata[ temobj.startID : temobj.endID ]   
    # println( "length(pieceData) ,length(va ) ，length(featuredata）: $(length(pieceData)) ,$(length(va )),$(length(featuredata) )" )
    va .=   pieceData
    va .= cumsum(  va )
    
    # for d in pieceData; print(d,"," );end
    # println("Cumsum,")
    # for d in va; print(d,"," );end ;println()
end

function setDTValue(cumObj::spaceCumSumData,dt  )
    cumObj.dt =  dt
end


function  postProcFeatureDataRT(spaceCumSumDataobj::spaceCumSumData ,data::Array{UInt16,1} )
    cumSumProc( spaceCumSumDataobj,  data  )
    # println("     ????                               ")    
    vsc = spaceCumSumDataobj.defaultSpaceCnt
    vTcNum =spaceCumSumDataobj.defaultTimeCnt
    ######### calRectSum( CumSumDataobj::spaceCumSumData, vPos ,vsc ,vTcNum   ) 
    for vpos = getSpaceLoopRng( spaceCumSumDataobj );
        # println("vpos ,vsc ,vTcNum :$vpos ,$vsc ,$vTcNum   "  )
        calRectSum( spaceCumSumDataobj, vpos ,vsc ,vTcNum   ) 
    end
    # println()
    AlarmCal(spaceCumSumDataobj) 
end