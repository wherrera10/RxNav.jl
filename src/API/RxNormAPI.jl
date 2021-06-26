#  github: part of RxNav.jl

"""
   filterByProperty
/rxcui/rxcui/filter	Concept RXCUI if the predicate is true	Active
"""
function filterByProperty(rxcui::String, propName::String, propValues::Vector{String} = [])
    argstring = "$rxcui/filter?propName=$propName"
    argstring *= isempty(propValues) ? "" : "&propValues=" * join(propValues, "+")
    s = ""
    try
        s = string(getdoc(baseurl(), argstring))
    catch y
        @warn y
    end
    return contains(rxcui, s)
end

"""
   findRxcuiById
/rxcui?idtype=...&id=...	Concepts associated with a specified identifier	Active or Current
"""
function findRxcuiById(idtype::String, id::String, allsrc = 0)
    argstring = "rxcui?idtype=$idtype&id=$id&allsrc=$allsrc"
    try
        doc = getdoc(baseurl(), argstring)
        rxn = findall("//idGroup/rxnormId", doc))
        return nodecontent.(rxn)
    catch y
        @warn y
        return String[]
    end
end

"""
   findRxcuiByString
/rxcui?name=...	Concepts with a specified name	Active or Current
"""
function findRxcuiByString(name::String, extras=[])
    argstring = "rxcui?name=" * HTTP.URIs.escapeuri(name)
    argstring *= isempty(extras) ? "" : morearg(extras)
    try
        doc = getdoc(baseurl(), argstring)
        return nodecontent(findfirst("//idGroup/rxnormId", doc))
    catch y
        @warn y
        return String[]
    end
end

"""
    getAllConceptsByStatus
/allstatus	Concepts having a specified status	Current and Historical
"""
function getAllConceptsByStatus(status = "ALL)
    argstring = "allstatus?status=$status"
    concepts = NamedTuple[]
    try
        doc = getdoc(baseurl(), argstring)
        rxn = findall("//minConceptGroup/minConcept", doc)
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
    getAllConceptsByTTY

/allconcepts	Concepts having a specified term type	Active
"""
function getAllConceptsByTTY(tty::Vector{String})
    argstring = "allconcepts?tty=" * join(tty, "+")
    concepts = NamedTuple[]
    try
        doc = getdoc(baseurl(), argstring)
        rxn = findall("//rxnormdata/minConceptGroup/minConcept")
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
   getAllHistoricalNDCs

/rxcui/rxcui/allhistoricalndcs	National Drug Codes (NDC) ever associated with a concept	Current and Historical
"""
function getAllHistoricalNDCs()
    argstring = "rxcui/1668240/allhistoricalndcs"
    times = NamedTuple[]
    try
        doc = getdoc(baseurl(), argstring)
        rxn = findall("//historicalNdcConcept/ndcTime", doc)
        for x in rxn
            endc = nodecontent(findfirst("ndc", x))
            estartDate = nodecontent(findfirst("startDate", x))
            eendDate = nodecontent(findfirst("endDate", x))
            push!(times, (ndc = endc, startDate = estartDate, endDate = eendDate))
        end
    catch y
        @warn y
    end
    return times
end

"""
    getAllNDCsByStatus

/allNDCstatus	NDCs having a specified NDC status	Current and Historical
"""
function getAllNDCsByStatus(status = "ALL")
    argstring = "allNDCstatus?status=$status"
    ndclist = String[]
    try
        doc = getdoc(baseurl(), argstring)
        for x in findall("//ndcList/ndc", doc)
            push!(ndclist, content(x))
        end
    catch y
        @warn y
    end
    return ndclist
end

"""
    getAllProperties

/rxcui/rxcui/allProperties	Concept details	Active
"""
function getAllProperties(rxcui, properties = ["ALL"])
    argstring = "rxcui/" * rxcui * "/allProperties?prop=" * join(properties, "+")
    query = RESTuri[baseurl()] * argstring
    concepts = NamedTuple[]
    try
        doc = getdoc(baseurl(), argstring)
        rxn = findall("//propConceptGroup/propConcept", doc)
        for x in rxn
            ecategory = nodecontent(findfirst("propCategory", x))
            ename = nodecontent(findfirst("propName", x))
            evalue = nodecontent(findfirst("propValue", x))
            push!(concepts, (category = ecategory, name = ename, value = evalue))
        end
    catch y
        @warn y
    end
    return concepts
end

"""
    getAllRelatedInfo

/rxcui/rxcui/allrelated	Concepts related directly or indirectly to a specified concept	Active
"""
function getAllRelatedInfo(rxcui::String)
    argstring = "rxcui/" * rxcui * "/allrelated"
    concepts = NamedTuple[]
    try
        doc = getdoc(baseurl(), argstring)
        rxn = findall("//allRelatedGroup/conceptGroup/conceptProperties", doc)
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
    getApproximateMatch

/approximateTerm	Concept and atom IDs approximately matching a query	Active or Current
"""
function getApproximateMatch(term::String, extras = [])
    argstring = "approximateTerm?term=" * HTTP.URIs.escapeuri(term) * isempty(extras) ? "" : morearg(extras)
    concepts = NamedTuple[]
    try
        doc = getdoc(baseurl(), argstring)
        rxn = findall("//approximateGroup/candidate", doc)
        for x in rxn
            erxcui = nodecontent(findfirst("rxcui", x))
            erxaui = nodecontent(findfirst("rxaui", x))
            push!(concepts, (rxcui = erxcui, rxaui = erxaui))
        end
    catch y
        @warn y
    end
    return concepts
end

"""
    getDisplayTerms

/displaynames	Strings to support auto-completion in a user interface	Active
"""
function getDisplayTerms()
    terms = String[]
    try
        doc = getdoc(baseurl(), "displaynames")
        rxn = findall("//displayTermsList/term", doc)
        for xterm in rxn
            push!(terms, nodecontent(xterm))
        end
    catch y
        @warn y
    end
    return terms
end

"""
    getDrugs

/drugs	Drugs related to a specified name	Active
"""
function getDrugs(name::String)
    argstring = "drugs?name=" * HTTP.URIs.escapeuri(name)
    concepts = NamedTuple[]
    try
        doc = getdoc(baseurl(), argstring)
        rxn = findall("//drugGroup/conceptGroup/conceptProperties", doc)
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
    getIdTypes

/idtypes	Identifier types	Current
"""
function getIdTypes()
    idnames = String[]
    try
        doc = getdoc(baseurl(), "idtypes")
        rxn = findall("//idTypeList/idName", doc)
        for xterm in rxn
            push!(idnames, nodecontent(xterm))
        end
    catch y
        @warn y
    end
    return idnames
end

"""
    getMultiIngredBrand

/brands	Brands containing specified ingredients	Active
"""
function getMultiIngredBrand(ingredientids::Vector{String})
    argstring = "brands?ingredientids=" * join(properties, "+")
    concepts = NamedTuple[]
    try
        doc = getdoc(baseurl(), argstring)
        rxn = findall("//brandGroup/conceptProperties", doc)
        for x in rxn
            erxcui = nodecontent(findfirst("rxcui", x))
            ename = nodecontent(findfirst("propName", x))
            push!(concepts, (rxcui = erxcui, name = ename))
        end
    catch y
        @warn y
    end
    return concepts
end

"""
    getNDCProperties

/ndcproperties	National Drug Code (NDC) details	Active
"""
function getNDCProperties(value::String)
    argstring = "ndcproperties?id=" * HTTP.URIs.escapeuri(value)
    concepts = NamedTuple[]
    try
        doc = getdoc(baseurl(), argstring)
        rxn = findall("//ndcPropertyList/ndcProperty/properttyConceptList/propertyConcept", doc)
        for x in rxn
            propname = nodecontent(findfirst("propName", x))
            propvalue = nodecontent(findfirst("propValue", x))
            push!(concepts, (name = propname, value = propvalue))
        end
    catch y
        @warn y
    end
    return concepts
end

"""
    getNDCStatus

/ndcstatus	Status of a National Drug Code (NDC)	Current and Historical
"""
function getNDCStatus(ndc::String, extras = [])
    argstring = "ndcstatus?ndc=" * HTTP.URIs.escapeuri(ndc) * isempty(extras) ? "" : morearg(extras)
    concepts = NamedTuple[]
    try
        doc = getdoc(baseurl(), argstring)
        rxn = findall("//ndcStatus/ndcHistory", doc)
        for x in rxn
            activeRx = nodecontent(findfirst("activeRxcui", x))
            originalRx = nodecontent(findfirst("originalRxcui", x))
            startDate = nodecontent(findfirst("startDate", x))
            endDate = nodecontent(findfirst("endDate", x))
            push!(concepts, (active = activeRx, original = originalRx, startdate = startDate, enddate = endDate))
        end
    catch y
        @warn y
    end
    return concepts
end

"""
getNDCs

/rxcui/rxcui/ndcs	National Drug Codes (NDC) associated with a concept	Active
"""
function getNDCs(rxcui::String)
    argstring = "rxcui/" * rxcui * "/ndcs"
    ndcs = String[]
    try
        doc = getdoc(baseurl(), argstring)
        rxn = findall("//ndcGroup/ndcList/ndc", doc)
        for ndc in rxn
            push!(ndcs, nodecontent(ndc))
        end
    catch y
        @warn y
    end
    return ndcs
end

"""
    getPropCategories

/propCategories	RxNav property categories	Active
"""
function getPropCategories()
    propcategories = String[]
    try
        doc = getdoc(baseurl(), "propCategories")
        rxn = findall("//propCategoryList/ndc")
        for pcat in rxn
            push!(propcategories, nodecontent(pcat))
        end
    catch y
        @warn y
    end
    return propcategories
end

"""
    getPropNames

/propnames	Property names	Active
"""
function getPropNames()
    propnames = String[]
    try
        doc = getdoc(baseurl(), "propnames")
        rxn = findall("//propNameList/propName")
        for pname in rxn
            push!(propcategories, nodecontent(pname))
        end
    catch y
        @warn y
    end
    return propnames
end

"""
    getProprietaryInformation

/rxcui/rxcui/proprietary	Strings from sources that require a UMLS license	Current
"""
function getProprietaryInformation(rxcui::String, ticket::String, extras = [])
    argstring = "rxcui/" * rxcui * "/proprietary.xml?ticket=$ticket" * isempty(extras) ? "" : morearg(extras)
    concepts = NamedTuple[]
    try
        doc = getdoc(baseurl(), argstring)
        rxn = findall("//proprietaryGroup/proprietaryInfo", doc)
        for x in rxn
            erxcui = nodecontent(findfirst("rxcui", x))
            ename = nodecontent(findfirst("propName", x))
            push!(concepts, (rxcui = erxcui, name = ename))
        end
    catch y
        @warn y
    end
    return concepts
end

"""
    getRelaTypes

/relatypes	RxNorm Relationship types	Active
"""
function getRelaTypes()
    relas = String[]
    try
        doc = getdoc(baseurl(), "relatypes")
        rxn = findall("//relationalTypeList/relationType", doc)
        for rel in rxn
            push!(relas, nodecontent(rel))
        end
    catch y
        @warn y
    end
    return relas
end

"""
    getRelatedByRelationship

/rxcui/rxcui/related?rela=...	Concepts directly related to a specified concept by a specified relationship	Active
"""
function getRelatedByRelationship(rxcui::String, relata::Vector{String})
    argstring = "rxcui/" * rxcui * "/related?rela=" * join(relata, "+")
    concepts = NamedTuple[]
    try
        doc = getdoc(baseurl(), argstring)
        rxn = findall("//relatedGroup/conceptGroup/conceptProperties", doc)
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
    getRelatedByType

/rxcui/rxcui/related?tty=...	Concepts of specified types that are directly or indirectly related to a specified concept	Active
"""
function getRelatedByType(rxcui::String, ttys::Vector{String})
    argstring = "rxcui/" * rxcui * "/related?tty=" * join(ttys, "+")
    concepts = NamedTuple[]
    try
        doc = getdoc(baseurl(), argstring)
        rxn = findall("//relatedGroup/conceptGroup/conceptProperties", doc)
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
    getRxConceptProperties

/rxcui/rxcui/properties	Concept name, TTY, and a synonym	Active
"""
function getRxConceptProperties(rxcui::String)
    argstring = "rxcui/" * rxcui * "/properties"
    try
        doc = getdoc(baseurl(), argstring)
        x = findfirst("properties")
        ename = nodecontent(findfirst("name", x))
        etty = nodecontent(findfirst("tty", x))
        elanguage = nodecontent(findfirst("language", x))
        esuppress = nodecontent(findfirst("suppress", x))
        return (name = ename, tty = etty, language = elanguage, suppress = esuppress)
    catch y
        @warn y
    end
    return (not_found = rxcui)
end

"""
    getRxNormName

/rxcui/rxcui	Name of a concept	Active
"""
function getRxNormName(rxcui::String)
    try
        doc = getdoc(baseurl(), rxcui)
        x = findfirst("//idGroup", doc)
        eid = nodecontent(findfirst("rxnormId", x))
        ename = nodecontent(findfirst("name", x))
        return (rxnormId = eid, name = ename)
    catch y
        @warn y
        return NamedTuple()
    end
end

"""
    getRxNormVersion

/version	RxNorm data set and API versions	Current
"""
function getRxNormVersion()
    try
        doc = getdoc(baseurl(), "version")
        x = root(doc)
        ver = nodecontent(findfirst("version", x))
        apiver = nodecontent(findfirst("name", x))
        return (version = ver, apiVersion = apiver)
    catch y
        @warn y
        return NamedTuple()
    end
end

"""
    getRxProperty

/rxcui/rxcui/property	A property of a concept	Active
"""
function getRxProperty(rxcui::String, propname::String)
    argstring = "rxcui/" * rxcui * "/property?propName=" * propname
    try
        doc = getdoc(baseurl(), argstring)
        x = findfirst("//propConceptGroup/propConcept", doc)
        cat = nodecontent(findfirst("propCategory", x))
        ename = nodecontent(findfirst("propName", x))
        val = nodecontent(findfirst("propValue", x))
        esuppress = nodecontent(findfirst("suppress", x))
        return (category = cat, name = ename, value = val)
    catch y
        @warn y
        return NamedTuple()
    end
end

"""
    getRxcuiHistoryStatus

/rxcui/rxcui/historystatus	Status, history, and other attributes of a concept	Current and Historical
Returns the (quite variable) metadata in XML form.
"""
function getRxcuiHistoryStatus(rxcui::String)
    argstring = "rxcui/" * rxcui * "/historystatus"
    try
        doc = getdoc(baseurl(), argstring)
        rxn = findfirst("//rxcuiStatusHistory/metaData", doc)
        return string(rxn)
    catch y
        @warn y
        return ""
    end
end

"""
    getSourceTypes

/sourcetypes	Vocabulary sources	Current
"""
function getSourceTypes()
    sourcetypes = String[]
    try
        doc = getdoc(baseurl(), "sourcetypes")
        rxn = findall("//sourceTypeList/sourceName", doc)
        for x in rxn
            push!(sourcetypes, nodecontent(x))
        end
    catch y
        @warn y
    end
    return sourcetypes
end

"""
    getSpellingSuggestions

/spellingsuggestions	Strings similar to a specified string	Active
"""
function getSpellingSuggestions(phrase::String)
    argstring = "spellingsuggestions?name=" * HTTP.URIs.escapeuri(phrase)
    suggestions = String[]
    try
        doc = getdoc(baseurl(), argstring)
        rxn = findall("//suggestionGroup/suggestionList/suggestion", doc)
        for x in rxn
            push!(suggestions, nodecontent(x))
        end
    catch y
        @warn y
    end
    return suggestions
end

"""
    getTermTypes

/termtypes	Term types	Active
"""
function getTermTypes()
    termtypes = String[]
    try
        doc = getdoc(baseurl(), "termtypes")
        rxn = findall("//termTypeList/termType", doc)
        for x in rxn
            push!(termtypes, nodecontent(x))
        end
    catch y
        @warn y
    end
    return termtypes
end
