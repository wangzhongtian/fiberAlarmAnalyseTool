using Printf
function MergeRestorefile( srcfile )
    ftgr = open( srcfile,"w" )
    IDX = 0
    while true
        IDX +=1
        srcfilename = @sprintf("%s.%03d",srcfile,IDX)
        if  ! ispath(srcfilename )
            break
        end
        try
            fsrc =open(srcfilename,"r")
            a= UInt8(0)
            while !eof( fsrc )
                a = read( fsrc,UInt8 )
                write( ftgr, a)
            end  
            close(fsrc)  
            println(IDX," pos:",position( ftgr ) )
        catch(e)
            println(e)
            break
        end
    end
    close(ftgr)  
end

function sliptfile( srcfile )
    fobj= open( srcfile,"r" )
    # byteNum =0x00;
    maxBytesPerfile =100*1014*1024
    IDX = 0
    while !eof( fobj )
        IDX +=1
        tgrfilename = @sprintf("%s.%03d",srcfile,IDX)
        fout =open(tgrfilename,"w")
        segNum = 1;
        a= UInt8(0)
        while !eof( fobj )
            a = read( fobj,UInt8 )
            write( fout, a)
            segNum +=1
            if segNum > maxBytesPerfile
                break
            end
        end  
        close(fout)  
        println(IDX," pos:",position( fobj) )
    end
end