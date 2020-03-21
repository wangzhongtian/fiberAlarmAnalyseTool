####################################################
# huawei 's  .conf wnejian 
#
#####################################

Base.MainInclude.include("./ToPTformat/01-Apphw2PTFileTransfer.jl")

#########################################################################################
# 寻找制定文件夹下所有的原厂格式的原始数据文件，并转换成对应的RAW1~RAW4文件；
#　生成的文件名中的主机编号为　ＭＡｃｈｉｎｅＩD。
###########################
# rootdir = "/media/wang/705fc396-8c76-4812-9d0b-d17382d9dfc7/backup/t/app/fiberproc/sjz004/高邑元氏20191126/"　　
# machineID ="GYYS-001"

srcfile=ENV["splitedFileRootName"]
rootdir =  dirname(srcfile)　
# machineID ="GYYS-001"
machineID =ENV["machineID"]
# dirname(srcfile)　
startTime = ""
endTime = ""

#cfgfile = "../Jl-Aux/glbCfg/hw2PTCfg-BD-001.jl"
Main.julia_main(["",])
