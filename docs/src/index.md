# RxNav.jl

Julia interface to the National Library of Medicine's online pharmaceutical RxNav API

![Description](assets//RXNavLogo.png)


    
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
        


    
## Functions Reference

See also the National Library of Medicine's [RxNorm API documentation](https://lhncbc-portal.lhcaws-prod-pub.nlm.nih.gov/RxNav/APIs/RxNormAPIs.html).
The database build methods used are shown at [PDDI_Interactions.jl](https://github.com/wherrera10/PDDI_InteractionFiles.jl).

```@index
```

```@autodocs
Modules = [RxNav]
```
