PT_ServerIP="0.0.0.0"
PT_ServerPort="19998"
fileReg="Data^Ver00^xxxx-004^20191117041823^ID00.RAW3"
baseFolder="/media/wang/34e67bec-7d42-4d87-824f-2f98672a41af/a/bin/sjz004/"
############## or set by enviroment 

baseFolder=ENV["baseFolder"]
println(baseFolder )
fileReg=ENV["fileReg"]
println(fileReg )

PT_ServerIP=ENV["PT_ServerIP"]
println(PT_ServerIP )
PT_ServerPort=ENV["PT_ServerPort"]
println(PT_ServerPort )

SLEEPSeconds1=ENV["SLEEPSeconds"]
println(SLEEPSeconds1 )
SLEEPSeconds=parse(Int ,SLEEPSeconds1)

using Dates
using Printf
using Libdl
@static if Base.Sys.islinux()
   # RawProcDLLName = joinpath( pwd(),"../Jl-Aux/dll/SVRTest.so"  )
else
   # RawProcDLLName = joinpath( pwd(),"../Jl-Aux/dll/SVRTest.dll" )
end
#print(RawProcDLLName)
ghDLLRawProc = nothing 

function dllLoad()
    global ghDLLRawProc 
	RawProcDLLName="SVRTest.so"
    println( RawProcDLLName)
    println()
    ghDLLRawProc = Libdl.dlopen(RawProcDLLName)
end

function Running(PT_RAWFileName ,  PT_ServerIP, PT_ServerPort,SLEEPSeconds) 
    dllLoad()
    cfunObj = Libdl.dlsym( Main.ghDLLRawProc,:mainJl )
    t = ccall(cfunObj, 
    Int32,
    (Cstring ,Cstring, Cstring,Cint ),
    PT_RAWFileName,  PT_ServerIP, PT_ServerPort,SLEEPSeconds) 
end



####################################################################################################################################################

PT_RAWFileName=joinpath(baseFolder,fileReg);
Running(PT_RAWFileName ,  PT_ServerIP, PT_ServerPort,SLEEPSeconds) 
