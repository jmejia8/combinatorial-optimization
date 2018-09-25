import Random.randperm

function is_better(S1, S2)
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

function swap(bin1, bin2; distance::Real=2)
    ii = jj = -1

    for i = 1:randperm(length(bin1.w))
        w = bin1.w[i]

        if w + bin2.f <= bin2.C
            ii = i
            break
        end
    end
    
    for j = 1:randperm(length(bin2.w))
        w = bin2.w[i]

        if w + bin1.f - bin1.w[ii] <= bin1.C
            jj = j
            break
        end
    end

    if ii > 0
        w = bin1.w[ii]
        bin1.w[ii] = bin2.w[jj]
        bin2.w[jj] = w
    end
    
    if jj > 0
        bin1.f += bin1.w[ii] - bin2.w[jj]
        bin2.f += -bin1.w[ii] + bin2.w[jj]
    end

    if jj < 0 && ii < 0
        return 
    end

end

function getNeighbor(bins::Array{Bin}, f::Function; distance::Real=2)
    b = length(bins)
    Ids = randperm(b)
    d = div(distance, 2)

    for i = 1:b
        bin1 = bins[Ids[i]]
        for j = i+1:b
            bin2 = bins[Ids[j]]

            swap(bin1, bin2)

        end
    end


end

initSolution(S::Permutation, f::Function) = getNeighbor(S, f; distance = Inf)
