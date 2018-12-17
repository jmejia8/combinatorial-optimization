import DelimitedFiles.readdlm

include("solutions.jl")
include("problems.jl")
include("optimizers.jl")
include("tools.jl")
include("genetic-algorithm.jl")
include("tabu.jl")
include("aco.jl")



function test(id = :u, D = 500)
    

    if id == :u
        fname = "u$D"
        W = readdlm("data/$(fname).csv", ',', '\n')
        C = 150
    else
        fname = "t$D"
        W = readdlm("data/$(fname).csv", ',', '\n')
        C = 100
    end
    
    optimum = SOLUTIONS[fname]

    algorithms = [hillClimbing,simulatedAnnealing,tabuSearch,geneticAlgorithm, ACO]
    algorithms_names = ["hill-climbing","simulated-annealing","tabu-search","genetic-algorithm",]

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


