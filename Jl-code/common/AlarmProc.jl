Base.MainInclude.include("../RawFileofflineProc/BaseLib.jl")
const WindOff= "windOff"
const WindOn ="windON"
function readInAlarm2Array(filename, chn2SegBegIdx,meterPerSeg)
    fiobj = open( filename,"r")
    skip(fiobj,3)
    All_alarms = [ ]
    for line in readlines( fiobj )
        # println(line)
        fields = split( line,",")
        # print(  )
        if  fields[8 ] == "有入侵"
            dt= fields[2] *" "*fields[3]
            t0 = DT2UInt( dt ,"y/m/d H:M:S" )
            chnid = parse( Int,fields[4 ] ) 
            fl = parse( Float64,fields[5])
            # begid = 1
            SegID =  floor( UInt ,fl / meterPerSeg )
            chnid == 1 ? begid= 1 : begid = chn2SegBegIdx
            SegID += begid
            # print("$t0,$chnid,$fl,$begid,$SegID\n")
            curAlarmInfo = [t0,SegID,chnid,fl,fields[1],  fields[2],fields[3],WindOff ]
            append!( All_alarms ,[curAlarmInfo])
        end
    end
    close( fiobj )
    return All_alarms
end

function windfind(All_alarms, t0,lasttime ,segId1,SegId2)
    t1= t0+ lasttime
    for data in  All_alarms
        segId = data[2 ]
        alt0= data[1]
        windStatus = data[8]

        if  alt0 >= t0 && alt0 <=t1  && segId >=segId1 && segId <= SegId2
             data[8] = WindOn
        end
    end
end



function ReadInWindLog!(All_alarms,WindLogfile )
    fiobj = open( WindLogfile,"r")
    skip(fiobj,3)
    for line in readlines( fiobj )
        a = split( line,",")
        if a[3] != "Y"
            continue
        end
        segid1,segid2 = split(a[2],"_")
        t0 =parse(UInt,a[4] )
        lasttime  = parse(UInt,a[6 ])
        # println("$segid1,$segid2,$t0, $lasttime")
        segid_1 =parse(UInt,segid1 )
        segid_2 =parse(UInt,segid2 )
        windfind(All_alarms, t0,lasttime ,segid_1,segid_2)
    end
end

#windfind(All_alarms, t0,lasttime ,segId1,SegId2)
# exit()

function countAlarms(All_alarms, t0,t1,Winding=WindOn)
    cnt=0
    for data in  All_alarms
        t00 =data[1]
        if t00 >= t0 && t00 <=t1 && data[8] == Winding
            cnt +=1
            # for col in data
            # print( col,",")
            # end
            # println("--")
        end
    end
    return cnt 
end
function findWindStatusinAlarmPrintout(All_alarms,t0,t1,WindStatus=WindOn )
    for data in  All_alarms
        t00 =data[1]
        if t00 >= t0 && t00 <=t1 && data[8] == WindStatus
            for col in data
                print( col ,",")
            end
            println("-------------")
        end
    end
end
function getRawFilesDT0_T1( rawDataRoot ::String )
    a=[]
    files = findAllFiles(rawDataRoot,".RAw3","","")
    for t in files
        size1 = Base.Filesystem.filesize( t) 
        deltaT =floor( UInt,size1/(2*8192+4) *0.426-100)
        Dt0 =split( t,"^")
        t0 =DT2UInt( string(Dt0[4]),"yyyymmddHHMMSS"  )

        append!(a,[ t0,t0+ deltaT ] )
    end
    return a
end
    
    
function Procs(Alarmfilename1,WindLogfile1 ,rootlog,t0,t1)
        meterPerSeg1 = 5.0404
        chn2SegBegIdx1 = 4097
    
        All_alarms = Main.readInAlarm2Array(Alarmfilename1, chn2SegBegIdx1,meterPerSeg1)
        logfiles = split(WindLogfile1)#," " )
        for logfile in logfiles
            WindLogfile2 =joinpath(rootlog,  logfile)
            Main.ReadInWindLog!(All_alarms,WindLogfile2 )
        end
    
    
        aLarmInWindoffCnt = Main.countAlarms(All_alarms, t0,t1,Main.WindOff)
        aLarmInWindONCnt  = Main.countAlarms(All_alarms, t0,t1,Main.WindOn)
        println("aLarmInWindoffCnt: $aLarmInWindoffCnt ,ALarmInWindONCnt :$aLarmInWindONCnt " )
        # exit()
        Main.findWindStatusinAlarmPrintout(All_alarms,t0,t1, Main.WindOff )
end
