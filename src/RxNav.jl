""" RxNav National Library of Medicine REST API wrapper in Julia. """
module RxNav

using Artifacts, Pkg, HTTP, EzXML, JSON, DataFrames, Arrow, Combinatorics

export rxcui, drugs, name, getSpellingSuggestions
export ENV_RXCHECK_API_KEY, interactions

include("util.jl")
include("interactions.jl")
include("API/RxClassAPI.jl")
include("API/RxNormAPI.jl")
include("API/RxTermsAPI.jl")

"""
    rxcui(name)

Take a name of an NDC drug, return its rxcui as String, or nothing on failure.
"""
function rxcui(name)
    isempty(name) && return nothing
    try
        doc = getdoc("rxcui", HTTP.URIs.escapeuri(name))
        idstring = findfirst("//idGroup/rxnormId", doc)
        isnothing(idstring) && return nothing
        return nodecontent(idstring)
    catch y
        @warn "rxcui lookup failed for $name" exception=y
        return nothing
    end
end

"""
    drugs(name)

Given a drug name, return a list of all available dosing forms of the drug.
Return nothing if the lookup fails.
"""
function drugs(name)
    isempty(name) && return nothing
    try
        doc = getdoc("drugs", HTTP.URIs.escapeuri(name))
        nameelements = findall("//drugGroup/conceptGroup/conceptProperties/name", doc)
        isempty(nameelements) && return nothing
        return nodecontent.(nameelements)
    catch y
        @warn "drugs lookup failed for $name" exception=y
        return nothing
    end
end

"""
    name(id) 


Given the rxcui number as an integer or string, return the drug name, or nothing on failure.
"""
function name(id)
    isempty(id) && return nothing
    try
        doc = getdoc("name", HTTP.URIs.escapeuri("$id"))
        namestring = findfirst("//idGroup/name", doc)
        isnothing(namestring) && return nothing
        return nodecontent(namestring)
    catch y
        @warn "name lookup failed for $id" exception=y
        return nothing
    end
end

end  # module
