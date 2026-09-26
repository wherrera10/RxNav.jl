using RxNav
using Test

@testset "RxNav Tests" begin
    @test rxcui("ibuprofen") == "5640"
    @test name(1191) == "aspirin"
    @test contains(first(drugs("naproxen")), "Oral")

end

@testset "RxClass Tests" begin
    @test RxNav.findClassByName("antihypertensives") == ["C02"]
    @test RxNav.findClassByName("beta blocking agents") == ["C07", "C07A", "S01ED"]
    @test RxNav.findClassesById("C02") == ["ANTIHYPERTENSIVES"]
    @test RxNav.findClassesById("C08") == ["CALCIUM CHANNEL BLOCKERS"]
end

@testset "Spelling Suggestions" begin
    @test getSpellingSuggestions("nortriptelene") == ["nortriptyline"]
    @test getSpellingSuggestions("asetaminifen") == ["acetaminophen"]
end

# Note: the NLM RxNav interactions database was taken offline in 2023
# The database at RxCheck.dev is now used for interactions.
# The  RxCheck API key should be placed in ENV as "RXCHECK_API_KEY" => "rxck_live_your_key_here"
# The testing first checks for the API key (as assigned by RxNav.jl to ENV_RXCHECK_API_KEY)
# and runs the testset below if found, but otherwise skips this testset.
if !isempty(ENV_RXCHECK_API_KEY)
    @testset "Interactions Tests" begin
        @test contains(last(interaction("61148"; ONCHigh = false)).description, "creased")
        @test first(interaction("sumatriptan")).severity == "high"
        @test contains(
            last(interaction_within_list(["207106", "656659"])).description, "metabolism",
        )
        @test last(interaction_within_list(["divalproex", "lamotrigine"])).severity == "N/A"
    end
else
    @info """
    ENV["RXCHECK_API_KEY"] not found. Interactions function tests are being skipped.
    To enable interaction functions, set the RXCHECK_API_KEY environment variable.
    Example: export RXCHECK_API_KEY='your_api_key_here'
    An API key for the interactions may be obtained from the RxCheck.dev website.
    """
end

true
