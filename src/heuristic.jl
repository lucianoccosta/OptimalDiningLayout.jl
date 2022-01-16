using Distances
using Random

function run_place_tables_close_corners(data::Data, auxdata::AuxData, graph::Graph)

    candidates = []
    load_candidates(graph, candidates)

    selected = falses(length(candidates))
    sort!(candidates, by = x -> (-x[3], x[2], x[1]))

    objvalue = 0
    sol = []
    u = candidates[1][1]
    selected[u] = true
    push!(sol, u)
    objvalue += candidates[1][3]

    while true

        toadd = select_to_add(auxdata, candidates, selected, sol)

        # If the element got here being equal to -1, break. There is no
        # element to be added to the solution
        if toadd == -1
            break
        end

        u = candidates[toadd][1]
        selected[u] = true
        push!(sol, u)
        objvalue += candidates[toadd][3]
    end

    return objvalue, objvalue, sol
end

function load_candidates(graph::Graph, candidates, origin = (0,0))
    origin = (0, 0)
    for table in graph.sittingconfigs
        # show_sitting_config(table)

        xm = (table.corners[2][1] + table.corners[1][1])/2
        ym = (table.corners[4][2] + table.corners[1][2])/2

        dist = euclidean(origin, (xm, ym))

        push!(candidates, (table.id, dist, table.npersons))
    end
end

function select_to_add(auxdata::AuxData, candidates, selected, sol)

    toadd = -1 # Position in candidates of the chosen element
    for i in 1:length(candidates)

        u = candidates[i][1]

        # if already selected, go to next
        if selected[u]
            continue
        end

        toadd = i
        for v in sol
            # if the candidate is in conflict with at least one element in
            # the solution, break and go to the next candidate

            e1 = u
            e2 = v
            if v < u
                e1 = v
                e2 = u
            end

            if auxdata.edge_exist[e1, e2]
                toadd = -1
                break
            end
        end

        # if toadd = -1, it means it is in conflict with some graph in
        # the solution: go to next. Otherwise, break. Element is elegible
        # to be added
        if toadd == -1
            continue
        else
            return toadd
        end
    end

    return toadd
end

function run_place_tables_randomly(data::Data, auxdata::AuxData, graph::Graph)

    Random.seed!(params.seed)

    candidates = []
    load_candidates(graph, candidates)

    selected = falses(length(candidates))
    shuffle!(candidates)

    objvalue = 0
    sol = []
    u = candidates[1][1]
    selected[u] = true
    push!(sol, u)
    objvalue += candidates[1][3]

    while true

        toadd = select_to_add(auxdata, candidates, selected, sol)

        # If the element got here being equal to -1, break. There is no
        # element to be added to the solution
        if toadd == -1
            break
        end

        u = candidates[toadd][1]
        selected[u] = true
        push!(sol, u)
        objvalue += candidates[toadd][3]
    end

    return objvalue, objvalue, sol
end
