import Random: shuffle, randperm
import DelimitedFiles.readdlm

include("structures.jl")
include("optimizers.jl")
include("problems.jl")

function firstFit!(bins::Array{Bin}, x::Int, w::Real, C::Int)

    saved = false
    b = 0
    for i ∈ 1:length(bins)
        if bins[i].rC + w < bins[i].C
            push!(bins[i].w, w)
            push!(bins[i].x, x)
            bins[i].rC += w
            saved = true
            b = i
            break
        end

    end

    if !saved
        push!(bins, Bin(Int[x], Real[w], C, w))
        b = length(bins)
    end
    
    return b

end

function generateBins(popSize, f, w, C, τ, R)
    population = Individual[]

    memory = Array[ Int[] for i = 1:length(w) ]

    for i = 1:popSize
        bins = Bin[]

        tmp = ones(Int, length(w))

        # save objects with probability τ
        while sum(tmp) > 0
            for i in R
                tmp[i] == 0 && (continue)

                if rand() < τ[i]
                    # b is the bin id which wi was saved
                    b = firstFit!(bins, i, w[i], C)
                    tmp[i] = 0
                    push!(memory[i], b)
                end
            end
        end

        fb = f(bins)

        push!(population, Individual(bins, fb))
    end

    population, memory
end


function pheromoneUpdate!(ants, w, memory, τ, p)
    # fs = [ ant.f for ant in ants ]
    R = Real[]

    for i = 1:length(τ)
        ip = rand(1:1 + floor(Int, p*length(ants)))
        pbest = ants[ ip ]
        
        u = unique(memory[i])
        b_emptiest = maximum(u) # emptiest of emptiest bin

        b = Int[ count(x -> x==j, memory[i]) for j in u ]

        # most common bin selected for weight i
        b_mode = u[argmax(b)]

        # w index in pbest bin  
        bin_id = findfirst( b -> w[i] in b.w, pbest.bins)
        bin_w = pbest.bins[bin_id] 

        r = bin_w.rC / bin_w.C
        push!(R, r)
        
        τ[i] =  b_mode / b_emptiest ;
    end


    # R = sortperm(R, rev=true)
    R = shuffle(1:length(w))

    return R

end


function ACO(f::Function, w, C; popSize::Int = 20, T::Int = 20)
    τ = 0.5ones(length(w))
    R = shuffle(1:length(w))
    best = nothing

    for t = 1:T
        # ants generate new bins
        ants, memory = generateBins(popSize, f, w, C, τ, R)

        sort!(ants, lt = (a, b) -> length(a.bins) < length(b.bins) )
            
        if best == nothing || best.f <= ants[1].f
            best = ants[1]
        end

        p = 1.0 - t / T
        R = pheromoneUpdate!(ants, w, memory, τ, p)

        println("iter: $t \t nBins: ", length(best.bins))
        println(R)
    end

    return best.bins
end


function simple_test()
    popSize = 10

    w = [4, 8, 1, 4, 2, 1]
    C = 10
    # sol: bin1 = {4, 4, 2} and bin2 = {8, 1, 1}

    fobj, initSol, getNeighbor, d, T = binpackingGroups(C, w)

    best = ACO(fobj, w, C)
    println(length(best))

    best
end

simple_test()
