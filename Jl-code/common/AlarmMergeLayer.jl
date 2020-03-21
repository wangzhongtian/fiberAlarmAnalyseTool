module AlarmMerge

    include( "AlrmReport.jl")
    using Printf
    mutable struct AlarmInfo
        AlarmID::String
        S1::UInt
        S2::UInt
        SC::UInt
        t0::UInt
        tfresh::UInt
        Tc::UInt
        function AlarmInfo()
            new()
        end
    end

    AlarmInfoHistory = Dict() 
    MergeWidth = 0 #In Grain or Seg
    MergeTime  = 0

    ####################################################################
    function FreshAlarmInfoDict( )
        for key1   in keys(AlarmInfoHistory)
            data  = AlarmInfoHistory[ key1 ]
            if data.tfresh - curtime >= 30*60 # 至少保存30分钟的历史数据
                delete!( AlarmInfoHistory ,key1 )
            end
        end
    end

    function getAlarmIDPre()
        a=Base.Libc.time();
        b=floor(UInt,100a);
        return b
    end

    function IsinSpaceRange(a::AlarmInfo,es1::UInt,es2::UInt,timetick::UInt )::Bool
        chn2Beg = 4096
        che2End = 8192
        try
            chn2Beg = Main.SegParaAlarmProc.getchn2BegID() #4096
            che2End = Main.SegParaAlarmProc.getSegNUmbers() #8192
        catch(e)
                println("-----:",e)
        end
        as1 = (a.S1   >= chn2Beg ) ? max( a.S1 - MergeWidth ,chn2Beg) : max( a.S1 - MergeWidth ,1)
        as2 = (a.S2 <  chn2Beg ) ? min( a.S2 + MergeWidth ,chn2Beg ) : min(  a.S2 + MergeWidth ,che2End )
        inrng = ( es2>= as1 && es2 <= as2 ) ||
                ( es1>= as1 && es1 <= as2 ) ||
                (es1 < as1 && es2 > as2 )

        return inrng    
    end

    function IsinTimeRange(a::AlarmInfo,es1::UInt,es2::UInt,timetick::UInt )::Bool
        inrng =  ( timetick - a.tfresh ) <= MergeTime
        return inrng    
    end

    function freshEvent2AlarmHIstory( a::AlarmInfo ,es1::UInt,es2::UInt,tick::UInt  )
        a.Tc  = getAlarmIDPre() 
        a.S1 = es1
        a.S2 = es2 
        a.SC = floor( UInt,(a.S2+a.S1)/2*10 )
        a.tfresh = tick 
        AlarmReport.LogAlarm(a,false)
    end

    function addEvent2AlarmHistory( es1::UInt,es2::UInt,tick::UInt  )
        alrmobj = AlarmInfo()
        alrmobj.Tc  = getAlarmIDPre() 
        # alrmobj.AlarmID = join( (Tc,string(es1),string(es2) ),"-" ) )
        alrmobj.S1 = es1
        alrmobj.S2 = es2 
        alrmobj.SC = floor( UInt,(es1+es2)/2*10 )
        alrmobj.t0 = tick 
        alrmobj.tfresh =tick 
        mainID=@sprintf(":%013u-%04u-%04u",alrmobj.Tc ,es1, es2)
        # mainID = join( (string( alrmobj.Tc ),string(es1),string(es2) ) ,"-" )
        for i =1 : 10000
            alrmobj.AlarmID  = @sprintf("%s-%05u",mainID,i)
            # alrmobj.AlarmID = join( ( mainID, string(i) ),"-"  )
            if  get(AlarmInfoHistory,alrmobj.AlarmID,nothing ) == nothing 
                AlarmInfoHistory[ alrmobj.AlarmID  ] = alrmobj
                break
            end
        end
        # writeLog
        AlarmReport.LogAlarm(alrmobj,true)
    end

    function mergeProc( es1::UInt,es2::UInt,tick::UInt )
        for data in values( AlarmInfoHistory )
            intimeRng = false
            inSpaceWidth = IsinSpaceRange(data,es1,es2,tick ) 
            if inSpaceWidth == true 
                intimeRng = IsinTimeRange(data,es1,es2,tick ) 
            end
            if intimeRng == true 
                 return freshEvent2AlarmHIstory(data,es1,es2,tick  ) 
            end
        end
        addEvent2AlarmHistory( es1,es2,tick  )
    end
    function initMergeCfg( ;MergeWidth1::UInt , MergeTime1::UInt )
        global MergeWidth , MergeTime
        MergeWidth =MergeWidth1;
        MergeTime = MergeTime1;
    end
end



