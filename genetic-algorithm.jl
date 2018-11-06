import Random: shuffle
include("structures.jl")
include("optimizers.jl")
include("problems.jl")

function popGenerator(popSize, f, w, C)
    population = Individual[]

    for i = 1:popSize
       b = currentFit(BinPacking( shuffle(w) , C))
       fb = f(b)

       push!(population, Individual(b, fb))
    end

    population
end

function indivCorrector(offsprings)
    
end

function selection(population; k = 2)
    # return population
    Argmin(L) = begin
        i_best = 1
        for i in 1:length(L)
            if L[i].f < L[i_best].f
                i_best = i
            end
        end

        i_best
    end

    N = length(population)

    I = Int[]

    for i = 1:N
        ii = rand(1:N, k)

        indiv = Argmin(population[ii])
        push!(I, indiv)
    end

    return population[I]
end

function crossover(parents;p = 0.5)
    offsprings = Individual[]


    for i = 1:div(length(parents), 2)
        parent1 = parents[2i-1]
        parent2 = parents[2i]

        sort!(parent1.bins, lt = (b1, b2) -> sum(b1.w) > sum(b2.w) )
        sort!(parent2.bins, lt = (b1, b2) -> sum(b1.w) > sum(b2.w) )

        offspring1 = deepcopy(parent1)
        offspring2 = deepcopy(parent1)

        for j = 1:min(length(parent1.bins), length(parent2.bins))
            if rand() < p
                offspring1.bins[j] = parent2.bins[j]
            else
                offspring2.bins[j] = parent2.bins[j]
            end

        end
       
        push!(offsprings, offspring1)
        push!(offsprings, offspring2)
    
    end

    offsprings

end

function mutation!(offsprings,f; p = 0.1)
    for offspring in offsprings
        rand() > p && (continue)

        b = hillClimbing(f, ()-> offspring.bins, getNeighbor; max_iters=10)

        offspring.bins = b


    end
end

function replacement!(population, offsprings)
    N = length(population)

    for offspring = offsprings
        push!(population, offspring)
    end

    sort!(population, lt = (b1, b2) -> b1.f < b2.f)

    population = population[1:N]
end


function geneticAlgorithm(f::Function, w, C; popSize::Int = 10, T::Int = 100)
    population = popGenerator(popSize, f, w, C)

    for t = 1:T
        # println("Selection")
        parents    = selection(population)
        # println("Crossover")
        offsprings = crossover(parents)

        # println("Mutation")
        mutation!(offsprings, f)

        # println("Replacement")
        replacement!(population, offsprings)
        println(length(parents[1].bins))
    end

    population
    
end


function test()
    popSize = 10

    w = [4, 8, 1, 4, 2, 1]
    C = 10
    # sol: bin1 = {4, 4, 2} and bin2 = {8, 2}

    fobj, initSol, getNeighbor, d, T = binpackingGroups(C, w)

    return geneticAlgorithm(fobj, w, C)

end

test()