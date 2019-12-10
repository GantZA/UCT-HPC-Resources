using Distributed
using SharedArrays
using ArgParse

@everywhere using LatentOrderBookModel

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "replications"
            arg_type = Int
            default = 2
        "surface_points"
            arg_type = Int
            default = 2
        "param1_name"
            arg_type = String
            default = "D"
        "param1_value_lower"
            arg_type = Float64
            default = 1.0
        "param1_value_upper"
            arg_type = Float64
            default = 5.0
        "param2_name"
            arg_type = String
            default = "σ"
        "param2_value_lower"
            arg_type = Float64
            default = 0.1
        "param2_value_upper"
            arg_type = Float64
            default = 4.0
    end
    return parse_args(s)
end


function main()
    parsed_args = parse_commandline()
    cpus_allocated = nworkers()
    println("$cpus_allocated cores allocated for job")

    replications = parsed_args["replications"]
    surface_points = parsed_args["surface_points"]
    println("Number of price paths generated: $(surface_points^2*replications)")
    println("Surface points: $surface_points and Replications: $replications")
    param1_name = parsed_args["param1_name"]
    param1_range = [parsed_args["param1_value_lower"], parsed_args["param1_value_upper"]]
    param1_values = repeat(repeat(collect(range(param1_range..., length=surface_points)),inner=surface_points),replications)

    param2_name = parsed_args["param2_name"]
    param2_range = [parsed_args["param2_value_lower"], parsed_args["param2_value_upper"]]
    param2_values = repeat(repeat(collect(range(param2_range..., length=surface_points)),outer=surface_points),replications)
    println("Creating surface plot for parameter $param1_name [$(param1_range[1]), $(param1_range[2])] and parameter $param2_name [$(param2_range[1]), $(param2_range[2])]")

    fixed_params=Dict()
    fixed_params["num_paths"] = replications
    fixed_params["T"]=2299
    fixed_params["p₀"]=238.745
    fixed_params["M"]=250
    fixed_params["β"]=0.1
    fixed_params["L"]=150
    fixed_params["σ"]=2.0
    fixed_params["D"]=5.0
    fixed_params["nu"]=0.0
    fixed_params["λ"]=1.0
    fixed_params["μ"]=0.002

    objective_surface = ObjectiveSurface(
        param1_name, param1_values,
        param2_name, param2_values,
        surface_points, fixed_params)

    random_seed = Int(rand(UInt32))
    price_paths = @time objective_surface(random_seed, true)
    println("Random seed is $random_seed")
    println(size(price_paths))
    io = open("$param1_name" * "_vs_" * "$param2_name" * "_price_paths.csv", "w")
    for i in 1:size(price_paths,1)
        write(io, join(Array(price_paths[i,:]), ", "), "\n")
    end
    close(io)
end

if "" != PROGRAM_FILE && occursin(PROGRAM_FILE, @__FILE__)
    main()
end

