#! /usr/bin/julia
#! /mnt/d/p/Julia/juliaLinux/bin/julia
#PATH=/mnt/d/p/Julia/juliaLinux/bin:$PATH

include("RawFileofflineProc/interface.jl") # 如果需要适配不同的算法来分析相应文件，需要修改 intrface.jl 中包含的算法库

##########
startMeters =100
endmeters  =31100
ProtectMeters =30 
chnid =1#  1 or  2
maxTimeCnt1 =-1## -1：time loop forever ,until data end 

println( "startMeters:$startMeters,\nendmeters:$endmeters,
 \nProtectMeters:$ProtectMeters,
 \nchnid :$chnid ,\nmaxTimeCnt1:$maxTimeCnt1\n")

###################### Linux  READ RAW  LC  Files ，必须指定  cfgfilename 和 dataFilename
basePath1 = "g:/other/fiber/fiberdata" #/home/wang/Documents/wangzht/fiber/fiberdata
basePath1 = "E:/DATAs/xxxx号机告警分析/20190212GY01BigWind"
# cfgfilename  =""# joinpath(basePath1, "20190212T131313.CONF"  )
# dataFilename = joinpath( basePath1,"20190212T131313.lc") #  处理单个文件时使用 
# @time calInternal(chnid,startMeters ,endmeters,maxTimeCnt1, dataFilename ,cfgfilename, ProtectMeters  )

######################  READ RAW1~RAW4 Files

dataFilename1="20190212T131313.RAW3"
dataFilename = joinpath(basePath1 ,dataFilename1)   
# dataFilename="G:\\Bd003\\data\\userdata1\\Data^Ver00^BD-003^20181107045148^ID00.RAW4"
calPT(chnid,startMeters ,endmeters,maxTimeCnt1, dataFilename , ProtectMeters )

exit(1)
