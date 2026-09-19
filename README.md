[![Build status](https://ci.appveyor.com/api/projects/status/cfw6pe03rfn9qsoo?svg=true)](https://ci.appveyor.com/project/wherrera10/RxNav.jl)
[![CI](https://github.com/wherrera10/RxNav.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/wherrera10/RxNav.jl/actions/workflows/CI.yml)

# RxNav.jl

Julia interface to the National Library of Medicine's online pharmaceutical RxNav API

<img src="https://github.com/wherrera10/RxNav.jl/blob/main/docs/src/assets/RXNavLogo.png">

## Examples
    
    julia> using RxNav
    
    julia> for i in interact("fentanyl", "selegiline")
               if i.severity == "high"
                   println(i.description)
               end
           end
    Narcotic analgesics - monoamine oxidase (MAO) inhibitors
    
    julia> println(RxNav.getSpellingSuggestions("nortriptelene"))
    ["nortriptyline", "Nortriptylina"]
    
    julia> RxNav.prescribable(true)
    true
    
    julia> println(RxNav.getSpellingSuggestions("nortriptelene"))
    ["nortriptyline"]
    
    julia> interact("1191", "warfarin", "vitamin K")
    3-element Vector{NamedTuple}:
     (drug1 = "aspirin", drug2 = "vitamin K", severity = "N/A", description = "Acetylsalicylic acid may decrease the excretion rate of Phylloquinone which could result in a higher serum level.")
     (drug1 = "aspirin", drug2 = "warfarin", severity = "N/A", description = "Acetylsalicylic acid may increase the anticoagulant activities of Warfarin.")
     (drug1 = "vitamin K", drug2 = "warfarin", severity = "N/A", description = "The therapeutic efficacy of Warfarin can be decreased when used in combination with Phylloquinone.")
    
    julia> filter(x -> occursin("Pediatric", x), drugs("riboflavin"))
    2-element Vector{String}:
     "alpha-tocopherol acetate 1.4 MG/ML / ascorbic acid 16 MG/ML / biotin 0.004 MG/ML / dexpanthenol 1 MG/ML / ergocalciferol 0.002 MG/ML / folic acid 0.028 MG/ML / niacinamide 3.4 MG/ML / pyridoxine hydrochloride 0.2 MG/ML / riboflavin 0.28 MG/ML / thiamine hydrochloride 0.24 MG/ML / vitamin A 0.14 MG/ML / vitamin B12 0.0002 MG/ML / vitamin K1 0.04 MG/ML Injectable Solution [MVI Pediatric]"
     "alpha-tocopherol acetate 1.4 UNT/ML / ascorbic acid 16 MG/ML / biotin 0.004 MG/ML / cholecalciferol 80 UNT/ML / dexpanthenol 1 MG/ML / folic acid 0.028 MG/ML / niacinamide 3.4 MG/ML / pyridoxine hydrochloride 0.2 MG/ML / riboflavin 0.28 MG/ML / thiamine hydrochloride 0.24 MG/ML / vitamin A palmitate 460 UNT/ML / vitamin B12 0.0002 MG/ML / vitamin K1 0.04 MG/ML Injectable Solution [Infuvite Pediatric]"
    


## General Use Functions

These functions are derived from the API, but are specialized and have been modified
for ease of use. For example, the functions may take either a drug name or an RxCUI
identifier as argument.


####    rcui(name)

Take a name of a drug as String argument, return its RxCUI as String.

####    drugs(name)

Given a drug name, return a list of all available dosing forms of the drug.

####    interact(list::Vector)
####    interact(s1::String, severeonly::Bool=true)
####    interact(s1::String, s2::String, args...)

Get a list of interactions for a single drug (or rxcui drug id) or pairwise interactions for more than one drug (or rxcuid).

####    interaction(id; ONCHigh = true)
    
Given a drug name or rxcui id string, return known drug interations for that drug.
If ONCHigh is true only return the ONCHigh database entries, which returns fewer
entries, tending to list only the more significant interactions. Set ONCHigh
to false to get all known interactions, which can be multiple and sometimes redundant.
Returns a `Vector` of `NamedTuple`s as in (drug1, drug2, severity, description).

####    interaction_within_list(idlist::Vector{String})

Given a list of drug names or rxcui id strings, return known drug interations for 
that combination of drugs. Results are organized pairwise, so if A, B, and C have
mutual interactions this will be reported for example as A with B, A with C, B with C.
Returns a `Vector` of `NamedTuple`s as in (drug1, drug2, severity, description)


## API functions

Note: There are two different RxNorm databases.  The more complete one, RxNorm, contains
medications including veterinary-use-only medications and medications no longer in use or
which are not available in United States pharmacies. The Julia functions default to this
database. In order to confine search results to generally available human medications,
the RxNorm database also supports the "Prescribable" RxNorm API, which gives results only
within medications currently available for medical prescription in the US. If you want the
"Prescribable" database used for your RxNorm API calls, you should first call the function 
''prescribable(true)'' after which all calls to the RxNorm API will use the somewhat smaller
Prescribable database. To reset, call `prescribable(false)`.

Some of the API functions take optional arguments. For details of the values for such arguments 
you should consult the NLM documentation (links are below). If the function takes an optional argument
called `extra`, this means that the function's optional argument `extra` should be provided as a `Dict`
or as a `Vector` of `Pairs`, with the keys to the Dict being the label for the optional term and the
values for that key as either a string or a vector of strings to be assigned to that value in the
final URL request. For example, `extra = Dict("sources" => ["ACTIVE", "OBSOLETE"], "toReturn" => 25)`
would be translated to `"&sources=ACTIVE+OBSOLETE&toReturn=25"` in the REST call request string sent by HTTP.

The list of API functions is extensive. The API function names are not exported from RxNav, so to call,
for example, `getSpellingSuggestions("asprin")` you must call this as `RxNav.getSpellingSuggestions("asprin")`.

### More documentation is at https://wherrera10.github.io/RxNav.jl/
