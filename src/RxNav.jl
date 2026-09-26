""" RxNav National Library of Medicine REST API wrapper in Julia. """
module RxNav

using HTTP, EzXML, JSON

export rxcui, drugs, name, interaction, interaction_within_list, interact, getSpellingSuggestions

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
    try
        doc = getdoc("rxcui", HTTP.URIs.escapeuri(name))
        idstring = nodecontent(findfirst("//idGroup/rxnormId", doc))
        return idstring
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
    try
        doc = getdoc("drugs", HTTP.URIs.escapeuri(name))
        nameelements = findall("//drugGroup/conceptGroup/conceptProperties/name", doc)
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
    try
        doc = getdoc("name", HTTP.URIs.escapeuri("$id"))
        namestring = nodecontent(findfirst("//idGroup/name", doc))
        return namestring
    catch y
        @warn "name lookup failed for $id" exception=y
        return nothing
    end
end

end  # module
