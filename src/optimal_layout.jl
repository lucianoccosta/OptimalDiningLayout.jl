params = Parameters(
    86400,      # time limit
    false,      #verbose
    true       # plot
)

function find_optimum_layout(data::Data)

    init_time = time_ns()

    graph, auxdata = create_conflicting_graph(data)

    results = Results(0, 0, [])

    results.objvalue, results.solution = solve_optimum_layout(data, auxdata, graph)

    results.cpu = round(Int64, (time_ns() - init_time) * 1e-8) * 1e-1

    generate_output(data, graph, results)
end