function hillClimbing(fObj::Function, initSolution::Function, getNeighbor::Function; distance::Int = 2, max_iters::Int = 1000)

    S_old = initSolution()

    for t = 1:max_iters
        S_new = getNeighbor(S_old, fObj; distance = distance)

        if is_better(S_new, S_old)
            S_old = S_new
        end
    end

    return S_old
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
            if bin.rC + w[j] < bin.C
                push!(bin.w, w[j])
                push!(bin.x, x[j])
                bin.rC += w[j]
                saved = true
                break
            end

        end
        !saved && push!(bins, Bin(x[j:j], w[j:j], C, w[j]))

        if order_bins == :fullestBin
            sort(bins; lt = (a, b) -> a.rC > b.rC)
        elseif order_bins == :emptiestBin
            sort(bins; lt = (a, b) -> a.rC < b.rC)
        end
    end
    
    return bins

end


function currentFit(problem::BinPacking, x = 1:length(problem.w))
    bins = Array{Bin}([])

    w = problem.w
    # x = 1:length(w)

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

function simulatedAnnealing(f::Function, initSolution::Function, getNeighbor::Function; distance::Int = 2, max_iters::Int = 1000)
    T_min = 0.1
    T0    = 100
    T     = T0
    max_attemps = 50

    g(T, t) = T_min + T0*(1.0 - t / max_iters)
    p(f_old, f_new, T) = exp( (f_new - f_old) / T ) # minimization problem


    S_old = initSolution()
    S_best = S_old
    f_old = f_best = f(S_old)

    t = 1
    while T >= T_min

        for i = 1:max_attemps
            S_new = getNeighbor(S_old, f; distance = distance)

            f_new = f(S_new)

            if f_new < f_old || rand() < p(f_old, f_new, T)
                S_old = S_new
                f_old = f_new

                if is_better(S_new, S_best)
                    S_best = S_new
                    f_best = f_new
                end
            end
        end
     
        t += 1
        T = g(T, t)
    end

    return S_best
end

function tabuSearch(f::Function, initSolution::Function, getNeighbor::Function; distance::Int = 2, max_iters::Int = 1000)
    S_old = initSolution()

    tabu_list = Tabu[]

    stop = false
    t = 0
    while !stop 

        S_new = getNeighbor(S_old, tabu_list, f; distance = distance, freq  = 5)

        if is_better(S_new, S_old)
            S_old = S_new
        end

        update_tabu_list!(tabu_list)

        t += 1
        stop = t >= max_iters
    end

    return S_old
end
