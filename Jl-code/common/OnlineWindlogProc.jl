Base.MainInclude.include( "../fileFind/filesfind.jl")
Base.MainInclude.include( "../RawFileofflineProc\\BaseLib.jl")
function getWindStatus!(WindStatusChangeLogfile,windinfoAofA1) 
    # tm0 = Base.Filesystem.mtime(WindStatusChangeLogfile )+8*60*60 
    # dt0 = Dates.unix2datetime( tm0)
    # jzdt = Dates.DateTime(baseDatetime ,Dates.DateFormat("yyyymmddHHMMSS" ))

    # relt= floor(UInt,(dt0-jzdt).value/1000 )
    # println( join( (dt0,jzdt,relt),"; ") )
    # println( dt0 ,WindStatusChangeLogfile)
    fiobj = open(WindStatusChangeLogfile,"r")
    skip(fiobj,0)
    relt=0
    filename = basename( WindStatusChangeLogfile)
    # println( filename )
    for line in readlines( fiobj )
        #line :67170634,ID=5991:6238,EventFirsttime:67170603,L0time：2019.03.30 10.30.34, Winding: 1
        # println( line)
        a = split( line,",")
        if length(a)  == 1
            time1 =replace(a[1],Pair("CurDatatime=","") )
            # println(time1)
            relt = parse(UInt,time1)
            dt0= UInt2DTStr( relt )
            append!(windinfoAofA1,[[ relt,0,0 ,false , relt ,filename,dt0]])
            continue
        end

        # for a0 in a
            ID =replace(a[2],Pair("ID=","") )
            
            segID1str ,segID2str= split(ID,":")
        
            segID1 =parse(UInt,segID1str )

            segID2 =parse(UInt,segID2str )    
            # println(ID,segID2str)  
            a3 = replace(a[3],"EventFirsttime:"=>"") 
            a3 = replace(a3,"EventFirsttime："=>"") 

            t0 = parse(UInt,a3)
            isWind =  occursin("1" , a[5]) #? true : false
            # println( join( (a[2],a[3],a[5] ,segID1,segID2 ,t0,isWind),";"))
            relt = parse( UInt,a[1])
            dt0= UInt2DTStr( relt )
            append!(windinfoAofA1,[[ t0,segID1,segID2 ,isWind , relt ,filename,dt0]])
        # end
    end
    # return a
end


function findwindofftime( seg1,seg2,tLog, windinfoAofA2)
    logt0 = tLog
    for idx =1 : length(windinfoAofA2 )
        a0= windinfoAofA2[idx]
        t1,segid1,segid2,iswind2,tLog2 = a0[1],a0[2],a0[3],a0[4],a0[5]
        logt0  = tLog2
        if iswind2 == false  && segid1 == seg1 && segid2 ==seg2 
            return t1            
        end
    end #for
    println("                NOT find  the offtime of $tLog, return the  last time: $logt0  in: $tLog  ")
    return logt0 
end

function CalwindPeriod( windinfoAofA1 )
    a=[]
    for idx =1 : length( windinfoAofA1)
        a0= windinfoAofA1[idx]
        t0,seg1,seg2,iswind,tLog,filename = a0[1],a0[2],a0[3],a0[4],a0[5],a0[6]
        if iswind == true 
            # if 67531208 == t0 
            #    println( join( (t0,seg1,seg2,iswind,tLog ,filename),",") )
            # end
            @views piecedata = windinfoAofA1[idx+1:end]
            toff = findwindofftime( seg1,seg2,tLog,piecedata )
            append!(a, [[ t0,toff ,seg1,seg2,iswind,tLog, ]] )
        end
    end
    return a 
end

# curtime,SegRange,Winding,StartTime,EndTime,LastingTime,CurDateTime
# 67089378,0199_0496,N,67085141,67089347,4206,2019.03.29 11.56.18
function SaveWindPeriods(windPeriod ,filename::String )
    fobj =open(filename,"w")
    for idx =1:length( windPeriod)
        a0= windPeriod[idx]
        # println( length( a0 ),typeof(a0))
        t0,toff ,seg1,seg2,iswind,tLog  = a0[1],a0[2],a0[3],a0[4],a0[5],a0[6]
        seg1Str = string(seg1,base=10,pad=4 )
        Segs= join( (string(seg1,base=10,pad=4 ),string(seg2,base=10,pad=4 ) ),"_" )

        if iswind == true && toff > t0
            str1= join( (t0,Segs,"Y",t0,toff ,string(toff -t0,base=10,pad=8 ) ,UInt2DTStr( t0,"yyyy.mm.dd HH.MM.SS" )),",")
            
        else
            str1 = join( (t0,Segs,"N",t0,toff ,string(toff -t0,base=10,pad=8 ) ,UInt2DTStr( t0,"yyyy.mm.dd HH.MM.SS" )),",")
        end 

        write( fobj, str1 *"\r\n")
    end
    close( fobj)
end


function Cal_SaveWindperiod(rootdir , windLogfile)
    windinfoAofA=[]
    files = findAllFiles(rootdir,".log","","" )
    sort!( files)
    for file1 in files
        println(basename(file1) )
    end
    for file1 in files
        getWindStatus!( file1,windinfoAofA ) 
    end
# for a in windinfoAofA
#     println( a )
# end
    windPeriod1 = CalwindPeriod( windinfoAofA )
#     println("windows ")
# for a in windPeriod1
#     for b in a
#       print(b,", ")
#     end
#     println()
# end

    SaveWindPeriods(windPeriod1 ,windLogfile )
end




