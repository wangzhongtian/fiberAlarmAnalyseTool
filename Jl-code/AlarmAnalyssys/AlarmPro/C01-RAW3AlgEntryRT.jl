module SegParaAlarmProc
    using Dates
    using  Base.Threads
    CalChn1_2Obj = nothing

    include("../../CSVParas/GetSegParaFromCSV.jl")
    include( "../../common/eventL1.jl")

    include("../../RawFileofflineProc/dataStruct.jl")
   
    include("Init.jl")
    include("cumSumAlg.jl")
    include("../../common/ConfigFileLib.jl")
    include("AlarmGen.jl")
    include("../../RawFileofflineProc/ReadFiberData.jl")
    include("../../RawFileofflineProc/BaseLib.jl")

    include("../../common/SegAlarmIDPara.jl")    
    include("timeSchmidtAlg.jl")
    include("spaceSchmidtAlg.jl")

    include( "../../common/AlarmMergeLayer.jl")
    include("../WindProc/WindIDRAW3AlgEntryRT.jl")
    include("../../common/outputConvert.jl")
    function showSegDictData(glbSegAlarmParasDictObj)
        a = collect( keys( glbSegAlarmParasDictObj ) )
        sort!( a )
        for key in a
            print(key,": ")

            valTuple =glbSegAlarmParasDictObj[ key ]
            println(
            valTuple.microtime.StaticThreshold == typemax( Int ),",",
            valTuple.microtime.DynamicThreshold_CalTimePeriod ,",",
            valTuple.microtime.DynamicThresHold_calCFactor ,",",
            valTuple.microtime.minTh ,",",
            valTuple.microtime.maxTh ,",",
            #微观过滤和合并 时间
            valTuple.microtime.microMergeTimePeriod,",",
            valTuple.microtime.microFilterTimePeriod,",",
            
            #微观过滤和合并 空间
            valTuple.microSpace.microMergeSpaceLength,",",
            valTuple.microSpace.microFilterSpaceLength,",",
            
            #宏观 空间 限制范围
            valTuple.macroSpace.macroMaxSpaceLength,",",
            valTuple.macroSpace.macroMinSpaceLength,",",
            #宏观 时间  限制范围
            valTuple.macroTime.macroMaxTimeInterval,",",
            valTuple.macroTime.macroMinTimeInterval,"\r\n"
            )
        end

    end

    function AlramProc(CalChn1_2Obj, row,FrameCnt )
        # println( " spaw-----------------------------0-----------------------n loope in  proloop2 ")
         postProcFeatureData(CalChn1_2Obj ,row ) #AlarmGen.jl
        #  println( " spaw-----------------------------1-----------------------n loope in  proloop2 ")
         FeaturetimeSchmidt( CalChn1_2Obj.dt ,FrameCnt)  #timeSchmidtAlg
        #  println( " spaw------------------------2----------------------------n loope in  proloop2 ")
        updateSpaceStatus( ) #spaceSchmidtAlg
        # println( " spaw------------------------3----------------------------n loope in  proloop2 ")
    end
    # ghDLL = nothing 
    # Libdl.dlopen("$RawProcDLLName")
    function RAW3AlgEntryC01(isOnline = true)
        global CalChn1_2Obj #,ghDLL
        # ghDLL = Libdl.dlopen("$RawProcDLLName")
        # @info "Data RAW3AlgEntryC01"
        FrameCnt=UInt(0)
        if isOnline 
            # @warn "Online Now"
            fecthDataFunc = Main.fetchFiberDatas 
        else
            fecthDataFunc = fetchOfflineFiberDatas 
        end
        # @warn "---------------------- Completed"
        lastWriteDT= UInt(0)
        cfgObj = cfgStruct()
        # @warn "------------00--------- Completed"

        fdobj = FiberRawData()
        # @warn "------01------------------------------- Completed"#, fdobj
        fecthDataFunc( fdobj )
        # @warn "------fecthDataFunc-02-------------------------------- Completed"
        readin!(cfgObj,fdobj.cfgdata)
        # @warn "--------------03------------------------- Completed" , fdobj.machineName
        Name = getStringFromArray( fdobj.machineName )
        println("Machine name is $Name,-----")
        evs ="machineName =\"$Name\""
        reps = Base.Meta.parse( evs )
        Core.eval( Main,reps )
        # @warn "-----+++++---------2--------------===------------- Completed"

        INIT( cfgObj )


        
        # @warn "--------------3------------------------- Completed"
        CalChn1_2Obj = spaceCumSumData( ) 
        # @warn "--------------6-------- Completed"
        InitObj(CalChn1_2Obj, Int(1),Int(cfgObj.SegNumber), Int(1),Int(cfgObj.SegNumber),-1 );
        CalChn1_2Obj.CfgInfoObj = cfgObj
        InitSegAlarms() #AlarmAnalyssys\AlarmPro\spaceSchmidtAlg.jl
        # @warn "---------------------- Completed"
        # println("WindID.Init----- ")
        WindID.Init( cfgObj ) #include("../AlarmAnalyssys/RAW3Alg-RTWind20190417/C01-RAW3AlgEntryRT.jl")
        # @warn "---------------------- Completed"

        EventL1.Init("Event")
        AlarmMerge.AlarmReport.Init("Alarm")
        WindID.fileLog_wind.Init("Wind");
        AlarmMerge.initMergeCfg( MergeWidth1 = UInt(1 ) , MergeTime1 = UInt( 2*60 ) )

        while true
            FrameCnt = FrameCnt + 1
            # println("in 1")
            fdobj = FiberRawData()
               fecthDataFunc( fdobj )
            # println("in 2")
            if fdobj.rawDatatype[] == 0x0003
                a=""
                for i = 1: length(fdobj.startDTStr )
                    a =string(a,string(Char( fdobj.startDTStr[i]) ))
                end
                CalChn1_2Obj.dt = a
                dataNum = fdobj.actualDatabytes[]/2
                row = fdobj.datas
                # 
                  WindID.WindProc(row, a ,fdobj.machineName) #include("../RAW3Alg-RTWind20190417/WindIDRAW3AlgEntryRT.jl")
                  
                  AlramProc(CalChn1_2Obj, row,FrameCnt )
                    #  println(" actual algrithm end:----------------------------------------------")
            end
        end
    end
end #module SegParaAlarmProc
