using Dates
using Printf
using Libdl
using Sockets
@static if Base.Sys.islinux()
    # RawProcDLLName = joinpath( pwd(),"../Jl-Aux/dll/RawProc.so"  )
	extention =".so"
   # RawDataSaveDLLName= "RawProc"
    # ghDLLRawProc = Libdl.dlopen(RawProcDLLName)
else
	extention =".dll"
    #RawProcDLLName = joinpath( pwd(),"../Jl-Aux/dll/RawProc.dll" )
    # RawDataSaveDLLName= "RawDataSave.dll"
    # ghDLLRawProc = Libdl.dlopen(RawProcDLLName)
end

ghDLLRawProc = nothing 
fetchJuliaFilepointer =nothing
function dllLoad()
    println(Base.@__MODULE__,"================" )
    global ghDLLRawProc 
    RawProcDLLName = "RawProc"*extention
    @warn "try load dll:",RawProcDLLName ,ENV["LD_LIBRARY_PATH"]
    
    ghDLLRawProc = Libdl.dlopen(RawProcDLLName)
    @warn RawProcDLLName " dll load ok" ghDLLRawProc
    # Name = ghDLLRawProc
    # baseGlbPath= replace(baseGlbPath,"\\"=>"/")
    eval("Main.ghDLLRawProc=ghDLLRawProc")
    return
end

Base.MainInclude.include("clearFolderlst.jl")

function gettupleFromStr(str::String ,idx )  
    len =length( str )
    if idx <= len
        return str[ idx]
    else
        return Char(0x00)
    end
end
# ghDLL = nothing
function Init(needSaveFile,needJuliaSend ,Logfolder,  folderA, folderB,NeedFlowControl ) 
    println(Base.@__MODULE__ )
    global fetchJuliaFilepointer
    global ghDLLRawProc 
    @warn "Init "
    # global ghDLL
    println( "------------------------------1-Init------------------------------")
    # println( "-------------------------------2------------------------------")
    @warn "init 1:::",Logfolder, ",", folderA,",", folderB,needSaveFile,needJuliaSend

    #initSaveData = Libdl.dlsym( Main.ghDLLRawProc,:initSaveData ) 

    initSaveData = Libdl.dlsym( Main.ghDLLRawProc,:initSaveData ) 
   @warn    "----- initSaveData:"  initSaveData
    # println( "------------------------------3-------------------------------")
    t = ccall(initSaveData, 
    Int32,
    (Cstring ,Cstring, Cstring ),
    Logfolder,  folderA, folderB) 
    @warn "init 2:::"

   # initJuliaData = Libdl.dlsym(Main.ghDLLRawProc,:initJuliaData )
    initJuliaData = Libdl.dlsym(Main.ghDLLRawProc,:initJuliaData )
@warn    "----- initJuliaData:"  initJuliaData
    t = ccall( initJuliaData , 
    Cint,
    (Cuchar  ,Cuchar,Cuchar ),
    needSaveFile,  needJuliaSend,NeedFlowControl) 
    @warn "init 2:::"
    # initJuliaData( bool needSaveFile, bool needJuliaSend );
    # println( "------------------------------4-------------------------------")

     @warn "..............  ............fetchFiberDatas  Entered.."  ghDLLRawProc   :fetchJuliaFile 
    fetchJuliaFilepointer = Libdl.dlsym(ghDLLRawProc,:fetchJuliaFile ) # fetchJuliaFile
	@warn "fetchFiberDatas  leaved.."   fetchJuliaFilepointer


end

function StartupMainThread(  ) 
    println( "------------------------------1--StartupMainThread-----------------------------")    
    global ghDLLRawProc 
    startProcessRawData = Libdl.dlsym(ghDLLRawProc,:startProcessRawData )
    t = ccall( startProcessRawData , 
    Cvoid,
    ( ) ) 
end
function InitIPAddressSvr(IpStr,Port ) 
    println(Base.@__MODULE__ )
    global ghDLLRawProc 
    println( "------------------------------1--InitIPAddressSvr-----------------------------")    
    IpStr1 = IpStr
    if IpStr =="0.0.0.0"
        IpStr1= string( Sockets.getipaddr() )
    end
    println( IpStr1 )


    initSvrIP = Libdl.dlsym(ghDLLRawProc,:initSvrIP )
    t = ccall( initSvrIP, 
    Cvoid,
    (Cstring ,UInt16  ),
    IpStr1,  Port ) 
end

function waitAllComplete()
    while true
        sleep(60*100);
        println("Continue...")
    end
end

function ClearExpiredFiles(RAW1MaxSpace, RAW2MaxSpace, RAW3MaxSpace, RAW4MaxSpace,Unit,root1,root2="")
    @warn "ClearExpiredFiles :::"
    # println( "RAW1 MaxSpace:$RAW1MaxSpace Mib,RAW2 MaxSpace:$RAW2MaxSpace Mib,RAW3 MaxSpace:$RAW3MaxSpace Mib,RAW4 MaxSpace:$RAW4MaxSpace Mib" )
    while true 
        # println( "start clear expired files,-$root1:$(now() )- ")
        getSizes( root1 ,RAW1MaxSpace, RAW2MaxSpace, RAW3MaxSpace, RAW4MaxSpace,Unit)
        # println( "Complete clear expired files,--$root1:$(now() )-")
        println()
        sleep(10)
        if root2 != ""
            # println( "start clear expired files,-$root2:$(now() )- ")
            getSizes( root2 ,RAW1MaxSpace, RAW2MaxSpace, RAW3MaxSpace, RAW4MaxSpace,Unit)
            # println( "Complete clear expired files,--$root2:$(now() )- ")
        end
        sleep(200)
    end
end


const constbufferbyteSize =512*8192 
mutable struct  FiberRawData 
    rawDatatype::Ref{Cshort}
    machineName::Array{UInt8,1}
    startDTStr::Array{UInt8,1} 
    cfgdata::Array{UInt16,1} 
    datas::Array{UInt16,1}
    actualDatabytes::Ref{Cint}
    function FiberRawData()
        rawDatatype = Ref{Cshort}(0)
        machineName=Array{UInt8,1}(undef,20)
        startDTStr=Array{UInt8,1}(undef,14) 
        cfgdata=Array{UInt16,1}(undef,7)
        datas=Array{UInt16,1}(undef, constbufferbyteSize )
        actualDatabytes=Ref{Cint}(0)
        new(rawDatatype ,machineName , startDTStr, cfgdata, datas, actualDatabytes   )
    end
end

const constbufferbyteSize =512*8192 
mutable struct  fileFiberRawData 
    rawDatatype::UInt16
    machineName::Array{UInt8,1}
    startDTStr::Array{UInt8,1} 
    cfgdata::Array{UInt16,1} 
    datas::Array{UInt16,1}
    actualData::UInt
    function fileFiberRawData(actualData)
        rawDatatype = 0
        machineName=Array{UInt8,1}(undef,20)
        startDTStr=Array{UInt8,1}(undef,14) 
        cfgdata=Array{UInt16,1}(undef,7)
        datas=Array{UInt16,1}(undef, actualData )
        # actualDatabytes=Ref{Cint}(0)
        
        new(rawDatatype ,machineName , startDTStr, cfgdata, datas , actualData   )
    end
end

function ShowContent( fdo::FiberRawData)
    println("-------------------------------")
    println( fdo.rawDatatype[] )
    println( String(fdo.startDTStr))

    mn = String(fdo.machineName )
    j=1
    for i = 1:20
        if !isprint( mn[i] )
            break
        end
        j = i
    end
    # println( j)
    a =mn[1:j]
    println( ( a   ) )
    
    # println( ( fdo.machineName   ) )
    println( fdo.actualDatabytes[]  )
end
# Ptr{UInt8},Ptr{UInt8},Ptr{UInt8},Ptr{UInt8} ,In
function fetchFiberDatas(fdobj)
    # type1=Ref{Cshort}(0)
    # println("---fetchFiberDatas")
    # @warn "fetchFiberDatas  Entered.."  ghDLLRawProc   Main.fetchJuliaFilepointer
    #fetchJuliaFile1 = Libdl.dlsym(ghDLLRawProc,:fetchJuliaFile ) # fetchJuliaFile
	# @warn "fetchFiberDatas  leaved.."   Main.fetchJuliaFilepointer  fetchJuliaFilepointer
	# println("234324324")
    t = ccall( fetchJuliaFilepointer,   
        Cint,
        (Ref{Cshort},Ptr{UInt8},Ptr{UInt8},Ptr{UInt8},Ptr{UInt8},Ref{Cint}),
        fdobj.rawDatatype,
        fdobj.machineName ,
        fdobj.startDTStr ,
        pointer(reinterpret(UInt8,fdobj.cfgdata)),
        pointer(reinterpret(UInt8,fdobj.datas) ) ,fdobj.actualDatabytes
    );
    #  @warn "fetchFiberDatas  Exit .."
    #println( t )
    if t == 0 
        println("--------Exception:Cannot get Socket Data in expected Time ")
        exit(-1)
    else
       
    end
    # println( fdobj.rawDatatype,"=================================")
    # ShowContent( fdobj)
end

function getCfg( cfgJl::String )
    evs =""
    cfgObj =open( cfgJl,"r")
    skip( cfgObj,3)
    for line in Base.readlines(cfgObj)
        if  strip( line ) != "" && line[1:1] != "#"
            evs = evs *line *"; "
        end
    end

    reps = Base.Meta.parse( evs )
    # println( reps )
    Core.eval(Main,reps )
end



function getStringFromArray( machineName::Array{UInt8,1})
    a=0
    for a1 in machineName
        if a1 == 0x00
            break
        else
            a +=1
			if a>=8
			break
		end
        end
    end 
    if a >0
        return String(machineName[ 1:a ])
    else
        return "NO-Name"
    # println("here ",String(machineName[ 1:a ]) )
    end
end


const baseDatetime ="20170211"*"000000"
glbjzdt = Dates.DateTime(2017,02,11)

function DT2UInt( DT::String,format1="yyyymmddHHMMSS"  )
    # return UInt(100)
    # df = Dates.DateFormat(format1);
    
    # curdt = Dates.DateTime(DT,format1)
    year = parse( UInt,DT[1:4])
    month= parse( UInt,DT[5:6])
    day= parse( UInt,DT[7:8])
    hour= parse( UInt,DT[9:10])
    minute=  parse( UInt,DT[11:12])
    secs= parse( UInt,DT[13:14])
    curdt = Dates.DateTime(year,month,day,hour,minute,secs)
    a =  curdt- glbjzdt 

    return  floor(UInt,a.value/1000)
    # return  floor(UInt,curdt.value/1000)
end

function UInt2DTStr( DT::UInt,format1="yyyymmddHHMMSS" )
    # try
        # df = Dates.DateFormat("yyyymmddHHMMSS");
        # jzdt = Dates.DateTime(baseDatetime  ,df )
        # a =  UInt(1)::UInt64
        # a= b1*1 +b2*256 +b3*256*256 +b4*256*256*256
        jzdt1 = glbjzdt + Dates.Second( DT )
        # print( jzdt1," -----" )
        dt =@sprintf( "%04d.%02d.%02d %02d.%02d.%02d",Dates.year(jzdt1 ) ,   Dates.month(jzdt1 ), Dates.day(jzdt1 ), Dates.hour(jzdt1 ), Dates.minute(jzdt1 ), Dates.second(jzdt1 ) )
        return dt
    # catch(e )
    #     println(e)
    #     return "2000.10.10.00.10.00"
    # end
end
   
function showCurDT2File(lastWriteDT::UInt, curDt::UInt)::UInt
    # return 0::UInt
    if curDt - lastWriteDT < 120
        return  UInt(0);
    end

    info1 = "CurDatatime=" *string(curDt )*"\r\n"
    fileLog_wind.LogEvent(info1);
 
    a1 = Dates.now() 
    # interval = (a1 - lasttime ) 
    # if interval.value > 1*60*1000
    #    lasttime = a1
    # @warn  "Computer time is :" ,a1 
    @warn  "CurDatatime=" *string(curDt )* ","*UInt2DTStr( curDt )   *"" ," ;Computer time is :" ,a1 
    return curDt
end

