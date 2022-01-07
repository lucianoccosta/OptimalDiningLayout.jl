# Electronic companion of the paper: "Optimal layout of a dining room in the era
# of COVID-19 using integer programming" by
# - Claudio Contardo: ESG UQAM, Canada, claudio.contardo@gerad.ca
# - Luciano Costa: UFPE, Brazil, luciano.ccosta@ufpe.br

# This code was written in Julia 1.4.1

include("OptimalDiningLayout.jl")

function solve_instance(instance)

    OptimalDiningLayout.set_verbose(OptimalDiningLayout.params, true)

    OptimalDiningLayout.set_plot(OptimalDiningLayout.params, true)

    data = OptimalDiningLayout.load_instance(instance)
    OptimalDiningLayout.set_min_distance(data, 2.0)
    OptimalDiningLayout.set_back_to_back_allowed(data, true)

    OptimalDiningLayout.find_optimum_layout(data)
end

instance = "instances/nowalls/5_5_nowalls.txt"
solve_instance(instance)

# source = "instances/nowalls"
# files = readdir(source)
# for f in files
#     instance = source * "/" * f
#     solve_instance(instance)
# end
