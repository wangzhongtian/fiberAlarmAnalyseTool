include("readCsvLib.jl")
include("mappingLib.jl")

CsvInfoObj = CsvInfos()

CsvInfoObj.防区表fieldname ="定位界标1,定位界标2,xxxx主机IP,通道号,定位界标1光程,定位界标2光程,子防区编号,防区起点GPS经度坐标,防区起点GPS纬度坐标,防区终点GPS经度坐标,防区终点GPS纬度坐标,左右岸,地名信息,界标之间围栏长度,管理处,分局"
CsvInfoObj.防区表signalStringName="定位界标1光程"
CsvInfoObj.防区表keyFieldNames ="定位界标1,定位界标1光程,定位界标2,定位界标2光程"
CsvInfoObj.防区表filename = "../河北分局防区信息.csv"

CsvInfoObj.老版参数表fieldname ="编号,使能,描述,通道,起始位置(米),结束位置(米),修改时间,立案票数,过零.静态票数,过零.动态票数,能量.静态票数,能量.动态票数,过零.静态阈值.数值,过零.动态时间常数(秒),过零.动态系数,过零.动态上限,过零.动态下限,能量.静态阈值,能量.动态时间常数(秒),能量.动态系数,能量.动态上限,能量.动态下限,空间.合并(米),空间.滤除(米),时间.合并(帧),时间.滤除(帧),振动范围上限(米),振动范围下限(米),持续时间上限(秒),持续时间下限(秒),时空积上限(米*秒),时空积下限(米*秒)"
CsvInfoObj.老版参数表signalStringName="起始位置(米)"
CsvInfoObj.老版参数表keyFieldNames ="编号,通道,起始位置(米),结束位置(米),过零.动态时间常数(秒),过零.动态系数,过零.动态上限,过零.动态下限,空间.合并(米),空间.滤除(米),时间.合并(帧),时间.滤除(帧),振动范围上限(米),振动范围下限(米),持续时间上限(秒),持续时间下限(秒)"
CsvInfoObj.老版参数表filename ="../AlarmAlgTSSetting无风.csv"


CsvInfoObj.主机信息表fieldname = "主机编号,友好名,主机位置,主机类型"
CsvInfoObj.主机信息表signalStringName = "主机类型"
CsvInfoObj.主机信息表keyFieldNames = "主机编号,友好名,主机位置,主机类型"
CsvInfoObj.主机信息表filename     = "../A100-xxxx主机IP信息表.csv"

basicInit( CsvInfoObj)

convertPara2SignalCordinate(CsvInfoObj,machine友好名1="高元001")

# show(CsvInfoObj.csvInfoDefencePara )
write2CSV(CSVinfo1= CsvInfoObj.csvInfoDefencePara,filename="../GYYS001.csv" )
println()

# convertPara_Fiberlength( CsvInfoObj,machine友好名1="高元001")
# show(CsvInfoObj.csvInfoDefencePara )