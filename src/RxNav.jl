module RxNav

using HTTP
using LightXML

export rcui, drugs, interaction, interaction_within_list

const RESTuri = Dict(
    "rcui" => "https://rxnav.nlm.nih.gov/REST/rxcui?name=",
    "drugs" => "https://rxnav.nlm.nih.gov/REST/drugs?name=",
    "interaction" => "https://rxnav.nlm.nih.gov/REST/interaction/interaction?rxcui=",
    "interactionlist" => "https://rxnav.nlm.nih.gov/REST/interaction/list?rxcuis=",
)

"""
    is_in_rxcui_format(s)

Tests whether the string is in the format for an RxNav rxcui identifier.
Currently rxcui identifiers are composed of only digits 0 through 9,
though there is nothing in the schema that says these must be only digits.
If that changes in future RxNav updates, the parsing here may also change.
"""
is_in_rxcui_format(s) = all(c -> c in "0123456789", collect(s))


"""
    rcui(name)

Take a name of an NDC drug, return its rxcui as String.
"""
function rcui(name)
    try
        query = RESTuri["rcui"] * HTTP.URIs.escapeuri(name)
        req = HTTP.request("GET", query)
        parsedXML = LightXML.parse_string(String(req.body))
        idstring = content(find_element(root(parsedXML)["idGroup"][1], "rxnormId"))
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
        query = RESTuri["drugs"] * HTTP.URIs.escapeuri(name)
        req = HTTP.request("GET", query)
        parsedXML = LightXML.parse_string(String(req.body))
        dgroup = root(parsedXML)["drugGroup"][1]
        cgroup = filter(x -> content(find_element(x, "tty")) == "SBD", dgroup["conceptGroup"])
        elems = reduce(vcat, x["conceptProperties"] for x in cgroup)
        names = [content(find_element(x, "name")) for x in elems]
        return names
    catch
        @warn("HTTP query of $name to RxNav drugs database failed.")
        return -1
    end
end

"""
    interaction(id; ONCHigh = true)

Given a drug name or rxcui id string, return known drug interations for that drug.
If ONCHigh is true only return the ONCHigh database entries, which returns fewer
entries, tending to list only the more significant interactions. Set ONCHigh
to false to get all known interactions, which can be multiple and sometimes redundant.
Return a vector of named 4-tuples consisting of (first drug, second drug,
severity, and interation description) formeach paired drug interation.
"""
function interaction(id; ONCHigh = true)
    if !is_in_rxcui_format(id)
        id = rcui(id)
    end
    interactions = NamedTuple[]
    try
        query = RESTuri["interaction"] * HTTP.URIs.escapeuri(id)
        query *= ONCHigh ? "&sources=ONCHigh" : ""
        req = HTTP.request("GET", query)
        parsedXML = LightXML.parse_string(String(req.body))
        igroups = root(parsedXML)["interactionTypeGroup"]
        isempty(igroups) && return interactions
        tgroups = reduce(vcat, x["interactionType"] for x in igroups)
        isempty(tgroups) && return interactions
        pairs = reduce(vcat, x["interactionPair"] for x in tgroups)
        for p in pairs
            ics = p["interactionConcept"]
            name1 = content(find_element((ics[1])["minConceptItem"][1], "name"))
            name2 = content(find_element((ics[2])["minConceptItem"][1], "name"))
            sev = content(find_element(p, "severity"))
            desc = content(find_element(p, "description"))
            push!(interactions, (drug1=name1, drug2=name2, severity=sev, description=desc))
        end
    catch
        @warn("HTTP query of $id to RxNav drug interaction database failed.")
    end
    return interactions
end

"""
    interaction_within_list(idlist::Vector{String})

Return a vector of named 4-tuples consisting of (first drug, second drug,
severity, and interation description) formeach paired drug interation.    
Takes as its argument a vector of drug names or rxcui identifiers for drugs for which to seek
any drug interactions.
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
        query = RESTuri["interactionlist"] * arg
        req = HTTP.request("GET", query)
        parsedXML = LightXML.parse_string(String(req.body))
        igroups = root(parsedXML)["fullInteractionTypeGroup"]
        isempty(igroups) && return interactions
        tgroups = reduce(vcat, x["fullInteractionType"] for x in igroups)
        isempty(tgroups) && return interactions
        pairs = reduce(vcat, x["interactionPair"] for x in tgroups)
        for p in pairs
            ics = p["interactionConcept"]
            name1 = content(find_element((ics[1])["minConceptItem"][1], "name"))
            name2 = content(find_element((ics[2])["minConceptItem"][1], "name"))
            sev = content(find_element(p, "severity"))
            desc = content(find_element(p, "description"))
            push!(interactions, (drug1=name1, drug2=name2, severity=sev, description=desc))
        end
    catch
        @warn("HTTP query of $idlist to RxNav drug interaction database failed.")
    end
    return interactions
end


end  # module
