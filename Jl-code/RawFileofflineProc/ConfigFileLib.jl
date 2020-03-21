
function readin!(cfgdata::cfgStruct,datafileName)
    fn = basename( datafileName )
    extensionName1  = uppercase( splitext( fn)[2]  )

    rawdatafileObj= open( datafileName,"r")

    if  extensionName1  in ( ".RAW3"  ,".RAW4"  ,".RAW1",".RAW2")
            seek( rawdatafileObj,512)
            cfgdata.meterperSeg = read( rawdatafileObj, UInt16 )/5000
            cfgdata.chn2SegBegIdx = read( rawdatafileObj, UInt16 )
            cfgdata.reflectorFactor = read( rawdatafileObj, UInt16 )/10000
            cfgdata.attenutionFactor = read( rawdatafileObj, UInt16 )/10000
            cfgdata.scanrate = read( rawdatafileObj, UInt16 )
            cfgdata.calSamples = read( rawdatafileObj, UInt16 )
            cfgdata.SegNumber = read( rawdatafileObj, UInt16 )
    end    
    close( rawdatafileObj )
end

function show( dataObj::RNG )
    println( "RNG Data :-----------------------------------" )
    println( " AlrmProcStartID:$(dataObj.AlrmProcStartID)")
    println( " AlrmProcEndtID1:$(dataObj.AlrmProcEndtID1)")
    println( " startID1:$(dataObj.startID1)")
    println( " endID1:$(dataObj.endID1)")
    println( " chnid:$(dataObj.chnid)")
    println( " ProtectSpaceWidth:$(dataObj.ProtectSpaceWidth)")
    println("----------------------")

end
###################
#############
function seg2Meters( CfgInfoObj::cfgStruct,segID::Int  )
    meter = CfgInfoObj.meterperSeg
    chn2Pos = CfgInfoObj.chn2SegBegIdx
    ## write the title s: 通道号下的光缆 时间、各段的米标 。
    # print( "时间" ,"," )
    # for segID = CumSumDataobj.AlrmProcStartID : CumSumDataobj.AlrmProcEndtID
    if segID  >= chn2Pos;
        return ( round( UInt,Float64(segID-chn2Pos)* meter) ,2 )
    else
        return (round( UInt,Float64( segID  )* meter ),1)
    end
end

function getRNG!( x::RNG,cfgObj::cfgStruct, startMeters::Int ,endmeters::Int ,ProtectMeters::Int,chnid::Int )
    ProtectSegs =  round(Int, Float64( ProtectMeters ) / cfgObj.meterperSeg)+1

    AlrmProcStartID =  round(Int, Float64( startMeters ) / cfgObj.meterperSeg)
    AlrmProcEndtID1 =   round(Int, Float64( endmeters ) / cfgObj.meterperSeg)


    if chnid == 1 ;
        AlrmProcStartID < 1 ? AlrmProcStartID = 1 : 0  ;
        AlrmProcEndtID1 >=  cfgObj.chn2SegBegIdx  ? AlrmProcEndtID1 = cfgObj.chn2SegBegIdx -1 : 0  ;

        startID1 = AlrmProcStartID - ProtectSegs
        endID1 = AlrmProcEndtID1 + ProtectSegs

        startID1 < 1 ? startID1 = 1 :  0 ;
        endID1 >=  cfgObj.chn2SegBegIdx  ? endID1 = cfgObj.chn2SegBegIdx : 0 ;
    else 
        AlrmProcEndtID1 +=  cfgObj.chn2SegBegIdx
        AlrmProcStartID += cfgObj.chn2SegBegIdx

        AlrmProcEndtID1 >  cfgObj.SegNumber  ? AlrmProcEndtID1 = cfgObj.SegNumber :  0 ;
        AlrmProcStartID >  cfgObj.SegNumber  ? AlrmProcStartID = cfgObj.SegNumber :  0 ;

        startID1 = AlrmProcStartID - ProtectSegs
        endID1 = AlrmProcEndtID1 + ProtectSegs

        startID1 < cfgObj.chn2SegBegIdx ? startID1 = cfgObj.chn2SegBegIdx : 0 ;
        endID1 >  cfgObj.SegNumber  ? endID1 = cfgObj.SegNumber :  0 ;
        # println( AlrmProcEndtID1 ,"=======$AlrmProcStartID===$endID1 ===$startID1====")
    end

    x.ProtectSpaceWidth = ProtectSegs

    x.AlrmProcStartID = AlrmProcStartID
    x.AlrmProcEndtID1 = AlrmProcEndtID1
    x.startID1 = startID1
    x.endID1 = endID1
    x.chnid = chnid >= 2 ? chnid =2 : chnid =1;

end    


function setValue!( x::cfgStruct  , y::CfgDataStruct)
    x.meterperSeg     = y.SpatialResolution
    x.chn2SegBegIdx   = y.LenCh1 +1
    x.reflectorFactor = y.Refractivity
    x.attenutionFactor=y.ATT
    x.scanrate        =y.ScanRate
    x.calSamples      = y.EnergyCnt
    x.SegNumber       = y.LenCh1 +y.LenCh2
end
function show( dataObj::CfgDataStruct   )
    println( "Config Data :-----------------------------------" )
    println( " SpatialResolution:$(dataObj.SpatialResolution)")
    println( " Refractivity:$(dataObj.Refractivity)")
    println( " OffsetM:$(dataObj.OffsetM)")
    println( " ATT:$(dataObj.ATT)")
    println( " ScanRate:$(dataObj.ScanRate)")
    println( " EnergyCnt:$(dataObj.EnergyCnt)")
    println( " LcLimitHigh:$(dataObj.LcLimitHigh)")
    println( " LcLimitLow:$(dataObj.LcLimitLow)")
    println( " StartCh1:$(dataObj.StartCh1)")
    println( " LenCh1:$(dataObj.LenCh1)")
    println( " StartCh2:$(dataObj.StartCh2)")
    println( " LenCh2:$(dataObj.LenCh2)")

    # println("----------------------")
end    
function show(cfgdata::cfgStruct)
    println(" meterPerSeg = $(cfgdata.meterperSeg) ")
    println(" chn2SegBegIdx = $(cfgdata.chn2SegBegIdx )")
    println(" reflectorFactor = $(cfgdata.reflectorFactor) ")
    println(" attenutionFactor = $(cfgdata.attenutionFactor) ")
    println(" calSamples = $(cfgdata.calSamples) ")
    println(" scanrate = $(cfgdata.scanrate) ")
    println(" SegNumber = $(cfgdata.SegNumber) ")
end
function readCfgFileData(filename)
    cfgdataObj = CfgDataStruct()
    cfgfileObj= open( filename,"r")

            num  =  read( cfgfileObj, UInt16 )
            cfgdataObj.SpatialResolution =  num*1.0 / 5000.0;			# result.SpatialResolution = (double)array[0] / 5000.0;

            num  =  read( cfgfileObj, UInt16 ) ;
            cfgdataObj.Refractivity =  num*1.0 / 10000.0;	# result.Refractivity = (double)array[1] / 10000.0;

            num  =  read( cfgfileObj, UInt16 ) ;
            cfgdataObj.OffsetM =  num*1.0 ;            		# result.OffsetM = (double)array[2];

            num  =  read( cfgfileObj, UInt16 ) ;
            cfgdataObj.ATT =  num*1.0 / 10000.0; 			# result.ATT = (double)array[3] / 10000.0;
            
            
            num  =  read( cfgfileObj, UInt16 ) ;
            cfgdataObj.ScanRate =  num*1.0  ; 	          # result.ScanRate = (double)array[4];

            num  =  read( cfgfileObj, UInt16 ) ;
            cfgdataObj.EnergyCnt =  num   ;# result.EnergyCnt = (int)array[5];

            num  =  read( cfgfileObj, UInt8 ) ;
            cfgdataObj.LcLimitHigh =  num  *1.0 ;			# result.LcLimitHigh = (double)(array[6] >> 8);


			num  =  read( cfgfileObj, UInt8 ) ;
            cfgdataObj.LcLimitLow =  num   *1.0;	# result.LcLimitLow = (double)((array[6] & 255) - 256);

			num  =  read( cfgfileObj, UInt16 ) ;
            cfgdataObj.StartCh1 =  num    ;			# result.StartCh1 = (int)array[7];

			num  =  read( cfgfileObj, UInt16 ) ;
            cfgdataObj.LenCh1 =  num    ;				# result.LenCh1 = (int)array[8];


			num  =  read( cfgfileObj, UInt16 ) ;
            cfgdataObj.StartCh2 =  num			# result.StartCh2 = (int)array[9];

            num  =  read( cfgfileObj, UInt16 ) ;
            cfgdataObj.LenCh2 =  num          # result.LenCh2 = (int)array[10];

    close( cfgfileObj)
    return cfgdataObj


end  
function read!(x::cfgStruct,filename)
    cfgdataObj  = readCfgFileData(filename)
    setValue!(x,cfgdataObj )

end

function TestRead(filename ="/media/wang/SSDP-128G/code/20190212T131313.conf")
    filename ="/media/wang/SSDP-128G/code/20190212T131313.conf"
    cfgdataObj  = readCfgFileData(filename)
    show(cfgdataObj )
end