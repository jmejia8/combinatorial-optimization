import DelimitedFiles.readdlm

include("problems.jl")
include("optimizers.jl")
include("tools.jl")



function test()
    data = readdlm("data/u120.csv", ',', Int, '\n')
    V = 150

    println("i\tf_i")
    for i = 1:size(data, 1)
        w = data[i,:]

        fobj, initSol, getNeighbor, d, T = binpacking(V, w)

        w, fv = hillClimbing(fobj, initSol, getNeighbor; distance=2, max_iters=T)
        println(i, "\t", fv)
    end
end

function test_greedy()

    id = :t

    if id == :u
        W = readdlm("data/u120.csv", ',', '\n')
        C = 150
    else
        W = readdlm("data/t120.csv", ',', '\n')
        C = 100
    end


    heuristic_names = ["First Fit","Current Fit", "Fullest Fit","Emptiest Fit"]
    heuristics      = [firstFit,    currentFit,   fullestFit,    emptiestFit]

    i = 1
    for heuristic ∈ heuristics
        println("=============[  ", heuristic_names[i], "  ]=============")
 
        for i = 1:size(W, 1)
            # ordered asc
            a = heuristic(BinPacking(sort(W[i,:]; lt = <), C))

            # ordered desc
            b = heuristic(BinPacking(sort(W[i,:]; lt = >), C))

            # Random
            w = W[i,:]
            c = heuristic(BinPacking(w[randperm(length(w))], C))

            @printf("%d asc = %d \t desc = %d \t rand = %d \n", i, length(a), length(b), length(c))

        end

        println("----------------------------------")
        i += 1
    end

end

# test()
# @time test_greedy()

# bins = firstFit(BinPacking(rand(10:20,10), 50))

# @time bins2 = getNeighbor(bins, x->1; distance=5)

# printbin(bins)
# println("-----------------------------------")
# printbin(bins2)
bins1 = currentFit(BinPacking(rand(1:40,10), 50))
initSolBins() = bins1

bins2 = hillClimbing(x->1, initSolBins, getNeighbor; distance=20, max_iters=100)

printbin(bins1)
println("-----------------------------------")
println("-----------------------------------")
printbin(bins2)

# cambiar a swaps (1, 0) (2, 2) ...