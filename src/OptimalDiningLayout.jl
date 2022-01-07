module OptimalDiningLayout
    using Plots: print
    include("typedefs.jl")
    include("loadinstance.jl")
    include("preprocessing.jl")
    include("formulation.jl")
    include("optimal_layout.jl")
    include("plotter.jl")
    include("util.jl")
end
