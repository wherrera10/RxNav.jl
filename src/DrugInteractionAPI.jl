#  github: part of RxNav.jl

"""
    findDrugInteractions

/interaction	Interactions of an RxNorm drug
"""
function findDrugInteractions(rxcui::String, extras = [])
    argstring = "interaction/interaction?rxcui=$rxcui" * isempty(extras) ? "" : morearg(extras)
    concepts = NamedTuple[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//interactionTypeGroup/interactionType/minConceptItem")
        for x in rxn
            erxcui = nodecontent(findfirst("rxcui", x))
            ename = nodecontent(findfirst("name", x))
            push!(concepts, (rxcui = erxcui, name = ename))
        end
    catch y
        @warn y
    end
    return concepts
end

"""
    findInteractionsFromList

/list	Interactions between a list of drugs
"""
function findInteractionsFromList(rxcuis::Vector{String}, extras = [])
    argstring = "interaction/list?rxcuis=" * join(rxcuis, "+") *
        isempty(extras) ? "" : morearg(extras)
    concepts = NamedTuple[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//interactionTypeGroup/fullInteractionType/interactionPair/interactionConcept/minConceptItem")
        for x in rxn
            erxcui = nodecontent(findfirst("rxcui", x))
            ename = nodecontent(findfirst("name", x))
            push!(concepts, (rxcui = erxcui, name = ename))
        end
    catch y
        @warn y
    end
    return concepts
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

