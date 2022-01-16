using Plots

function plot_sitting_configuration(data::Data, configuration)

    x = []
    y = []

    for location in configuration.sitting_locations
        push!(x, location[1])
        push!(y, location[2])
    end

    plot(x,
        y,
        xticks = 0:(data.length_side_table/2):data.ncols,
        xrotation = 90,
        yticks = 0:(data.length_side_table/2):data.nrows,
        seriestype = :scatter,
        aspect_ratio=:equal,
        markersize = 15,
        primary=false, # remove labels
        title = "Layout $(configuration.id)"
    )

    plot!(rectangle(configuration.corners[1],
                    configuration.corners[2],
                    configuration.corners[3],
                    configuration.corners[4]),
        opacity=.5, primary=false)

    # format = ".pdf"
    format = ".png"
    savefig("plots/layout_table$(configuration.id)$format")
end

function plotter(filename::String, data::Data, graph::Graph, sol)

    x = []
    y = []

    for u in sol
        for location in graph.sittingconfigs[u].sitting_locations
            push!(x, location[1])
            push!(y, location[2])
        end
    end

    plot(x,
        y,
        # remove axis
        # xaxis=nothing,
        # yaxis=nothing,
        # xticks = 0:(data.length_side_table):data.ncols,
        xticks = 0:(data.length_side_table):data.ncols*data.length_side_table,
        # xrotation = 90,
        yticks = 0:(data.length_side_table):data.nrows*data.length_side_table,
        xaxis = :white,
        yaxis = :white,
        seriestype = :scatter,
        aspect_ratio=:equal,
        size = (400, 400), # Force the plot to have the same length on both sides
        crop = true,
        primary = false, # remove labels
        # title = data.instance_name,
        dpi=300,
        # markersize = 10 # toy0
        # markersize = 8 # toy1
        markersize = 5 # toy2
        )

    for u in sol
        #label coordinates
        x = graph.sittingconfigs[u].corners[1][1]
        y = graph.sittingconfigs[u].corners[1][2]
        plot!(rectangle(graph.sittingconfigs[u].corners[1],
                        graph.sittingconfigs[u].corners[2],
                        graph.sittingconfigs[u].corners[3],
                        graph.sittingconfigs[u].corners[4]),
                        # annotations = ([x], [y], u), # Add labels to the tables
            opacity=.5, primary=false, legend = false, dpi=720)
    end

    if length(data.plexiglass) > 0
        seg = data.plexiglass[1]
        plot!(color = :dimgrey, [seg.x1, seg.x2], [seg.y1, seg.y2], legend = false, dpi=720)

        for i in 2:length(data.plexiglass)
            seg = data.plexiglass[i]
            plot!(color = :dimgrey, [seg.x1, seg.x2], [seg.y1, seg.y2], legend = false, dpi=720)
        end
    end

    # if length(data.boundarywalls) > 0
    #     seg = data.boundarywalls[1]
    #     plot!(color = :dimgrey, [seg.x1, seg.x2], [seg.y1, seg.y2], legend = false, dpi=720)

    #     for i in 2:length(data.boundarywalls)
    #         seg = data.boundarywalls[i]
    #         plot!(color = :dimgrey, [seg.x1, seg.x2], [seg.y1, seg.y2], legend = false, dpi=720)
    #     end
    # end

    # format = ".pdf"
    format = ".png"
    savefig("plots/$filename$format")
end

function plot_current_solution_with_cliques(data::Data, graph::Graph, sol, cliques)

    println("Solution")
    println(sol)

    println("Cliques")
    for clique in cliques
        println(clique)
    end
    println("Nb cliques: ")
    println(length(cliques))
    readline()

    x = []
    y = []

    for u in sol
        for location in graph.sittingconfigs[u].sitting_locations
            push!(x, location[1])
            push!(y, location[2])
        end
    end

    plot(x,
        y,
        xticks = 0:(data.length_side_table):data.ncols*data.length_side_table,
        yticks = 0:(data.length_side_table):data.nrows*data.length_side_table,
        xaxis = :white,
        yaxis = :white,
        seriestype = :scatter,
        aspect_ratio=:equal,
        crop = true,
        primary = false, # remove labels
        title = "Layout",
        dpi=300,
        markersize = 5 # toy2
        )

    # Plotting sitting configuration
    for u in sol
        plot!(rectangle(graph.sittingconfigs[u].corners[1],
                        graph.sittingconfigs[u].corners[2],
                        graph.sittingconfigs[u].corners[3],
                        graph.sittingconfigs[u].corners[4]),
            opacity=.5, primary=false)
    end


    stop_after_print_node = false
    nb_cliques = 1
    for clique in cliques
        println(clique)

        chosencolor = :red
        if nb_cliques % 2 == 0
            chosencolor = :blue
        end

        for u in clique

            if stop_after_print_node && graph.sittingconfigs[u].type == "R"
                chosencolor = :blue
            end

            plot!(color = chosencolor,
                rectangle(graph.sittingconfigs[u].corners[1],
                    graph.sittingconfigs[u].corners[2],
                    graph.sittingconfigs[u].corners[3],
                    graph.sittingconfigs[u].corners[4]),
                    opacity=.5, primary=false)

            if stop_after_print_node
                show_sitting_config(graph.sittingconfigs[u])
                format1 = ".pdf"
                # format = ".png"
                savefig("plots/layout$format1")
                println("Press enter to continue...")
                readline()
            end

        end

        format = ".pdf"
        # format = ".png"
        savefig("plots/layout$format")

        println("Just plotted $nb_cliques clique\nPress enter to continue!")
        nb_cliques += 1
        readline()
    end
end

function plot_current_solution_with_cliques(data::Data, graph::Graph, sol, cliques, weight)

    println("Solution")
    println(sol)

    println("Cliques")
    for clique in cliques
        println(clique)
    end
    println("Nb cliques: ")
    println(length(cliques))
    readline()

    x = []
    y = []

    for u in sol
        for location in graph.sittingconfigs[u].sitting_locations
            push!(x, location[1])
            push!(y, location[2])
        end
    end

    plot(x,
        y,
        xticks = 0:(data.length_side_table):data.ncols,
        yticks = 0:(data.length_side_table):data.nrows,
        xaxis = :white,
        yaxis = :white,
        seriestype = :scatter,
        aspect_ratio=:equal,
        crop = true,
        primary = false, # remove labels
        title = "Layout",
        dpi=300,
        markersize = 5 # toy2
        )

    # Plotting sitting configuration
    for u in sol
        plot!(rectangle(graph.sittingconfigs[u].corners[1],
                        graph.sittingconfigs[u].corners[2],
                        graph.sittingconfigs[u].corners[3],
                        graph.sittingconfigs[u].corners[4]),
            opacity=.5, primary=false)
    end


    stop_after_print_node = false
    nb_cliques = 1
    for clique in cliques
        clique_v = [u for u in clique if weight[u] > 0]
        println("Cardinality: ", length(clique), " Clique: ", clique)
        println("Cardinality: ", length(clique), " Augmented clique: ", clique)

        chosencolor = :red
        if nb_cliques % 2 == 0
            chosencolor = :blue
        end

        for u in clique

            if stop_after_print_node && graph.sittingconfigs[u].type == "R"
                chosencolor = :blue
            end

            plot!(color = chosencolor,
                rectangle(graph.sittingconfigs[u].corners[1],
                    graph.sittingconfigs[u].corners[2],
                    graph.sittingconfigs[u].corners[3],
                    graph.sittingconfigs[u].corners[4]),
                    opacity=.5, primary=false)

            if stop_after_print_node
                show_sitting_config(graph.sittingconfigs[u])
                format1 = ".pdf"
                # format = ".png"
                savefig("plots/layout$format1")
                println("Press enter to continue...")
                readline()
            end

        end

        format = ".pdf"
        # format = ".png"
        savefig("plots/layout$format")

        println("Just plotted $nb_cliques clique\nPress enter to continue!")
        nb_cliques += 1
        readline()
    end
end

function rectangle(bl, br, tr, tl)
    #bl: bottom left
    #br: bottom left
    #tr: bottom left
    #tl: bottom left

    Shape([bl[1], br[1], tr[1], tl[1]], [bl[2], br[2], tr[2], tl[2]])
end


