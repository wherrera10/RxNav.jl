using RxNav
using Test

@test rcui("ibuprofen") == "5640"
@test contains(first(drugs("naproxen")), "")
@test contains(first(interaction("61148", ONCHigh = false)), "")
@test contains(first(interaction("sumatriptan")), "")
@test contains(interaction_within_list(["207106", "656659"]), "")
@test contains(interaction_within_list(["divalproex", "lamotrigine"]), "")

    
