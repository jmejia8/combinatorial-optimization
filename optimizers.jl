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
