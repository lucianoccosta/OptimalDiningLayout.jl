using Base: Float64

mutable struct Data
    instance_name::String       # instance name
    instance_type::String
    length_side_table::Float64  # length of side of one entry in the grid#
    length_plexiglass::Float64  # length of plexiglass
    position_walls::String      # position walls
    nrows::Int64                # nb of rows in the grid
    ncols::Int64                # nb of columns in the grid
    grid                        # binary matrix with 1's and 0's to represent grid
    nnonemptysquares::Int64
    min_social_distance::Float64
    back_back_allowed::Bool
    plexiglass
    boundarywalls
end

function set_min_distance(data::Data, min_distance::Float64)
    data.min_social_distance = min_distance
end

function set_back_to_back_allowed(data::Data, flag::Bool)
    data.back_back_allowed = flag
end

function show_instance_info(data::Data)
    println("Instance name: ", data.instance_name)
    println("Instance type: ", data.instance_type)
    println("Length side table: ", data.length_side_table)
    println("Length walls: ", data.length_walls)
    println("Position walls: ", data.position_walls)
    println("Nb rows: ", data.nrows)
    println("Nb cols: ", data.nrows)
    println("Nb non-empty squares: ", data.nnonemptysquares)
    println("Nb of plexiglass walls: ", length(data.plexiglass))
    println("Nb of boundary walls: ", length(data.boundarywalls))
end

mutable struct Segment
    x1::Float64
    y1::Float64
    x2::Float64
    y2::Float64
end

function show_segment(segment::Segment)
    println("A: (", segment.x1, ", ", segment.y1, ")")
    println("B: (", segment.x2, ", ", segment.y2, ")")
end

mutable struct SittingConfig
    id::Int64
    type::String        # S (square), R (retangle)
    sitting_axis        # vertical: (axis N - S), horizontal (axis W - E)
    occupiedblocks      # which blocks in the grid the configuration occupies
    npersons::Int64     # nb of persons seated
    sitting_locations   # coordinates of where persons seats in the grid
    seating_sense       # Sense of people seating
    corners             # coordinates of table corners in the grid
end

function show_sitting_config(config::SittingConfig)
    println("=========================")
    println("Id: $(config.id)
    Nb persons: $(config.npersons)
    Type: $(config.type)
    Sitting Axis: $(config.sitting_axis)")

    print("Occupied squares: ")
    for square in config.occupiedblocks
        print(square)
    end
    print("\nSitting locations: ")
    for location in config.sitting_locations
        print(location)
    end
    print("\nSeating sense: ")
    for sense in config.seating_sense
        print(sense, " ")
    end
    print("\nCorners: ")
    for corner in config.corners
        print(corner)
    end
    println()
end

mutable struct AuxData
    tables_in_block             # - Matrix (m x n), where m and n are the number
    # of rows and columns, respectively, in the grid. Each position (i,j) of
    # this structure contains the sitting configurations which use the position.
    # A sitting configuration can appear in more than one position (i,j).
    edge_exist                 # - Boolean matrix (l x l), where l is the total
    # number of sitting configuration to indicate which sitting configurations
    # are in conflict with each other due to social distancing. This matrix
    # represents undirected graph, hence, only positions (u,v), with u < v
    # filled in the matrix.
    conflict_with_seat          # - Array with length (l) where each position
    # contains a list of all sitting configurations in conflict with the
    # configurations associated with the corresponding position.
    cliques_in_neighborhood     # - Matrix (m x n), where m and n are the number
    # of rows and columns, respectively, in the grid. Each position stores all
    # cliques within a neighborhood that are associated with sitting configurations
    # in a block (i,j)
    conflict_in_neighborhood    # - Matrix (m x n), where m and n are the number
    # of rows and columns, respectively, in the grid. Each position (i,j) of
    # this structure stores the sitting configurations associated with the
    # blocks in the neighborhood of (i,j) which are in conflict  with at least
    # one sitting configuration located in position (i,j).
    pool_lazy_constraints
end

mutable struct Graph
    nconfigurations::Int64      # total number of configurations enumerated
    sittingconfigs              # array with structs representing sitting configs
    edges                       # arry of edges in conflict graph. extremities are sittingconfigs ids
end

mutable struct Parameters
    max_time::Int
    verbose::Bool
    plot::Bool
end

function set_maximum_time(params::Parameters, max_time::Int)
    params.max_time = max_time
end

function set_verbose(params::Parameters, flag)
    params.verbose = flag
end

function set_plot(params::Parameters, flag)
    params.plot = flag
end

mutable struct Results
    cpu::Float64
    objvalue::Float64
    solution
end
