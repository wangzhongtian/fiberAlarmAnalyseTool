
using Base.Filesystem

function findAllFiles( rootdir,typestr,starttime::String,endtime::String)
    fileskv=Dict()
    for (root, dirs, files) in walkdir(rootdir)
        # println("Directories in $root")
        for file in files
            extname =  uppercase( splitext( file )[2]  )
            # println( file ,"  ,", extname,"   ", typestr  )
            # if starttime != ""
                if extname == uppercase(typestr ) 
                    ts = split( file,"^" )
                    # println( ts )
                    intimeRng = true #ts[4] >= starttime && ts[4] <= endtime

                    if  starttime != "" && length(ts) >= 5 && intimeRng == true
                # Data^Ver00^GYYS-001^20190304200109^ID00.RAW3
                        fileskv[ file ] = joinpath(root,file )
                    elseif starttime == ""
                        fileskv[ file ] = joinpath(root,file )
                    end
                end
            # else
                
            # end
        end
    end

    tfiles = keys(fileskv)
    files=[]
    for t in tfiles
        # global files
        append!(files, [t])
    end
    sort!(files)
    rets=[]  
    for  v  in files 
        append!(rets ,[fileskv[v] ] )
    # println(  )
    end
    return rets 
end
function TEST()
    rootdir="e:/dataroot/"
    # riqi= "20190304"
    startTIme= "20190304" * "200109"
    endtime=  "20190304" * "231544"
    files = findAllFiles(rootdir,".RAW3",startTIme,endtime)
    for t in files
    println( t )
    end
end


