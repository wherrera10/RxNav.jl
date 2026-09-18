# RxNav.jl

Julia interface to the National Library of Medicine's online pharmaceutical RxNav API

![Description](assets//RXNavLogo.png)



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
    
    julia> interact("1191", "warfarin", "vitamin K")
    3-element Vector{NamedTuple}:
     (drug1 = "aspirin", drug2 = "vitamin K", severity = "N/A", description = "Acetylsalicylic acid may decrease the excretion rate of Phylloquinone which could result in a higher serum level.")
     (drug1 = "aspirin", drug2 = "warfarin", severity = "N/A", description = "Acetylsalicylic acid may increase the anticoagulant activities of Warfarin.")
     (drug1 = "vitamin K", drug2 = "warfarin", severity = "N/A", description = "The therapeutic efficacy of Warfarin can be decreased when used in combination with Phylloquinone.")
    
    julia> filter(x -> occursin("Pediatric", x), drugs("riboflavin"))
    2-element Vector{String}:
     "alpha-tocopherol acetate 1.4 MG/ML / ascorbic acid 16 MG/ML / biotin 0.004 MG/ML / dexpanthenol 1 MG/ML / ergocalciferol 0.002 MG/ML / folic acid 0.028 MG/ML / niacinamide 3.4 MG/ML / pyridoxine hydrochloride 0.2 MG/ML / riboflavin 0.28 MG/ML / thiamine hydrochloride 0.24 MG/ML / vitamin A 0.14 MG/ML / vitamin B12 0.0002 MG/ML / vitamin K1 0.04 MG/ML Injectable Solution [MVI Pediatric]"
     "alpha-tocopherol acetate 1.4 UNT/ML / ascorbic acid 16 MG/ML / biotin 0.004 MG/ML / cholecalciferol 80 UNT/ML / dexpanthenol 1 MG/ML / folic acid 0.028 MG/ML / niacinamide 3.4 MG/ML / pyridoxine hydrochloride 0.2 MG/ML / riboflavin 0.28 MG/ML / thiamine hydrochloride 0.24 MG/ML / vitamin A palmitate 460 UNT/ML / vitamin B12 0.0002 MG/ML / vitamin K1 0.04 MG/ML Injectable Solution [Infuvite Pediatric]"


## Installation

You may install the package from Github in the usual way, or to install the current master copy:
    
    using Pkg
    Pkg.add("http://github.com/wherrera10/RxNav.jl")
    
## Functions Reference
This block automatically extracts docstrings from your source code:

```@index
```

```@autodocs
Modules = [RxNav]
```
