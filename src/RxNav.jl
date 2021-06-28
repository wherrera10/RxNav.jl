module RxNav

using EzXML
using HTTP

export rcui, drugs, interaction, interaction_within_list, prescribable, interact

include("util.jl")
include("API/RxNormAPI.jl")
include("API/RxTermsAPI.jl")
include("API/DrugInteractionAPI.jl")

"""
    rcui(name)

Take a name of an NDC drug, return its rxcui as String.
"""
function rcui(name)
    try
        doc = getdoc("rcui", HTTP.URIs.escapeuri(name))
        idstring = nodecontent(findfirst("//idGroup/rxnormId", doc))
        return idstring
    catch y
        @warn y
        return ""
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
    catch y
        @warn y
        return String[]
    end
end

"""
    interactinteract(list::Vector)
    interact(s1::String, severeonly::Bool=true)
    interact(s1::String, s2::String, args...)

Get a list of interactions for a single drug (or rxcui drug id) or pairwise interactions for more than one drug (or rxcuid).
"""
interact(list::Vector) = if length(list) > 1 interaction_within_list(list); else interact(first(list)) end
interact(s1::String, severeonly::Bool=true) = interaction(s1; ONCHigh=severeonly)
interact(s1::String, s2::String, args...) = interact([[s1, s2]; [x for x in args]])

"""
    interaction(id; ONCHigh = true)

Given a drug name or rxcui id string, return known drug interations for that drug.
If ONCHigh is true only return the ONCHigh database entries, which returns fewer
entries, tending to list only the more significant interactions. Set ONCHigh
to false to get all known interactions, which can be multiple and sometimes redundant.
Returns a `Vector` of `NamedTuple`s as in (drug1, drug2, severity, description)
"""
function interaction(id; ONCHigh = true)
    if !is_in_rxcui_format(id)
        id = rcui(id)
    end
    interactions = NamedTuple[]
    try
        tail = HTTP.URIs.escapeuri(id) * (ONCHigh ? "&sources=ONCHigh" : "")
        doc = getdoc("interaction", tail)
        pairs = findall("//interactionTypeGroup/interactionType/interactionPair", doc)
        for p in pairs
            sev = nodecontent(findfirst("severity", p))
            desc = nodecontent(findfirst("description", p))
            enames = findall("interactionConcept/minConceptItem/name", p)
            if !isempty(enames)
                names = nodecontent.(enames)
                push!(interactions, (drug1=names[1], drug2=names[2], severity=sev, description=desc))
            end
        end
    catch y
        @warn y
    end
    return interactions
end

"""
    interaction_within_list(idlist::Vector{String})
    
Given a list of drug names or rxcui id strings, return known drug interations for 
that combination of drugs. Results are organized pairwise, so if A, B, and C have
mutual interactions this will be reported for example as A with B, A with C, B with C.
Returns a `Vector` of `NamedTuple`s as in (drug1, drug2, severity, description)
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
            enames = findall("interactionConcept/minConceptItem/name", p)
            if !isempty(enames)
                names = nodecontent.(enames)
                push!(interactions, (drug1=names[1], drug2=names[2], severity=sev, description=desc))
            end
        end
        catch y
        @warn y
    end
    return interactions
end

end  # module
