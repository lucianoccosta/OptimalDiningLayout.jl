# Electronic companion of the paper: "Optimal layout of a dining room in the era
# of COVID-19 using integer programming" by
# - Claudio Contardo: ESG UQAM, Canada, claudio.contardo@gerad.ca
# - Luciano Costa: UFPE, Brazil, luciano.ccosta@ufpe.br

# This code was written in Julia 1.4.1

include("OptimalDiningLayout.jl")

if length(ARGS) < 1
    println("Usage: julia --project=. src/run_optimal_layout.jl [instance]")
    exit(0)
end

instance = ARGS[1]

function solve_instance(instance)

    OptimalDiningLayout.set_verbose(OptimalDiningLayout.params, true)

    OptimalDiningLayout.set_plot(OptimalDiningLayout.params, true)

    data = OptimalDiningLayout.load_instance(instance)
    OptimalDiningLayout.set_min_distance(data, 2.0)
    OptimalDiningLayout.set_back_to_back_allowed(data, true)

    OptimalDiningLayout.find_optimum_layout(data)
end

toy_instance = "instances/nowalls/5_5_nowalls.txt"

solve_instance(toy_instance)

solve_instance(instance)
