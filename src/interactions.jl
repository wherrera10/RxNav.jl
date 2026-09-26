# part of RxNav.jl

"""
    loadAPIkey(printwarning = true)
        Load the RxCheck API key from the environment variable "RXCHECK_API_KEY".
        Returns the API key as a string, or an empty string if not found.
"""
function loadAPIkey(printwarning = true)
    if haskey(ENV, "RXCHECK_API_KEY")
        return ENV["RXCHECK_API_KEY"]
    else
        if printwarning
            @warn "ENV[\"RXCHECK_API_KEY\"] not found: drug interactions not available."
        end
        return ""
    end
end

const ENV_RXCHECK_API_KEY = loadAPIkey()
const RXCHECK_API_HEADER = ["X-API-Key" => ENV_RXCHECK_API_KEY]

"""
    interact(list::Vector)
    interact(s1::String, severeonly::Bool=true)
    interact(s1::String, s2::String, args...)

Get a list of interactions for a single drug (or rxcui drug id) or pairwise interactions
for more than one drug (or rxcuid). Since RxNav no longer maintains an interactions
database, this function uses the RxCheck API, and requires an API key to be set in the
environment as ENV["RXCHECK_API_KEY"]. See https://rxcheck.dev for more information.
"""
interact(list::Vector) = if length(list) > 1
    interaction_within_list(list)
else
    interact(first(list))
end
interact(s1::String, severeonly::Bool = true) = interaction(s1, severeonly = severeonly)
interact(s1::String, s2::String, args...) = interact([[s1, s2]; [x for x in args]])

"""
    interaction(id, severeonly=true)

Given a drug name or rxcui id string, return known drug interactions for that drug.

NOTE: Because the RxNav database dropped its interactions database in 2023, the RxCheck
database is queried here instead. This requires the RxCheck API key be placed in the
environment prior to running this function, for example as ENV["RXCHECK_API_KEY"]. A 
limited-use (100x/month) API key can be obtained from RxCheck.dev for free use as of 2026.

Returns a `Vector` of `NamedTuple`s as in (drug1, drug2, severity, description)
"""
function interaction(id, severeonly = true)
    if is_in_rxcui_format(id)
        id = name(id)
    end
    interactions = NamedTuple[]
    try
        tail = HTTP.URIs.escapeuri(id) *
            "/interactions" *
            (severeonly ? "?severity=major" : "")
        json = getjson("interactions", tail; headers = RXCHECK_API_HEADER)
        @show json
        #=
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
=#
        return interactions
    catch y
        @warn y
        return nothing
    end
end

"""
    interaction_within_pair(name1, name2)

Given two drug names or rxcui id strings, return known drug interactions for that pair.
Returns a Vector of NamedTuples as in (drug1, drug2, severity, description)
"""
function interaction_within_pair(name1, name2)
    try
        if is_in_rxcui_format(name1)
            name1 = name(name1)
        end
        if is_in_rxcui_format(name2)
            name2 = name(name2)
        end
        tail = "drug1=" *
            HTTP.URIs.escapeuri(name1) *
            "&drug2=" *
            HTTP.URIs.escapeuri(name2)
        d = getjson("interactionpair", tail; headers = RXCHECK_API_HEADER)
        interactions = NamedTuple[]
        if haskey(d, "interaction")
            dict = Dict(d["interaction"])
        @show dict
            severity = get(dict, "severity", "")
            if severity != "none"
                mechanism = get(dict, "mechanism", "")
                push!(interactions, (name1=name1, name2=name2, severity=severity,
                                     description=mechanism))
            end
        end
        return interactions
    catch y
        @warn y
        return nothing
    end
end

"""
    interaction_within_list(namelist::Vector{String})
    
Given a list of drug names or rxcui id strings, return known drug interations for 
that combination of drugs. Results are organized pairwise, so if A, B, and C have
mutual interactions this will be reported for example as A with B, A with C, B with C.

NOTE: Because the RxNav database dropped the interactions database in 2023, the RxCheck
database is queried here instead. This requires the RxCheck API key be placed in the
environment prior to running this function, for example as ENV["RXCHECK_API_KEY"]. A 
limited-use (100x/month) API key can be obtained from RxCheck.dev for free use as of 2026.

Returns a `Vector` of `NamedTuple`s as in (drug1, drug2, severity, description)
"""
function interaction_within_list(namelist::Vector{String})
    try
        for (i, name) in enumerate(namelist)
            if is_in_rxcui_format(name)
                namelist[i] = name(name)
            end
        end
        listing = join(map(x -> HTTP.URIs.escapeuri(x), namelist), ",")
        interactions = NamedTuple[]
        json = getjson("interactionlist", listing; headers = RXCHECK_API_HEADER)
        @show json
        return interactions
    catch y
        @warn y
        return nothing
    end
end
