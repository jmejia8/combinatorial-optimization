mutable struct Permutation
    w::Array{Real}
    f::Int32
end

mutable struct Bin
    x::Array{Int}   # items
    w::Array{Real}  # whight
    C::Real         # capacity
    f::Int32        # obj. func. value
end

struct BinPacking
    w::Array{Real}
    C::Real
end