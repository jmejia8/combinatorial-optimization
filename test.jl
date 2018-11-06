import DelimitedFiles.readdlm

include("problems.jl")
include("optimizers.jl")
include("tools.jl")



function test()
    id = :u

    if id == :u
        W = readdlm("data/u120.csv", ',', '\n')
        C = 150
    else
        W = readdlm("data/t120.csv", ',', '\n')
        C = 100
    end

    println("i\tCFD\tHC\tSA\tTB")
    for i = 1:size(W, 1)
        w = W[i,:]

        fobj, initSol, getNeighbor, d, T = binpackingGroups(C, w)

        result_hc = hillClimbing(fobj, initSol, getNeighbor; distance=2, max_iters=T)
        result_sa = simulatedAnnealing(fobj, initSol, getNeighbor; distance=2, max_iters=T)
        result_tb = tabuSearch(fobj, initSol, getNeighbor; distance=2, max_iters=T)
        println(i, "\t", length(initSol()), "\t", length(result_hc), "\t", length(result_sa), "\t", length(result_tb))

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

function simpleTest()
    w = [4, 8, 1, 4, 2, 1]
    C = 10
    # sol: bin1 = {4, 4, 2} and bin2 = {8, 2}

    fobj, initSol, getNeighbor, d, T = binpackingGroups(C, w)
    result_hc = hillClimbing(fobj, initSol, getNeighbor; distance=2, max_iters=T)
    result_sa = simulatedAnnealing(fobj, initSol, getNeighbor; distance=2, max_iters=T)
    println(length(result_hc), "\t", length(result_sa))
    println("--==================================== S0 ====================================--")
    printbin(initSol())
    println("--==================================== HC ====================================--")
    printbin(result_hc)
    println("--==================================== SA ====================================--")
    printbin(result_sa)
end

# simpleTest()
test()
