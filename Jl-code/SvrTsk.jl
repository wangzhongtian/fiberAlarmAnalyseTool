
##############################################################################################
using Dates
buffSvr= Channel(100);

function SVrReadFileTsk(fileName )
    fi1 =open(fileName,"r")
    seek( fi1,512)
    cfgdata =readCfg(fi1)
    while(!eof( fi1))
        dataBuf = Array{UInt16,1}(undef,8192 )
        DT = readdDT(fi1)
        a= readdataType(fi1)
        # senddataType(sock)
        readindatas(fi1,1,dataBuf)
        # println(" read 1 row data ")
        put!(buffSvr, (cfgdata, DT,a,dataBuf ) )
        yield()
        # sleep(0.3) #seconds
    end
    close(fi1 )
    sleep(1000)
    print("exit out ")
end

function sendTestBufferFrame(sock,typeCode::UInt16,cfgdata::Array{UInt16,1} ,dataBuf::Array{UInt16,1}, DT,a) 
    # println("---", typeCode ," ",DT ," ",length(dataBuf)," ",a)
    # println()
    SendHeadID(sock)
    sendTypeCode(sock,typeCode)
    sendcheckCode(sock)
    a= sendmachineName(sock, glbMachineName)#"TEST-567890")
    # DT = readdDT(fi1)
    a= sendDT(sock,DT)
    yield()
    sendparas(sock,cfgdata)
    yield()
    senddataType(sock)

    if typeCode ==1 || typeCode == 2
        sendDataPayLoad(sock,UInt(512),dataBuf)
    else
        sendDataPayLoad(sock,UInt(1),dataBuf)
    end
    yield()
    sendtailCheckCode(sock)
    yield()
end 

function  SendoutBuffData( sock )
    # iscontinue= true
    cnt = 0
    while true
        if isready(buffSvr) 
            # iscontinue = true
            cnt=0
            cfgdata, DT,a,dataBuf =take!( buffSvr )
            typeCode  = UInt16( glbtypecode)
            sendTestBufferFrame(sock,typeCode,cfgdata ,dataBuf, DT,a)
            println("$(now()),$typeCode ")
            sleep(0.2)
        else
            println("empty send Queue ")
            cnt+=1;
            sleep( 0.1)
            if cnt >100 
                return 
            end
        end
    end
end
function SVrSendSocketTskEntry(Port ,IPAddr)
    # println("SVrSendSocketTskEntry start ")
    if IPAddr =="" 
        server = listen(IPv4(0),Port) 
    else
        server = listen(IPv4(IPAddr),Port) 
    end
    println(server)
    try 
        while true # 1 
            sock = accept(server)
            println("Client up")
            SendoutBuffData(sock)
            close(sock)
        end
    catch ex
        println( ex)
        exit(1)
    finally
        println("Except happen")
    end
end
