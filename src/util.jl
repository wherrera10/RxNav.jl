#  github: part of RxNav.jl

export prescribeable

const PRESCRIBEABLE = [true]

prescribeable() = PRESCRIBEABLE[1]

""" set whether to use Prescribeable database or entire database including items no longer available """
prescribeable(tf) = begin PRESCRIBEABLE[1] = tf end

""" get the base url for RxNorm, default is the Prescribeable RxNorm set. """
baseurl() = prescribeable() ? "prescribeable" : "baseurl"

""" RESTuri is a Dict of RxNav REST urls keyed by strings. """
const RESTuri = Dict(
    "baseurl" => "https://rxnav.nlm.nih.gov/REST/",
    "prescribeable" => "https://rxnav.nlm.nih.gov/REST/Prescribe/",
    "rcui" => "https://rxnav.nlm.nih.gov/REST/rxcui?name=",
    "drugs" => "https://rxnav.nlm.nih.gov/REST/drugs?name=",
    "interaction" => "https://rxnav.nlm.nih.gov/REST/interaction/interaction?rxcui=",
    "interactionlist" => "https://rxnav.nlm.nih.gov/REST/interaction/list?rxcuis=",
)

"""
    getdoc(urlkey, urltail)

get the document found by the string formed by: (the key indexed by urlkey) * (the urltail)
"""
function getdoc(urlkey, urltail)
    req = HTTP.request("GET", RESTuri[urlkey] * urltail)
    return root(parseXML(String(req.body)))
end

"""
    is_in_rxcui_format(s)

Tests whether the string is in the format for an RxNav rxcui identifier.
Currently rxcui identifiers are composed of only digits 0 through 9,
though there is nothing in the schema that says these must be only digits.
If that changes in future RxNav updates, the parsing here may also change.
"""
is_in_rxcui_format(s) = all(c -> c in "0123456789", collect(s))

"""
    morearg(name, value)

Return further arguments to the REST query of the form "&name=value"
or if values is a vector, of the form "&name=val1+val2+val3"
Starts with &, not $, so there must be a prior argument in the url string.
"""
morearg(name::String, value::String) = "&$name=$(HTTP.URIs.escapeuri(value))"
morearg(name::String, values::Vector{String}) = "&$name=" * join(values, "+")

"""
    morearg(pairs)

Return further arguments to the REST query of the form "&name=value&name2=value2",
etc, where pairs is a vector of [name, value] pairs. Starts with &, not $,
so there must be a prior argument in the url string.
"""
morearg(pairs::Vector) = reduce(*, morearg(a[1], a[2]) for a in pairs)
morearg(d::Dict) = query(collect(d))
