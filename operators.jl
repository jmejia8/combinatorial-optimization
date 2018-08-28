import Random.randperm

function is_better(S1::Permutation, S2::Permutation)
    # S1 is better than S2
    return S1.f < S2.f
end

function swap(S::Permutation, I::Array{Int}, J::Array{Int})
    x = copy(S.x)
    w = copy(S.w)

    for i ∈ 1:length(I)
        S.x[I[i]] = x[J[i]]
        S.w[I[i]] = w[J[i]]

        S.x[J[i]] = x[I[i]]
        S.w[J[i]] = w[I[i]]
    end

    return S
end

function getNeighbor(S::Permutation, f::Function; distance::Real = 2)
    # Hamming distance is supposed
    distance = min(distance, length(S.x))
    k = max(2, round(Int, distance / 2))

    I = randperm(length(S.x))
    
    neighbor = swap(Permutation(S.x, S.w, S.f), I[1:k], I[k+1:2k])
    neighbor.f = f(neighbor)

    return neighbor
end

initSolution(S::Permutation, f::Function) = getNeighbor(S, f; distance = Inf)