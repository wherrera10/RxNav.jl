using RxNav
using Test

@testset "RxNav.jl" begin

    @testset "Core RxNav functions" begin
        @test rxcui("ibuprofen") == "5640"
        @test rxcui("aspirin") == "1191"
        @test rxcui("acetaminophen") == "161"

        @test name(1191) == "aspirin"
        @test name("1191") == "aspirin"
        @test name(5640) == "ibuprofen"

        @test rxcui("") === nothing
        @test rxcui("this-is-not-a-real-drug-name") === nothing
        @test name("999999999") === nothing

        naproxen = drugs("naproxen")
        @test naproxen isa Vector{String}
        @test !isempty(naproxen)
        @test any(contains(x, "Oral") for x in naproxen)

        @test drugs("this-is-not-a-real-drug-name") === nothing
    end

    @testset "Spelling suggestions" begin
        @test getSpellingSuggestions("nortriptelene") == ["nortriptyline"]
        @test getSpellingSuggestions("asetaminiphen") == ["acetaminophen"]
        @test getSpellingSuggestions("unikorn") == String[]

        suggestions = getSpellingSuggestions("ibuprofn")
        @test suggestions isa Vector{String}
        @test "ibuprofen" in suggestions
    end

    @testset "Interactions" begin
        result = interactions("612")

        @test result isa Vector
        @test !isempty(result)
        @test any(t -> t.drug2 == "Cefuroxime", result)

        for t in result
            @test hasproperty(t, :drug1)
            @test hasproperty(t, :drug2)
            @test hasproperty(t, :is_severe)
            @test hasproperty(t, :description)
            @test hasproperty(t, :source)
            @test t.drug1 isa AbstractString
            @test t.drug2 isa AbstractString
            @test t.description isa AbstractString
            @test t.source isa AbstractString
        end

        pair = interactions("INSULIN", "PROPRANOLOL")
        @test !isempty(pair)
        @test contains(first(pair).description, "self-monitoring of blood glucose")

        @test interactions("insulin", "propranolol") == pair
        @test interactions(" insulin ", " propranolol ") == pair

        reverse_pair = interactions("PROPRANOLOL", "INSULIN")
        @test reverse_pair == pair

        one = interactions(["insulin"])
        @test one == interactions("insulin")

        two = interactions(["insulin", "propranolol"])
        @test two == pair

        @test interactions(String[]) == NamedTuple[]

        three = interactions(["fluconazole", "PROGESTERONE", "haloperidol"])
        @test length(three) == 3

        four = interactions("10689", "7052", "7804", "3288")
        @test length(four) == 6
        @test all(t -> startswith(t.source, "DrugBank"), four)

        @test interactions("10689", "7052", "7804", "3288") ==
            interactions(["10689", "7052", "7804", "3288"])

        severe = interactions("INSULIN", "PROPRANOLOL"; severeonly = true)
        @test length(severe) <= length(pair)
        @test all(t -> t.is_severe === true, severe)

        all_insulin = interactions("INSULIN")
        severe_insulin = interactions("INSULIN"; severeonly = true)
        @test length(severe_insulin) <= length(all_insulin)
        @test all(t -> t.is_severe === true, severe_insulin)

        duplicated = interactions(["insulin", "propranolol", "insulin"])
        @test unique(duplicated) == unique(pair)
        @test length(duplicated) == length(unique(duplicated))
    end

    @testset "RxNorm lookup and concept functions" begin
        @test RxNav.findRxcuiByString("aspirin") == "1191"

        ids = RxNav.findRxcuiById("NDC", "00904629161")
        @test ids isa Vector{String}
        @test "617310" in ids

        props = RxNav.getRxConceptProperties(
            "1191",
        ) # https://rxnav.nlm.nih.gov/REST/Prescribe/rxcui/1191/properties
        @test props !== nothing
        @test props.name == "aspirin"
        @test !isempty(props.tty)
        @test !isempty(props.language)
        @test !isempty(props.suppress)

        concept = RxNav.getRxNormName("1191")
        @test concept !== nothing
        @test concept.rxnormId == "1191"
        @test concept.name == "aspirin"

        @test RxNav.getRxNormName("999999999") === nothing
        @test RxNav.getRxConceptProperties("999999999") === nothing

        version = RxNav.getRxNormVersion()
        @test version !== nothing
        @test !isempty(version.version)
        @test !isempty(version.apiVersion)

        history = RxNav.getRxcuiHistoryStatus("1191")
        @test history isa AbstractString
        @test !isempty(history)
    end

    @testset "RxNorm metadata lists" begin
        idtypes = RxNav.getIdTypes()
        @test idtypes isa Vector{String}
        @test !isempty(idtypes)
        @test "USP" in idtypes

        propcategories = RxNav.getPropCategories()
        @test propcategories isa Vector{String}
        @test !isempty(propcategories)

        propnames = RxNav.getPropNames()
        @test propnames isa Vector{String}
        @test !isempty(propnames)

        relatypes = RxNav.getRelaTypes()
        @test relatypes isa Vector{String}
        @test !isempty(relatypes)

        sourcetypes = RxNav.getSourceTypes()
        @test sourcetypes isa Vector{String}
        @test !isempty(sourcetypes)

        termtypes = RxNav.getTermTypes()
        @test termtypes isa Vector{String}
        @test !isempty(termtypes)

        displayterms = RxNav.getDisplayTerms()
        @test displayterms isa Vector{String}
        @test length(displayterms) > 20_000
    end

    @testset "RxNorm properties and relationships" begin
        properties = RxNav.getAllProperties("1191")
        @test properties isa Vector
        @test !isempty(properties)
        @test any(t -> t.category == "NAMES" && t.value == "aspirin", properties)
        @test all(
            hasproperty(x, :category) && hasproperty(x, :name) && hasproperty(x, :value)
            for x in properties
        )

        related = RxNav.getAllRelatedInfo("1191")
        @test related isa Vector
        @test !isempty(related)
        @test all(hasproperty(x, :rxcui) && hasproperty(x, :name) for x in related)

        property = RxNav.getRxProperty("1191", "ATC")
        @test property !== nothing
        @test hasproperty(property, :category)
        @test hasproperty(property, :name)
        @test hasproperty(property, :value)

        related_by_type = RxNav.getRelatedByType("1191", ["IN"])
        @test related_by_type isa Vector
        @test all(
            hasproperty(x, :rxcui) && hasproperty(x, :name) && hasproperty(x, :synonym)
            for x in related_by_type
        )

        related_by_rela = RxNav.getRelatedByRelationship("174742", ["tradename_of"])
        @test related_by_rela isa Vector
        @test all(hasproperty(x, :rxcui) && hasproperty(x, :name) for x in related_by_rela)
    end

    @testset "RxNorm drug and approximate matching" begin
        drugs_result = RxNav.getDrugs("naproxen")
        @test drugs_result isa Vector
        @test !isempty(drugs_result)
        @test all(hasproperty(x, :rxcui) && hasproperty(x, :name) for x in drugs_result)
        @test any(startswith(x.name, "naproxen sodium") for x in drugs_result)

        approximate = RxNav.getApproximateMatch("ibuprofn")
        @test approximate isa Vector
        @test !isempty(approximate)
        @test all(hasproperty(x, :rxcui) && hasproperty(x, :rxaui) for x in approximate)
        @test any(x -> x.rxcui == "5640", approximate)
    end

    @testset "RxNorm NDC functions" begin
        ndcs = RxNav.getNDCs("213269")
        @test ndcs isa Vector{String}
        @test !isempty(ndcs)

        ndc = first(ndcs)

        ndc_properties = RxNav.getNDCProperties(ndc)
        @test ndc_properties isa Vector
        @test all(hasproperty(x, :name) && hasproperty(x, :value) for x in ndc_properties)

        ndc_status = RxNav.getNDCStatus(ndc)
        @test ndc_status isa Vector
        @test all(
            hasproperty(x, :active) &&
                hasproperty(x, :original) &&
                hasproperty(x, :startdate) &&
                hasproperty(x, :enddate)
            for x in ndc_status
        )
    end

    @testset "RxClass basic lookup" begin
        @test RxNav.findClassByName("antihypertensives") == ["C02"]
        @test RxNav.findClassByName("beta blocking agents") == ["C07", "C07A", "S01ED"]

        @test RxNav.findClassesById("C02") == ["ANTIHYPERTENSIVES"]

        @test RxNav.findClassesById("C08") == ["CALCIUM CHANNEL BLOCKERS"]

        @test RxNav.findClassByName("this-is-not-a-real-class") == String[]
        @test RxNav.findClassesById("NOT_A_CLASS") == String[]
    end

    @testset "RxClass metadata" begin
        class_types = RxNav.getClassTypes()
        @test class_types isa Vector{String}
        @test !isempty(class_types)

        sources = RxNav.getSourcesOfDrugClassRelations()
        @test sources isa Vector{String}
        @test !isempty(sources)
    end

    @testset "RxClass drug lookup" begin
        by_id = RxNav.getClassByRxNormDrugId("1191")
        @test by_id isa Vector
        @test !isempty(by_id)
        @test all(hasproperty(x, :name) && hasproperty(x, :type) for x in by_id)

        by_name = RxNav.getClassByRxNormDrugName("aspirin")
        @test by_name isa Vector
        @test !isempty(by_name)
        @test all(hasproperty(x, :name) && hasproperty(x, :type) for x in by_name)
    end

    @testset "RxTerms" begin
        display_name = RxNav.getRxTermDisplayName("198440")
        @test display_name isa AbstractString
        @test !isempty(display_name)

        all_info = RxNav.getAllRxTermInfo("198440")
        @test all_info isa AbstractString
        @test !isempty(all_info)

        version = RxNav.getRxTermsVersion()
        @test version isa AbstractString
        @test !isempty(version)
    end

    @testset "Extended RxNorm tests" begin
        all_status = RxNav.getAllConceptsByStatus("ACTIVE")
        @test all_status isa Vector
        @test !isempty(all_status)
        @test all(x -> hasproperty(x, :rxcui) && hasproperty(x, :name), all_status)

        tty_concepts = RxNav.getAllConceptsByTTY(["IN"])
        @test tty_concepts isa Vector
        @test !isempty(tty_concepts)
        @test all(x -> hasproperty(x, :rxcui) && hasproperty(x, :name), tty_concepts)

        all_ndcs = RxNav.getAllNDCsByStatus("ACTIVE")
        @test all_ndcs isa Vector{String}
        @test !isempty(all_ndcs)

        historical_ndcs = RxNav.getAllHistoricalNDCs("351772")
        @test historical_ndcs isa Vector
        @test !isempty(historical_ndcs)
        @test all(
            x -> hasproperty(x, :ndc) &&
                hasproperty(x, :startDate) &&
                hasproperty(x, :endDate),
            historical_ndcs,
        )

        brands = RxNav.getMultiIngredBrand(["1191"])
        @test brands isa Vector
        @test all(x -> hasproperty(x, :rxcui) && hasproperty(x, :name), brands)

        filter_result = RxNav.filterByProperty("1191")
        @test filter_result isa Bool
    end

    @testset "Extended RxTerms tests" begin
        all_concepts = RxNav.getAllConcepts()
        @test all_concepts isa Vector
        @test !isempty(all_concepts)
        @test all(length(x) == 3 for x in all_concepts)
        @test all(all(y -> y isa String, x) for x in all_concepts)
    end

    @testset "Extended RxClass tests" begin
        all_classes = RxNav.getAllClasses()
        @test all_classes isa Vector
        @test !isempty(all_classes)
        @test all(x -> hasproperty(x, :name) && hasproperty(x, :type), all_classes)

        contexts = RxNav.getClassContexts("C02")
        @test contexts isa Vector
        @test !isempty(contexts)
        @test all(x -> hasproperty(x, :name) && hasproperty(x, :type), contexts)

        tree = RxNav.getClassTree("C02")
        @test tree isa Vector
        @test !isempty(tree)
        @test all(x -> hasproperty(x, :name) && hasproperty(x, :type), tree)

        members = RxNav.getClassMembers("N0000008638")
        @test members isa Vector
        @test !isempty(members)
        @test all(x -> hasproperty(x, :rxcui) && hasproperty(x, :name), members)

        relas = RxNav.getRelas()
        @test relas isa Vector{String}
        @test !isempty(relas)
    end

    @testset "RxClass regression tests" begin
        graph = RxNav.getClassGraphBySource("C02")
        @test graph isa Vector
        @test !isempty(graph)
        @test all(
            x -> hasproperty(x, :id) && hasproperty(x, :name) && hasproperty(x, :type),
            graph,
        )

        similar_classes = RxNav.findSimilarClassesByDrugList(["1191"])
        @test similar_classes isa Vector
        @test all(x -> hasproperty(x, :name) && hasproperty(x, :classid), similar_classes)
    end
end

true
