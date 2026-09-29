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
    @test getSpellingSuggestions("asetaminiphen") == ["acetaminophen"]
    @test getSpellingSuggestions("unikorn") == String[]
end

@testset "Interactions Tests" begin
    @test any(t -> t.drug2 == "Cefuroxime", interactions("612"))
    @test contains(
        first(interactions("INSULIN", "PROPRANOLOL")).description,
        "self-monitoring of blood glucose",
    )
    @test length(interactions(["fluconazole", "PROGESTERONE", "haloperidol"])) == 3
    inters = interactions("10689", "7052", "7804", "3288")
    @test length(inters) == 6
    @test all(t -> startswith(t.source, "DrugBank"), inters)
end

true
