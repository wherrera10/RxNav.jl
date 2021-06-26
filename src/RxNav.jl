module RxNav

using HTTP
using EzXML

export rcui, drugs, interaction, interaction_within_list

include "util.jl"
include "RxNormAPI.jl"
include "RxTermsAPI.jl"
include "DrugInteractionAPI.jl"

"""
    rcui(name)

Take a name of an NDC drug, return its rxcui as String.
"""
function rcui(name)
    try
        doc = getdoc("rcui", HTTP.URIs.escapeuri(name))
        idstring = nodecontent(first(findall("//idGroup/rxnormId", doc)))
        return idstring
    catch
        @warn("HTTP query of $name to RxNav rcui database failed.")
        return -1
    end
end

"""
    drugs(name)

Given a drug name, return a list of all available dosing forms of the drug.
"""
function drugs(name)
    try
        doc = getdoc("drugs", HTTP.URIs.escapeuri(name))
        nameelements = findall("//drugGroup/conceptGroup/conceptProperties/name", doc)
        return nodecontent.(nameelements)
    catch
        @warn("HTTP query of $name to RxNav drugs database failed.")
        return String[]
    end
end

"""
    interaction(id; ONCHigh = true)

Given a drug name or rxcui id string, return known drug interations for that drug.
If ONCHigh is true only return the ONCHigh database entries, which returns fewer
entries, tending to list only the more significant interactions. Set ONCHigh
to false to get all known interactions, which can be multiple and sometimes redundant.
"""
function interaction(id; ONCHigh = true)
    if !is_in_rxcui_format(id)
        id = rcui(id)
    end
    interactions = NamedTuple[]
    try
        tail = HTTP.URIs.escapeuri(id) * ONCHigh ? "&sources=ONCHigh" : ""
        doc = getdoc("interaction", tail)
        pairs = findall("//interactionTypeGroup/interactionType/interactionPair", doc)
        for p in pairs
            sev = nodecontent(findfirst("severity", p))
            desc = nodecontent(findfirst("description", p))
            enames = findall("iterationConcept/minconceptItem/name", p)
            if !isempty(enames)
                names = nodecontent.(enames)
                push!(interactions, (drug1=names[1], drug2=names[2], severity=sev, description=desc))
            end
        end
    catch
        @warn("HTTP query of $id to RxNav drug interaction database failed.")
    end
    return interactions
end

"""
    interaction_within_list(idlist::Vector{String})

"""
function interaction_within_list(idlist::Vector{String})
    for (i, id) in enumerate(idlist)
        if !is_in_rxcui_format(id)
            idlist[i] = rcui(id)
        end
    end
    interactions = NamedTuple[]
    try
        arg = join(map(x -> HTTP.URIs.escapeuri(x), idlist), "+")
        doc = getdoc("interactionlist", arg)
        pairs = findall("//fullInteractionTypeGroup/fullInteractionType/interactionPair", doc)
        for p in pairs
            sev = nodecontent(findfirst("severity", p))
            desc = nodecontent(findfirst("description", p))
            enames = findall("iterationConcept/minconceptItem/name", p)
            if !isempty(enames)
                names = nodecontent.(enames)
                push!(interactions, (drug1=names[1], drug2=names[2], severity=sev, description=desc))
            end
        end
    catch
        @warn("HTTP query of $idlist to RxNav drug interaction database failed.")
    end
    return interactions
end

end  # module
