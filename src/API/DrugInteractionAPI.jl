#  github: part of RxNav.jl

"""
    findDrugInteractions

/interaction	Interactions of an RxNorm drug
returns a Vector of NamedTuples
"""
function findDrugInteractions(rxcui::String, extras = [])
    argstring = "interaction/interaction?rxcui=$rxcui" * isempty(extras) ? "" : morearg(extras)
    interactions = NamedTuple[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//interactionTypeGroup/fullInteractionType/interactionPair")
        for x in rxn
            sev = nodecontent(findfirst("severity", p))
            desc = nodecontent(findfirst("description", p))
            namepair = findall("interactionConcept/minConceptItem/name", p)
            if !isempty(namepair)
                enames = nodecontent.(namepair)
                push!(interactions, (drug1 = enames[1], drug2 = enames[2], severity = sev, description = desc))
            end
        end
    catch y
        @warn y
    end
    return interactions
end

"""
    findInteractionsFromList

/list	Interactions between a list of drugs
returns a Vector of NamedTuples
"""
function findInteractionsFromList(rxcuis::Vector{String}, extras = [])
    argstring = "interaction/list?rxcuis=" * join(rxcuis, "+") *
        isempty(extras) ? "" : morearg(extras)
    interactions = NamedTuple[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//interactionTypeGroup/fullInteractionType/interactionPair")
        for x in rxn
            sev = nodecontent(findfirst("severity", p))
            desc = nodecontent(findfirst("description", p))
            namepair = findall("interactionConcept/minConceptItem/name", p)
            if !isempty(namepair)
                enames = nodecontent.(namepair)
                push!(interactions, (drug1 = enames[1], drug2 = enames[2], severity = sev, description = desc))
            end
        end
    catch y
        @warn y
    end
    return interactions
end

"""
    getInteractionSources

/sources	Sources of the interactions
"""
function getInteractionSources()
    sources = String[]
    try
        doc = getdoc("baseurl", "interaction/sources")
        rxn = findall("//sourceList/source")
        for x in rxn
            push!(sources, nodecontent(x))
        end
    catch y
        @warn y
    end
    return sources
end

"""
    getVersion

/version	Version of the data set(s)
"""
function getVersion()
    versions = String[]
    try
        doc = getdoc("baseurl", "version")
        rxn = findall("//sourceVersionList/sourceVersion")
        for x in rxn
            push!(versions, nodecontent(x))
        end
    catch y
        @warn y
    end
    return versions
end

