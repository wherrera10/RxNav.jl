#  part of RxNav.jl

""" URI_DICT is a Dict of RxNav REST or RxCheck v1 urls keyed by strings. """
const URI_DICT = Dict(
    "baseurl" => "https://rxnav.nlm.nih.gov/REST/",
    "rxcui" => "https://rxnav.nlm.nih.gov/REST/rxcui?name=",
    "name" => "https://rxnav.nlm.nih.gov/REST/rxcui/",
    "drugs" => "https://rxnav.nlm.nih.gov/REST/drugs?name=",
    "interactions" => "https://api.rxcheck.dev/v1/drugs/",
    "interactionpair" => "https://api.rxcheck.dev/v1/interactions?",
    "polypharmacy" => "https://api.rxcheck.dev/v1/interactions/polypharmacy?drugs=",
)

"""
    getdoc(urlkey, arg)

get the XML document found by the string formed by: RESTuri[urlkey] * (the urltail)
"""
function getdoc(urlkey, arg)
    req = HTTP.get(URI_DICT[urlkey] * arg)
    return parsexml(String(req.body)).root
end

"""
    getjson(urlkey, urltail, APIKEY = "")

Get the JSON document found by the string formed by: uri, arg.
Optionally add headers as a vector of Pairs to the request
"""
function getjson(urlkey, arg; headers= Pair{String,String}[])
    if isempty(headers)
        req = HTTP.get(URI_DICT[urlkey] * arg)
    else
        req = HTTP.get(URI_DICT[urlkey] * arg; headers = headers)
    end
    return JSON.parse(String(req.body))
end

"""
    is_in_rxcui_format(s)

Tests whether the string is in the format for an RxNav rxcui identifier.
Currently rxcui identifiers are composed of only digits 0 through 9,
though there is nothing in the schema that says these must be only digits.
If that changes in future RxNav updates, the parsing here may also change.
"""
is_in_rxcui_format(s) = all(c -> c in "0123456789", s)

"""
    morearg(name, value)

Return further arguments to the REST query of the form "&name=value"
or if values is a vector, of the form "&name=val1+val2+val3"
Starts with &, not ?, so there must be a prior argument in the url string.
"""
morearg(name::String, value::String) = "&$name=$(HTTP.URIs.escapeuri(value))"
morearg(name::String, values::Vector{String}) = "&$name=" * join(values, "+")

"""
    morearg(pairs)

Return further arguments to the REST query of the form "&name=value&name2=value2",
etc, where pairs is a vector of [name, value] pairs. Starts with &, not ?,
so there must be a prior argument in the url string.
"""
morearg(pairs::Vector) = reduce(*, morearg(a[1], a[2]) for a in pairs)
morearg(d::Dict) = morearg(collect(d))
