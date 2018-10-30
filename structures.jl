mutable struct Permutation
    w::Array{Real}
    f::Int32
end

mutable struct Bin
    x::Array{Int}   # items
    w::Array{Real}  # weight
    C::Real         # capacity
    rC::Real        # remaining capacity
end

struct BinPacking
    w::Array{Real}
    C::Real
end