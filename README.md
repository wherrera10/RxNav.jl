# RxNav.jl
Julia interface to the National Library of Medicine's online pharmaceutical RxNav API

<img src="https://github.com/wherrera10/RxNav.jl/blob/main/docs/src/RXNavLogo.png">

## General Use Functions

These functions are derived from the API, but are specialized and have been modified
for ease of use. For example, the functions may take either a drug name or an NDC
identifier as argument.

<br /><br />

    rcui(name)

Take a name of an NDC drug, return its rxcui as String.
<br /><br /><br />

    drugs(name)

Given a drug name, return a list of all available dosing forms of the drug.
<br /><br /><br />

    interaction(id; ONCHigh = true)
Given a drug name or rxcui id string, return known drug interations for that drug.
If ONCHigh is true only return the ONCHigh database entries, which returns fewer
entries, tending to list only the more significant interactions. Set ONCHigh
to false to get all known interactions, which can be multiple and sometimes redundant.
<br /><br /><br />

    interaction_within_list(idlist::Vector{String})

Given a list of drug names or rxcui id strings, return known drug interations for 
that combination of drugs. Results are organized pairwise, so if A, B, and C have
mutual interactions this will be reported for example as A with B, A with C, B with C.
<br /><br /><br />

## API functions

Note: There are two different RxNorm databases.  The more complete one, RxNorm, contains
medications including vetinary-use-only medications and medications no longer in use or
which are not available in United States pharmacies. The Julia functions default to this
database. In order to confine search results to generally available human medications,
the RxNorm database also supports the "Prescribable" RxNorm API, which gives results only
within medications currently available for medical presciption in the US. If you want the
"Prescribable" database used for your RxNorm API calls, you should first call the function 
<br /><br />
    prescribable(true)
<br /><br />
after which all calls to the RxNorm API will use the somewhat smaller Prescribable database.
To set this back to using the more general database, call `prescribable(false)`.
<br /><br /><br />

### RxClass API

<br />

See <link>https://rxnav.nlm.nih.gov/RxClassAPIs.html</link>, as copied below:

<br />

| Function | REST Resource | Description |
| ---      |     ---       |   ---      |
findClassByName | /class/byName | Drug classes with a specified class name
findClassesById | /class/byId | Drug classes with a specified class identifier
findSimilarClassesByClass | /class/similar | Classes with similar clinically-significant RxNorm ingredients
findSimilarClassesByDrugList | /class/similarByRxcuis | Classes with clinically-significant RxNorm ingredients similar to a specified list
getAllClasses | /allClasses | All classes (may limit by class type)
getClassByRxNormDrugId | /class/byRxcui | Classes containing a specified drug RXCUI
getClassByRxNormDrugName | /class/byDrugName | Classes containing a drug of the specified name
getClassContexts | /classContext | Paths from the specified class to the root of its class hierarchies
getClassGraphBySource | /classGraph | Classes along the path from a specified class to the root of a class hierarchy
getClassMembers | /classMembers | Drug members of a specified class
getClassTree | /classTree | Subclasses or descendants of the specified class
getClassTypes | /classTypes | Class types
getRelas | /relas | Relationships expressed by a source of drug relations
getSimilarityInformation | /class/similarInfo | Similarity of the clinically-significant membership of two classes
getSourcesOfDrugClassRelations | /relaSources | Sources of drug-class relations
getSpellingSuggestions | /spellingsuggestions | Drug or class names similar to a given string

<br /><br />

    findClassByName(classname::String, types::Vector{String} = String[])

Get drug classes with a specified class name
<br /><br />

    findClassesById(classid::String)

Get drug classes with a specified class identifier
<br /><br />

    findSimilarClassesByClass(classid::String, relasource::String, extra=[])
    
Get classes with similar clinically-significant RxNorm ingredients
<br /><br />

    findSimilarClassesByDrugList(rxcuis::Vector{String}, extra=[])

Get classes with clinically-significant RxNorm ingredients similar to a specified list
<br /><br />

    getAllClasses(classtypes::Vector{String}=String[])

Get all classes (may limit by class type with optional argument)
<br /><br />

    getClassByRxNormDrugId(rxcui::String, extras = [])

Get classes containing a specified drug RXCUI
<br /><br />

    getClassByRxNormDrugName(drugname::String, extras = [])

Get classes containing a drug of the specified name
<br /><br />

    getClassContexts(classid::String)
    
Get name and type context for paths from the specified class to the root of its class hierarchies
<br /><br />

    getClassGraphBySource(classId, source="")
    
Get classes along the path from a specified class to the root of a class hierarchy
<br /><br />


    getClassMembers(classid::String, source::String="")
    
Get drug members of a specified class
<br /><br />

    getClassTree(classid::String, type="")
    
Get subclasses or descendants of the specified class
<br /><br />

    getClassTypes()

Get class types
<br /><br />

    getRelas()
    
Get relationships expressed by a source of drug relations
<br /><br />

    getSimilarityInformation(id1, source1, id2, source2, extras=[])

Get similarity of the clinically-significant membership of two classes by id and source
<br /><br />

    getSourcesOfDrugClassRelations()
    
Get sources of drug-class relations
<br /><br />

    getSpellingSuggestions(term::String, type="")

Get drug or class names similar to a given string
<br /><br />

<br />

### RxNorm API

<br />

See <link>https://rxnav.nlm.nih.gov/RxNormAPIs.html</link>, as copied below:

<br />

| Function | REST Resource | Description |
| ---      |     ---       |   ---      |
filterByProperty | /rxcui/rxcui/filter | Concept RXCUI if the predicate is true | Active
findRxcuiById | /rxcui?idtype=...&id=... | Concepts associated with a specified identifier | Active or Current
findRxcuiByString | /rxcui?name=... | Concepts with a specified name | Active or Current
getAllConceptsByStatus | /allstatus | Concepts having a specified status | Current and Historical
getAllConceptsByTTY | /allconcepts | Concepts having a specified term type | Active
getAllHistoricalNDCs | /rxcui/rxcui/allhistoricalndcs | National Drug Codes (NDC) ever associated with a concept | Current and Historical
getAllNDCs (Deprecated) | /rxcui/rxcui/allndcs | National Drug Codes (NDC) associated with a concept | Current
getAllNDCsByStatus | /allNDCstatus | NDCs having a specified NDC status | Current and Historical
getAllProperties | /rxcui/rxcui/allProperties | Concept details | Active
getAllRelatedInfo | /rxcui/rxcui/allrelated | Concepts related directly or indirectly to a specified concept | Active
getApproximateMatch | /approximateTerm | Concept and atom IDs approximately matching a query | Active or Current
getDisplayTerms | /displaynames | Strings to support auto-completion in a user interface | Active
getDrugs | /drugs | Drugs related to a specified name | Active
getIdTypes | /idtypes | Identifier types | Current
getMultiIngredBrand | /brands | Brands containing specified ingredients | Active
getNDCProperties | /ndcproperties | National Drug Code (NDC) details | Active
getNDCStatus | /ndcstatus | Status of a National Drug Code (NDC) | Current and Historical
getNDCs | /rxcui/rxcui/ndcs | National Drug Codes (NDC) associated with a concept | Active
getPropCategories | /propCategories | RxNav property categories | Active
getPropNames | /propnames | Property names | Active
getProprietaryInformation | /rxcui/rxcui/proprietary | Strings from sources that require a UMLS license | Current
getRelaTypes | /relatypes | RxNorm Relationship types | Active
getRelatedByRelationship | /rxcui/rxcui/related?rela=... | Concepts directly related to a specified concept by a specified relationship | Active
getRelatedByType | /rxcui/rxcui/related?tty=... | Concepts of specified types that are directly or indirectly related to a specified concept | Active
getRxConceptProperties | /rxcui/rxcui/properties | Concept name, TTY, and a synonym | Active
getRxNormName | /rxcui/rxcui | Name of a concept | Active
getRxNormVersion | /version | RxNorm data set and API versions | Current
getRxProperty | /rxcui/rxcui/property | A property of a concept | Active
getRxcuiHistoryStatus | /rxcui/rxcui/historystatus | Status, history, and other attributes of a concept | Current and Historical
getSourceTypes | /sourcetypes | Vocabulary sources | Current
getSpellingSuggestions | /spellingsuggestions | Strings similar to a specified string | Active
getTermTypes | /termtypes | Term types | Active

<br /><br />

    filterByProperty(rxcui::String, propName::String, propValues::Vector{String} = [])
   
Returns true if rxcui has the propName property (and fits optional propValues criteria if given)
<br /><br />

    findRxcuiById(idtype::String, id::String, allsrc = 0)
    
Get concepts associated with a specified identifier
<br /><br />

    findRxcuiByString(name::String, extras=[])

Get concepts with a specified name	Active or Current
<br /><br />

    getAllConceptsByStatus(status = "ALL")

Get concepts having a specified status
<br /><br />

    getAllConceptsByTTY(tty::Vector{String})

Get concepts having a specified term type (tty)
<br /><br />

    getAllHistoricalNDCs()

Get National Drug Codes (NDC) ever associated with a concept
<br /><br />

    getAllNDCsByStatus(status = "ALL")

NDCs having a specified NDC status
<br /><br />

    getAllProperties(rxcui, properties = ["ALL"])

Get concept details
<br /><br />

    getAllRelatedInfo(rxcui::String)

Get concepts related directly or indirectly to a specified concept (rxcui)
<br /><br />

    getApproximateMatch(term::String, extras = [])

Get concept and atom IDs approximately matching a query
<br /><br />

    getDisplayTerms()

Get strings to support auto-completion, as used in a user interface
<br /><br />

    getDrugs(name::String)

Get drugs related to a specified name
<br /><br />

    getIdTypes()

Get identifier types
<br /><br />

    getMultiIngredBrand(ingredientids::Vector{String})

Get brands containing specified ingredients
<br /><br />

    getNDCProperties(value::String)

Get National Drug Code (NDC) details
<br /><br />

    getNDCStatus(ndc::String, extras = [])

Get status of a National Drug Code (NDC)
<br /><br />

    getNDCs(rxcui::String)

Get National Drug Codes (NDC) associated with a concept
<br /><br />

    getPropCategories()

Get RxNav property categories
<br /><br />

    getPropNames()

Get property names
<br /><br />

    getProprietaryInformation(rxcui::String, ticket::String, extras = [])

Get strings from sources that require a UMLS license
<br /><br />

    getRelaTypes()

Get RxNorm Relationship types
<br /><br />

    getRelatedByRelationship(rxcui::String, relata::Vector{String})

Get concepts directly related to a specified concept by a specified relationship
<br /><br />

    getRelatedByType(rxcui::String, ttys::Vector{String})

Get concepts of specified types that are directly or indirectly related to a specified concept
<br /><br />

    getRxConceptProperties(rxcui::String)

Get concept name, TTY, and a synonym
<br /><br />

    getRxNormName(rxcui::String)

Get name of a concept
<br /><br />

    getRxNormVersion()

Get	RxNorm data set and API versions
<br /><br />

    getRxProperty(rxcui::String, propname::String)

Get a property of a concept
<br /><br />

    getRxcuiHistoryStatus(rxcui::String)

Get XML for status, history, and other attributes of a concept
Note: as the XML content labels vary, this function returns the metadata in XML form.
<br /><br />

    getSourceTypes()

Get vocabulary sources
<br /><br />

    getSpellingSuggestions(phrase::String)

Get strings similar to a specified string
<br /><br />

    getTermTypes()

Get term types
<br /><br />

<br />

### RxTerms API

<br />

See <link>https://rxnav.nlm.nih.gov/RxTermsAPIs.html</link>, as copied below:

<br />

| Function | REST Resource | Description |
| ---      |     ---       |   ---      |
getAllConcepts | /allconcepts | All RxTerms concepts
getAllRxTermInfo | /rxcui/rxcui/allinfo | RxTerms information for a specified RxNorm concept
getRxTermDisplayName | /rxcui/rxcui/name | RxTerms display name for a specified RxNorm concept
getRxTermsVersion | /version | RxTerms version

<br /><br />

    getAllConcepts()

Get all RxTerms concepts
<br /><br />

    getAllRxTermInfo(rxcui::String)

Get RxTerms information for a specified RxNorm concept
Returns the (quite variable) properties data in XML form.
<br /><br />

    getRxTermDisplayName(rxcui::String)

Get	RxTerms display name for a specified RxNorm concept
<br /><br />

    getRxTermsVersion()

Get RxTerms version
<br /><br />

<br />

### Drug Interaction API

<br />

See <link>https://rxnav.nlm.nih.gov/RxTermsAPIs.html</link>, as copied below:

<br />

| Function | REST Resource | Description |
| ---      |     ---       |   ---      |
findDrugInteractions | /interaction | Interactions of an RxNorm drug
findInteractionsFromList | /list | Interactions between a list of drugs
getInteractionSources | /sources | Sources of the interactions
getVersion | /version | Version of the data set(s)

<br /><br />

    findDrugInteractions(rxcui::String, extras = [])

Get interactions of an RxNorm drug with other items in the RxNorm database.
<br /><br />

    findInteractionsFromList(rxcuis::Vector{String}, extras = [])
    
Get pairwise interactions between items in a list of drugs
<br /><br />

    getInteractionSources()
    
Get sources of the interactions
<br /><br />

    getVersion()
    
Get version of the data set(s)
<br /><br />

<br />

## Installation

<br />

You may install the package from Github in the usual way, or to install the current master copy:
    
    using Pkg
    Pkg.add("http://github.com/wherrera10/RxNav.jl")
    
<br />
