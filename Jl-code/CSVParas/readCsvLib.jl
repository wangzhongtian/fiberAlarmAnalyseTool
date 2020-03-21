using Printf
using StringEncodings
mutable struct  CSVinfo
     fieldname ::String 
     signalStringName::String
     keyFieldNames::String 
     fieldNameDict::Dict
     Area2FiberLen
     # PosNames
     function CSVinfo(;fieldname::String ="定位界标1,定位界标2,xxxx主机IP,通道号,定位界标1光程,定位界标2光程,子防区编号,防区起点GPS经度坐标,防区起点GPS纬度坐标,防区终点GPS经度坐标,防区终点GPS纬度坐标,左右岸,地名信息,界标之间围栏长度,管理处,分局",
          signalStringName::String="定位界标1光程",
          keyFieldNames::String ="定位界标1,定位界标1光程,定位界标2,定位界标2光程"
           )
          Area2FiberLen=[ ]
          new(fieldname,signalStringName,keyFieldNames ,Dict(),Area2FiberLen)
     end

end

# 
function initDict!(CSVinfo1::CSVinfo)
     CSVinfo1.fieldNameDict = Dict()
     ts = split(CSVinfo1.fieldname,"," )
     for t = 1: length( ts )
          CSVinfo1.fieldNameDict[ ts[t] ] = 0
     end
     # return fieldNameDict
end

function readinCSVFile1!(CSVinfo1::CSVinfo;csvfile="../xxxx分局防区信息.csv",coding1=enc"GBK") 
     ret=false;
     initDict!(CSVinfo1 ) 
     fields= split( CSVinfo1.keyFieldNames,",")
     fieldlen =length( fields)
     # csvfileAbsname = csvfile

     csvfileAbsname =joinpath(pwd(), csvfile)
     fin =nothing
     # println( string(coding1));println()
     if string(coding1 ) =="UTF8"
          fin = open(csvfileAbsname,"r" )
     elseif string(coding1 ) =="UTF8-BOM"
          println( csvfileAbsname)
          fin = open(csvfileAbsname,"r" )
         # @info "here ",fin
          i1 = read(fin,UInt8); #@info "here ", i1
          i2= read(fin,UInt8);#@info "here ", i2
          i3 = read(fin,UInt8);#@info "here ", i3
          if i1 ==  UInt8(239) &&  i2 == UInt8(187) && i3 == UInt8(191)
               println( "$csvfile: UTF8-BOM file ")
          else
               return false;
               # break
          end
     else
          fin = open(csvfileAbsname, coding1, "r");
          println( "$csvfile:$coding1 file ")
          # break
     end
     try
               CSVinfo1.Area2FiberLen =[]
               for line in readlines(fin)
                    ts = split(line,"," )
                    if occursin(CSVinfo1.signalStringName , line) ## 首行
                         for t = 1: length( ts )
                              CSVinfo1.fieldNameDict[ ts[t] ] = t
                         end  
                    else
                         a=[]

                         for i =1:fieldlen
                              field = fields[i]
                              idx = CSVinfo1.fieldNameDict[ field] 
                              val  = ts[ idx ] 
                              append!(a,[val])
                         end
                         append!(CSVinfo1.Area2FiberLen,[ a ])
                    end  
               end
               # println("open and read ok !!!!!!!!!!!!!");println()
               ret=true;
     catch 
          # println(e)
          # println("open and read Error !!!!!!!!!!!!!");println()
     finally
         # close(fin )
     end
     # println("open and read result: $ret ----");println()
     return ret
end

function readinCSVFile!(CSVinfo1::CSVinfo;csvfile="../xxxx分局防区信息.csv")  
     ret= false;
     while ret ==false 
          for bianma=[enc"GBK",enc"UTF-8"]
               println()
               ret = readinCSVFile1!(CSVinfo1,csvfile=csvfile,coding1=bianma) 
               if ret == true
                    break
               end
          end
     end
end
function show(CSVinfo1::CSVinfo )
     fields= split( CSVinfo1.keyFieldNames,",")
     fieldlen =length( fields)
     for  row  in CSVinfo1.Area2FiberLen
          for i =1:fieldlen 
               fieldname = fields[ i ]
               print("$fieldname:$(row[i]) ,")
          end
          println()
     end
end
function write2CSV(;CSVinfo1::CSVinfo,filename::String )
     fileobj = open( filename,"w")
     # EF BB BF
     write( fileobj,0xEF)
     write( fileobj,0xBB)
     write( fileobj,0xBF)

     write( fileobj, CSVinfo1.keyFieldNames )  
     write(fileobj,"\r\n")

     # fields= split( CSVinfo1.keyFieldNames,",")
     # fieldlen =length( fields)
     total = length( CSVinfo1.Area2FiberLen)
     for  idx  = 1: total 
          row = CSVinfo1.Area2FiberLen[idx]

          for i =1:length( row )-1 

               write( fileobj, "$(row[i])," ) 
               # fieldname = fields[ i ]
               # print("$fieldname:$(row[i]) ,")
          end
          write( fileobj, "$(row[end])\r\n" ) 
          # println()
     end
end


