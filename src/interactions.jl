# part of RxNav.jl

const PDDI_DIR = artifact"pddi_interactions"
const PDDI_FILE = joinpath(PDDI_DIR, "pddi_interactions.arrow")
const DF = DataFrame(Arrow.Table(PDDI_FILE))

"""
    interactions(s1::AbstractString; severeonly::Bool = false)
    interactions(s1::AbstractString, s2::AbstractString; severeonly::Bool = false)
    interactions(list::Vector{<:AbstractString}; severeonly::Bool = false)
    interactions(args...; severeonly::Bool = false)
 
Get a list of interactions for a pair of drugs, a single drug, or pairwise from a list
of drug names (or rxcui drug ids). Since RxNav no longer maintains an interactions
database, this function uses a custom Arrow database. For details about the database
construction used, check the src/arrow/csv subdirectory and its contents.

Returns a list of NamedTuples representing the interactions. Each NamedTuple contains the following fields:
- `drug1`: The name of the first drug.
- `drug2`: The name of the second drug.
- `is_severe`: A boolean indicating if the interaction is severe.
- `description`: A description of the interaction.
- `source`: The source of the interaction information.
"""
function interactions(x::AbstractString; severeonly::Bool = false)
    target = titlecase(strip(!is_in_rxcui_format(x) ? x : name(x)))
    results = NamedTuple[]
    isempty(target) && return results
    mask = (DF.Name_1 .== target) .| (DF.Name_2 .== target)
    if severeonly
        mask .&= DF.is_severe
    end
    for row in eachrow(DF[mask, [:Name_1, :Name_2, :is_severe, :description, :source]])
        push!(
            results,
            (
                drug1 = row[:Name_1],
                drug2 = row[:Name_2],
                is_severe = row[:is_severe] ?
                    true :
                    contains(row[:source], "DrugBank") ? "not given" : false,
                description = row[:description],
                source = row[:source],
            ),
        )
    end
    return results |> unique!
end
function interactions(x1::AbstractString, x2::AbstractString; severeonly::Bool = false)
    results = NamedTuple[]
    name1 = titlecase(strip(!is_in_rxcui_format(x1) ? x1 : name(x1)))
    name2 = titlecase(strip(!is_in_rxcui_format(x2) ? x2 : name(x2)))
    if name1 == name2 || isempty(name2)
        return interactions(name1; severeonly = severeonly)
    elseif isempty(name1) 
        return interactions(name2; severeonly = severeonly)
    end
    if name1 > name2 # standardize order
        name1, name2 = name2, name1
    end
    mask = (
        ((DF.Name_1 .== name1) .& (DF.Name_2 .== name2)) .|
            ((DF.Name_1 .== name2) .& (DF.Name_2 .== name1))
    )
    if severeonly
        mask .&= DF.is_severe
    end
    for row in eachrow(DF[mask, [:Name_1, :Name_2, :is_severe, :description, :source]])
        push!(
            results,
            (
                drug1 = row[:Name_1],
                drug2 = row[:Name_2],
                is_severe = row[:is_severe] ?
                    true :
                    contains(row[:source], "DrugBank") ? "not given" : false,
                description = row[:description],
                source = row[:source],
            ),
        )
    end
    return results |> unique! |> sort!
end
function interactions(arr::Vector{<:AbstractString}; severeonly::Bool = false)
    len = length(arr)
    len == 0 && return NamedTuple[]
    len == 1 && return interactions(arr[1]; severeonly = severeonly)
    len == 2 && return interactions(arr[1], arr[2]; severeonly = severeonly)
    names = [titlecase(strip(!is_in_rxcui_format(x) ? x : name(x))) for x in arr]
    sort!(unique!(names))
    combos = collect(combinations(names, 2))
    return reduce(
        vcat,
        (interactions(combo[1], combo[2]; severeonly = severeonly) for combo in combos)
    ) |>
        unique!
end
""" Convenience function for interaction queries with arbitrary number of arguments """
function interactions(args::AbstractString...; severeonly::Bool = false)
    return interactions(collect(args); severeonly = severeonly)
end
