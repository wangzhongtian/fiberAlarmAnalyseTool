using Printf
using StringEncodings
using Base.Filesystem

mutable struct  CSVinfo
     fieldname ::String 
     signalStringName::String
     keyFieldNames::String 
     fieldNameDict::Dict
     Area2FiberLen
     # PosNames
     function CSVinfo(;fieldname::String ="定位界标1	定位界标2	xxxx主机IP	通道号	定位界标1光程	定位界标2光程	子防区编号	防区起点GPS经度坐标	防区起点GPS纬度坐标	防区终点GPS经度坐标	防区终点GPS纬度坐标	左右岸	地名信息	界标之间围栏长度	管理处	分局	分局编号	管理处编号	类型	主机编号	防区编号	通道号	归属IP",
          signalStringName::String="定位界标1光程",
          keyFieldNames::String ="定位界标1光程	定位界标2光程	地名信息	管理处编号	防区编号	通道号	归属IP	定位界标1	定位界标2"
           )
          Area2FiberLen=[ ]
          new(fieldname,signalStringName,keyFieldNames ,Dict(),Area2FiberLen)
     end

end

# 
function initDict!(CSVinfo1::CSVinfo)
     CSVinfo1.fieldNameDict = Dict()
     ts = split(CSVinfo1.fieldname,"\t" )
     for t = 1: length( ts )
          CSVinfo1.fieldNameDict[ ts[t] ] = 0
     end
     # return fieldNameDict
end

function readinCSVFile!(CSVinfo1::CSVinfo;csvfile="../Jl-Aux/glbCfg/org/全局-xxxx主机-防区信息.csv") 
     initDict!(CSVinfo1 ) 
     fields= split( CSVinfo1.keyFieldNames,"\t")
     fieldlen =length( fields)
     # csvfileAbsname = csvfile

     csvfileAbsname =joinpath(pwd(), csvfile)
     fin =nothing
     while true
          println( csvfileAbsname)
          fin = open(csvfileAbsname,"r" )
         # @info "here ",fin
          i1 = read(fin,UInt8); #@info "here ", i1
          i2= read(fin,UInt8);#@info "here ", i2
          i3 = read(fin,UInt8);#@info "here ", i3
          if i1 ==  UInt8(239) &&  i2 == UInt8(187) && i3 == UInt8(191)
               # println( "UTF8 -BOM file ")
               break
          else
               close(fin )
               fin = open(csvfileAbsname, enc"GBK", "r");
               # println( "GBK file ")
               break
          end
     end
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
end
function show(CSVinfo1::CSVinfo )
     fields= split( CSVinfo1.keyFieldNames,"\t")
     fieldlen =length( fields)
     for  row  in CSVinfo1.Area2FiberLen
          for i =1:fieldlen 
               fieldname = fields[ i ]
               print("$fieldname:$(row[i]) ,")
          end
          println()
     end
end

function getrow(CSVinfo1,归属IP,strchnid,strAreaID )
     for rowobj in CSVinfo1.Area2FiberLen  
     #"定位界标1光程	定位界标2光程	地名信息	管理处编号	防区编号	通道号	归属IP"	
          if rowobj[ 7 ] == 归属IP && rowobj[ 6 ] == strchnid 
               # println( rowobj[ 9 ][ end-2:end]  )
               if rowobj[ 5 ] == strAreaID 
                    return rowobj 
               elseif rowobj[ 9 ][ end-2:end] == strAreaID[2:end]  # 末尾的标牌是该管理处
                    return rowobj
               end
          end
     end
  return

end



function  outfile(CSVinfo1::CSVinfo;归属IP)
 tgrFolder = Base.Filesystem.dirname( csvfile1  )
 for chnid = 1:2
   filename ="defence-" * 归属IP *"Sheet "*string( chnid)*".csv"
   tgrfullname = Base.Filesystem.joinpath(tgrFolder, filename ) 
   fobj = open( tgrfullname ,enc"GBK","w")
   write(fobj ,"编号,通道,起点光程,防区号,防区描述,使能\n")
fiberpos1 =""
idx =0
地名信息 =""
  for AreaID = 1:10000
                idx = AreaID 
	strAreaID = @sprintf("_%03d", AreaID )
	rowDictObj = getrow(CSVinfo1,归属IP,string( chnid),strAreaID )
	if  rowDictObj  == nothing
		break		
	end
	# if rowDictObj[ 3 ]   == nothing 
	# 	地名信息 =""
	# else
		地名信息 = rowDictObj[ 3 ]
     # end
     if rowDictObj[ 5 ] == strAreaID
          fiberpos1 = rowDictObj[ 1 ]
          rowStr = @sprintf("%04d,%d,%s,_%03d,%s,1\n",idx ,chnid, fiberpos1 ,  AreaID  , 地名信息  )
     else
          fiberpos1 = rowDictObj[ 2 ]
          rowStr = @sprintf("%04d,%d,%s,_%03d,%s,1\n",idx ,chnid, fiberpos1 ,  AreaID  , ""  )
     end    
	write( fobj , rowStr )
  end

   close(fobj  )
end
end


###############################

csvfile1 = "../Jl-Aux/glbCfg/org/全局-xxxx主机-防区信息.csv"
CSVinfoObj = CSVinfo()
readinCSVFile!(CSVinfoObj ,csvfile=csvfile1);
#show( CSVinfoObj )
IPs= "10.17.171.41 10.17.174.41 10.17.178.41 10.17.36.41 10.17.39.41 10.17.46.41 10.17.5.41 10.18.132.41 10.18.135.41 10.18.136.41 10.19.138.41 10.19.139.41 10.19.141.41 10.19.164.41"
for  归属IP1 in split(IPs," ")
	#归属IP1= "10.19." * string(A4) * ".41"
                println(  归属IP1 )
	outfile( CSVinfoObj ,归属IP= 归属IP1)
end
