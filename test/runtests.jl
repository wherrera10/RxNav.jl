using RxNav
using Test

@test rcui("ibuprofen") == "5640"

@test contains(first(drugs("naproxen")), "Oral")

@test contains(last(interaction("61148"; ONCHigh = false)).description, "creased")

@test first(interaction("sumatriptan")).severity == "high"

@test contains(last(interaction_within_list(["207106", "656659"])).description, "metabolism")

@test last(interaction_within_list(["divalproex", "lamotrigine"])).severity == "N/A" 
