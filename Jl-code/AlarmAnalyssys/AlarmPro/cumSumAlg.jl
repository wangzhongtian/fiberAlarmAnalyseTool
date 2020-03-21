# module fiberDataProcLib 
# export  CalDatainFile
using Statistics
using Printf
using Dates

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

    spaceCumSumDataObj.AlrmProcStartID  = AlrmProcStartID1
    spaceCumSumDataObj.AlrmProcEndtID = AlrmProcEndtID1  

    spaceCumSumDataObj.maxTimeCnt = maxTimeCnt1

    spaceCumSumDataObj.defaultSpaceCnt =10
    # Cache Data Number ： 
    minutes = 10.0;
    spaceCumSumDataObj.defaultTimeCnt = floor(UInt ,minutes*60.0/0.42) #

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
###因为 矩阵的数据结构为 循环填写有效数据，所以一共有两对   时间下标，每对包含起点、终点     
#################### 
function getTimeRng(tcMax,curtc,vTcNum ) # time is Row 
    tcNum = Int(vTcNum )
        if curtc < 1 ;curtc = tcMax ;end
        if curtc > tcMax ;curtc = tcMax ;end
        if tcNum > tcMax; tcNum =tcMax;end

        tctop1=0;tcbottom1 =0
        tctop2=0;tcbottom2 = 0

        tctop1= curtc
        tcbottom1  = tctop1-  tcNum + 1
        # @info ":::::::-::::::: ",tcbottom1 , tctop1,  tcNum , typeof(tcNum)
        if tcbottom1  <  1 ; 
            tcbottom1 =1;
            cnt =  ( tctop1- tcbottom1)+1
            if  cnt < tcNum;
                tctop2= tcMax
                tcbottom2 = tctop2- (tcNum-cnt-1)
            end
            # @printf( "%d,%d,%d----,%d,%d,%d---%d\n",  tctop2,tcbottom2,(tc-cnt),  tctop1,tcbottom1, cnt  ,tc )
        end

      return (  (  tctop1,tcbottom1), (tctop2,tcbottom2,) )
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

  
function calRectAvg( CumSumDataobj::spaceCumSumData, vPos ,vsc=1 ,vTcNum=20 ) 
    temobj = CumSumDataobj
    rectsumObj =temobj.rectSum

    vsideMax  = length( rectsumObj )  #？

    timeRngMax1 = length(　temobj.m1[:,1])　 #？

    curtcIdx = temobj.curRow
    # (left,right )=getSpaceRng( vPos, vsideMax,vsc)
    (absleft1,absright1 )=getSpaceRng( temobj,vPos,vsc)
    # @info "-??-，vTcNum,curtcIdx ,timeRngMax1", vTcNum,curtcIdx ,timeRngMax1
    a = getTimeRng(timeRngMax1,curtcIdx,vTcNum )
    # @info "getTimeRng " , a
    # println(  "time rng : $a " )
    right = getRelPos(CumSumDataobj ,Int(absright1 )  )
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

    sumv =0
    for ( top1,bottom1) in a;  ## time range loop
        # println( "absleft1,absright1,left,right,bottom1,top1::$absleft1,$absright1,$left,$right, $bottom1, $top1 ")
            # println( "VPos,absleft1,absright1,left,right,bottom1,top1::$vPos  :$absleft1,$absright1,$left,$right, $bottom1, $top1 ")
            if top1 == 0; 
                continue;
            end

            rows += top1 - bottom1+1
            # println(  " ###:",size( temobj.m1) ," " ,right," " ,bottom1," ",top1)
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
        avg = round( UInt,sumv /numbercnt)
        return avg
        # curtcIdx = getRelPos(CumSumDataobj ,vPos )
        # rectsumObj[ curtcIdx ]  = avg
       
end  

######################
# vsc  计算均值时的 空间点颗粒 的 个数
# vTcNum  计算均值时的 时间点的 个数
# vPos  当前计算点的空间 位置，空间索引点 ，对应本结构下的 rectSum的下标位置,不是光缆的绝对参考 颗粒号
###############
function calRectSum( CumSumDataobj::spaceCumSumData, vPos ,vsc ,vTcNum ) 
    temobj = CumSumDataobj
    rectsumObj = temobj.rectSum
    avg = calRectAvg( CumSumDataobj, vPos ,vsc ,vTcNum) 
    curtcIdx = getRelPos(CumSumDataobj ,vPos )
    # println("$curtcIdx:$avg")
    rectsumObj[ curtcIdx ]  = avg
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
    
end

function setDTValue(cumObj::spaceCumSumData,dt  )
    cumObj.dt =  dt
end
 
function CalDynmicTh(CumSumDataobj::spaceCumSumData, vPos)
    segID = getAbsPos(CumSumDataobj ,vPos)
    CalTimePeriod,calCFactor ,minTh,maxTh = getSegDynParaValue( glbSegAlarmParasDictObj,segID )
    #  println("----",calCFactor )
    vsc=1
    avg = calRectAvg(CumSumDataobj, vPos ,vsc,CalTimePeriod  ) 
    if calCFactor != typemax( Int )
        dynTh1 = floor(Int,avg * (calCFactor/100) )
        if dynTh1 < minTh 
            dynTh1 = minTh
        elseif dynTh1 > maxTh
            dynTh1 = maxTh
        end
        curAlarmsinSEG[segID].DynTh    = dynTh1
    else
        curAlarmsinSEG[segID].DynTh    = typemax( Int )
    end
    # @info " SefID ,Dyn , AVg  CalTimePeriod,calCFactor ,minTh,maxTh .is :  ",segID,curAlarmsinSEG[segID].DynTh ,Int(avg),CalTimePeriod,calCFactor ,minTh,maxTh
end

function AlarmRTCalAna( CumSumDataobj::spaceCumSumData)
    temobj = CumSumDataobj
    rectsumObj =temobj.rectSum
    viewa  = @view rectsumObj[ 1 : end] 
    e = length( viewa )
     @threads for k = 1 : e
        temobj.startID > 1 ? segID = k - 1 + temobj.startID : segID = k
        if Int( viewa[ k ] ) > curAlarmsinSEG[segID].DynTh 
            # @info "AlarmRTCalAna :",segID , Int(viewa[ k ] ), curAlarmsinSEG[segID].DynTh 
            AlarmDynStatus[segID ] = true
        else
            AlarmDynStatus[segID ] = false
        end
    end
    # showResult( "$(temobj.dt[1:8]):$(temobj.dt[9:14])" ,AlarmDynStatus, AlarmStaticStatus,CumSumDataobj )
end

