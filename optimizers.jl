function hillClimbing(fObj::Function, initSolution::Function, getNeighbor::Function; distance::Int = 2, max_iters::Int = 1000)

    S_old = initSolution()

    for t = 1:max_iters
        S_new = getNeighbor(S_old, fObj; distance = distance)

        if is_better(S_new, S_old)
            S_old = S_new
        end
    end

    return S_old.w, S_old.f
end

function firstFit(problem::BinPacking; order_bins = :firstBin)
    # order_bins = :firstBin
    # order_bins = :fullestBin
    # order_bins = :emptiestBin
    bins = Array{Bin}([Bin([], [], problem.C, 0)])

    w = problem.w
    x = 1:length(w)
    C = problem.C

    for j = 1:length(problem.w)
        saved = false
        for bin ∈ bins
            if bin.f + w[j] < bin.C
                push!(bin.w, w[j])
                push!(bin.x, x[j])
                bin.f += w[j]
                saved = true
                break
            end

        end
        !saved && push!(bins, Bin(x[j:j], w[j:j], C, w[j]))

        if order_bins == :fullestBin
            sort(bins; lt = (a, b) -> a.f > b.f)
        elseif order_bins == :emptiestBin
            sort(bins; lt = (a, b) -> a.f < b.f)
        end
    end
    
    return bins

end


function currentFit(problem::BinPacking)
    bins = Array{Bin}([])

    w = problem.w
    x = 1:length(w)

    i = 1
    for j = 1:length(problem.w)
        if sum(w[i:j]) > problem.C
            bin = Bin(x[i:j-1], w[i:j-1], problem.C, sum(w[i:j-1]))
            push!(bins, bin)
            i = j
        end
    end
    
    bin = Bin(x[i:end], w[i:end], problem.C, sum(w[i:end]))
    push!(bins, bin)

    return bins

end


fullestFit(problem::BinPacking) = firstFit(problem; order_bins = :fullestBin)
emptiestFit(problem::BinPacking) = firstFit(problem; order_bins = :emptiestBin)
