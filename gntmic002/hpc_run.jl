using Distributed
using SharedArrays

@everywhere using LatentOrderBookModel

###########
# boltz_const      [0, 20]
# sigma            [0, 0.1]
# D                [0, 20]
# eta              [0, 0.1]
# lambda           [0, 20]
# mu               [0, 1]
# alpha            [0, 2.0]
###########

# param1_name::String
# param1_values::Array{Any,1}
# param2_name::String
# param2_values::Array{Any,1}
# surface_points::Int64
# replications::Int64
# params::Dict{String, Any}
# log_prices::Array{Float64,1}

cpus_allocated = size(Sys.cpu_info(),1)
println("$cpus_allocated cores allocated for job")

replications = 10
surface_points = 32
println("Number of price paths generated: $(surface_points^2*replications)")
param1_name = "α"
param1_values = repeat(repeat(collect(range(1.0, 10.0, length=surface_points)),inner=surface_points),replications)

param2_name = "ν"
param2_values = repeat(repeat(collect(range(0.0001, 0.0003, length=surface_points)),outer=surface_points),replications)
println("Creating surface plot for parameter $param1_name [1.0, 10.0] and parameter $param2_name [0.0001, 0.0003]")

fixed_params=Dict()
fixed_params["T"]=2300
fixed_params["τ"]=20
fixed_params["initial_mid_price"]=238.745
fixed_params["n_spatial_points"]=4501
fixed_params["boltz_const"]=1.0
fixed_params["sample_std"]=7.415
fixed_params["σ"]=0.001
fixed_params["D"]=5.0
fixed_params["ν"]=0.001
fixed_params["α"]=1.0
fixed_params["λ"]=1.0
fixed_params["μ"]=0.5

objective_surface = ObjectiveSurface(
    param1_name, param1_values,
    param2_name, param2_values,
    surface_points, replications,
    fixed_params)

random_seed = Int(rand(UInt32))
price_paths = @time objective_surface(random_seed, true)
println("Random seed is $random_seed")
println(size(price_paths))
io = open("alpha_vs_nu_price_paths.csv", "w")
for i in 1:size(price_paths,1)
    write(io, join(Array(price_paths[i,:]), ", "), "\n")
end
close(io)

#
# include("preprocess_bar_data.jl")
# include("mom_basic.jl")
#
# bar_data = process_bar_data("Original_Price_Bars_2300.csv")
# log_prices = bar_data.log_price
#
# num_bootstap = 20000
# b = 20
# W = weight_matrix(4547, log_prices, b, num_bootstap)
#
# function redim_pp(price_paths, T, replications, surface_points)
#     price_paths_new_dim = Array{Float32, 3}(undef, T,replications, surface_points^2)
#     for i in 1:surface_points^2
#         for k in 1:replications
#             price_paths_new_dim[:,k,i] = price_paths[:,i + (k-1)*surface_points^2]
#         end
#
#     end
#     return price_paths_new_dim
# end
#
# price_paths_new_dim = redim_pp(price_paths, fixed_params["T"], replications, surface_points)
#
# function objective_value_surface_plot(price_paths, W, log_prices)
#     T, replications, surface_points_sq = size(price_paths)
#     objective_values = zeros(Float32, surface_points_sq)
#     objective_value_fn(price_path) = objective_value(price_path, log_prices, W)
#     for i in 1:surface_points_sq
#         objective_values[i] = objective_value_fn(price_paths[:,:,i])
#     end
#     return objective_values
# end
#
# objective_values = objective_value_surface_plot(price_paths_new_dim, W,
#     log_prices)
#
# x_s = param1_values[1:surface_points^2]
# y_s = param2_values[1:surface_points^2]
# z_s = objective_values[1:end]
# z_s[.!(isnan.(z_s))]
# z_max = log(maximum(z_s[.!(isnan.(z_s))]))
# z_min = log(minimum(z_s[.!(isnan.(z_s))]))
#
#
# using Plots
# pyplot()
# using PyPlot
# pygui(true)
#
# plt = Plots.plot(x_s, y_s, z_s, st=:surface, size=[1000,800],
#     xlabel=param1_name, ylabel=param2_name,
#     zlabel="objective value", camera=(0,30), show=true)
#
# using JLD
# save("D:/Documents/UCT 2019/dissertation/scripts/masters-dissertation/data/alpha_nu_price_paths_001.jld", "price_paths",
#     price_paths, "objective_surface", objective_surface, "objective_values", objective_values, compress=true)
