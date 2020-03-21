include("SnapData/partsnapLib.jl")
#TestSnap()
 ###############para##############
folderB="E:/a/b"
folderA=""
#folderA=""
# 2019/4/4	10:16:26

StartT="20190404" * "103826"
StartTime= DtFormat(StartT) 
TimePeriod=4*60 #s
ChannelID=1
StartFiberLength=16595-100 #meters
FLRange=200 #meters
TgrFolder="E:/a/"

################Para######################
ret = SnapPicedata2File(folderB,
                folderA,
                StartTime,
                TimePeriod,
                StartFiberLength,
                FLRange,
                ChannelID,
                TgrFolder  )
println(ret)