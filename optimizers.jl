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

function firstFit(problem::BinPacking)
    bins = Array{Bin}([])

    x = randperm(length(problem.w))
    w = problem.w[x]

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
