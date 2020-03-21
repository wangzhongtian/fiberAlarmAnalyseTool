using Base.Filesystem

function getDiskSpace( diskName  )
    cmdstr =  `cmd /c dir $diskName`  
    # println( cmds )
    aa=read( cmdstr,String)
    bb= split( aa,'\n')
    for b1 in ( bb[end-1],)
        c= split(strip(b1), " ");
        for c1 in (c[3],)
            a11= c1 
            # println( a11 )

            c0 = split(a11,",")
            w=""
            for c11 in c0
                w = string(w,c11)
            end
            # println( w ,"  ,    ",a11)
            space=  parse(UInt, w)
            return space
        end
    end
end
function getSizes( root,RAW1MaxSpace=3 , RAW2MaxSpace=3, RAW3MaxSpace=1, RAW4MaxSpace=1,Unit= 1024*1024*1024*1024)
    row1 = 0x0000
    row2= 0x0000
    row3 = 0x0000
    row4 = 0x0000
    row1fs=[]
    row2fs=[]
    row3fs=[]
    row4fs=[]
    a = Filesystem.readdir(root) 
    for b in a
        m,e = splitext( b  )
        fsize = Base.Filesystem.filesize( joinpath(root,b) )
        # fsize =
        # println(m ," === ",e ,"  ", fsize)
        if occursin( "1",e)
            row1 += fsize
            append!(row1fs ,[b])
        elseif occursin( "2",e)
            row2 += fsize 
            append!(row2fs ,[b])
        elseif occursin( "3",e) 
            append!(row3fs ,[b])   
            row3 += fsize
        elseif occursin( "4",e)
            append!(row4fs ,[b])
            row4 += fsize
        end
    end
    println("---------------------------")

    for (row,fs,max ) in ( (row1,row1fs,RAW1MaxSpace),(row2,row2fs,RAW2MaxSpace),(row3,row3fs,RAW3MaxSpace) ,(row4,row4fs,RAW4MaxSpace)   )
        sort!( fs,rev=true )
        # row *= Unit #in kbytes
        max *= Unit # in kbytes
        while row > max && length( fs ) >2
            if length( fs ) >1
                fs1 = pop!(fs) 
                fullnamefs = joinpath(root,fs1)
                fsize = Base.Filesystem.filesize( fullnamefs )
                # fsize =round(UInt, s  )
                Filesystem.rm(fullnamefs )
                row -= fsize 
                
                println( "$fullnamefs, Cursize(kbytes):$(row/Unit) ,Max(kbytes):$(max/Unit)")
            end
        end
        println()
    end
    # return ( row1,row2,row3,row4 )
end

function testMain(root)
    RAW1MaxSpace=0
    RAW2MaxSpace=0
    RAW3MaxSpace=0
    RAW4MaxSpace=1
    Unit= 1024*1024*1024
    while true 
        rowsizes  = getSizes( root ,RAW1MaxSpace, RAW2MaxSpace, RAW3MaxSpace, RAW4MaxSpace,Unit)
        exit(1)
        sleep(10)
        println( "start clear expired files ")
    end
end

# testMain()