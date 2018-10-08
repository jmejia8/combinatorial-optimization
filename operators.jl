import Random.randperm

function is_better(S1, S2)
    # S1 is better than S2
    return S1.f < S2.f
end

function is_better(B1::Array{Bin}, B2::Array{Bin})
    # B1 is better than B2
    f1 = sum( [ b.f^2 for b in B1 ] )
    f2 = sum( [ b.f^2 for b in B2 ] )
    # println(f1)
    # println(f2)
    return f1 >= f2
end

function swap(S::Permutation, I::Array{Int}, J::Array{Int})

    for i ∈ 1:length(I)
        w_i = S.w[I[i]]
        S.w[I[i]] = S.w[J[i]]
        S.w[J[i]] = w_i
    end

    return S
end

function getNeighbor(S::Permutation, f::Function; distance::Real = 2, max_tries::Int=10)
    # Hamming distance is supposed
    distance = min(distance, length(S.w))
    k = max(1, round(Int, distance / 2))

    I = randperm(length(S.w))

    neighbor = swap(Permutation(copy(S.w), S.f), I[1:k], I[k+1:2k])
    neighbor.f = f(neighbor)


    i = 1

    while !is_better(neighbor, S) && max_tries < 10
        I = randperm(length(S.w))

        neighbor = swap(Permutation(copy(S.w), S.f), I[1:k], I[k+1:2k])
        neighbor.f = f(neighbor)
        i += 1
    end
    

    return neighbor
end

function swap(bin1::Bin, bin2::Bin; distance::Real=2)
    ii = jj = -1

    for i = randperm(length(bin1.w))
        w = bin1.w[i]

        if w + bin2.f <= bin2.C
            ii = i
            break
        end
    end
    
    wii = ii > 0 ? bin1.w[ii] : 0

    for j = randperm(length(bin2.w))
        w = bin2.w[j]

        if w + bin1.f - wii <= bin1.C
            jj = j
            break
        end
    end

    if ii > 0 && jj > 0
        bin1.f += -bin1.w[ii] + bin2.w[jj]
        bin2.f += bin1.w[ii] - bin2.w[jj]
        
        w = bin1.w[ii]
        bin1.w[ii] = bin2.w[jj]
        bin2.w[jj] = w
        return 2
    elseif ii > 0
        bin1.f -= bin1.w[ii]
        bin2.f += bin1.w[ii]

        push!(bin2.w, bin1.w[ii])
        deleteat!(bin1.w, ii)
        return 1
    elseif jj > 0
        bin1.f += bin2.w[jj]
        bin2.f -= bin2.w[jj]

        push!(bin1.w, bin2.w[jj])
        deleteat!(bin2.w, jj)
        return 1
    end

    return 0

end

function getNeighbor(Bins::Array{Bin}, f::Function; distance::Real=2)
    bins = deepcopy(Bins)
    b = length(bins)
    Ids = randperm(b)
    d = 0

    for i = 1:b
        bin1 = bins[Ids[i]]
        for j = (i+1):b
            bin2 = bins[Ids[j]]


            d  += swap(bin1, bin2)

            if d >= distance
                break
            end

        end

        if d >= distance
            break
        end
    end


    rms = Int[]
    for i = 1:b
        if bins[i].f < 1
            push!(rms, i)
        end
    end

    deleteat!(bins, rms)
    return bins


end



initSolution(S::Permutation, f::Function) = getNeighbor(S, f; distance = Inf)
