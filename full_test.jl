import DelimitedFiles.readdlm

include("problems.jl")
include("optimizers.jl")
include("tools.jl")
include("genetic-algorithm.jl")
include("aco.jl")



function test()
    id = :u

    if id == :u
        W = readdlm("data/u120.csv", ',', '\n')
        optimum = readdlm("data/sol_u120.csv", ',', '\n')
        C = 150
    else
        W = readdlm("data/t120.csv", ',', '\n')
        optimum = 40ones(Int, 120)
        C = 100
    end

    algorithms = [hillClimbing,simulatedAnnealing,tabuSearch,geneticAlgorithm, ACO]
    algorithms_names = ["hill-climbing","simulated-annealing","tabu-search","genetic-algorithm",]

    println("i\tCFD\tHC\tSA\tTB\tGA")
    for i = 1:size(W, 1)
        w = W[i,:]

        fobj, initSol, getNeighbor, d, T = binpackingGroups(C, w)

        results = Int[]

        for alg in algorithms
            result = []
            try
                result = alg(fobj, initSol, getNeighbor)
            catch
                result = alg(fobj, w, C)
            end

            push!(results, length(result))
        end

        println(results .- optimum[i])

    end
end


test()
