# Electronic companion of the paper: "Optimal layout of a dining room in the era
# of COVID-19 using integer programming" by
# - Claudio Contardo: ESG UQAM, Canada, claudio.contardo@gerad.ca
# - Luciano Costa: UFPE, Brazil, luciano.ccosta@ufpe.br

# This code was written in Julia 1.6.5 (LTS)

include("OptimalDiningLayout.jl")
include("argparse.jl")

function solve_instance(instance, parsed_args)

    if parsed_args["verbose"]
        println("parsed_args: ", parsed_args)
    end

    OptimalDiningLayout.set_verbose(OptimalDiningLayout.params, parsed_args["verbose"])

    OptimalDiningLayout.set_plot(OptimalDiningLayout.params, parsed_args["plot"])

    OptimalDiningLayout.set_seed(OptimalDiningLayout.params, parsed_args["seed"])

    OptimalDiningLayout.set_max_time(OptimalDiningLayout.params, parsed_args["tl"])

    data = OptimalDiningLayout.load_instance(instance)

    OptimalDiningLayout.set_min_distance(data, parsed_args["mindist"])

    OptimalDiningLayout.set_back_to_back_allowed(data, parsed_args["backback"])

    OptimalDiningLayout.find_layout(data, parsed_args["method"])
end

parsed_args = parse_commandline()

toy_instance = "instances/nowalls/5_5_nowalls.txt"

solve_instance(toy_instance, parsed_args)

instance = parsed_args["instance"]

solve_instance(instance, parsed_args)
