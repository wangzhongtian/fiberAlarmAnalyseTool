using Base.Filesystem

function writehead(tgrfileObj )
    for i=1:512
        Base.write(tgrfileObj,0x00::UInt8 )
    end
end
function writeDataSize(tgrfileObj )
    Base.write(tgrfileObj,0x00::UInt8 )
    Base.write(tgrfileObj,0x02::UInt8 )
end

###################################################################################

function write(tgrfileObj, cfgdata::cfgStruct)
        writehead(tgrfileObj )
        cfgdatas = Array{UInt16,1}(undef,7)
        cfgdatas.=0x0000
        cfgdatas[1] =floor(UInt16,(cfgdata.meterperSeg *5000+0.001) ) 
        cfgdatas[2] =cfgdata.chn2SegBegIdx
        cfgdatas[3] =floor(UInt16,(cfgdata.reflectorFactor *10000+0.001) ) 
        cfgdatas[4] =floor(UInt16,(cfgdata.attenutionFactor *10000+0.001) ) 
        cfgdatas[5] =cfgdata.scanrate
        # cfgdatas[1] =floor(Uint16,(cfgdata.meterperSeg *5000) ) 
        cfgdatas[6] =cfgdata.calSamples 
        cfgdatas[7] =cfgdata.SegNumber 
        cfgString= reinterpret(UInt8, cfgdatas)

        Base.write(tgrfileObj,cfgString   )
        pos2=position( tgrfileObj )
        println( "Position  :",pos2," ,",cfgdata.meterperSeg )
        # for i =1:7
        #     println( cfgdatas[i] )
        # end
        # println()
        # exit()

end

function write(  tgrfileObj,dtdata::DatetimeData )
    # dt
    pos1=position( tgrfileObj )
    Base.write(tgrfileObj,dtdata.dt )
    writeDataSize(tgrfileObj )
    pos2=position( tgrfileObj )
    # println( "write Length :",pos2-pos1)

end

function write(  tgrfileObj,row::Array{UInt16,1} )
    pos1=position( tgrfileObj )
    data8Array= reinterpret( UInt8,  row)
    Base.write(tgrfileObj, data8Array );
    pos2=position( tgrfileObj )
    # println( "write Length :",pos2-pos1)
end

function Trasfer1File( dataFilename ,cfgfilename,tgrfileObj)
    chnid=1
    startMeters=0
    endmeters=1000000
    maxTimeCnt1=-1
    ProtectMeters=5000
    cfgObj = cfgStruct()
    # aRNG = RNG()
    CalObj = spaceCumSumData( ) 
    read!(cfgObj,cfgfilename)
    write(tgrfileObj, cfgObj)
    show( cfgObj  )
    # getRNG!( aRNG,cfgObj, startMeters ,endmeters ,ProtectMeters,chnid )
    # show( aRNG)
    # CalObj.CfgInfoObj = cfgObj
    # InitObj(CalObj, aRNG.AlrmProcStartID,aRNG.AlrmProcEndtID1 , aRNG.startID1 ,aRNG.endID1,maxTimeCnt1 )
    readinDatainFile( dataFilename,CalObj,tgrfileObj,maxTimeCnt1 )
end

function readinDatainFile( filename,spaceCumSumDataObj ,tgrfileObj,Count=-1)
    global extensionName
    fn = basename( filename )
    extensionName  =uppercase( splitext( fn)[2]  )
    SegNumber=8192
    println(  abspath( filename ) ,"   ",fn,"   " ,extensionName ,"   ",splitext( fn)[1]   )
    if  extensionName == ".RAW1"  ||   extensionName  == ".RAW"
        SegNumber =8192*512
    elseif  extensionName  in (   ".RAW3"  ,".RAW4"  ,".LC")
        SegNumber =8192*1
    end

    rawdatafileObj= open( filename,"r")
    readin(rawdatafileObj,NULLDATA)
    cnt=1
    dtdata = DatetimeData("")
    row = Array{UInt16,1}(undef,SegNumber) 

    while( !eof(rawdatafileObj ) )
        try
            readin!(rawdatafileObj,dtdata)
            readin!(rawdatafileObj,row)
            # setDTValue( spaceCumSumDataObj , dtdata.dt)
            write(  tgrfileObj,dtdata )
            #@time
            # saveLogInfo(spaceCumSumDataObj ,row  )
            write(  tgrfileObj,row )
            # postProcFeatureData(spaceCumSumDataObj ,row )
            cnt= cnt+1
            if cnt > Count && Count >= 0
                break
            end
        catch(e)
            println("File End :$e")
        end
        end
    close( rawdatafileObj )
end


function transferfiles( files,confgfilename,ext )
    # ext=".RAW4"
    for dataFilename in files
        println( dataFilename)
        # tgrfilename = dirname( dataFilename )
        # basefilename = basename(dataFilename)
        extensition = splitext(dataFilename)
        tgr =  extensition[1] * ext
        tgr =  gettgrFilename(dataFilename) 
        tgrfileObj = open(tgr,"w+")
		#if ispath( dataFilename) 
        		Trasfer1File( dataFilename ,confgfilename,tgrfileObj)
		# else
		# 		close(tgrfileObj )
		# 		break
		# end
        close(tgrfileObj )
        # break
    end
end

function getmachineID()
    return Main.machineID
    return "Test-001"
end

function renamefiles( files )
    # ext=".RAW4"
    for dataFilename in files
        # println( dataFilename)
        if occursin("^", dataFilename)
            #println( dataFilename)
            continue
        end
        folder = dirname( dataFilename )
        basefilename = basename(dataFilename)
        filename,ext = splitext(basefilename)
        #println( folder," ", basefilename, " ",filename," ",ext," "  )
        fn = replace(filename,Pair("T","") )
        tgrname= "Data^Ver00^$(getmachineID())^"* fn*"^ID00"*ext
        fullname= joinpath( folder,tgrname)
        println( fullname )
        mv(dataFilename ,fullname  )
        # tgr =  extensition[1] * ext
        # tgrfileObj = open(tgr,"w+")
        # Trasfer1File( dataFilename ,confgfilename,tgrfileObj)
        # close(tgrfileObj )
        # break
    end
end

function gettgrFilename(srcname)
        if occursin("^", srcname)
            #println( dataFilename)
            return ""
        end
        folder = dirname( srcname )
        basefilename = basename(srcname)
        filename,ext = splitext(basefilename)
        #println( folder," ", basefilename, " ",filename," ",ext," "  )
        fn = replace(filename,Pair("T","") )
        ext =uppercase( ext )
        ext = replace(ext,Pair(".RAW",".RAW1"))
        ext = replace(ext,Pair(".LC",".RAW3"))
        ext = replace(ext,Pair(".ENERGY",".RAW4"))        
        tgrname= "Data^Ver00^$(getmachineID())^"* fn*"^ID00"*ext
        fullname= joinpath( folder,tgrname)
        println( fullname )
        return fullname
        # mv(srcname ,fullname  )
end
