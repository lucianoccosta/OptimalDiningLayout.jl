function generate_output(data::Data, graph::Graph, params::Parameters, results::Results, method::String)

    if params.verbose
        println("Number of persons to accomodate: $(results.objvalue)")
        println("Dual bound: $(results.dualobjvalue)")
        println("Time to build conflicting graph: $(results.cpugraph)")
        println("Elapsed time: $(results.cpu)")
    end
    filename = generate_filename(data, params, method)

    if params.plot
        plotter(filename, data, graph, results.solution)
    end

    create_file_results(filename, data, params, results, method)
end

function generate_filename(data::Data, params::Parameters, method::String)
    sep = "_"
    filename = data.instance_name * sep *
        data.instance_type * sep *
        string(data.min_social_distance) * sep *
        string(data.nrows) * sep *
        string(data.ncols) * sep *
        string(data.length_side_table) * sep *
        string(data.length_plexiglass) * sep *
        string(length(data.plexiglass)) * sep *
        data.position_walls

    if data.back_back_allowed
        filename = filename * sep * "backback"
    else
        filename = filename * sep * "nobackback"
    end

    filename = filename * sep * method
    filename = filename * sep * string(params.seed)
    filename = filename * sep * string(params.max_time)

    return filename
end

function create_file_results(filename::String, data::Data, params::Parameters, results::Results, method::String)
    sep = "\t"

    line = data.instance_name * sep *
        data.instance_type * sep *
        string(data.min_social_distance) * sep *
        string(data.nrows) * sep *
        string(data.ncols) * sep *
        string(data.length_side_table) * sep *
        string(data.length_plexiglass) * sep *
        string(length(data.plexiglass)) * sep *
        data.position_walls

    if data.back_back_allowed
        line = line * sep * "backback"
    else
        line = line * sep * "nobackback"
    end

    line = line * sep * method
    line = line * sep * string(params.seed)

    line = line * sep *
        string(results.objvalue) * sep *
        string(results.dualobjvalue) * sep *
        string(results.cpugraph) * sep *
        string(results.cpu)

    line = line * sep * string(params.max_time)

    resultfile = "results/" * filename
    f = open(resultfile, "w")
    write(f, line * "\n")
    close(f)
end