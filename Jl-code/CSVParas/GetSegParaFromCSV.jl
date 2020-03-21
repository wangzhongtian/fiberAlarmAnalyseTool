module ReadCFGPARA
    include("readCsvLib.jl")
    include("mappingLib.jl")

    CsvInfoObj = CsvInfos()

    CsvInfoObj.防区表fieldname ="定位界标1,定位界标2,xxxx主机IP,通道号,定位界标1光程,定位界标2光程,子防区编号,防区起点GPS经度坐标,防区起点GPS纬度坐标,防区终点GPS经度坐标,防区终点GPS纬度坐标,左右岸,地名信息,界标之间围栏长度,管理处,分局"
    CsvInfoObj.防区表signalStringName="定位界标1光程"
    CsvInfoObj.防区表keyFieldNames ="定位界标1,定位界标1光程,定位界标2,定位界标2光程"
    CsvInfoObj.防区表filename = "../Jl-Aux/glbCfg//防区信息.csv"

    CsvInfoObj.主机信息表fieldname = "主机编号,友好名,主机位置,主机类型"
    CsvInfoObj.主机信息表signalStringName = "主机类型"
    CsvInfoObj.主机信息表keyFieldNames = "主机编号,友好名,主机位置,主机类型"
    CsvInfoObj.主机信息表filename     = "../Jl-Aux/glbCfg/A100-xxxx主机IP信息表.csv"

    CsvInfoObj.老版参数表fieldname ="编号,通道,标牌坐标1,标牌坐标2,动态阈值时长,动态阈值系数,动态阈值下限,动态阈值上限,事件合并时长,事件滤除时间,事件合并距离,事件滤除距离,告警空间下限,告警空间上限,告警续时下限,告警续时上限,地名标识,说明"
    CsvInfoObj.老版参数表signalStringName="标牌坐标1"
    CsvInfoObj.老版参数表keyFieldNames ="通道,标牌坐标1,标牌坐标2,动态阈值时长,动态阈值系数,动态阈值下限,动态阈值上限,事件合并时长,事件滤除时间,事件合并距离,事件滤除距离,告警空间下限,告警空间上限,告警续时下限,告警续时上限"
    CsvInfoObj.老版参数表filename ="../Jl-Aux/glbCfg/xxxx-AlarmParas.csv"
    CsvInfoObj.ParasPosNames  = "通道,标牌坐标1,标牌坐标2"

    function Readin_cfgParas(;machine友好名0="GYYS001" )
        CsvInfoObj.老版参数表filename = replace(CsvInfoObj.老版参数表filename, Pair("xxxx",machine友好名0) )
        # println( " Here -----------------------00--------------------")
        basicInit( CsvInfoObj)

        convertPara_Fiberlength( CsvInfoObj,machine友好名1=machine友好名0)
        # println( " Here ------------------------11-------------------")
        return
    end

    function Paras_tofloatArray(;metersPerSeg::Float64,timeUnit::Float64=0.426)::Array
        fieldNum =  length( split(CsvInfoObj.老版参数表keyFieldNames,",") )
        rowdata = CsvInfoObj.csvInfoDefencePara.Area2FiberLen
        rowNum = length( rowdata )
     #   println( ":::rowdata len is $rowNum")
        rows = Array{Float64,2}(undef,rowNum,fieldNum)

        spacefactor1s=[2,3, 10,11,12,13 ]
        # timefactors =[4,8,9,14,15]
        timefactors =[4,14,15] # IN 0.426秒

        for row =1: rowNum
            fieldidx = 1
            rows[row,fieldidx]= parse(Float64, rowdata[row][ fieldidx ] )
            fieldidx = 2 
            rows[row,fieldidx] = rowdata[row][ fieldidx ]    
            # rows[row,fieldidx]
            fieldidx =3 
            rows[row,fieldidx] =  rowdata[row][ fieldidx ]             
            for fieldidx =4:fieldNum
                rows[row,fieldidx]= parse(Float64,rowdata[row][ fieldidx ] )
               
            end

            for fieldidx in spacefactor1s
                rows[row,fieldidx] = rows[row,fieldidx]/metersPerSeg +0.01
                # println( rows[row,fieldidx], "->",rowdata[row][ fieldidx ]," in unit :" ,metersPerSeg)
            end 
            # println()
            # for fieldidx in timefactors
            #     rows[row,fieldidx] = rows[row,fieldidx]/ timeUnit + 0.01
            # end
            # rows[row,5]  =rows[row,5] 
           # "通道,标牌坐标1,标牌坐标2,动态阈值时长,动态阈值系数,动态阈值下限,动态阈值上限,事件合并时长,事件滤除时间,事件合并距离,事件滤除距离,告警空间下限,告警空间上限,告警续时下限,告警续时上限"

        end
        # return rows
        function transfer(data::Float64)
            return floor( UInt, data)
        end

        rows1 = Array{UInt,2}(undef,rowNum,fieldNum)
        rows1 = map(transfer, rows)
        return rows1
    end

    function initParaDict( ;paraDict::Dict,rowsObj::Array,chn1SegIDRng::Array , chn2SegIDRng::Array )
        # println(chn2SegIDRng ," **************** ",chn1SegIDRng  )
        # exit()

        # println("----------------------------------")
        # rowNum,fieldNum   = size( rowsObj )
        # println("--------------#$rowNum,$fieldNum--------------------")
        # for row =1: rowNum
        #         # l=fieldNum
        #         for  idx = 1:fieldNum
        #             print( rowsObj[ row,idx] ," --")
        #         end
        #         println()
        # end
        # exit()

        rowNum,fieldNum   = size( rowsObj )
        # for row =1:rowNum
        for rowidx =1: rowNum # in rowsObj
            rowobj = rowsObj[rowidx,:]
            # println( size( rowobj))
            #
            # l1 =length(rowobj )
            # for i =1:l1
            #         println("$i,$(rowobj[i]) ")
            # end
            # println("=====================================================")
            if rowobj[ 2 ] == UInt(0) &&  rowobj[ 3 ]  == UInt(0) ## the default para
               
                if rowobj[ 1 ] == 1 #Channel 1 
                    # println("default para Fill................1............",chn1SegIDRng[1],";",chn1SegIDRng[2])
                    for idx = chn1SegIDRng[1] : chn1SegIDRng[2]
                         paraDict[ idx ] = rowobj[4:end] 
                    end
                elseif rowobj[ 1 ] == 2 #Channel 2
                    
                    for idx = chn2SegIDRng[1] : chn2SegIDRng[2]
                     
                        paraDict[ idx ] = rowobj[4:end] 
                    end
                end

            end
        end


        for rowidx = 1: rowNum # in rowsObj
            rowobj = rowsObj[rowidx,:]
            startSegID = rowobj[ 2 ] 
            endSegID   = rowobj[ 3 ] 
            # println( "...............$( rowobj[ 1 ])_$startSegID,  $endSegID")
            if startSegID != 0 ||  endSegID != 0 ## NOT the default para
                if rowobj[ 1 ] == 1
                    offsetSegID = 0
                elseif rowobj[ 1 ] == 2
                    offsetSegID = chn2SegIDRng[1]-1
                else
                   ;# println( "$startSegID,  $endSegID")
                end
                begid = offsetSegID + startSegID  
                endid= offsetSegID + endSegID
                rngid= begid: endid
                #println( "----$begid: $endid----" )
                for idx = rngid
                    paraDict[ idx ] = rowobj[4:end] 
                end
            end
        end
    # println("======================================")
    # v=[]
    # for i in keys(paraDict ) 
    #     append!(v,i)
    #     # println( i )
    # end
    # a= sort(v )
    # for a1 =a 
    #     println(a1)
    # end

    # exit()
    end
end #module ReadCFGPARA
function MainCfgPara(;machine友好名0="GYYS-001",metersPerSeg1::Float64,timeUnit1::Float64=0.426,Chn1Seg1::Int =1,Chn1Seg2::Int =4196, Chn2Seg1::Int =4197, Chn2Seg2::Int =8192 )
    ReadCFGPARA.Readin_cfgParas(machine友好名0=machine友好名0 )
    # println( " Here -------------------------------------------")
    rows = ReadCFGPARA.Paras_tofloatArray( metersPerSeg = metersPerSeg1,timeUnit=timeUnit1 )


    paraDictObj = Dict()
    chn1SegIDRng=[Chn1Seg1,Chn1Seg2]
    chn2SegIDRng=[Chn2Seg1,Chn2Seg2]
    ReadCFGPARA.initParaDict(paraDict=paraDictObj ,rowsObj=rows  ,chn1SegIDRng=chn1SegIDRng , chn2SegIDRng=chn2SegIDRng)
    # v=[]
    # for i in keys(paraDictObj ) 
    #     append!(v,i)
    #     # println( i )
    # end
    # a= sort(v )
    # for a1 =a 
    #     println(a1)
    # end
    return paraDictObj
end

function TestMain(;machine友好名0="GYYS001" )
    ReadCFGPARA.Readin_cfgParas(machine友好名0=machine友好名0 )

    rows = ReadCFGPARA.Paras_tofloatArray( metersPerSeg = Float64(6.001) )
    # show(ReadCFGPARA.CsvInfoObj.csvInfoDefencePara )
    rowNum,fieldNum   = size( rows )

    for row =1:rowNum
        for fieldidx = 1:fieldNum
            print( rows[row,fieldidx],"," )
        end
        println()
    end
    paraDictObj = Dict()
    chn1SegIDRng=[1,8000]
    chn2SegIDRng=[9000,9000+8000]
    ReadCFGPARA.initParaDict(paraDict=paraDictObj ,rowsObj=rows  ,chn1SegIDRng=chn1SegIDRng , chn2SegIDRng=chn2SegIDRng)
    for key = chn1SegIDRng[1] :chn1SegIDRng[2] # 9000:17000) 
        try
            valobj = paraDictObj[key]
            print(key,": ")
            for idx =1: length(valobj )
                print( valobj[idx] ,",  ")
            end
            println()
        catch( e )
            # println(e)
        end
    end

    for key in   chn2SegIDRng[1] :chn2SegIDRng[2]# 9000:17000) 
        try
            valobj = paraDictObj[key]
            print(key,": ")
            for idx =1: length(valobj )
                print( valobj[idx] ,",  ")
            end
            println()
        catch( e )
            # println(e)
        end
    end

end
# TestMain(machine友好名0="GYYS001" )
