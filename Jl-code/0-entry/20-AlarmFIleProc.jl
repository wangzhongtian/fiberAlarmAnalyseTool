Base.MainInclude.include("../common/AlarmProc.jl")
###################### # MainEntry ################################
include("../filefind/filesfind.jl")
##xxx-xxx
rootlog ="../log/xxx离线大风识别结果/"
filename1 =joinpath( rootlog, "xxx-xxx-10.14.165.41-201903.csv")
WindLogfile1 = "xxx-xxx-wind-03-31-12-S.log   xxx-xxx-wind-03-31-13-F.log
xxx-xxx-wind-03-31-14-S.log   xxx-xxx-wind-03-31-15-F.log
xxx-xxx-wind-03-31-15-S.log   xxx-xxx-wind-03-31-16-F.log
xxx-xxx-wind-03-31-16-S.log   xxx-xxx-wind-03-31-17-F.log
xxx-xxx-wind-03-31-17-S.log   xxx-xxx-wind-03-31-18-F.log
xxx-xxx-wind-03-31-19-F.log   xxx-xxx-wind-03-31-19-S.log
xxx-xxx-wind-03-31-20-F.log   xxx-xxx-wind-03-31-20-S.log
xxx-xxx-wind-03-31-21-F.log   xxx-xxx-wind-03-31-14-S.log
xxx-xxx-wind-03-31-15-F.log   xxx-xxx-wind-03-31-15-S.log
xxx-xxx-wind-03-31-16-F.log   xxx-xxx-wind-03-31-16-S.log
xxx-xxx-wind-03-31-17-F.log   xxx-xxx-wind-03-31-19-F.log
xxx-xxx-wind-03-31-19-S.log   xxx-xxx-wind-03-31-21-F.log
xxx-xxx-wind-03-31-21-S.log   xxx-xxx-wind-03-31-22-F.log
xxx-xxx-wind-03-31-23-S.log   
"

function getRawFilesDT0_T1( rawDataRoot ::String )
    a=[]
    files = findAllFiles(rootdir,".conf",startTIme,endtime)
    for t in files
        Base。Filesystem.size( t) 
        a += [ t,Base。Filesystem.size( t) ]
    end
    return a
end


a= getRawFilesDT0_T1( "F:/99-RAWData/xx-xxx机历史数据/" )
for a1 in a 
    print(a1)
end
exit(0)
Dt0="20190310045716"
t0 =DT2UInt( DT::String,format1="yyyymmddHHMMSS"  )
deltaT =floor( UInt,2*1024*1024*1024/(526+8192+4) *0.426-1000)
t1 = t0+ deltaT
meterPerSeg1 = 5.0404
chn2SegBegIdx1 = 4097

All_alarms = Main.readInAlarm2Array(filename1, chn2SegBegIdx1,meterPerSeg1)
logfiles = split(WindLogfile1," " )
for logfile in logfiles
    WindLogfile2 =joinpath(rootlog,  logfile)
    Main.ReadInWindLog!(All_alarms,WindLogfile2 )
end


aLarmInWindoffCnt = Main.countAlarms(All_alarms, t0,t1,Main.WindOff)
aLarmInWindONCnt  = Main.countAlarms(All_alarms, t0,t1,Main.WindOn)
println("$aLarmInWindoffCnt ,$aLarmInWindONCnt " )
# exit()
Main.findWindStatusinAlarmPrintout(All_alarms,t0,t1, Main.WindOff )


