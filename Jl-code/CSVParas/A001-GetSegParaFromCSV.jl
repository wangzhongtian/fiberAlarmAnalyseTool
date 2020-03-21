include("GetSegParaFromCSV.jl")
#=
ReadCFGPARA.Readin_cfgParas(machine友好名0=machine友好名0 )
rows = ReadCFGPARA.Paras_tofloatArray( metersPerSeg = Float64(6.001) ,timeUnit=0.426)
paraDictObj = Dict()
chn1SegIDRng=[1,8000]
chn2SegIDRng=[9000,9000+8000]
ReadCFGPARA.initParaDict(paraDict=paraDictObj ,rowsObj=rows  ,chn1SegIDRng=chn1SegIDRng , chn2SegIDRng=chn2SegIDRng)
=#
function TestMain(;machine友好名0="GYYS001" )
    ReadCFGPARA.Readin_cfgParas(machine友好名0=machine友好名0 )

    rows = ReadCFGPARA.Paras_tofloatArray( metersPerSeg = Float64(6.001),timeUnit=0.426 )
    # show(ReadCFGPARA.CsvInfoObj.csvInfoDefencePara )
    rowNum,fieldNum   = size( rows )

    for row =1:rowNum
        for fieldidx = 1:fieldNum
            print( rows[row,fieldidx],"," )
        end
        println()
    end
    paraDictObj = Dict()
    chn1SegIDRng=[1,8000]
    chn2SegIDRng=[9000,9000+8000]
    ReadCFGPARA.initParaDict(paraDict=paraDictObj ,rowsObj=rows  ,chn1SegIDRng=chn1SegIDRng , chn2SegIDRng=chn2SegIDRng)
    for key = chn1SegIDRng[1] :chn1SegIDRng[2] # 9000:17000) 
        try
            valobj = paraDictObj[key]
            print(key,": ")
            for idx =1: length(valobj )
                print( valobj[idx] ,",  ")
            end
            println()
        catch( e )
            # println(e)
        end
    end

    for key in   chn2SegIDRng[1] :chn2SegIDRng[2]# 9000:17000) 
        try
            valobj = paraDictObj[key]
            print(key,": ")
            for idx =1: length(valobj )
                print( valobj[idx] ,",  ")
            end
            println()
        catch( e )
            # println(e)
        end
    end

end

TestMain(machine友好名0="GYYS001" )
