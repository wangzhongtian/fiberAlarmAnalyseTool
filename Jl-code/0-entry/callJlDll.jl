
using Dates
using Printf
using Libdl
@static if Base.Sys.islinux()
    RawProcDLLName = joinpath( pwd(),"dll/.so"  )
else
    RawProcDLLName = joinpath( pwd(),"./builddir/31-OnlineApp.dll" )
end
ghDLLRawProc = nothing 

function dllLoad()
    global ghDLLRawProc 
    ghDLLRawProc = Libdl.dlopen(RawProcDLLName)

    return
    evs ="ghDLLRawProc = Libdl.dlopen(\"$RawProcDLLName\")"
    reps = Base.Meta.parse( evs )
    Core.eval( Main,reps )
end

function MainCall(  ) 
    startProcessRawData = Libdl.dlsym(Main.ghDLLRawProc,:julia_main )
  println( startProcessRawData ," " ,Main.ghDLLRawProc )
    t = ccall( startProcessRawData , 
    Cint,
    ( ) ) 
end

dllLoad()
println("----------------")
MainCall()