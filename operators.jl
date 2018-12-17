import Random.randperm

function is_better(S1, S2)
    # S1 is better than S2
    return S1.f < S2.f
end

function is_better(B1::Array{Bin}, B2::Array{Bin})
    # B1 is better than B2
    f1 = sum( [ b.rC^2 for b in B1 ] )
    f2 = sum( [ b.rC^2 for b in B2 ] )
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

    while !is_better(neighbor, S) && i < max_tries
        I = randperm(length(S.w))

        neighbor = swap(Permutation(copy(S.w), S.f), I[1:k], I[k+1:2k])
        neighbor.f = f(neighbor)
        i += 1
    end
    

    return neighbor
end

function getNeighbor(S::Permutation, f::Function, tabuList; distance::Real = 2, max_tries::Int=10)
    # Hamming distance is supposed
    distance = min(distance, length(S.w))
    k = max(1, round(Int, distance / 2))

    neighbor = deepcopy(S)

    # i = 1
    # while !is_better(neighbor, S) && max_tries < 10
    #     d = 0
    #     while d < distance && j ∉ tabuList
            
    #     end
    #     i += 1
    # end
    

    return neighbor
end

function swap(bin1::Bin, bin2::Bin; distance::Real=2)
    ii = jj = -1

    bin_tmp = bin1

    if length(bin2.w) == 1
        bin1 = bin2
        bin2 = bin_tmp
    end
    
    swap01 = length(bin1.w) == 1

    II = randperm(length(bin1.w))
    JJ = randperm(length(bin2.w))

    swap_found = false
    for i ∈ II
        w1 = bin1.w[i]

        if w1 + bin2.rC <= bin2.C
            ii = i
            swap_found = true
            break
        end

        for j ∈ JJ
            w2 = bin2.w[j]

            if w2 + bin1.rC <= bin1.C
                jj = j
                swap_found = true
                break
            end

            if w1 - w2 + bin2.rC <= bin2.C && w2 - w1 + bin1.rC <= bin1.C
                ii, jj = i, j
                swap_found = true
                break
            end
        end

        swap_found && (break)
    end

    if ii > 0 && jj > 0
        bin1.rC += -bin1.w[ii] + bin2.w[jj]
        bin2.rC += bin1.w[ii] - bin2.w[jj]
        
        w = bin1.w[ii]
        x = bin1.x[ii]
        bin1.w[ii] = bin2.w[jj]
        bin2.w[jj] = w

        bin1.x[ii] = bin2.x[jj]
        bin2.x[jj] = x
        return 2
    elseif ii > 0
        bin1.rC -= bin1.w[ii]
        bin2.rC += bin1.w[ii]

        push!(bin2.w, bin1.w[ii])
        push!(bin2.x, bin1.x[ii])
        deleteat!(bin1.w, ii)
        deleteat!(bin1.x, ii)
        return 1
    elseif jj > 0
        bin1.rC += bin2.w[jj]
        bin2.rC -= bin2.w[jj]

        push!(bin1.w, bin2.w[jj])
        push!(bin1.x, bin2.x[jj])
        deleteat!(bin2.w, jj)
        deleteat!(bin2.x, jj)
        return 1
    end

    if swap_found
        return distance    
    end

    return 0

end

function getNeighbor(Bins::Array{Bin}, f::Function; distance::Real=2)
    bins = deepcopy(Bins)
    b = length(bins)
    Ids = randperm(b)
    Ids2 = randperm(b)
    d = 0

    for i = Ids
        bin1 = bins[i]
        for j = Ids2

            (i == j) && (continue)

            bin2 = bins[j]


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
        if bins[i].rC < 1 || length(bins[i].w) < 1
            push!(rms, i)
        end
    end

    deleteat!(bins, rms)
    return bins
end





initSolution(S::Permutation, f::Function) = getNeighbor(S, f; distance = Inf)
