using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--method"
            help = "method to be performed: exact | placeclosecorner | placerandomly."
            range_tester = (x->x=="exact"||x=="placeclosecorner"||x=="placerandomly") 
            default = "exact"
        "--plot"
            help = "allows plotting the layout. By default: false"
            action = :store_true
        "--verbose"
            help = "verbose output. By default: false"
            action = :store_true
        "--mindist"
            help = "minimum distance allowed between persons"
            arg_type = Float64
            default = 2.0
        "--backback"
            help = "allow people to sit back to back within less than the minimum distance. By default: false"
            action = :store_true
        "--seed"
            help = "seed to control randomness of heuristic"
            arg_type = Int64
            default = 0
        "--tl"
            help = "time limit"
            arg_type = Int64
            default = 86400
        "--instance"
            help = "path to instance file"
            required = true
    end

    return parse_args(s)
end