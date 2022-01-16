# Electronic companion of the paper: "Optimal layout of a dining room in the era
# of COVID-19 using integer programming" by
# - Claudio Contardo: ESG UQAM, Canada, claudio.contardo@gerad.ca
# - Luciano Costa: UFPE, Brazil, luciano.ccosta@ufpe.br

# This code was written in Julia 1.6.5 (LTS)

include("OptimalDiningLayout.jl")

function solve_instance(instance, method)

    OptimalDiningLayout.set_verbose(OptimalDiningLayout.params, true)

    OptimalDiningLayout.set_plot(OptimalDiningLayout.params, true)

    OptimalDiningLayout.set_seed(OptimalDiningLayout.params, 0)

    OptimalDiningLayout.set_max_time(OptimalDiningLayout.params, 86400)

    data = OptimalDiningLayout.load_instance(instance)

    OptimalDiningLayout.set_min_distance(data, 2.0)

    OptimalDiningLayout.set_back_to_back_allowed(data, true)

    OptimalDiningLayout.find_layout(data, method)
end

instance = "instances/nowalls/15_15_nowalls.txt"

method = "exact"
# method = "placeclosecorner"
# method = "placerandomly"

solve_instance(instance, method)

# source = "instances/nowalls"
# files = readdir(source)
# for f in files
#     instance = source * "/" * f
#     solve_instance(instance)
# end
