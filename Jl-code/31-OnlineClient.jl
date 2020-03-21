

include("31-OnlineApp.jl")
while true 
    try
        julia_main([""])
    catch(e)
        println( e)
    end
    sleep(30)
end
