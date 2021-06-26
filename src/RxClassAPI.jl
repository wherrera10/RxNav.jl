#  github: part of RxNav.jl

"""
    findClassByName

/class/byName    Drug classes with a specified class name
"""
function findClassByName(classname::String, types::Vector{String} = String[])
    argstring = "rxclass/class/byName?className=" * HTTP.URIs.escapeuri(classname) *
        (isempty(types) ? "" : "&classTypes=" * join(types, "+"))
    ids = String[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//rxclassMinConceptList/rxclassMinConcept/classId", doc)
        for x in rxn
            push!(ids, nodecontent(x))
        end
    catch y
        @warn y
    end
    return ids
end

"""
    findClassesById

/class/byId    Drug classes with a specified class identifier
"""
function findClassesById(classid::String)
    argstring = "rxclass/class/byId?classZId=" * HTTP.URIs.escapeuri(id)
    names = String[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//rxclassMinConceptList/rxclassMinConcept/className", doc)
        for x in rxn
            push!(names, nodecontent(x))
        end
    catch y
        @warn y
    end
    return names
end

"""
    findSimilarClassesByClass

/class/similar    Classes with similar clinically-significant RxNorm ingredients
"""
function findSimilarClassesByClass(classid::String, relasource::String, extra=[])
    argstring = "rxclass/class/similar.xml?classId=" * classid * "&relaSource=" * relasource *
        isempty(extra) ? "" : morearg(extra)
    similars = NamedTuple[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//similarityMember/rankClassConcept/drugClassConceptItem/rxclassMinConceptitem", doc)
        for x in rxn
            ename = nodecontent(findfirst("className", x))
            eid = nodecontent(findfirst("classId", x))
            push!(similars, (name = ename, classid = eid))
        end
    catch y
        @warn y
    end
    return similars
end

"""
    findSimilarClassesByDrugList
/class/similarByRxcuis    Classes with clinically-significant RxNorm ingredients similar to a specified list
"""
function findSimilarClassesByDrugList(rxcuis::Vector{String}, extra=[])
    argstring = "rxclass/class/similarByRxcuis?rxcuis=" * join(rxcuis, "+") * isempty(extra) ? "" : morearg(extra)
    similars = NamedTuple[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//similarityMember/rankClassConcept/drugClassConceptItem/rxclassMinConceptItem", doc)
        for x in rxn
            ename = nodecontent(findfirst("className", x))
            eid = nodecontent(findfirst("classId", x))
            push!(similars, (name = ename, classid = eid))
        end
    catch y
        @warn y
    end
    return similars
end

"""
    getAllClasses
/allClasses    All classes (may limit by class type)
"""
function getAllClasses(classtypes::Vector{String}=String[])
    argstring = "rxclass/allClasses" * isempty(classtypes) ? "" : "?classTypes=" * join(classtypes, "+")
    classes = NamedTuple[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//rxclassMinConceptList/rxClassMinConcept", doc)
        for x in rxn
            ename = nodecontent(findfirst("className", x))
            etype = nodecontent(findfirst("classType", x))
            push!(classes, (name = ename, type = etype))
        end
    catch y
        @warn y
    end
    return classes
end

"""
    getClassByRxNormDrugId
/class/byRxcui    Classes containing a specified drug RXCUI
"""
function getClassByRxNormDrugId(rxcui::String, extras = [])
    argstring = "rxclass/class/byRxcui?rxcui=" * rxcui * isempty(extras) ? "" : morearg(extras)
    classes = NamedTuple[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//rxclassDrugInfoList/rxclassDrugInfo/rxclassMinConceptItem", doc)
        for x in rxn
            ename = nodecontent(findfirst("className", x))
            etype = nodecontent(findfirst("classType", x))
            push!(classes, (name = ename, type = etype))
        end
    catch y
        @warn y
    end
    return classes
end

"""
    getClassByRxNormDrugName
/class/byDrugName    Classes containing a drug of the specified name
"""
function getClassByRxNormDrugName(drugname::String, extras = [])
    argstring = "rxclass/class/byDrugName?drugName=" * drugname * isempty(extras) ? "" : morearg(extras)
    classes = NamedTuple[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//rxclassDrugInfoList/rxclassDrugInfo/rxclassMinConceptItem", doc)
        for x in rxn
            ename = nodecontent(findfirst("className", x))
            etype = nodecontent(findfirst("classType", x))
            push!(classes, (name = ename, type = etype))
        end
    catch y
        @warn y
    end
    return classes
end

"""
    getClassContexts
/classContext    Paths from the specified class to the root of its class hierarchies
"""
function getClassContexts(classid::String)
    argstring = "rxclass/classContext.xml?classId=" * classid
    classes = NamedTuple[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//classPathList/classPath/rxclassMinConcept", doc)
        for x in rxn
            ename = nodecontent(findfirst("className", x))
            etype = nodecontent(findfirst("classType", x))
            push!(classes, (name = ename, type = etype))
        end
    catch y
        @warn y
    end
    return classes
end

"""
    getClassGraphBySource
/classGraph    Classes along the path from a specified class to the root of a class hierarchy
"""
function getClassGraphBySource(classId, source="")
    argstring = "rxclass/classGraph?classId=" * classid * isempty(source) ? "" : "&source=$source"
    classes = NamedTuple[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//rxClassGraph/rxclassMinConceptItem", doc)
        for x in rxn
            eid =nodecontent(findfirst("classId", x))
            ename = nodecontent(findfirst("className", x))
            etype = nodecontent(findfirst("classType", x))
            push!(classes, (id = eid, name = ename, type = etype))
        end
    catch y
        @warn y
    end
    return classes
end

"""
    getClassMembers
/classMembers    Drug members of a specified class
"""
function getClassMembers(classid::String, source::String="")
    argstring = "/rxclass/classMembers?classId=" * classid * "&relaSource=" * source
    argstring *= isempty(extras) ? "" : morearg(extras)
    drugs = NamedTuple[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//drugMemberGroup/drugMember/minConcept", doc)
        for x in rxn
            erxcui =nodecontent(findfirst("rxcui", x))
            ename = nodecontent(findfirst("name", x))
            push!(drugs, (rxcui = erxcui, name = ename))
        end
    catch y
        @warn y
    end
    return drugs
end

"""
    getClassTree
/classTree    Subclasses or descendants of the specified class
"""
function getClassTree(classid::String, type="")
    argstring = "/rxclass/classTree?classId=" * classid * isempty(type) ? "" : "&classType=$type"
    classes = NamedTuple[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//rxclassTree/rxclassMinConceptItem", doc)
        for x in rxn
            ename = nodecontent(findfirst("className", x))
            etype = nodecontent(findfirst("classType", x))
            push!(classes, (name = ename, type = etype))
        end
    catch y
        @warn y
    end
    return classes
end

"""
    getClassTypes
/classTypes    Class types
"""
function getClassTypes()
    classtypes = String[]
    try
        doc = getdoc("baseurl", "rxclass/classTypes")
        rxn = findall("//classTypeList/classTypeName", doc)
        for x in rxn
            push!(classtypes, nodecontent(x))
        end
    catch y
        @warn y
    end
    return classtypes
end

"""
    getRelas
/relas    Relationships expressed by a source of drug relations
"""
function getRelas()
    argstring = "/rxclass/relas?relaSource=" * relasource
    relas = String[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//relaList/rela", doc)
        for x in rxn
            push!(relas, nodecontent(x))
        end
    catch y
        @warn y
    end
    return relas
end

"""
    getSimilarityInformation
/class/similarInfo    Similarity of the clinically-significant membership of two classes
"""
function getSimilarityInformation(id1, source1, id2, source2, extras=[])
    argstring = "rxclass/class/similarInfo?classId1=$id1&relaSource1=$source1&classId2=$id2&relaSource2=source2"
    argstring *= isempty(extras) ? "" : morearg(extras)
    similars = NamedTuple[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//SimilarityInformation/drugClassPair/minConcept", doc)
        for x in rxn
            erxcui = nodecontent(findfirst("rxcui", x))
            ename = nodecontent(findfirst("className", x))
            push!(similars, (rxcui = erxcui, name = ename))
        end
    catch y
        @warn y
    end
    return similars
end

"""
    getSourcesOfDrugClassRelations
/relaSources    Sources of drug-class relations
"""
function getSourcesOfDrugClassRelations()
    sources = String[]
    try
        doc = getdoc("baseurl", "rxclass/relaSources")
        rxn = findall("//relaSourceList/relaSourceName", doc)
        for x in rxn
            push!(sources, nodecontent(x))
        end
    catch y
        @warn y
    end
    return sources
end

"""
    getSpellingSuggestions
/spellingsuggestions    Drug or class names similar to a given string
"""
function getSpellingSuggestions(term::String, type="")
    argstring = "/rxclass/spellingsuggestions?term=$term" * isempty(type) ? "" : "&type=$type"
    suggestions = String[]
    try
        doc = getdoc("baseurl", argstring)
        rxn = findall("//suggestionList/suggestion", doc)
        for x in rxn
            push!(suggestions, x)
        end
    catch y
        @warn y
    end
    return suggestions
end
