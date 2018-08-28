include("structures.jl")
include("operators.jl")

function binpacking(V::Float64, w::Array{Float64})
    
    # objective function
    f(w) = begin
        B = 1; j = 1
        for i = 1:length(w)
            if sum( w[j:i]) > V
                j = i; B += 1
            end
        end
        return B + length(w) - j
    end

    S = Permutation(1:length(w), w, f(w))

    initSol() = S

    distance = 2
    max_iters = 1000

    fobj(S::Permutation) = f(S.w)

    return fobj, initSol, getNeighbor, distance, max_iters

end

ftmp(w) = begin
        B = 1; j = 1
        for i = 1:length(w)
            if sum( w[j:i]) >= V
                println(w[j:i], sum(w[j:i]))
                j = i; B += 1
            end
        end
        B
    end