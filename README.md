# Combinatorial Optimization

Some algorithms for solving Combinatorial Optimization problems

## Optimizers

Some algorithms will be developed.

### Hill Climbing

Actually, Hill climbing is working for a permutation representation.

Example:

```julia
include("optimizers.jl")
include("problems.jl")

weight = [4, 8, 1, 4, 2, 1]
C = 10 # Bin Capacity 

# Solution: 2

fobj, initSol, getNeighbor, d, T = binpacking(C, weight)

w_ordered, C_approx = hillClimbing(fobj, initSol, getNeighbor; distance=2, max_iters=T)
```

Output: `[2, 8, 4, 1, 4, 1], 2`.


## Developing

Hill climbing for the bin packing problem.
