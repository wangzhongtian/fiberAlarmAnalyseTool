

using Dates

Base.MainInclude.include("../common/AlarmProc.jl")
Base.MainInclude.include("../filefind/filesfind.jl")
Base.MainInclude.include("../common/OnlineWindlogProc.jl")
################################

function Cal_SaveWindperiod(rootdir , windLogfile)
    windinfoAofA=[]
    files = findAllFiles(rootdir,".log","","" )
    sort!( files)
    for file1 in files
        getWindStatus!( file1,windinfoAofA ) 
    end

    windPeriod1 = CalwindPeriod( windinfoAofA )
    SaveWindPeriods(windPeriod1 ,windLogfile )
end



###################### # MainEntry ################################


rootlog ="H:/99-RAWData/gyys-001-3月和4月报警汇总以及脚本的大风状态Log/"

AlarmfileFullname =joinpath( rootlog, "xxxx-001-10.14.38.51-201903.csv")

windLogfile1 = joinpath(rootlog,"d.csv")
Cal_SaveWindperiod(rootlog , windLogfile1)
WindLogfile1 = "$windLogfile1 "
t_0 = DT2UInt( "20190330"*"080100" )
t_1 = DT2UInt( "20190330"*"132900" )
a=[t_0,t_1,]
for a1 =1:2:length(a ) 
    t0 =a[a1]
    t1=a[a1+1]
    println("$t0~$t1,$(UInt2DTStr(t0) ) ~ $(UInt2DTStr(t1)) ")    
    Procs(AlarmfileFullname,WindLogfile1 ,rootlog,t0,t1)
    println("----------------")
    # break
end



