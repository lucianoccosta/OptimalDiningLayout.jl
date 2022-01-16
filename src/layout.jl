params = Parameters(
    0,          # seed
    86400,      # time limit
    false,      # verbose
    false        # plot
)

function find_layout(data::Data, method::String)
    init_time = time_ns()

    graph, auxdata = create_conflicting_graph(data)

    results = Results(0.0, 0.0, 0.0, 0.0, [])

    results.cpugraph = round(Int64, (time_ns() - init_time) * 1e-8) * 1e-1

    if method == "exact"
        if params.verbose
            println("$method method being executed...")
        end
        results.objvalue, results.dualobjvalue, results.solution = solve_optimum_layout(data, auxdata, graph)
    elseif method == "placeclosecorner"
        if params.verbose
            println("$method method being executed...")
        end
        results.objvalue, results.dualobjvalue, results.solution = run_place_tables_close_corners(data, auxdata, graph)
    elseif method == "placerandomly"
        if params.verbose
            println("$method method being executed...")
        end

        results.objvalue, results.dualobjvalue, results.solution = run_place_tables_randomly(data, auxdata, graph)
    end

    results.cpu = round(Int64, (time_ns() - init_time) * 1e-8) * 1e-1

    generate_output(data, graph, params, results, method)
end