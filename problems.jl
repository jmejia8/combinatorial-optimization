include("structures.jl")
include("operators.jl")

function binpacking(C::Real, w::Vector)
    # objective function
    f(w) = begin
        B = 1; j = 1
        for i = 1:length(w)
            if sum( w[j:i]) > C
                j = i; B += 1
            end
        end
        return B
    end

    S = Permutation(w, f(w))

    initSol() = S

    distance = 2
    max_iters = 1000

    fobj(S::Permutation) = f(S.w)

    return fobj, initSol, getNeighbor, distance, max_iters

end

function binpackingGroups(C::Real, w::Vector)
    # objective function (minize)
    fobjGroups(B::Array{Bin}) = begin
        s = 0
        for b ∈ B
            s += b.rC .^ 2
        end
        -s/length(B)
    end

    S = currentFit( BinPacking(w, C) )

    initSol() = S

    distance = 2
    max_iters = 100


    return fobjGroups, initSol, getNeighbor, distance, max_iters

end
