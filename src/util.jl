function generate_output(data::Data, graph::Graph, results::Results)

    println("Elapsed time: $(results.cpu)")

    if params.plot
        plotter(data, graph, results.solution)
    end

    create_file_results(data, results)
end

function create_file_results(data::Data, results::Results)
    line = data.instance_name * "\t" *
        data.instance_type * "\t" *
        string(data.min_social_distance) * "\t" *
        string(data.nrows) * "\t" *
        string(data.ncols) * "\t" *
        string(data.length_side_table) * "\t" *
        string(data.length_plexiglass) * "\t" *
        string(length(data.plexiglass)) * "\t" *
        data.position_walls * "\t" *
        string(results.objvalue) * "\t" *
        string(results.cpu)
    
    instancename = "results/" * data.instance_name
    f = open(instancename, "w")
    write(f, line * "\n")
    close(f)
end