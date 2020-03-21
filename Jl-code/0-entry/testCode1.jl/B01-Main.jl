Base.@ccallable function julia_main(ARGS::Vector{String})::Cint 
    csvfileAbsname =joinpath(@__DIR__ ,"csvfile.csv" )
    println(csvfileAbsname )
end
