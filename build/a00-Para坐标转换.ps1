. 00-envset.ps1
#　直接将从原厂告警配置文件ｅｘｃｅｌ文件中另存的ｃｓｖ文件的告警参数配置数据导出到　新格式的配置文件中。
#　新格式的配置文件可以直接被新系统脚本使用。
#　注意以下几点：
#　　１　编号１００１和２００１的配置为１通道和２通道的缺省配置参数
#　　２　计算动态阈值的系数，原厂为ａ的话，新配置给乘了１００，相当于单位为原厂的０.０１倍含义不变。
$env:defenceAreaTblfile="../Jl-Aux/glbCfg/防区信息.csv"
$env:machineInfoMainfile="../Jl-Aux/glbCfg/A100-xxxx主机IP信息表.csv"
$env:specifiedParaofFiberLenFile="../Jl-Aux/glbCfg/GaoYuan001-AlarmAlgTSSetting.csv" #input file

$env:tgrParafilename="../Jl-Aux/glbCfg/GYYS-001-AlarmParas.csv" # output file
$env:machine友好名="GYYS-001"

julia   ../Jl-code/a02-gaojingcanshuzuobiaoZHUANHUAN.jl   


