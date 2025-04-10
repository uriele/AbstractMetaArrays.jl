using AbstractMetaArrays
using Test
using Aqua

@testset "AbstractMetaArrays.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(AbstractMetaArrays)
    end
    # Write your tests here.
end


struct NoColMetadata{T,N} <: AbstractMetaArray{T,N}
  _data::AbstractArray{T,N}
  _metadata::MetaType
end

struct ColMetadata{T,N} <: AbstractMetaArray{T,N}
  _data::AbstractArray{T,N}
  _metadata::MetaType
  _colmetadata::Dict{Symbol,MetaType}
end



@testset "Concrete implementations of AbstractMetaArray" begin
  data = [1, 2, 3]
  metadata = Dict("description" => ("test array", :default))
  colmetadata = Dict(:col1 => Dict("unit" => ("meters", :default)))

  # Implementation without column metadata
  struct NoColMetaArray{T,N} <: AbstractMetaArray{T,N}
      _data::AbstractArray{T,N}
      _metadata::MetaType
  end
  ColMetadataTrait(::Type{<:NoColMetaArray}) = NoColMetadata()

  no_col_meta_array = NoColMetaArray{Int,1}(data, metadata)
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
