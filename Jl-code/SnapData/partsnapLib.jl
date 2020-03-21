
function SnapPicedata2File(folderB,
    folderA,
    StartTime,
    TimePeriod,
    StartFiberLength,
    FLRange,
    ChannelID,
    TgrFolder  )

    t= ccall( (:snapPartdata,"partSnap.dll") ,Int32,
                (Cstring ,Cstring , Cstring,Clong,Clong,Clong ,Clong ,Cstring  ),
                folderB,
                folderA,
                StartTime,
                TimePeriod,
                StartFiberLength,
                FLRange,
                ChannelID,
                TgrFolder
                )
    return t
end    



function DtFormat( DtStr)
#orgformat:"20181107045146"
#TgtFormat: #"2019-03-06-18:42:59"
    return  DtStr[1:4] *"-" *DtStr[5:6]* "-" * DtStr[7:8] *"-"* DtStr[9:10] *":"* DtStr[11:12] *":"* DtStr[13:14]
end

function TestSnap()
    folderB="G:/Bd003/data/userdata1"
    folderA="G:/Bd003/data/userdata1"
    t= "Data^Ver00^BD-003^20181107045146^ID00"
    StartT="20181107045146"
    StartTime= DtFormat(StartT)  #"2019-03-06-18:42:59"
    TimePeriod=300 #s
    StartFiberLength=1
    FLRange=20744
    ChannelID=2
    TgrFolder="G:\\dataroot\\log"

    ret = SnapPicedata2File(folderB,
                    folderA,
                    StartTime,
                    TimePeriod,
                    StartFiberLength,
                    FLRange,
                    ChannelID,
                    TgrFolder  )
    println(ret)
end
