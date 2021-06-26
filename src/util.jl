


morearg(name::String, value::String) = "?$name=$(HTTP.URIs.escapeuri(value))"
moreqarg(name::String, values::Vector{String}) = "?$name=" * join(values, "+")
morearg(pairs::Vector) = "?" * reduce(*, morearg(a[1], a[2]) for a in pairs)[2:end]
morearg(d::Dict) = query(collect(d))
