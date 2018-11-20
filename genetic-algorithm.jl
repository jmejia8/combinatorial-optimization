import Random: shuffle, randperm
import DelimitedFiles.readdlm

include("structures.jl")
include("optimizers.jl")
include("problems.jl")

function popGenerator(popSize, f, w, C)
    population = Individual[]

    for i = 1:popSize
        r = randperm(length(w))
        b = currentFit(BinPacking( w[r] , C), r)
        fb = f(b)

        push!(population, Individual(b, fb))
    end

    population
end


function firstFit!(bins::Array{Bin}, x::Int, w::Real)
    # order_bins = :firstBin

    saved = false
    for bin ∈ bins
        if bin.rC + w < bin.C
            push!(bin.w, w)
            push!(bin.x, x)
            bin.rC += w
            saved = true
            break
        end

    end

    if !saved
        push!(bins, Bin(Int[x], Real[w], bins[1].C, w))
        # println("pasa")
    end
    
    return bins

end

function indivCorrector!(offspring, w)
    bin_ids = Int[]

    for bin ∈ offspring.bins
        rms = Int[]
        
        j = 1
        for i = bin.x
            if i ∉ bin_ids
                push!(bin_ids, i)
            else
                push!(rms, j)
            end
            j += 1
        end

        if length(rms) > 0
            bin.rC -= sum(bin.w[rms])
            deleteat!(bin.x, rms)
            deleteat!(bin.w, rms)
        end
    end



    for i ∈ 1:length(w)
        i ∈ bin_ids && continue

        firstFit!(offspring.bins, i, w[i])

    end

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

function crossover(parents, w, C;p = 0.5)
    offsprings = Individual[]


    for i = 1:div(length(parents), 2)
        parent1 = parents[2i-1]
        parent2 = parents[2i]

        sort!(parent1.bins, lt = (b1, b2) -> sum(b1.w) > sum(b2.w) )
        sort!(parent2.bins, lt = (b1, b2) -> sum(b1.w) > sum(b2.w) )

        offspring1 = deepcopy(parent1)
        offspring2 = deepcopy(parent1)

        # recombination
        for j = 1:min(length(parent1.bins), length(parent2.bins))
            if rand() < p
                offspring1.bins[j] = parent2.bins[j]
            else
                offspring2.bins[j] = parent2.bins[j]
            end

        end

        indivCorrector!(offspring1, w)
        indivCorrector!(offspring2, w)
       
        push!(offsprings, offspring1)
        push!(offsprings, offspring2)
    
    end

    offsprings

end

function mutation!(offsprings,f; p = 0.1)
    for offspring in offsprings
        offspring.f = f(offspring.bins)
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

    deleteat!(population, N+1:length(population))

end


function geneticAlgorithm(f::Function, w, C; popSize::Int = 10, T::Int = 20)
    population = popGenerator(popSize, f, w, C)

    for t = 1:T
        # println("Selection")
        parents    = selection(population)
        # println(">>> ", length(parents[1].bins))
        # println("Crossover")
        offsprings = crossover(parents, w, C)

        # println("Mutation")
        mutation!(offsprings, f)

        # println("Replacement")
        replacement!(population, offsprings)
        # println(parents[1])
    end

    population[1].bins
    
end
