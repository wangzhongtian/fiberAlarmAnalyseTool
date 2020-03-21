const fenjuPos =2:2
const guanlichuPos=2:10
const signalChnPos=11:11
const SignalIDPos=12:14
const SignalIDfullPos=11:14


mutable struct CsvInfos
    csvInfoSignalID2FiberPos
    csvInfoDefencePara
    csvInfoMachineInfo
    防区表fieldname
    防区表signalStringName
    防区表keyFieldNames
    防区表filename 

    老版参数表fieldname
    老版参数表signalStringName
    老版参数表keyFieldNames
    老版参数表filename 

    主机信息表fieldname
    主机信息表signalStringName
    主机信息表keyFieldNames
    主机信息表filename   
    ParasPosNames  
    function  CsvInfos()
         csvInfoSignalID2FiberPos = nothing
         csvInfoDefencePara = nothing
         csvInfoMachineInfo = nothing
         new(csvInfoSignalID2FiberPos,   csvInfoDefencePara, csvInfoMachineInfo,"","","","","","","","","","","","","")
    end
end

function findMachineRegID( ;csvInfoMachineInfo::CSVinfo ,machine友好名::String="xxxx001")::String
    if occursin( "友好名" , csvInfoMachineInfo.keyFieldNames)
        fields =split( csvInfoMachineInfo.keyFieldNames,",")
        pos友好名 =0
        pos主机编号=0
        for i = 1: length(fields )
            if fields[i] =="友好名"
                pos友好名 = i
            elseif  fields[i] =="主机编号"
                pos主机编号=i

            end
        end
        for infos in  csvInfoMachineInfo.Area2FiberLen
            if infos[pos友好名] == machine友好名
                return infos[pos主机编号]
            end
        end

    else
        # return ""
    end
    return ""
end

function getSpecMachineSlogansInfo( ; csvInfoSignalID2FiberPos1::CSVinfo ,machineRegID::String="A302042001",通道1::String="1")
    a=[]
    refobj = csvInfoSignalID2FiberPos1.Area2FiberLen 
    fields =split( csvInfoSignalID2FiberPos1.keyFieldNames,",")
    pos定位界标1 = 0
    pos定位界标1光程 = 0
    pos定位界标2 = 0
    pos定位界标2光程 = 0    
    for i = 1: length(fields )
        if fields[i] == "定位界标1"
            pos定位界标1 = i
        elseif  fields[i] == "定位界标1光程"
            pos定位界标1光程 = i
        elseif  fields[i] == "定位界标2光程"
            pos定位界标2光程 = i
        elseif fields[i] == "定位界标2"
            pos定位界标2 = i
        end
    end
    # "定位界标1,定位界标1光程"
    rowobj = nothing 
    lastSignalID = nothing
    lastFIberPos = 0
    for i = 1:length(refobj)
        rowobj = refobj[i]
        jiebiao1 = rowobj[pos定位界标1]
        # println( jiebiao1[ guanlichuPos] ,"-",machineRegID[guanlichuPos] )
        if jiebiao1[ guanlichuPos] ==  machineRegID[guanlichuPos]  && jiebiao1[signalChnPos] == 通道1
                append!(a,[ [jiebiao1 ,parse( UInt,rowobj[pos定位界标1光程] )  ]  ] )
                lastSignalID = rowobj[pos定位界标2] 
                lastFIberPos = rowobj[pos定位界标2光程] 
        end
    end
    if lastSignalID  != nothing
        append!(a,[ [lastSignalID ,parse( UInt,lastFIberPos ) ]  ] )
    end

    return a
end

function getPos_Signal(位置::String,Rows=[])::String
    pos1=parse(UInt,位置)
    # println( pos1 )
    pos0 =0
    pos2 = 0
    for idx =1: length(Rows)-1
     row1 = Rows[idx]
     row2 = Rows[idx+1]
        pos0 = row1[2] 
        pos2 = row2[2] 
        if pos1 >= pos0 && pos1 <= pos2
            # println( row[1],"-",row[2],"-",row[3],"-",row[4] )
            if pos2 - pos1 > pos1 -pos0 
                return string(row1[1][SignalIDfullPos],"+",pos1 -pos0 )  ;
                # println( 位置,":",row[1],"+",pos1 -pos0,", ",row[2], )
            else
                return string(row2[1][SignalIDfullPos],"-",pos2 -pos1 )  ;
                # println( 位置,":",row[3],"-",pos2 -pos1,", ",row[4], )
            end
        end
        if pos1 < pos0
            return string(row1[1][SignalIDfullPos],"-",pos0 -pos1)  ;
        end
    end
    row = Rows[end]
    pos2 = row[ 2 ]
    if pos1 > pos2
        return string(row[1][SignalIDfullPos],"+",pos1 -pos2)  ;
    end
    # return ""
end


function getPos_FiberLen(位置::String,Rows=[])::Int
    sign = -1
    base = nothing
    biase = nothing
    if occursin("-" ,位置)
        sign = -1
        base,biase = split(位置,"-")
    elseif occursin("+" ,位置)
        sign = 1
        base,biase = split(位置,"+")
    else
        return "" 
    end

    if base == "0" && biase == "0"
        return 0
    end
    signalID= nothing
    fiberPos = -1
    for idx =1: length(Rows)
     row1 = Rows[idx]
     signalID = row1[1][SignalIDfullPos] 
     if base == signalID
        fiberPos = row1[2] 
        break
        end
    end

    if fiberPos == -1
        println("not find...$位置")
        return -1
    else
        # println("$fiberPos,$sign,$biase")
        return fiberPos + sign*parse(UInt,biase)
    end
end


function getSlogenCorordinats( ;通道::String,位置::String,csvInfoSignalID2FiberPos2::CSVinfo,machineRegID1::String="A302042001")::String
    Rows= getSpecMachineSlogansInfo( csvInfoSignalID2FiberPos1 = csvInfoSignalID2FiberPos2  ,
        machineRegID = machineRegID1,
        通道1 = 通道)
    posStr = getPos_Signal(位置,Rows)
    return posStr
end


function convertPara2SignalCordinate( CsvInfoObj::CsvInfos;machine友好名1="xxxx001")
    machineRegID1 = findMachineRegID( csvInfoMachineInfo=CsvInfoObj.csvInfoMachineInfo ,machine友好名=machine友好名1)
    sort!(CsvInfoObj.csvInfoDefencePara.Area2FiberLen)
    keyname = "通道,起始位置(米),结束位置(米)"

    keynames = split( keyname ,",")
    fields = split( CsvInfoObj.csvInfoDefencePara.keyFieldNames,",")
    pos通道 = 0
    pos起始位置 = 0
    pos结束位置 = 0
   
    for i = 1: length(fields )
        if fields[i] == keynames[1]
              pos通道 = i
        elseif  fields[i] ==  keynames[2]
              pos起始位置 = i
        elseif  fields[i] == keynames[3]
              pos结束位置 = i
        end
    end
    rows = nothing
    tongdaoID =""
    dataobjs = CsvInfoObj.csvInfoDefencePara.Area2FiberLen
    datalen = length(dataobjs  )
    for idx =1:datalen
         dataobj = dataobjs[ idx ]
         通道 = dataobj[pos通道]
         起始位置 = dataobj[pos起始位置]
         结束位置 = dataobj[pos结束位置]
         if 通道 != tongdaoID
              rows = getSpecMachineSlogansInfo( csvInfoSignalID2FiberPos1= CsvInfoObj.csvInfoSignalID2FiberPos  ,
              machineRegID=machineRegID1,
              通道1=string(通道) )
              tongdaoID= string(通道)
         end

        #  print(通道 ," ",起始位置," ",结束位置,":" )
          
         posStr = getPos_Signal(string(起始位置),rows)
        #  print( "  ",起始位置,":",posStr )
         dataobj[pos起始位置]= posStr
         posStr = getPos_Signal(string(结束位置),rows)
        #  println( "  ",结束位置,":",posStr )
         dataobj[pos结束位置] = posStr
        #  println( dataobj )
    end
end


function convertPara_Fiberlength( CsvInfoObj::CsvInfos;machine友好名1="xxxx001")
    machineRegID1 = findMachineRegID( csvInfoMachineInfo=CsvInfoObj.csvInfoMachineInfo ,machine友好名=machine友好名1)
    sort!(CsvInfoObj.csvInfoDefencePara.Area2FiberLen)
   
    keyname =  CsvInfoObj.ParasPosNames #"通道,起始位置(米),结束位置(米)"

    keynames = split( keyname ,",")
    fields = split( CsvInfoObj.csvInfoDefencePara.keyFieldNames,",")
    pos通道 = 0
    pos起始位置 = 0
    pos结束位置 = 0
   
    for i = 1: length(fields )
        if fields[i] == keynames[1]
              pos通道 = i
        elseif  fields[i] ==  keynames[2]
              pos起始位置 = i
        elseif  fields[i] == keynames[3]
              pos结束位置 = i
        end
    end
    rows = nothing
    tongdaoID =""
    dataobjs = CsvInfoObj.csvInfoDefencePara.Area2FiberLen
    datalen = length(dataobjs  )
    for idx =1:datalen
         dataobj = dataobjs[ idx ]
         通道 = dataobj[pos通道]
         起始位置 = dataobj[pos起始位置]
         结束位置 = dataobj[pos结束位置]
         if 通道 != tongdaoID
              rows = getSpecMachineSlogansInfo( csvInfoSignalID2FiberPos1 = CsvInfoObj.csvInfoSignalID2FiberPos  ,
              machineRegID=machineRegID1,
              通道1=string(通道) )
              tongdaoID= string(通道)
         end

        #print(通道 ," === :",起始位置," ",结束位置,":" )
          
         pos1 = getPos_FiberLen(string(起始位置),rows)
       #  print( "---- ",起始位置,"=>",pos1 )
         dataobj[pos起始位置]= pos1
         pos2 = getPos_FiberLen(string(结束位置),rows)
     #   println( "----  ",结束位置,"=>",pos2 )
         dataobj[pos结束位置] = pos2
        #  println( dataobj )
    end
end

function testCode()
    machineRegID1 = findMachineRegID( csvInfoMachineInfo=csvInfoMachineInfo ,machine友好名="xxxx001")
    通道="2"
    Rows = getSpecMachineSlogansInfo( csvInfoSignalID2FiberPos1=csvInfoSignalID2FiberPos  ,
         machineRegID=machineRegID1,
         通道1=通道)
    # println(machineRegID1)
    位置1="1230"
    posStr = getPos_Signal(位置1,Rows)
    println( 位置1,":",posStr )

    位置1="12310"
    posStr = getPos_Signal(位置1,Rows)
    println( 位置1,":",posStr )

    位置1="100"
    posStr = getPos_Signal(位置1,Rows)
    println( 位置1,":",posStr )
    位置1="24950"
    posStr = getPos_Signal(位置1,Rows)
    println( 位置1,":",posStr )

    位置1="24950"
    posStr = getPos_Signal(位置1,Rows)
    println( 位置1,":",posStr )

    # for row in Rows
    #      println( row[1],"-",row[2])
    # end
end 


function basicInit( CsvInfoObj::CsvInfos)
    CsvInfoObj.csvInfoSignalID2FiberPos = CSVinfo( 
         fieldname =CsvInfoObj.防区表fieldname,
         signalStringName=CsvInfoObj.防区表signalStringName,
         keyFieldNames =CsvInfoObj.防区表keyFieldNames
    )
    readinCSVFile!(CsvInfoObj.csvInfoSignalID2FiberPos,csvfile=CsvInfoObj.防区表filename ) 
    sort!(CsvInfoObj.csvInfoSignalID2FiberPos.Area2FiberLen)
    # show( csvInfoSignalID2FiberPos )

    CsvInfoObj.csvInfoMachineInfo = CSVinfo( 
         fieldname = CsvInfoObj.主机信息表fieldname,
         signalStringName = CsvInfoObj.主机信息表signalStringName,
         keyFieldNames = CsvInfoObj.主机信息表keyFieldNames
    )
    readinCSVFile!(CsvInfoObj.csvInfoMachineInfo,csvfile = CsvInfoObj.主机信息表filename) 
    # show(csvInfoMachineInfo )

    if CsvInfoObj.老版参数表filename !=""
        CsvInfoObj.csvInfoDefencePara= CSVinfo( 
             fieldname =CsvInfoObj.老版参数表fieldname,
             signalStringName =CsvInfoObj.老版参数表signalStringName,
             keyFieldNames =CsvInfoObj.老版参数表keyFieldNames
        )
        readinCSVFile!(CsvInfoObj.csvInfoDefencePara,csvfile=CsvInfoObj.老版参数表filename) 
        sort!(CsvInfoObj.csvInfoDefencePara.Area2FiberLen)
        # show(csvInfoDefencePara )
    end

end