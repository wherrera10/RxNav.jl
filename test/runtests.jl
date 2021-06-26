using RxNav
using Test

@test rcui("ibuprofen") == "5640"
@test contains(drugs("naproxen"), "")
@test contains(interaction("61148", ONCHigh = false)[1], "")
@test contains(interaction("sumatriptan")[1], "")
@test contains(interaction_within_list(["207106", "656659"]))
@test contains(interaction_within_list(["divalproex", "lamotrigine"]))

    
