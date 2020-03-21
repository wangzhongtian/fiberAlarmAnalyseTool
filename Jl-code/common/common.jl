using Dates
using Printf
using Libdl
using Sockets
function getCfg(modulename, cfgJl::String )
    println( cfgJl )
    evs =""
    cfgObj =open( cfgJl,"r")
    # skip( cfgObj,3)
    for line in Base.readlines(cfgObj)
        # println( line )
        if  strip( line ) != "" && line[1:1] != "#"
            evs = evs *line *"; "
        end
    end

    reps = Base.Meta.parse( evs )
    Base.eval(modulename,reps )
end
