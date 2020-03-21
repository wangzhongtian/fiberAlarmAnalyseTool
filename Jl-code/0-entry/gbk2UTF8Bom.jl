#julia %USERPROFILE%\.julia\packages\PackageCompiler\oT98U\juliac.jl -C ivybridge -vRe gbk2UTF8Bom.jl
using StringEncodings


function TransferGbkCSV2UTF8BomCsv( ;srcFile::String ,TgrFile::String )
    f = open(srcFile, enc"GB2312", "r");
    fout = open(TgrFile, enc"UTF-8", "w"); 
    write(fout,UInt8(239) )
    write(fout,UInt8(187) )
    write(fout,UInt8(191) )
    for line in readlines( f )
        println( line )
        write( fout,line )
        write(fout,"\r\n")
    end
    close( fout)
    close(f)
end
Base.@ccallable function julia_main1()::Cint
    srcFile = "D:/Jl-2019-0521/Jl/glbCfg/xxxxx-ParasGBk-FULL.csv"
    TgrFile  = "GYYS-001-AlarmParas.csv"
    TransferGbkCSV2UTF8BomCsv( srcFile= srcFile ,TgrFile= TgrFile )
    return 0
end
#julia_main1()


