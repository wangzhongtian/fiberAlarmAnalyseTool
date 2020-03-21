defenceAreaTblfile=ENV["defenceAreaTblfile"]
specifiedParaofFiberLenFile= ENV["specifiedParaofFiberLenFile"]
machineInfoMainfile= ENV["machineInfoMainfile"]
tgrParafilename= ENV["tgrParafilename"]
machine友好名= ENV["machine友好名"]

####################################  below do not alter   ###########################################################
include("CSVParas/readCsvLib.jl")
include("CSVParas/mappingLib.jl")

CsvInfoObj = CsvInfos()
CsvInfoObj.防区表fieldname ="定位界标1,定位界标2,xxxx主机IP,通道号,定位界标1光程,定位界标2光程,子防区编号,防区起点GPS经度坐标,防区起点GPS纬度坐标,防区终点GPS经度坐标,防区终点GPS纬度坐标,左右岸,地名信息,界标之间围栏长度,管理处,分局"
CsvInfoObj.防区表signalStringName="定位界标1光程"
CsvInfoObj.防区表keyFieldNames ="定位界标1,定位界标1光程,定位界标2,定位界标2光程"
CsvInfoObj.防区表filename = defenceAreaTblfile

CsvInfoObj.老版参数表fieldname ="编号,使能,描述,通道,起始位置(米),结束位置(米),修改时间,立案票数,过零.静态票数,过零.动态票数,能量.静态票数,能量.动态票数,过零.静态阈值.数值,过零.动态时间常数(秒),过零.动态系数,过零.动态上限,过零.动态下限,能量.静态阈值,能量.动态时间常数(秒),能量.动态系数,能量.动态上限,能量.动态下限,空间.合并(米),空间.滤除(米),时间.合并(帧),时间.滤除(帧),振动范围上限(米),振动范围下限(米),持续时间上限(秒),持续时间下限(秒),时空积上限(米*秒),时空积下限(米*秒)"
CsvInfoObj.老版参数表signalStringName="起始位置(米)"
CsvInfoObj.老版参数表keyFieldNames ="编号,通道,起始位置(米),结束位置(米),过零.动态时间常数(秒),过零.动态系数,过零.动态上限,过零.动态下限,空间.合并(米),空间.滤除(米),时间.合并(帧),时间.滤除(帧),振动范围上限(米),振动范围下限(米),持续时间上限(秒),持续时间下限(秒)"
CsvInfoObj.老版参数表filename =specifiedParaofFiberLenFile


CsvInfoObj.主机信息表fieldname = "主机编号,友好名,主机位置,主机类型"
CsvInfoObj.主机信息表signalStringName = "主机类型"
CsvInfoObj.主机信息表keyFieldNames = "主机编号,友好名,主机位置,主机类型"
CsvInfoObj.主机信息表filename     = machineInfoMainfile

basicInit( CsvInfoObj)
convertPara2SignalCordinate(CsvInfoObj,machine友好名1=machine友好名)
# show(CsvInfoObj.csvInfoDefencePara )

tem1 = CsvInfoObj.csvInfoDefencePara.keyFieldNames
tem1= replace(tem1,"起始位置(米)"=>"标牌坐标1")
tem1= replace(tem1,"结束位置(米)"=>"标牌坐标2")

tem1= replace(tem1,"过零.动态时间常数(秒)"=>"动态阈值时长")

tem1= replace(tem1,"过零.动态系数"=>"动态阈值系数")
tem1= replace(tem1,"过零.动态下限"=>"动态阈值下限")
tem1= replace(tem1,"过零.动态上限"=>"动态阈值上限" )

tem1= replace(tem1,"空间.合并(米)"=>"事件合并距离"  )

tem1= replace(tem1,"空间.滤除(米)"=>"事件滤除距离")
tem1= replace(tem1,"时间.合并(帧)"=>"事件合并时长")
tem1= replace(tem1,"时间.滤除(帧)"=>"事件滤除时间")
tem1= replace(tem1,"振动范围上限(米)"=>"告警空间上限")
tem1= replace(tem1,"振动范围下限(米)"=>"告警空间下限")
tem1= replace(tem1,"持续时间上限(秒)"=>"告警续时上限")
tem1= replace(tem1,"持续时间下限(秒)"=>"告警续时下限")
    
CsvInfoObj.csvInfoDefencePara.keyFieldNames =tem1
tem2 =CsvInfoObj.csvInfoDefencePara.keyFieldNames
# for key1 in split(tem2 ,",")
#     println( key1)
# end
csvObject = CsvInfoObj.csvInfoDefencePara.Area2FiberLen
total = length(csvObject)
for  idx  = 1: total 
    row = csvObject[idx]

    i=5 # 转换  过零.动态时间常数(秒) 单位为 帧（0.426秒)
    a = floor(Int, parse( Int , row[i] ) /0.426)
    row[i]  =string(a)

    i=6 # 转换 动态阈值的系数 单位为 0.01
    a = parse( Int , row[i] ) *100
    row[i]  =string(a)

    i=16 # # 转换  持续时间上/下限(秒) 单位为 帧（0.426秒)
    a = floor(Int, parse( Int , row[i] ) /0.426)
    row[i]  =string(a)
    i=15 # # 转换  持续时间上/下限(秒) 单位为 帧（0.426秒)
    a = floor(Int, parse( Int , row[i] ) /0.426)
    row[i]  =string(a)


    # i=6 # 转换动态阈值的系数单位为 0.01
    # a = parse( Int , row[i] ) *100
    # row[i]  =string(a)


    if row[1] =="1001" || row[1] =="2001"
        row[3]=row[4]="0+0"
        println(row[1],"-",row[3],"-",row[4])
    end
#         print("$fieldname:$(row[i]) ,$a\r\n")
end
write2CSV(CSVinfo1= CsvInfoObj.csvInfoDefencePara,filename=tgrParafilename )
println()
# convertPara_Fiberlength( CsvInfoObj,machine友好名1="高元001")
# show(CsvInfoObj.csvInfoDefencePara )