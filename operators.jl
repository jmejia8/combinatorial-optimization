import Random.randperm

function is_better(S1::Permutation, S2::Permutation)
    # S1 is better than S2
    return S1.f < S2.f
end

function swap(S::Permutation, I::Array{Int}, J::Array{Int})

    for i ∈ 1:length(I)
        w_i = S.w[I[i]]
        S.w[I[i]] = S.w[J[i]]
        S.w[J[i]] = w_i
    end

    return S
end

function getNeighbor(S::Permutation, f::Function; distance::Real = 2)
    # Hamming distance is supposed
    distance = min(distance, length(S.w))
    k = max(2, round(Int, distance / 2))

    I = randperm(length(S.w))
    
    neighbor = swap(Permutation(copy(S.w), S.f), I[1:k], I[k+1:2k])
    neighbor.f = f(neighbor)

    return neighbor
end

initSolution(S::Permutation, f::Function) = getNeighbor(S, f; distance = Inf)
