using Statistics
using Printf
using Dates

Base.MainInclude.include("dataStruct.jl")
# Base.include(Main, "ConfigFileLib.jl")
Base.MainInclude.include("ConfigFileLib.jl")
const segNum =8192
const maxhistorydataCnt = 2*60 #*60

#######################################################################################################################
extensionName=""
headlen=512
cfglen=14
extensionsAll=( ".RAW1",  ".RAW3" ,".RAW4" ,".LC" ,".RAW" , ) 
extensions1=( ".RAW1",   ".RAW" , ) 
extensions2=( ".RAW2", ".FIL" , ) 
extensions3=(  ".RAW3" , ".LC"  , ) 

mutable struct DatetimeData
    dt::String
end

abstract type NULLDATA
end

###################################################################################
function readin!(rawdatafileObj,cfgdata::cfgStruct)
    global     extensionName
    # println( "readin  ",extensionName )
    if  extensionName  in ( ".RAW3"  ,".RAW4"  ,".RAW1",".RAW2")
            seek( rawdatafileObj,512)
            cfgdata.meterperSeg = read( rawdatafileObj, UInt16 )/5000
            cfgdata.chn2SegBegIdx = read( rawdatafileObj, UInt16 )
            cfgdata.reflectorFactor = read( rawdatafileObj, UInt16 )/10000
            cfgdata.attenutionFactor = read( rawdatafileObj, UInt16 )/10000
            cfgdata.scanrate = read( rawdatafileObj, UInt16 )
            cfgdata.calSamples = read( rawdatafileObj, UInt16 )
            cfgdata.SegNumber = read( rawdatafileObj, UInt16 )
    end    
end


function readin(rawdatafileObj,NULLDATA)
    global     extensionName
    # println( "readin  ",extensionName )
    if  extensionName  in (   ".RAW3"  ,".RAW4"  ,".RAW1",".RAW2")
            seek( rawdatafileObj,512)
            skip( rawdatafileObj,14 )
    end    
end

function readin!(rawdatafileObj,dtdata::DatetimeData)
    global extensionName

    if  extensionName  in (   ".RAW3"  ,".RAW4"  ,".RAW1",".RAW2")
                dtdata.dt=string("")
            # println("===",dtdata.dt,"------------" )
                curpos = position(rawdatafileObj )
                for i in 1:14
                    s =  read( rawdatafileObj,UInt8 ) 
                    dtdata.dt =string( dtdata.dt ,Char(s) )
                end
                s =  read( rawdatafileObj,UInt16)  # readin the type info 
    else
        b1 =  read( rawdatafileObj,UInt8)  # readin the type info 
        b2 =  read( rawdatafileObj,UInt8)  # readin the type info 
        b3 =  read( rawdatafileObj,UInt8)  # readin the type info 
        b4 =  read( rawdatafileObj,UInt8)  # readin the type info 
        dtdata.dt =string("20201012123456" )

        df = Dates.DateFormat("y-m-d");
        jzdt = Dates.DateTime( "2010-1-1" ,df)
        a =  UInt(1)::UInt64
        a= b1*1 +b2*256 +b3*256*256 +b4*256*256*256
        jzdt1= jzdt + Dates.Second( a )
        # print( jzdt1," -----" )
        dtdata.dt =@sprintf( "%04d%02d%02d%02d%02d%02d",Dates.year(jzdt1 ) ,   Dates.month(jzdt1 ), Dates.day(jzdt1 ), Dates.hour(jzdt1 ),Dates. minute(jzdt1 ), Dates.second(jzdt1 ) )
    end
end

function readin!(rawdatafileObj,data::Array{UInt16,1})
    segNumber= length(data )
    # curpos = position(rawdatafileObj )
    for i in 1:segNumber
        s =  read( rawdatafileObj, UInt16 ) 
        data[i]=s
    end
 
end

## THE SPEED SLOW THEN ABOVE CODE 
function readin1!(rawdatafileObj,data::Array{UInt16,1})
    segNumber= length(data )
 
    gr = reinterpret(UInt8,data)
    readbytes!( rawdatafileObj,  gr )

end



function show(dtdata::DatetimeData)
    print( dtdata.dt[1:4] , "-",dtdata.dt[5:6], "-", dtdata.dt[7:8] ,"  " ,dtdata.dt[9:10]  ,":", dtdata.dt[11:12] , ":",dtdata.dt[13:14]," ," )
end

function showRawData( ID , Dtdata::DatetimeData,RowData::Array{UInt16,1} )
    print( "ID :$ID  " ) 
    show(Dtdata   )
    println("data len is :$(length(RowData)  )"  )
end

function  writeTitle(CumSumDataobj)
    meter = CumSumDataobj.CfgInfoObj.meterperSeg
    chn2Pos = CumSumDataobj.CfgInfoObj.chn2SegBegIdx
    ## write the title s: 通道号下的光缆 时间、各段的米标 。
    print( "时间" ,"," )
    for segID = CumSumDataobj.AlrmProcStartID : CumSumDataobj.AlrmProcEndtID
        if segID  >= chn2Pos;
            print( round( UInt,Float64(segID-chn2Pos+1)* meter) ,"  $segID 米," )
        else
            print( round( UInt,Float64( segID  )* meter )," $segID 米," )
        end
    end
    println(   )
end

function saveLogInfo(spaceCumSumDataObj ,row  )
f=open("tem001.data","a")
for i in  row;
    print(f,i,",")
end
println(f)
close(f)
end

function readinDatainFile( filename,spaceCumSumDataObj ,Count=-1)
    global extensionName
    fn = basename( filename )
    extensionName  =uppercase( splitext( fn)[2]  )
    # println(  abspath( filename ) ,"   ",fn,"   " ,extensionName ,"   ",splitext( fn)[1]   )
    if  extensionName == ".RAW1"  ||   extensionName  == ".RAW"
        SegNumber =8192*512
    elseif  extensionName  in (   ".RAW3"  ,".RAW4"  ,".LC")
        SegNumber =8192*1
    end

    rawdatafileObj= open( filename,"r")
    # cfgdata =  cfgStruct()
    # readin!(rawdatafileObj,cfgdata)
    readin(rawdatafileObj,NULLDATA)
    # historyNum =3
    cnt=1
    dtdata = DatetimeData("")
    row = Array{UInt16,1}(undef,SegNumber) 


    while( !eof(rawdatafileObj ) )
            readin!(rawdatafileObj,dtdata)
            readin!(rawdatafileObj,row)
            setDTValue( spaceCumSumDataObj , dtdata.dt)
            #@time
            # saveLogInfo(spaceCumSumDataObj ,row  )
            postProcFeatureData(spaceCumSumDataObj ,row )
            cnt= cnt+1
            if cnt > Count && Count >= 0
                break
            end
        end
    close( rawdatafileObj )
end

function getAllfiles( rootfolder ,extensions=( ".RAW1",  ".RAW3" ,".RAW4" ,".LC" ,".RAW" , ) )
    fns= []
    # rootfolder=cwd
    for  (root, dirs, files) in  walkdir(rootfolder)
        for fn  in files
               extensionName  =uppercase( splitext( fn)[2]  )
                if  extensionName in extensions
                    fullname = joinpath(root, fn )
                    push!(fns ,  fullname)
                    # println(fullname) # path to files
                end
        end
    end
    return fns
end #getAllfiles

function entryFun( fns  ,spaceCumSumDataObj,Count =-1 )
    for  file in fns
        println( "\n\nFilename: $file")
        readinDatainFile( file,spaceCumSumDataObj,Count )
        println()
    end 
end

############################
function calInternal(chnid,startMeters ,endmeters,maxTimeCnt1, dataFilename ,cfgfilename ="", ProtectMeters =50)
    cfgObj = cfgStruct()
    aRNG = RNG()
    CalObj = spaceCumSumData( ) 
    if  cfgfilename != ""  ;
        read!(cfgObj,cfgfilename)
    else
        readin!(cfgObj,dataFilename)
    end
    show( cfgObj  )
    getRNG!( aRNG,cfgObj, startMeters ,endmeters ,ProtectMeters,chnid )
    show( aRNG)
    CalObj.CfgInfoObj = cfgObj
    InitObj(CalObj, aRNG.AlrmProcStartID,aRNG.AlrmProcEndtID1 , aRNG.startID1 ,aRNG.endID1,maxTimeCnt1 )
   
    if typeof(dataFilename) == String 
        tfiles=[dataFilename, ]
    else
        tfiles = dataFilename
    end
    writeTitle(CalObj) 
    entryFun( tfiles  ,CalObj,maxTimeCnt1 )
end

function calPT(chnid,startMeters ,endmeters,maxTimeCnt1, dataFilename , ProtectMeters =50)
    cfgfilename =""
    return calInternal(chnid,startMeters ,endmeters,maxTimeCnt1, dataFilename ,cfgfilename  , ProtectMeters  )
end


function calPTFiles(chnid,startMeters ,endmeters,maxTimeCnt1, dataFilenames , ProtectMeters =50)
    if typeof(dataFilenames) == String 
        tfiles=[dataFilenames, ]
    else
        tfiles = dataFilenames
    end

    if length(tfiles ) <1 
        return -1;
    end
        dataFilename = tfiles[1]
        cfgObj = cfgStruct()
        aRNG = RNG()
        CalObj = spaceCumSumData( ) 
        readin!(cfgObj,dataFilename)
        show( cfgObj  )
        getRNG!( aRNG,cfgObj, startMeters ,endmeters ,ProtectMeters,chnid )
        show( aRNG)
        CalObj.CfgInfoObj = cfgObj
        InitObj(CalObj, aRNG.AlrmProcStartID,aRNG.AlrmProcEndtID1 , aRNG.startID1 ,aRNG.endID1,maxTimeCnt1 )
        writeTitle(CalObj)
        # entryFun( dataFilename  ,CalObj,maxTimeCnt1 )
        for dataFilename in tfiles
            # println( "\n\nFilename: $dataFilename")
            readinDatainFile( dataFilename,CalObj,maxTimeCnt1 )
            # println()
        end
        return 0
end




function GetMachinenameFromFilename(filename)

    # tgrname :Data^Ver00^GYYS-001^20190304090024^ID00.*
    a= split(filename,"^")
    if length(a ) >=5
        return a[3]
    else
        return "OFFline-0001"
    end
end 

function readinPT_1_File( filename,cfgObj::cfgStruct )
    global extensionName
    # @warn "Will Put Data into Channel....."
    fn = basename( filename )
    extensionName  =uppercase( splitext( fn)[2]  )
    println(  abspath( filename ) ,"   ",fn,"   " ,extensionName ,"   ",splitext( fn)[1]   )
    if  extensionName == ".RAW1"  ||   extensionName  == ".RAW"
        SegNumber =8192*512
    elseif  extensionName  in (   ".RAW3"  ,".RAW4"  ,".LC")
        SegNumber =8192*1
        
    end
    if extensionName == ".RAW3"
        rawDatatype =0x0003
    elseif extensionName == ".RAW1"
        rawDatatype =0x0001
    elseif extensionName == ".RAW4"
        rawDatatype =0x0004  
    elseif extensionName == ".RAW2"
        rawDatatype =0x0002  
    end
    rawdatafileObj= open( filename,"r")
    readin(rawdatafileObj,NULLDATA)
    # println("1")
    cfgArray = Array{UInt16,1}(undef,7)
    cfgArray[1] = floor(UInt16,cfgObj.meterperSeg*5000)
    cfgArray[2] = cfgObj.chn2SegBegIdx
    cfgArray[3] = 0 #reflectorFactor::Float64
    cfgArray[4] = 0 #attenutionFactor::Float64
    cfgArray[5] = cfgObj.scanrate
    cfgArray[6] = cfgObj.calSamples
    cfgArray[7] = cfgObj.SegNumber

    show( cfgObj )
    # return 
    cnt=1
    dtdata = DatetimeData("")
    machineName=GetMachinenameFromFilename(fn) 
    while( !eof( rawdatafileObj ) )
        # println("1")
        aobj = fileFiberRawData(SegNumber)
        dtstr = ""
        row = Array{UInt16,1}(undef,SegNumber) 
            readin!(rawdatafileObj,dtdata)
            for i =1:length( dtdata.dt)
                aobj.startDTStr[i] = dtdata.dt[i]
                dtstr  = string(dtstr,Char(dtdata.dt[i]) ) 
            end

            if Main.startTime != "" &&  Main.endTime != ""
                # @info dtstr, Main.startTime , Main.endTime
                if  dtstr >=  Main.startTime &&  dtstr <= Main.endTime
                    ;
                else
                    # @info  "Not in time RNG "
                    skip(rawdatafileObj, length( row) *2 )
                    continue
                    # close( rawdatafileObj )
                    # return 
                end
            end
            readin!(rawdatafileObj,row)
            aobj.datas .= row
            aobj.rawDatatype =  rawDatatype 
            for i =1:length( machineName)
                aobj.machineName[i] = machineName[i]
            end
            len = length( machineName ) +1
            aobj.machineName[len] = 0x00
            
            aobj.cfgdata .= cfgArray
            # print("+")
            # global fileRawDataChannel
            # @warn "Will Put Data into Channel....."
            put!( Main.fileRawDataChannel ,aobj )
            # println(".+")
    end
    close( rawdatafileObj )
end

function fetchOfflineFiberDatas(fdobj)

    aobj = take!(  Main.fileRawDataChannel   )

    fdobj.rawDatatype[] = aobj.rawDatatype
    
    fdobj.machineName .= aobj.machineName
    fdobj.startDTStr .= aobj.startDTStr 
    fdobj.cfgdata .= aobj.cfgdata
    # println( getStringFromArray( fdobj.machineName  ) )
    len =aobj.actualData
    @views a = fdobj.datas[1:len]
    a .= aobj.datas

    actualDatabytes = length( aobj.datas )*2
    fdobj.actualDatabytes = Ref{Cint}(actualDatabytes)
    # exit(-1)
end

function readinPTFiles( dataFilenames)
    # @warn "po？p"
        # println( dataFilenames )
        if typeof(dataFilenames) == String 
            tfiles=[dataFilenames, ]
        else
            tfiles = dataFilenames
        end

        if length(tfiles ) <1 
            println("No files found ,Exit out !!")
            exit(0)
            return -1;
        end

        for dataFilename in tfiles
            cfgObj = cfgStruct()
            # println( dataFilename )
            readin!(cfgObj,dataFilename)
            # println( dataFilename )

            # t = calPeriodLen(dataFilename )

            readinPT_1_File( dataFilename ,cfgObj)
            # println( dataFilename )
        end
        @warn "------------will exit---------cur time is :", Dates.now()
        println( "All File is Processed . will Exit out After 10 Seconds ...." )
        sleep(10)
        exit(0)
        return 0
end

