using AbstractMetaArrays
using AbstractMetaArrays: ColMetadataTrait, NoColMetadata, HasColMetadata
using AbstractMetaArrays: _convert_dictkey_to_string, _create_colmeta
using LinearAlgebra
using Test
#using Aqua
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
  d1=nothing
  d2=Dict(:a=>nothing, 1=> "a")
  d3=Dict(:a=>(nothing,:entry), 1=> ("a",:exit))
  d4=Dict("a"=>(nothing,:entry), "1"=> ("a",:exit))
  empty_metadata   = Dict{String,Tuple{Any,Symbol}}()
  default_metadata = Dict("a" => (nothing, :default),"1"=>("a", :default))
  full_metadata    = Dict("a" => (nothing, :entry), "1"=>("a", :exit))

  colsym=(:x,:y,:z)
  empty_colsym=()

  no_colmedata=Dict{Symbol, Dict{<:AbstractString, Tuple{Any, Symbol}}}()
  empty_colmetadata=Dict(
    :x=> empty_metadata,
    :y=> empty_metadata,
    :z=> empty_metadata
  )
  default_colmetadata=Dict(
    :x=> default_metadata,
    :y=> default_metadata,
    :z=> default_metadata
  )
  full_colmetadata=Dict(
    :x=> full_metadata,
    :y=> full_metadata,
    :z=> full_metadata
  )

  mixed_colmetadata=Dict(
    :x=> empty_metadata,
    :y=> default_metadata,
    :z=> full_metadata
  )

  @testset "_convert_dictkey_to_string" begin
    _convert_dictkey_to_string(d1) == empty_metadata
    _convert_dictkey_to_string(d2) == default_metadata
    _convert_dictkey_to_string(d3) == full_metadata
    _convert_dictkey_to_string(d4) == full_metadata
  end

  @testset "__create_colmeta" begin
    AbstractMetaArrays.__create_colmeta(empty_colsym,d1) = no_colmedata
    AbstractMetaArrays.__create_colmeta(empty_colsym,d2) = no_colmedata
    AbstractMetaArrays.__create_colmeta(empty_colsym,d3) = no_colmedata
    AbstractMetaArrays.__create_colmeta(empty_colsym,d4) = no_colmedata

    AbstractMetaArrays.__create_colmeta(colsym,d1) == empty_colmetadata
    AbstractMetaArrays.__create_colmeta(colsym,d2) == default_colmetadata
    AbstractMetaArrays.__create_colmeta(colsym,d3) == full_colmetadata
    AbstractMetaArrays.__create_colmeta(colsym,d4) == full_colmetadata
    AbstractMetaArrays.__create_colmeta(colsym,tuple(d1,d2,d3))== mixed_colmetadata
  end
end


@testset "arrays"
  simple= [1,2,3]
  testst= [TestStruct(1,2), TestStruct(3,4)]
  _meta_default = Dict("description" => "test array")
  _meta_empty     = Dict{String,Tuple{<:Any,Symbol}}()
  _meta_nodefault = Dict{String,Tuple{<:Any,Symbol}}("description" => ("changed test array", :entry))
  _meta_nodefault2 = Dict{String,Tuple{<:Any,Symbol}}("description" => ("changed test array", :entry), "normalized" => (true, :bool))

  _colmeta_test = (Dict("unit" => ("m", :default)),
                  Dict("unit" => ("km", :entry)))
  _colmeta_static=(Dict("unit" => ("m", :default)),
                  Dict("unit" => ("km", :entry)),
                  Dict("unit" => ("cm", :entry)))

  _colmeta_empty= Dict{Symbol, Dict{String, Tuple{Any, Symbol}}}()
  _colmeta_changed = Dict{Symbol, Dict{String, Tuple{Any, Symbol}}}(
    :a => Dict("unit" => ("km", :default)),
    :b => Dict("unit" => ("km", :entry)))
  _colmeta_changed2 = Dict{Symbol, Dict{String, Tuple{Any, Symbol}}}(
    :a => Dict("unit" => ("km", :default)),
    :b => Dict("unit" => ("km", :entry),"normalized" => (true, :bool)))

  colmeta_simple = ColMetaArray(simple, _meta_default, _colmeta_test)
  colmeta_test   = ColMetaArray(testst, _meta_nodefault, _colmeta_test)
  colmeta_simplestatic = ColMetaArray(SVector{3}(simple), _meta_default, _colmeta_static)

  nocolmeta_simple = NoColMetaArray(simple, _meta_default)
  nocolmeta_test   = NoColMetaArray(testst, _meta_nodefault)
  nocolmeta_simplestatic = NoColMetaArray(SVector{3}(simple), _meta_default)
  @testset "comparisons" begin
    @test colmeta_simple   == simple
    @test nocolmeta_simple == simple
    @test colmeta_simple   == nocolmeta_simple

    @test colmeta_test     == testst
    @test nocolmeta_test   == testst
    @test colmeta_test     == nocolmeta_test

    @test colmeta_simplestatic == simple
    @test nocolmeta_simplestatic == simple
    @test colmeta_simplestatic == nocolmeta_simplestatic
  end

@test "metadata" begin
  metadata(colmeta_simple;style=false)==_meta_default
  # change content metadata
  metadata!(colmeta_simple,"description","changed test array";style=:entry)
  metadata(colmeta_simple;style=true) ==_meta_nodefault
  # add content metadata
  metadata!(colmeta_simple,"normalized",true;style=:bool)
  metadata(colmeta_simple;style=true) ==_meta_nodefault2
  # remove content metadata
  deletemetadata!(colmeta_simple,"normalized")
  metadata(colmeta_simple;style=true) ==_meta_nodefault
  # empty content metadata
  emptymetadata!(colmeta_simple)
  metadata(colmeta_simple;style=true) == _meta_empty
end

#@test "colmetadata" begin
  # colmetadata without col support
  colmetadata(colmeta_simple) == _colmeta_empty
  colmetadata(colmeta_simplestatic; style=true)   ==Dict((:x,:y,:z) .=> _colmeta_static)
  # change column metadata
  colmetadata!(colmeta_simple,:a,"unit","km";style=:entry)
  colmetadata(colmeta_simple) == _colmeta_changed
  # add column metadata
  colmetadata!(colmeta_simple,:a,"normalized",true;style=:bool)
  colmetadata(colmeta_simple) == _colmeta_changed2
  # remove column metadata
  deletecolmetadata!(colmeta_simple,:a,"normalized")
  colmetadata(colmeta_simple) == _colmeta_changed
  # empty column metadata
  emptycolmetadata!(colmeta_simple)
  colmetadata(colmeta_simple) == _colmeta_empty

end

@testset "without colmetadata"


end



cm=ColMetaArray(StructArray([TestStruct(1,2), TestStruct(3,4)]),Dict("description"=>"a"),Dict(:km=>:units))
sm1=ColMetaArray(SVector(1), Dict("description" => ("test array", :default)), Dict("unit" => ("meters", :default)))
sm2=ColMetaArray(SVector(1,2), Dict("description" => ("test array", :default)), Dict("unit" => ("meters", :default)))
sm3=ColMetaArray(SVector(1,2,3), Dict("description" => ("test array", :default)), Dict("unit" => ("meters", :default)))
sm4=ColMetaArray(SVector(1,2,3,4), Dict("description" => ("test array", :default)), Dict("unit" => ("meters", :default)))
sm5=ColMetaArray(SVector(1,2,3,4,5), Dict("description" => ("test array", :default)), Dict("unit" => ("meters", :default)))

colmetadata(cm)

colmetadata!(cm,:a,"value",3)


#@testset "Concrete implementations of AbstractMetaArray" begin
  data = [1, 2, 3]
  mymetadata = Dict("description" => ("test array", :default))
  mycolmetadata = Dict(:col1 => Dict("unit" => ("meters", :default)))

  # Implementation without column metadata
  ColMetadataTrait(::Type{<:NoColMetaArray}) = NoColMetadata()

  no_col_meta_array = NoColMetaArray{Int,1}(data, mymetadata)

  @test DataAPI.metadata(no_col_meta_array, "description") == "test array"
  @test_throws ArgumentError DataAPI.colmetadata(no_col_meta_array, :col1, "unit")

  # Implementation with column metadata
  struct WithColMetaArray{T,N} <: AbstractMetaArray{T,N}
      _data::AbstractArray{T,N}
      _metadata::MetaType
      _colmetadata::Dict{Symbol,MetaType}
  end
  ColMetadataTrait(::Type{<:WithColMetaArray}) = HasColMetadata()

  with_col_meta_array = WithColMetaArray{Int,1}(data, metadata, colmetadata)
  @test DataAPI.metadata(with_col_meta_array, "description") == "test array"
  @test DataAPI.colmetadata(with_col_meta_array, :col1, "unit") == "meters"
end
