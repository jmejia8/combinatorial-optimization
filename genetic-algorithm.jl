import Random: shuffle!, randperm
import DelimitedFiles.readdlm

include("structures.jl")
include("optimizers.jl")
include("problems.jl")

function popGenerator(popSize, f, w, C)
    population = Individual[]

    for i = 1:popSize
        r = randperm(length(w))
        b = firstFit(BinPacking( w[r] , C), r)
        fb = f(b)

        push!(population, Individual(b, fb))
    end

    population
end


function firstFit!(bins::Array{Bin}, x::Int, w::Real)

    saved = false
    for i ∈ 1:length(bins)
        if bins[i].rC + w <= bins[i].C
            push!(bins[i].w, w)
            push!(bins[i].x, x)
            bins[i].rC += w
            saved = true
            break
        end

    end

    if !saved
        push!(bins, Bin(Int[x], Real[w], bins[1].C, w))
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



    for x ∈ 1:length(w)
        x ∈ bin_ids && continue

        firstFit!(offspring.bins, x, w[x])

    end

end

function selection(population; k = 2)
    Argmin(L) = begin
        i_best = 1
        for i in 2:length(L)
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
        parent1 = deepcopy(parents[2i-1])
        parent2 = deepcopy(parents[2i])

        sort!(parent1.bins, lt = (b1, b2) -> sum(b1.w) > sum(b2.w) )
        sort!(parent2.bins, lt = (b1, b2) -> sum(b1.w) > sum(b2.w) )

        offspring1 = parent1
        offspring2 = parent1

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

function mutation!(offsprings,f,w; p = 0.1)
    for i in 1:length(offsprings)
        if rand() < p 
            k = length(offsprings[i].bins)

            r = 0.1 + 0.2rand()
            ratio = round(Int, r * k) - 1

            deleted_bins = offsprings[i].bins[k-ratio:k]
            shuffle!(deleted_bins)

            deleteat!(offsprings[i].bins, k-ratio:k)

            indivCorrector!(offsprings[i], w)

        end
        
        offsprings[i].f = f(offsprings[i].bins)

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


function geneticAlgorithm(f::Function, w, C; popSize::Int = 20, T::Int = 1000)
    population = popGenerator(popSize, f, w, C)

    for t = 1:T
        # println("Selection")
        parents    = selection(population)

        # println("Crossover")
        offsprings = crossover(parents, w, C)

        # println("Mutation")
        mutation!(offsprings, f, w)

        # println("Replacement")
        replacement!(population, offsprings)
    end

    sort!(population, lt = (a, b) -> length(a.bins) < length(b.bins) )
    
    population[1].bins
end
