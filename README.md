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
(To set this back to using the more general database, call `prescribable(false)` ).
<br /><br /><br />

### RxClass API

### RxNorm API

### RxTerms API

### Drug Interaction API





## Installation

