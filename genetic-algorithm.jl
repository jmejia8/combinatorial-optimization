include("optimizers.jl")

function geneticAlgorithm(f::Function, popSize::Int, popGenerator::Function, indivCorrector::Function)
    population = popGenerator(popSize)

    for t = 1:T
        parents    = selection(population)
        offsprings = crossover(parents)

        mutation!(offsprings)

        replacement!(parents, offsprings)
    end
    
end
