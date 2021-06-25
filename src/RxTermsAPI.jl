"""
    getAllConcepts

/allconcepts	All RxTerms concepts
"""
function getAllConcepts()
    clist = Vector{String}[]
    try
        doc = getdoc("baseurl", "RxTerms/allconcepts")
        for x in findall("//minConceptGroup/minConcept", doc)
            push!(clist, [nodecontent(findfirst(s, x)) for s in ["fullName", "termType", "rxcui"]])
        end
    catch y
        @warn y
    end
    return ndclist
end

"""
    getAllRxTermInfo

/rxcui/rxcui/allinfo	RxTerms information for a specified RxNorm concept
Returns the (quite variable) properties data in XML form.
"""
function getAllRxTermInfo(rxcui::String)
    argstring = "RxTerms/rxcui/" * rxcui * "/allinfo"
    try
        doc = getdoc("baseurl", argstring)
        rxn = findfirst("//rxtermsProperties", doc)
        return string(rxn)
    catch y
        @warn y
        return ""
    end
end

"""
    getRxTermDisplayName

/rxcui/rxcui/name	RxTerms display name for a specified RxNorm concept
"""
function getRxTermDisplayName(rxcui::String)
    argstring = "RxTerms/rxcui/" * rxcui * "/name"
    try
        doc = getdoc("baseurl", argstring)
        x = findfirst("//displayGroup", doc)
        return nodecontent(findfirst("displayName", x))
    catch y
        @warn y
        return ""
    end
end

"""
getRxTermsVersion

/version	RxTerms version
"""
function getRxTermsVersion()
    try
        doc = getdoc("baseurl", "rxTerms/version")
        return nodecontent(findfirst("//rxTermsVersion", doc))
    catch y
        @warn y
        return ""
    end
end

