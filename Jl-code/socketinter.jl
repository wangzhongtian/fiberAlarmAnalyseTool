using Sockets
using Printf
using Dates
#####################              ######################## 
function writeInt16( sock,num::UInt16)
    # println( num )
    a1=UInt8(num & 0x00FF)
    a2 =UInt8( num>>8)
    write( sock, a1,a2 )
    return 2
end
#####################################################################
function SendHeadID(sock)
    writeInt16( sock ,0xEB90)
    return writeInt16( sock ,0xEB90)
end

function readHeadID(sock) :: UInt32
    return read( sock ,UInt32)
end
# unsigned short type ; /*01表示原始数据，02表示滤波后数据，03表示过零数据，04表示能量数据    */
function sendTypeCode(sock ,type::UInt16)
    return writeInt16( sock ,type)
    # unsigned short checkCode ;   
end     
function readTypeCode(sock ) :: UInt16
    return read( sock ,UInt16)
    # unsigned short checkCode ;   
end    

function sendcheckCode( sock )
    return writeInt16( sock ,0xEB90)
end
function readcheckCode( sock )  :: UInt16
    return read( sock ,UInt16)
end
# char machineName[20];// null terminated string，固定长度
function sendmachineName( sock,machineName::String)
    len = length( machineName  ) 
    if len >= 20
        temstr = machineName[1:20]
        return write( sock ,temstr)
    else
        temstr = @sprintf( "%s",machineName)
        # println( "--",temstr,"--")
        write( sock ,temstr)
        for i=len+1:20
            write(sock,UInt8(0x00))
        end
        return 20
    end
    
end

function readmachineName( sock ) :: String
    machinename =""
    terminated = false
    # position( )
    for i=1:20
        c= read( sock ,UInt8)
        # print(string(c))
        if c != 0x00 && terminated == false
            # print(string("-",c,"-"))
            c= Char(c)
            machinename = string( machinename, c)
        else
            terminated = true
            continue
        end 
    end
    machinename =strip( machinename)
    # println(" machinename is: --$machinename----")
    return machinename
end


function sendDT( sock ,DT::String)
    len = length( DT  ) 
    if len > 14
        temstr = DT[1:14]
    else
        temstr = @sprintf( "%-14s",DT)
    end
    # println( "--------------",temstr)
    return write( sock ,temstr)
    # return writeInt16( sock ,0xEB90)
end

function readdDT( sock)::String
    DT  =""
    for i=1:14
        c= read( sock ,Char)
        # if c != 0x00
        DT = string(DT,c)
        # else
        #     break
        # end 
    end
    return DT
end

function sendparas(sock ,CfgData::Array{UInt16,1})
    for i in CfgData 
        writeInt16(sock,i)
    end 
end

function readCfg(fi1) :: Array{UInt16,1}
    cfgs=Array{UInt16,1}(undef,7)
    for idx =1: length( cfgs )
        cfgs[idx] = read( fi1,UInt16)
    end
    return cfgs
end

 
function senddataType(sock )
    # unsigned short dataType;
    # //01表示char，02表示uchar，03表示int16，04表示uint16，05表示int32，06表示uint32，07表示float，08表示double
    writeInt16(sock,0x0004)
end

function readdataType(sock )
    # unsigned short dataType;
    # //01表示char，02表示uchar，03表示int16，04表示uint16，05表示int32，06表示uint32，07表示float，08表示double
    return read(sock,UInt16)
end

function sendDataPayLoad(sock ,data)
    for i =1:length( data )
        writeInt16(sock,data[i] )
    end 

end

function sendDataPayLoad(sock ,frameLen::UInt,data::Array{UInt16,1})
    Ar = reinterpret(UInt8,data)
    # println( "------",length(Ar) ," ",frameLen )
    a=0x0000
    for i =1:frameLen
       yield()
       a+=write( sock , Ar)
    end 
    # println(a)
end

function readindatas(fi1,dataBuf::Array{UInt16,1} ) :: Array{UInt16,1}
    cfgs=dataBuf #Array{UInt16,1}(undef,8192)
    for idx =1: length( cfgs )
        cfgs[idx] = read( fi1,UInt16)
    end
    return cfgs
end

function readindatas(fi1,frameLen,dataBuf::Array{UInt16,1}) #:: Array{UInt16,1}
    cfgs =@view dataBuf[ 1:8192*frameLen ]
    for idx =1: length( cfgs )
        cfgs[idx] = read( fi1,UInt16)
    end
    # return cfgs
end

function readindatas!(fi1,frameLen,dataBuf::Array{UInt16,1}) #:: Array{UInt16,1}
    cfgs =@view dataBuf[ 1:8192* frameLen]
    dr = reinterpret(UInt8, cfgs)
    unsafe_read( fi1 ,pointer(dr ), length(dr ))
end

function  sendtailCheckCode(sock )
    # unsigned int tailCheckCode; //FFFF FFFF
    writeInt16(sock,0xFFFF)
    writeInt16(sock,0xFFFF)
end
function  readtailCheckCode(sock )
    return read(sock,UInt32)
end


######################

function sendTestFrames(sock,fi1)
    cfgdata =readCfg(fi1)
    dataBuf = Array{UInt16,1}(undef,8192 )
    dataBuf.=0x0000
    while ! eof(fi1)

        pos1 = position( fi1 )
        sendTestFrame(sock,fi1,UInt16(1),cfgdata,dataBuf  )

        seek( fi1,pos1 )
        sendTestFrame(sock,fi1,UInt16(2),cfgdata, dataBuf )

        seek( fi1,pos1 )
        sendTestFrame(sock,fi1,UInt16(3),cfgdata , dataBuf  )

        seek( fi1,pos1 )
        sendTestFrame(sock,fi1,UInt16(4),cfgdata , dataBuf  )
        # println(pos1)
    end
end

function sendTestFrame(sock,fi1,typeCode::UInt16,cfgdata::Array{UInt16,1} ,dataBuf::Array{UInt16,1} )

    SendHeadID(sock)
    sendTypeCode(sock,typeCode)

    sendcheckCode(sock)
    a= sendmachineName(sock,"TEST-567890")

    DT = readdDT(fi1)
    a= sendDT(sock,DT)
    sendparas(sock,cfgdata)
   
    readdataType(fi1)
    senddataType(sock)
    
    readindatas(fi1,1,dataBuf)
    # Datas =@view dataBuf[1:8192]
    if typeCode ==1 || typeCode == 2
        # for i=1:512
        @time  sendDataPayLoad(sock,UInt(512),dataBuf)
        # end
    else
        @time  sendDataPayLoad(sock,UInt(1),dataBuf)
    end
    # sendDataPayLoad(sock,Datas)

    sendtailCheckCode(sock)
end 


# Base.include(Main,"ClientTsk.jl")
# Base.include(Main,"SvrTsk.jl")