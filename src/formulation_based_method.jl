using JuMP
using CPLEX

function solve_optimum_layout(data::Data, auxdata::AuxData, graph::Graph)

    # CPLEX
    model = Model(
        optimizer_with_attributes(
            CPLEX.Optimizer,
            "CPX_PARAM_SCRIND" => 1,    # 0: nothing / 1: show
            "CPX_PARAM_THREADS" => 1,
            "CPX_PARAM_MIPEMPHASIS" => 1,
            # CPXPARAM_Emphasis_MIP # CPLEX 20.10
            "CPX_PARAM_TILIM" => params.max_time)
    )

    create_vars(graph, model)

    create_objective_function(graph, model)

    create_constraints(data, auxdata, graph, model)

    status = optimize!(model)
    objvalue = objective_value(model)
    dualobjvalue = dual_objective_value(model)
    xvals = value.(model[:x])

    sol = [u for u in 1:graph.nconfigurations if xvals[u] > 0.5]

    return objvalue, dualobjvalue, sol
end

function create_vars(graph::Graph, model::Model)
    @variable(model, x[1:graph.nconfigurations], Bin)
end

function create_objective_function(graph::Graph, model::Model)
    @objective(model, Max,
    sum([graph.sittingconfigs[u].npersons * model[:x][u]
        for u in 1:graph.nconfigurations]))
end

function create_constraints(data::Data, auxdata::AuxData, graph::Graph, model::Model)
    create_one_constr_for_each_edge_in_graph(graph, model)
end

function create_one_constr_for_each_edge_in_graph(graph::Graph, model::Model)
    @constraint(model,
        Pairwise[(u,v) in graph.edges],
        model[:x][u] + model[:x][v] <= 1)
end