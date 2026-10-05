[![Build status](https://ci.appveyor.com/api/projects/status/cfw6pe03rfn9qsoo?svg=true)](https://ci.appveyor.com/project/wherrera10/RxNav.jl)
[![CI](https://github.com/wherrera10/RxNav.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/wherrera10/RxNav.jl/actions/workflows/CI.yml)

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
    ["nortriptyline"]
    
    julia> println(RxNav.getSpellingSuggestions("nortriptelene"))
    ["nortriptyline"]
    
    julia> interactions("diazepam")
    430-element Vector{NamedTuple}:
     (drug1 = "Sedative Medications", drug2 = "Diazepam", is_severe = false, description = "ASDEC - APEC Association not recommended: - with sodium oxybate.", source = "FrenchDDI,    translated, originally via Github")
     (drug1 = "Diazepam", drug2 = "Diazepam", is_severe = false, description = "Precaution for use: Warn patients of the increased risk when driving a car or operating machinery.", source = "FrenchDDI, translated, originally via Github")
     (drug1 = "Morphinics", drug2 = "Diazepam", is_severe = false, description = "To be taken into account: Increased risk of respiratory depression, which can be fatal in", source = "FrenchDDI, translated, originally via Github")
     (drug1 = "Alcohol (Beverage Or Excipient)", drug2 = "Diazepam", is_severe = true, description = "Association NOT RECOMMENDED Avoid consuming alcoholic beverages and medications containing alcohol.", source = "FrenchDDI, translated, originally via Github")
     (drug1 = "Diazepam", drug2 = "Diazepam", is_severe = false, description = "To be taken into account: Risk of increased side effects of buspirone.", source = "FrenchDDI, translated, originally via Github")
     (drug1 = "Clozapine", drug2 = "Diazepam", is_severe = false, description = "To be taken into account: Increased risk of collapse with respiratory and/or cardiac arrest.", source = "FrenchDDI, translated, originally via Github")
     ...
    
    julia> interactions("progesterone", "erythromycin", "morphine", "ibuprofen")
    2-element Vector{NamedTuple}:
     (drug1 = "Progesterone", drug2 = "Erythromycin", is_severe = "not given", description = "The metabolism of Erythromycin can be decreased when combined with Progesterone.", source = "DrugBank via Kaggle")
     (drug1 = "Morphine", drug2 = "Erythromycin", is_severe = "not given", description = "The metabolism of Erythromycin can be decreased when combined with Morphine.", source = "DrugBank via Kaggle")
    
    julia> filter(x -> occursin("Pediatric", x), drugs("riboflavin"))
    1-element Vector{String}:
     "alpha-tocopherol acetate 1.4 UN" ⋯ 342 bytes ⋯ " Solution [Infuvite Pediatric]"
        

## General Use Functions

These functions are derived from the API, but are specialized and have been modified
for ease of use. For example, the functions may take either a drug name or an RxCUI
identifier as argument.


####    rxcui(name)

Take a name of a drug as String argument, return its RxCUI as String.

####    drugs(name)

Given a drug name, return a list of all available dosing forms of the drug.

####    name(id)

Given an RxCUI id, return the drug name.

####    interactions(id; severeonly::Bool = false)
    
Given a drug name or rxcui id string, return known drug interations for that drug.
If severeonly is true only return entries marked as serious such as those in the ONCHigh database.
Returns a `Vector` of `NamedTuple`s as in (drug1, drug2, severity, description).

####    interactions(s1::AbstractString, s2::AbstractString; severeonly::Bool = false)
Given a two drug names or rxcui id strings, return known drug interations for those drugs.
If severeonly is true only return entries marked as serious such as those in the ONCHigh database.
Returns a `Vector` of `NamedTuple`s as in (drug1, drug2, severity, description).

####    interactions(idlist::Vector{String}; severeonly = false)

Given a list of drug names or rxcui id strings, return known drug interations for 
that combination of drugs. Results are organized pairwise, so if A, B, and C have
mutual interactions this will be reported for example as A with B, A with C, B with C.
Returns a `Vector` of `NamedTuple`s as in (drug1, drug2, severity, description)

## API functions

Some of the API functions take optional arguments. For details of the values for such arguments 
you should consult the NLM documentation (links are below). If the function takes an optional argument
called `extra`, this means that the function's optional argument `extra` should be provided as a `Dict`
or as a `Vector` of `Pairs`, with the keys to the Dict being the label for the optional term and the
values for that key as either a string or a vector of strings to be assigned to that value in the
final URL request. For example, `extra = Dict("sources" => ["ACTIVE", "OBSOLETE"], "toReturn" => 25)`
would be translated to `"&sources=ACTIVE+OBSOLETE&toReturn=25"` in the REST call request string sent by HTTP.

The list of API functions is extensive. The long API function names are not exported from RxNav, so to call,
for example, `getSourcesOfDrugClassRelations()` you must call this as `RxNav.getSourcesOfDrugClassRelations()`.


### More documentation is at https://wherrera10.github.io/RxNav.jl/
