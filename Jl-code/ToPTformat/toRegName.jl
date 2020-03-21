include("../filefind/filesfind.jl")
# include("baseTransferLib.jl")
###########################################################
function Regularfiles( files )
    #tgrname :Data^Ver00^GYYS-001^20190304090024^ID00
    #srcFileName :GYYS-001-2019-0224_13-0833
    for dataFilename in files
        folder = dirname( dataFilename )
        basefilename = basename(dataFilename)
        filename,ext = splitext(basefilename)
        try
            UnitName,ID,Year,monthDayHour,Ms= split( filename,"-" )
            monthDayHour= replace(monthDayHour,Pair("_","") )
            newName = "Data^Ver00^$UnitName-$ID^$Year$monthDayHour$Ms^ID00"*ext
            tgrName= joinpath("$folder","$newName" )
            println( tgrName)
            mv(dataFilename ,tgrName  )
        catch(e)
            println(e)
            return 
        end 

    end
end
function regFiles(rootdir  )
    println()
    startTIme=""
    endtime= ""
    for ext in [".RAW1", ".RAW2", ".RAW3",".RAW4"]
        files = findAllFiles(rootdir,ext,startTIme,endtime)
        Regularfiles( files )
    end
end
 