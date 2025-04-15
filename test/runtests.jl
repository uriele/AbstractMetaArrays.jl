using AbstractMetaArrays
using Test
using Aqua
using StructArrays
using StaticArrays

include("datastructuretest.jl")

@testset "AbstractMetaArrays.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(AbstractMetaArrays)
    end
    # Write your tests here.
end

@testset "helper functions" begin
    d1 = nothing
    d2 = Dict(:a => nothing, 1 => "a")
    d3 = Dict(:a => (nothing, :entry), 1 => ("a", :exit))
    d4 = Dict("a" => (nothing, :entry), "1" => ("a", :exit))
    empty_metadata = Dict{String, Tuple{Any, Symbol}}()
    default_metadata = Dict("a" => (nothing, :default), "1" => ("a", :default))
    full_metadata = Dict("a" => (nothing, :entry), "1" => ("a", :exit))

    colsym = (:x, :y, :z)
    empty_colsym = ()

    no_colmedata = Dict{Symbol, Dict{String, Tuple{Any, Symbol}}}()
    empty_colmetadata = Dict(
        :x => empty_metadata, :y => empty_metadata, :z => empty_metadata)
    default_colmetadata = Dict(
        :x => default_metadata, :y => default_metadata, :z => default_metadata)
    full_colmetadata = Dict(:x => full_metadata, :y => full_metadata, :z => full_metadata)

    mixed_colmetadata = Dict(
        :x => empty_metadata, :y => default_metadata, :z => full_metadata)

    @testset "_convert_dictkey_to_string" begin
        AbstractMetaArrays._convert_dictkey_to_string(d1) == empty_metadata
        AbstractMetaArrays._convert_dictkey_to_string(d2) == default_metadata
        AbstractMetaArrays._convert_dictkey_to_string(d3) == full_metadata
        AbstractMetaArrays._convert_dictkey_to_string(d4) == full_metadata
    end

    @testset "__create_colmeta" begin
        @test AbstractMetaArrays.__create_colmeta(empty_colsym, d1) == no_colmedata
        @test AbstractMetaArrays.__create_colmeta(empty_colsym, d2) == no_colmedata
        @test AbstractMetaArrays.__create_colmeta(empty_colsym, d3) == no_colmedata
        @test AbstractMetaArrays.__create_colmeta(empty_colsym, d4) == no_colmedata

        @test AbstractMetaArrays.__create_colmeta(colsym, d1) == empty_colmetadata
        @test AbstractMetaArrays.__create_colmeta(colsym, d2) == default_colmetadata
        @test AbstractMetaArrays.__create_colmeta(colsym, d3) == full_colmetadata
        @test AbstractMetaArrays.__create_colmeta(colsym, d4) == full_colmetadata
        @test AbstractMetaArrays.__create_colmeta(colsym, tuple(d1, d2, d3)) ==
              mixed_colmetadata
    end
end

@testset "arrays" begin
    @testset "comparisons" begin
        @test colmeta_simple ==
              colmeta_empty ==
              nocolmeta_simple ==
              nocolmeta_empty ==
              colmeta_simplestatic
        for metaarray in (
            colmeta_simple,
            colmeta_empty,
            nocolmeta_simple,
            nocolmeta_empty,
            colmeta_simplestatic
        )
            @test metaarray == simple
        end
        @test colmeta_test = nocolmeta_test == testst
    end

    @testset "copy" begin
        dst_colmeta_test = similar(colmeta_test)
        copyto!(dst_colmeta_test, colmeta_test)
        @test dst_colmeta_test == colmeta_test
        @test dst_colmeta_test._metadata == colmeta_test._metadata
        @test dst_colmeta_test._colmetadata == colmeta_test._colmetadata

        new_colmeta_test = copy(colmeta_test)
        @test new_colmeta_test == colmeta_test
        @test new_colmeta_test._metadata == colmeta_test._metadata
        @test new_colmeta_test._colmetadata == colmeta_test._colmetadata
    end

    @testset "type metatada" begin
        for metaarray in (colmeta_empty, colmeta_simple, colmeta_test, colmeta_simplestatic)
            @test typeof(metaarray._metadata) <: MetaType
            @test typeof(metaarray._metadata) == AbstractMetaArrays.ConcreteMetaType
            @test typeof(metaarray._colmetadata) <: Dict{Symbol, <:MetaType}
            @test typeof(metaarray._colmetadata) ==
                  Dict{Symbol, AbstractMetaArrays.ConcreteMetaType}
        end

        @testset "metadata" begin
            colmeta_local = copy(colmeta_simple)
            # metadata without col support
            metadata(colmeta_local) == _meta_empty
            @test metadata(colmeta_simplestatic; style = false) == _meta_default
            # change content metadata
            metadata!(colmeta_local, "description", "changed test array"; style = :entry)
            @test metadata(colmeta_local; style = true) == _meta_nodefault
            # add content metadata
            metadata!(colmeta_local, "normalized", true; style = :bool)
            @test metadata(colmeta_local; style = true) == _meta_nodefault2
            # remove content metadata
            deletemetadata!(colmeta_local, "normalized")
            @test metadata(colmeta_local; style = true) == _meta_nodefault
            # empty content metadata
            emptymetadata!(colmeta_local)
            @test metadata(colmeta_local; style = true) == _meta_empty
        end
    end

    @testset "colmetadata" begin
        colmeta_local = copy(colmeta_test)
        # colmetadata without col support
        colmetadata(colmeta_simple) == _colmeta_empty
        @test colmetadata(colmeta_simplestatic; style = true) ==
              Dict((:x, :y, :z) .=> _colmeta_static)
        # change column metadata
        colmetadata!(colmeta_local, :a, "unit", "km")
        colmetadata!(colmeta_local, :b, "unit", "km"; style = :entry)
        @test colmetadata(colmeta_local) != colmetadata(colmeta_test)
        @test colmetadata(colmeta_local; style = true) == _colmeta_changed
        # add column metadata
        colmetadata!(colmeta_local, :b, "normalized", true; style = :bool)
        @test colmetadata(colmeta_local; style = true) == _colmeta_changed2
        # remove column metadata
        deletecolmetadata!(colmeta_local, :b, "normalized")
        @test colmetadata(colmeta_local; style = true) == _colmeta_changed
        # empty column metadata
        emptycolmetadata!(colmeta_local)
        colmetadata(colmeta_local) == _colmeta_empty
    end

    @testset "StructArrays" begin
        @test propertynames(colmeta_test) == (:a, :b)
        @test propertynames(colmeta_simplestatic) == (:x, :y, :z)
        @test propertynames(colmeta_simple) == ()
    end
end

@testset "metadatasupport" begin
    woc = WriteOnlyColMetaArray([1])
    roc = ReadOnlyColMetaArray([1])
    wom = WriteOnlyMetaArray([1])
    rom = ReadOnlyMetaArray([1])

    @test colmetadatasupport(typeof(woc)) == (read = false, write = true)
    @test colmetadatasupport(typeof(roc)) == (read = true, write = false)
    @test metadatasupport(typeof(wom)) == (read = false, write = true)
    @test metadatasupport(typeof(rom)) == (read = true, write = false)
    @test metadatasupport(typeof(nocolmeta_simple)) == (read = true, write = true)
    @test metadatasupport(typeof(colmeta_simple)) == (read = true, write = true)

    @test_throws ArgumentError colmetadata(woc, :a)
    @test_throws ArgumentError colmetadatakeys(woc)
    @test_throws ArgumentError colmetadata!(roc, :a, "unit", "km")
    @test_throws ArgumentError emptycolmetadata!(roc)
    @test_throws ArgumentError deletecolmetadata!(roc, :a, "unit")

    @test_throws ArgumentError metadata(wom)
    @test_throws ArgumentError metadatakeys(wom)
    @test_throws ArgumentError metadata!(rom, "description", "test array")
    @test_throws ArgumentError emptymetadata!(rom)
    @test_throws ArgumentError deletemetadata!(rom, "description")

    @test_throws ArgumentError colmetadata(nocolmeta_simple)
end
