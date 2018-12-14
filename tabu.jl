import Base.∈


function ∈(bins::Tuple{Int64,Int64}, tabu_list::Array{Tabu})
    is_tabu(x) = x.bin1 ∈ bins && x.bin2 ∈ bins
    i = findfirst(is_tabu, tabu_list)
    
    if i == nothing
        return false
    end

    return true
end

function getNeighbor(Bins::Array{Bin}, tabu_list::Array{Tabu}, f::Function; distance::Real=2, freq::Int = 3)
    bins = deepcopy(Bins)
    b = length(bins)
    Ids = randperm(b)
    Ids2 = randperm(b)
    d = 0

    for i = Ids
        bin1 = bins[i]
        for j = Ids2

            if i == j || (i, j) ∈ tabu_list
                continue
            end

            bin2 = bins[j]

            s  = swap(bin1, bin2)
            
            if s > 0
                update_tabu_list!(tabu_list, (i, j), freq)
            end

            d += s

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
            update_tabu_list!(tabu_list, i)
            push!(rms, i)
        end
    end

    deleteat!(bins, rms)
    return bins
end

function update_tabu_list!(tabu_list::Array{Tabu}, bins::Tuple{Int64,Int64}, freq::Int = 3)
    push!(tabu_list, Tabu( bins[1], bins[2], freq))
end

function update_tabu_list!(tabu_list::Array{Tabu}, bin::Int64)
    is_tabu(x) = x.bin1 == bin || x.bin2 == bin
    items = findall(is_tabu, tabu_list)
    deleteat!(tabu_list, items)
end


function update_tabu_list!(tabu_list::Array{Tabu})
    rms = Int[]
    for i = 1:length(tabu_list)
        tabu_list[i].freq -= 1
        if tabu_list[i].freq < 1
            push!(rms, i)
        end
    end

    deleteat!(tabu_list, rms)
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
