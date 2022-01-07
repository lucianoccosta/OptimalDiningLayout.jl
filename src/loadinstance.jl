function load_instance(filename)

    data = Data(
        "",                 # instance_name
        "",                 # instance_type
        0.0,                # length_side_table,
        0.0,                # length of walls,
        "",                 # position of walls: vertical, horizontal, vertical
        0,                  # nrows
        0,                  # ncols
        zeros(Int64, 0, 0), # grid
        0,                  # nnonemptysquares
        0,                  # min_social_distance
        true,               # back_back_allowed
        [],                 # plexiglass
        []                  # boundarywalls
    )

    open(filename) do f

        lines = readlines(f)
        
        loadinstancetype = false
        loadedlength = false
        loadedlengthwalls = false
        loadedpositionwalls = false
        loadednrows = false
        loadedncols = false
        loadedgrid = false
        loadplexiglass = false
        loadboundary = false
        row = 1

        for line in lines
            sline = split(line)

            if !loadinstancetype
                data.instance_type = sline[1]
                loadinstancetype = true
                continue
            end

            if !loadedlength
                data.length_side_table = parse(Float64, sline[1])
                loadedlength = true
                continue
            end

            if !loadedlengthwalls
                data.length_plexiglass = parse(Float64, sline[1])
                loadedlengthwalls = true
                continue
            end

            if !loadedpositionwalls
                data.position_walls = sline[1]
                loadedpositionwalls = true
                continue
            end

            if !loadednrows
                data.nrows = parse(Int64, sline[1])
                loadednrows = true
                continue
            end

            if !loadedncols
                data.ncols = parse(Int64, sline[1]) 
                loadedncols = true
                continue
            end

            if !loadedgrid && loadednrows && loadedncols && !loadplexiglass
                data.grid = zeros(Int64, data.nrows, data.ncols)
                loadedgrid = true
            end

            if loadedgrid
                for col in 1:data.ncols
                    data.grid[row, col] = parse(Int64, sline[col])

                    if data.grid[row, col] == 1
                        data.nnonemptysquares += 1
                    end
                end
            end
            
            if row == data.nrows && !loadplexiglass
                loadedgrid = false
                loadplexiglass = true
                continue
                # break
            end

            if loadplexiglass && sline[1] == "plexiglasswalls"
                continue
            end

            if loadplexiglass && sline[1] == "endplex"
                loadboundary = true
                continue
            end

            if loadplexiglass && !loadboundary
                segment = Segment(parse(Float64, sline[1]),
                    parse(Float64, sline[2]),
                    parse(Float64, sline[3]),
                    parse(Float64, sline[4]))

                push!(data.plexiglass, segment)
            end

            if loadboundary && sline[1] == "boundarywalls"
                continue
            end

            if loadboundary && sline[1] == "endbound"
                break
            end

            if loadboundary
                segment = Segment(parse(Float64, sline[1]),
                parse(Float64, sline[2]),
                parse(Float64, sline[3]),
                parse(Float64, sline[4]))

                push!(data.boundarywalls, segment)
            end
            row += 1
        end
    end

    sname = split(filename, "/")[end]
    data.instance_name = split(sname, ".")[1]
    println("\nInstance file $(data.instance_name) parsed successfully")

    return data
end
