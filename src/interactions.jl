# part of RxNav.jl

const ARTIFACT_TOML = joinpath(@__DIR__, "Artifacts.toml")
const ARTIFACT_HASH = artifact_hash("pddi_interactions", ARTIFACT_TOML)
const ARROW_PATH = artifact_path(ARTIFACT_HASH)
const DF = DataFrame(Arrow.Table(ARROW_PATH))

"""
    interactions(list::Vector)
    interactions(s1::AbstractString; severeonly::Bool = false)
    interactions(s1::AbstractString, s2::AbstractString)

Get a list of interactions for a pair of drugs, a single drug, or pairwise from a list
of drug names (or rxcui drug ids). Since RxNav no longer maintains an interactions
database, this function uses a custom Arrow database. For details about the database
construction used, check the src/arrow/csv subdirectory and its contents.
"""
function interactions(x::AbstractString; severeonly::Bool = false)
    target = titlecase(strip(!is_in_rxcui_format(x) ? x : name(x)))
    mask = (DF.Name_1 .== target) .| (DF.Name_2 .== target)
    if severeonly
        mask = mask .& DF.is_severe
    end
    @show DF[mask, [:Name_1, :Name_2, :is_severe, :description, :source]]
    for row in eachrow(DF[mask, [:Name_1, :Name_2, :is_severe, :description, :source]])
        push!(
            interactions,
            (
                drug1 = row[:Name_1],
                drug2 = row[:Name_2],
                severity = row[:is_severe],
                description = row[:description],
            ),
        )
    end
    return interactions
end
function interactions(x1::AbstractString, x2::AbstractString; severeonly::Bool = false)
    interactions = NamedTuple[]
    if is_in_rxcui_format(x1)
        x1 = name(x1)
    end
    if is_in_rxcui_format(x2)
        x2 = name(x2)
    end
    mask = (
        (DF.Name_1 .== x1) .& (DF.Name_2 .== x2) .| (DF.Name_1 .== x2) .& (DF.Name_2 .== x1)
    )
    if severeonly
        mask = mask .& DF.is_severe
    end
    for row in eachrow(DF[mask, [:Name_1, :Name_2, :is_severe, :description, :source]])
        push!(
            interactions,
            (
                drug1 = row[:Name_1],
                drug2 = row[:Name_2],
                severity = row[:is_severe],
                description = row[:description],
            ),
        )
    end
    return interactions
end
function interactions(arr::Vector{<:AbstractString}, severeonly::Bool = false)
    combos = collect(combinations(arr, 2))
    return reduce(
        vcat,
        (interactions(combo[1], combo[2]; severeonly = severeonly) for combo in combos)
    )
end
