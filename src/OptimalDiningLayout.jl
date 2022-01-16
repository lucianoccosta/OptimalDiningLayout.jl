module OptimalDiningLayout
    using Plots: print
    include("typedefs.jl")
    include("loadinstance.jl")
    include("preprocessing.jl")
    include("formulation_based_method.jl")
    include("heuristic.jl")
    include("layout.jl")
    include("plotter.jl")
    include("util.jl")
end
