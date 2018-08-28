import DelimitedFiles.readdlm

include("optimizers.jl")
include("problems.jl")



function test()
    data = readdlm("data/u120.csv", ',', Float64, '\n')
    V = 150.0

    for i = 1:size(data, 1)
        w = data[i,:]

        fobj, initSol, getNeighbor, d, T = binpacking(V, w)

        w, fv = hillClimbing(fobj, initSol, getNeighbor; distance=2, max_iters=T)
        println(i, "\t", fv)
    end
end

test()