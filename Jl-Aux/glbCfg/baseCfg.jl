# using Dates
using Base.Filesystem
needSaveFile=true
needJuliaSend=true 

# println("000")
@static if Base.Sys.islinux()
    root=homedir()
    root = pwd()
    println( "root is :$root") 
    Logfolder= joinpath( root,"../dataroot/","log/")

    folderA = joinpath( root,"../dataroot/","b/")
    folderB = joinpath( root,"../dataroot/","a/")        
else
    root="d:\\"
    root = pwd() 
    Logfolder= joinpath( root,"../dataroot\\","log\\")

    folderA = joinpath( root,"../dataroot\\","b\\")
    folderB = joinpath( root,"../dataroot\\","a\\")    
end 


# dataRoot=joinpath(root,"dataroot/")
println("Root data Folder is:",root )

IpStr = "192.168.99.193";
IpStr = "192.168.0.109"
IpStr = "127.0.0.1"
IpStr="10.14.38.51"
#IpStr = "172.20.160.131"
#IpStr = "192.168.1.5"
IpStr = "0.0.0.0" 
#localhost
Port = UInt16(19998); 
# MBytes
Unit= 1024*1024 
# should be in Mib ,1G=124Mib
DiskTotalSpace = 80*1024  

# 特征数据可占用总磁盘的百分比例，包含RAW3~4.其它的为 RAW1~2 占用
FeatureRatio=80             

RAW12Total = DiskTotalSpace *(100-FeatureRatio ) /100
RAW34Total = DiskTotalSpace *FeatureRatio /100

RAW1MaxSpace= floor( UInt32,RAW12Total / 2 *2) 
RAW2MaxSpace= floor( UInt32,RAW12Total / 2*0 ) 
RAW3MaxSpace= floor( UInt32,RAW34Total / 2 *2 )  
RAW4MaxSpace= floor( UInt32,RAW34Total/  2 *0 )
# space = getDiskSpace( root )
###################################
for pa in (Logfolder, folderA, folderB )
    Filesystem.mkpath( pa )
end
struct cfgDataOnline
    folderA
    folderB 
    IpStr
    Port
    Unit
    RAW1MaxSpace
    RAW2MaxSpace
    RAW3MaxSpace
    RAW4MaxSpace
    needSaveFile
    needJuliaSend
    Logfolder
    function cfgDataOnline(folderA,folderB ,IpStr,Port,Unit,RAW1MaxSpace,RAW2MaxSpace,RAW3MaxSpace,RAW4MaxSpace,needSaveFile,needJuliaSend,Logfolder)
        new(folderA,folderB ,IpStr,Port,Unit,RAW1MaxSpace,RAW2MaxSpace,RAW3MaxSpace,RAW4MaxSpace,needSaveFile,needJuliaSend,Logfolder)
    end
end

cfgObj = cfgDataOnline(folderA,folderB ,IpStr,Port,Unit,RAW1MaxSpace,RAW2MaxSpace,RAW3MaxSpace,RAW4MaxSpace,needSaveFile,needJuliaSend,Logfolder)
# println(cfgObj)
# cfgObj
