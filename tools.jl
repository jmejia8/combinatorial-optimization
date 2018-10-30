import Statistics.std, Statistics.mean
import Printf.@printf

function printbin(b::Bin)
    println("x: ", b.x)
    println("w: ", b.w)
    println("C = $(b.C) \t rC = $(b.rC)")
end

function printbin(bins::Array{Bin})
    i = 1
    for bin ∈ bins
        println("================= Bin $i =================")
        printbin(bin)
        # println("===========================================")
        i += 1
    end
end

function summary_(bins::Array{Bin})
    Cs = [ bin.rC for bin ∈ bins]
    @printf("|B| = %d \t mean(w) = %.3f \t std(w) = %.3f\n", length(bins), mean(Cs), std(Cs))
end