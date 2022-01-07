using LazySets

function create_conflicting_graph(data::Data)

    auxdata = AuxData(
        Matrix{Any}(nothing, 0, 0),
        falses(0, 0),           # edge_exist
        [],                     # conflict_with_seat
        Matrix{Any}(nothing, 0, 0), # cliques_in_neighborhood
        Matrix{Any}(nothing, 0, 0), # conflict_in_neighborhood
        Set()
    )

    graph = Graph(
        0,                  # nconfigurations
        [],                 # sittingconfigs
        []                  # edges
    )

    load_sitting_configurations(data, auxdata, graph)

    build_graph_incompatible_sitting_configutions(data, auxdata, graph)

    return graph, auxdata
end

function load_sitting_configurations(data::Data, auxdata::AuxData, graph::Graph)

    auxdata.tables_in_block = Matrix{Any}(nothing, data.nrows, data.ncols)
    for i in 1:data.nrows
        for j in 1:data.ncols
            auxdata.tables_in_block[i,j] = []
        end
    end

    graph.nconfigurations = 0

    load_square_table(data, auxdata, graph)

    load_rectangular_horizontal_table(data, auxdata, graph)

    load_rectangular_vertical_table(data, auxdata, graph)

    println("$(graph.nconfigurations) sitting configurations loaded!")
end

function load_square_table(data::Data, auxdata::AuxData, graph::Graph)
    for i in 1:data.nrows
        for j in 1:data.ncols
            if data.grid[i,j] == 1
                type = "S"
                blocks = [(i,j)]
                for sitting_axis in ["vertical", "horizontal"]
                    npersons = 2
                    corners = get_corners(data, type, blocks, sitting_axis)

                    create_sitting_configuration(data, auxdata, graph, type,
                        blocks, npersons, sitting_axis, corners)
                end
            end
        end
    end
end

function load_rectangular_horizontal_table(data::Data, auxdata::AuxData, graph::Graph)
    for i in 1:data.nrows
        for j in 1:data.ncols - 1
            if data.grid[i,j] == 1 && data.grid[i,j+1] == 1
                type = "R"
                blocks = [(i,j), (i,j+1)]
                npersons = 4
                sitting_axis = "vertical"
                corners = get_corners(data, type, blocks, sitting_axis)
                create_sitting_configuration(data, auxdata, graph, type,
                    blocks, npersons, sitting_axis, corners)
            end
        end
    end
end

function load_rectangular_vertical_table(data::Data, auxdata::AuxData, graph::Graph)
    for i in 1:data.nrows - 1
        for j in 1:data.ncols
            if data.grid[i, j] == 1 && data.grid[i+1, j] == 1
                type = "R"
                blocks = [(i,j), (i+1,j)]
                npersons = 4
                sitting_axis = "horizontal"
                corners = get_corners(data, type, blocks, sitting_axis)
                create_sitting_configuration(data, auxdata, graph, type,
                    blocks, npersons, sitting_axis, corners)
            end
        end
    end
end

function create_sitting_configuration(data::Data, auxdata::AuxData, graph::Graph,
    type, blocks, npersons, sitting_axis, corners)

    graph.nconfigurations += 1

    if table_intersects_wall(data, corners)
        graph.nconfigurations -= 1
        return false
    end

    sitting_locations = get_coord_sitting_locations(data, type, blocks, sitting_axis)

    seating_sense = get_seating_sense(type, sitting_axis)
 
    if table_intersects_wall_in_sitting_axis(data, corners, sitting_locations)
        graph.nconfigurations -= 1
        return false
    end

    config = SittingConfig(graph.nconfigurations,
                            type,
                            sitting_axis,
                            blocks,
                            npersons,
                            sitting_locations,
                            seating_sense,
                            corners)
    push!(graph.sittingconfigs, config)

    # In which blocks the sitting config is placed.
    for block in blocks
        push!(auxdata.tables_in_block[block[1],block[2]], graph.nconfigurations)
    end

    return true
end

function get_coord_sitting_locations(data::Data, type, blocks, sitting_axis)

    coords = []

    if type == "S"

        (i,j) = blocks[1]

        if sitting_axis == "vertical"

            x = ((j-1) * data.length_side_table) + (data.length_side_table / 2)
            y = (i-1) * data.length_side_table
            push!(coords, (x,y))

            x = ((j-1) * data.length_side_table) + (data.length_side_table / 2)
            y = i * data.length_side_table
            push!(coords, (x,y))

        elseif sitting_axis == "horizontal"

            x = (j-1) * data.length_side_table
            y = ((i-1) * data.length_side_table)  + (data.length_side_table / 2)
            push!(coords, (x,y))

            x = j * data.length_side_table
            y = ((i-1) * data.length_side_table) + (data.length_side_table / 2)
            push!(coords, (x,y))
        end

    elseif type == "R"

        if sitting_axis == "vertical"

            for (i,j) in blocks
                x = ((j-1) * data.length_side_table) + (data.length_side_table / 2)
                y = (i-1) * data.length_side_table
                push!(coords, (x,y))

                x = ((j-1) * data.length_side_table) + (data.length_side_table / 2)
                y = i * data.length_side_table
                push!(coords, (x,y))
            end

        elseif sitting_axis == "horizontal"

            for (i,j) in blocks
                x = (j-1) * data.length_side_table
                y = ((i-1) * data.length_side_table) + (data.length_side_table / 2)
                push!(coords, (x,y))

                x = j * data.length_side_table
                y = ((i-1) * data.length_side_table) + (data.length_side_table / 2)
                push!(coords, (x,y))
            end

        end

    end

    return coords
end

function get_seating_sense(type, sitting_axis)
    
    senses = []

    if type == "S"

        if sitting_axis == "vertical"
            senses = [90, 270]
        elseif sitting_axis == "horizontal"
            senses = [0, 180]
        end

    elseif type == "R"

        if sitting_axis == "vertical"
            senses = [90, 270, 90, 270]
        elseif sitting_axis == "horizontal"
            senses = [0, 180, 0, 180]
        end

    end

    return senses

end

function get_corners(data::Data, type, blocks, sitting_axis)

    if type == "S"
        (i,j) = blocks[1]

        lb = ((j-1) * data.length_side_table, (i-1) * data.length_side_table)
        rb = (j * data.length_side_table, (i-1) * data.length_side_table)
        rt = (j * data.length_side_table, i * data.length_side_table)
        lt = ((j-1) * data.length_side_table, i * data.length_side_table)

        corners = [lb, rb, rt, lt]
        return corners
    end

    if type == "R" && sitting_axis == "vertical"
        (i1,j1) = blocks[1]
        (i2,j2) = blocks[2]

        lb = ((j1-1) * data.length_side_table, (i1-1) * data.length_side_table)
        rb = (j2 * data.length_side_table, (i2-1) * data.length_side_table)
        rt = (j2 * data.length_side_table, i2 * data.length_side_table)
        lt = ((j1-1) * data.length_side_table, i1 * data.length_side_table)

        corners = [lb, rb, rt, lt]
        return corners
    end

    if type == "R" && sitting_axis == "horizontal"
        (i1,j1) = blocks[1]
        (i2,j2) = blocks[2]

        lb = ((j1-1) * data.length_side_table, (i1-1) * data.length_side_table)
        rb = (j1 * data.length_side_table, (i1-1) * data.length_side_table)
        rt = (j2 * data.length_side_table, i2 * data.length_side_table)
        lt = ((j2-1) * data.length_side_table, i2 * data.length_side_table)

        corners = [lb, rb, rt, lt]
        return corners
    end

    return []
end

function build_graph_incompatible_sitting_configutions(data::Data,
    auxdata::AuxData, graph::Graph)

    auxdata.edge_exist = falses(graph.nconfigurations, graph.nconfigurations)

    auxdata.conflict_with_seat = Array{Any}(nothing, graph.nconfigurations)
    for i in 1:graph.nconfigurations
        auxdata.conflict_with_seat[i] = []
    end

    same_block(data, auxdata, graph)

    distancing_restriction(data, auxdata, graph)

    println("$(length(graph.edges)[1]) incompatible pairs!")
end

function same_block(data::Data, auxdata::AuxData, graph::Graph)

    for i in 1:data.nrows
        for j in 1:data.ncols

            # check if there is at least one sitting pattern in the block
            if isempty(auxdata.tables_in_block[i,j])
                continue
            end

            for u in auxdata.tables_in_block[i,j]
                for v in auxdata.tables_in_block[i,j]

                    if u == v
                        continue
                    end

                    e1 = u
                    e2 = v

                    if v < u
                        e1 = v
                        e2 = u
                    end

                    # Checking if edge already in the graph
                    if auxdata.edge_exist[e1, e2]
                        continue
                    end

                    push!(graph.edges, (e1, e2))
                    auxdata.edge_exist[e1, e2] = true

                    # Collecting setting in conflicts among them
                    push!(auxdata.conflict_with_seat[e1], e2)
                    push!(auxdata.conflict_with_seat[e2], e1)
                end
            end
        end
    end

end

function distancing_restriction(data::Data, auxdata::AuxData, graph::Graph)

    for i in 1:data.nrows
        for j in 1:data.ncols

            # Getting indexes of blocks which are within the neighborhood of
            # block (i,j)
            neigh_blocks = get_blocks_in_neighborhood(data, i,j)

            for (k,l) in neigh_blocks

                for u in auxdata.tables_in_block[i,j]
                    for v in auxdata.tables_in_block[k,l]

                        if u == v
                            continue
                        end

                        e1 = u
                        e2 = v

                        if v < u
                            e1 = v
                            e2 = u
                        end

                        # Checking if edge already in the graph
                        if auxdata.edge_exist[e1, e2]
                            continue
                        end

                        if !respect_social_distancing(data,
                            graph.sittingconfigs[e1],
                            graph.sittingconfigs[e2])

                            if data.back_back_allowed
                                if back_to_back(data,
                                    graph.sittingconfigs[e1],
                                    graph.sittingconfigs[e2])
                                    continue
                                end
                            end

                            if data.instance_type != "R"
                                if separated_by_corner(data,
                                    graph.sittingconfigs[e1],
                                    graph.sittingconfigs[e2])
                                    continue
                                end
                            end

                            if separated_by_plexiglass(data,
                                graph.sittingconfigs[e1],
                                graph.sittingconfigs[e2])
                                continue
                            end

                            auxdata.edge_exist[e1, e2] = true

                            push!(graph.edges, (e1,e2))

                            # Collecting setting in conflicts among them
                            push!(auxdata.conflict_with_seat[e1], e2)
                            push!(auxdata.conflict_with_seat[e2], e1)
                        end
                    end
                end
            end
        end
    end

end

function get_blocks_in_neighborhood(data::Data, x,y, size_neighborhood = 4)

    #size_neighborhood = 4
    #Blocks farther than this should already respect social distancing

    neighbors = []
    for i in max(1,x-size_neighborhood):min(data.ncols,x+size_neighborhood)
        for j in max(1,y-size_neighborhood):min(data.nrows,y+size_neighborhood)
            if x == i && y == j
                continue
            end
            push!(neighbors, (i,j))
        end
    end

    return neighbors
end

function respect_social_distancing(data::Data, config1, config2)
    for p1 in config1.sitting_locations
        for p2 in config2.sitting_locations
            if euclidean_distance(p1, p2) < data.min_social_distance
                return false
            end
        end
    end
    return true
end

function euclidean_distance(p1, p2)
    return sqrt((p1[1] - p2[1])^2 + (p1[2] - p2[2])^2)
end

function get_conflict_with_all_seats_in_block(auxdata::AuxData, i,j)

    potential_conflict = Set()
    for u in auxdata.tables_in_block[i,j]
        union!(potential_conflict, u)
        for v in auxdata.conflict_with_seat[u] # all nodes in conflict with u
            union!(potential_conflict, v)
        end
    end

    return [u for u in potential_conflict]
end

function collect_sitting_patterns_within_neighborhood(data::Data, auxdata::AuxData, i,j)

    all_sitting = Set()

    sitting = auxdata.tables_in_block[i,j]
    for u in sitting
        union!(all_sitting, u)
    end

    blocks = get_blocks_in_neighborhood(data, i,j)
    for (k,l) in blocks
        sitting = auxdata.tables_in_block[k,l]
        for u in sitting
            union!(all_sitting, u)
        end
    end

    candidates = collect(all_sitting)
    sort!(candidates)

    return candidates
end

function table_intersects_wall(data::Data, corners)

    c1, c2, c3, c4 = corners

    side1 = LineSegment([c1[1], c1[2]], [c2[1], c2[2]])
    side2 = LineSegment([c2[1], c2[2]], [c3[1], c3[2]])
    side3 = LineSegment([c3[1], c3[2]], [c4[1], c4[2]])
    side4 = LineSegment([c1[1], c1[2]], [c4[1], c4[2]])

    for wall in data.plexiglass

        wallside = LineSegment([wall.x1, wall.y1], [wall.x2, wall.y2])

        res1 = is_intersection_empty(side1, wallside, true)
        if !res1[1]
            return true
        end

        res2 = is_intersection_empty(side2, wallside, true)
        if !res2[1]
            return true
        end

        res3 = is_intersection_empty(side3, wallside, true)
        if !res3[1]
            return true
        end

        res4 = is_intersection_empty(side4, wallside, true)
        if !res4[1]
            return true
        end

    end

    return false
end

function table_intersects_wall_in_sitting_axis(data::Data, corners, sitting_locations)

    c1, c2, c3, c4 = corners

    side1 = LineSegment([c1[1], c1[2]], [c2[1], c2[2]])
    side2 = LineSegment([c2[1], c2[2]], [c3[1], c3[2]])
    side3 = LineSegment([c3[1], c3[2]], [c4[1], c4[2]])
    side4 = LineSegment([c1[1], c1[2]], [c4[1], c4[2]])

    for wall in data.plexiglass

        wallside = LineSegment([wall.x1, wall.y1], [wall.x2, wall.y2])

        if parallel_segment_intersects(side1, wallside) &&
            at_least_one_person_sitting_along_table_side(side1, sitting_locations)
            return true
        end

        if parallel_segment_intersects(side2, wallside) &&
            at_least_one_person_sitting_along_table_side(side2, sitting_locations)
            return true
        end

        if parallel_segment_intersects(side3, wallside) &&
            at_least_one_person_sitting_along_table_side(side3, sitting_locations)
            return true
        end

        if parallel_segment_intersects(side4, wallside) &&
            at_least_one_person_sitting_along_table_side(side4, sitting_locations)
            return true
        end
    end

    return false
end

function parallel_segment_intersects(a::LineSegment, b::LineSegment)

    # verify if the two endpoints of a segments belong to the other segment.
    # We do this for both segments. if two parallel segments intersect, there
    # will be at two end points belonging to a segment.

    nbmemberships = 0

    if a.p in b
        nbmemberships += 1
    end

    if a.q in b
        nbmemberships += 1
    end

    if b.p in a
        nbmemberships += 1
    end

    if b.q in a
        nbmemberships += 1
    end

    return nbmemberships > 1
end

function at_least_one_person_sitting_along_table_side(side::LineSegment, sitting_locations)

    for table in sitting_locations
        if collect(table) in side
            return true
        end
    end

    return false
end


function back_to_back(data::Data, config1, config2)
    
    for i in 1:length(config1.sitting_locations)
        for j in 1:length(config2.sitting_locations)

            l1 = config1.sitting_locations[i]
            l2 = config2.sitting_locations[j]

            dist = euclidean_distance(l1, l2)
            if dist < data.min_social_distance

                a1 = config1.seating_sense[i]
                a2 = config2.seating_sense[j]

                if abs(a1 - a2) != 180
                    return false
                end
            end
        end  
    end
    return true
end

function separated_by_corner(data::Data, config1, config2)

    if length(data.boundarywalls) == 0
        return false
    end

    close_positions = []
    for p1 in config1.sitting_locations
        for p2 in config2.sitting_locations
            dist = euclidean_distance(p1, p2)
            if dist < data.min_social_distance
                push!(close_positions, [p1, p2])
            end
        end
    end

    for pos in close_positions

        hasatleastonebarrier = false

        p1 = pos[1]
        p2 = pos[2]
        connect = LineSegment([p1[1], p1[2]], [p2[1], p2[2]])
        # connect = LineSegment(Point2f0(p1[1], p1[2]), Point2f0(p2[1], p2[2]))
        for wall in data.boundarywalls

            wallside = LineSegment([wall.x1, wall.y1], [wall.x2, wall.y2])
            # wallside = LineSegment(Point2f0(wall.x1, wall.y1), Point2f0(wall.x2, wall.y2))
            # Since all positions in close_positions are located less than 2m
            # from each other, if there is at least a pair position for which
            # there is no wall between them, we forbid it.

            res = is_intersection_empty(wallside, connect, true)

            if !res[1]
                hasatleastonebarrier = true
            end
        end

        if !hasatleastonebarrier
            return false
        end
    end

    return true
end

function separated_by_plexiglass(data::Data, config1, config2)

    if length(data.plexiglass) == 0
        return false
    end

    close_positions = []
    for p1 in config1.sitting_locations
        for p2 in config2.sitting_locations
            dist = euclidean_distance(p1, p2)
            if dist < data.min_social_distance
                push!(close_positions, [p1, p2])
            end
        end
    end

    for pos in close_positions

        hasatleastonebarrier = false

        p1 = pos[1]
        p2 = pos[2]
        connect = LineSegment([p1[1], p1[2]], [p2[1], p2[2]])
        # connect = LineSegment(Point2f0(p1[1], p1[2]), Point2f0(p2[1], p2[2]))
        for wall in data.plexiglass

            wallside = LineSegment([wall.x1, wall.y1], [wall.x2, wall.y2])
            # wallside = LineSegment(Point2f0(wall.x1, wall.y1), Point2f0(wall.x2, wall.y2))
            # Since all positions in close_positions are located less than 2m
            # from each other, if there is at least a pair position for which
            # there is no wall between them, we forbid it.

            res = is_intersection_empty(wallside, connect, true)

            if !res[1]
                hasatleastonebarrier = true
            end

            # if !intersects(wallside, connect)[1]
            #     return false
            # end
        end

        if !hasatleastonebarrier
            return false
        end
    end

    return true
end