"""
   SimpleMetaArray{T,N,A<:AbstractArray{T,N}} <: AbstractMetaArray{T,N,A<:AbstractArray{T,N}}

Concrete implementation of AbstractMetaArray for a simple array with metadata. This is a concrete type that can be used to create instances of AbstractMetaArray.
It has metadata and colmetadata fields that are dictionaries with string keys and values of type `Tuple{Any,Symbol}`.

It uses the following traits:

  $(@__MODULE__).ColMetadataTrait(::Type{<:SimpleMetaArray}) = HasColMetadata()
  $(@__MODULE__).ColMetadataStyle(::Type{<:SimpleMetaArray}) = ReadWriteColMetadata()
  $(@__MODULE__).MetadataStyle(::Type{<:SimpleMetaArray}) = ReadWriteMetadata()

See also [`AbstractMetaArray`](@ref) for more information on the abstract type and its methods.
"""
struct SimpleMetaArray{T, N, A} <: AbstractMetaArray{T, N, A}
    _data::A
    _metadata::MetaType
    _colmetadata::Dict{Symbol, MetaType}
    function SimpleMetaArray{T, N}(
            data::A,
            metadata::DictOrNothing = nothing,
            colmetadata::Union{NTuple{N, DictOrNothing}, DictOrNothing} = nothing
    ) where {T, N, A <: AbstractArray{T, N}}
        metainfo = create_metaarray(SimpleMetaArray, data, metadata, colmetadata)
        new{T, N, A}(data, metainfo...)
    end
end
"""
    SimpleMetaArray{T,N}(data::A, metadata::DictOrNothing=nothing, colmetadata::Union{NTuple{N,DictOrNothing},DictOrNothing}=nothing) where {T,N,A<:AbstractArray{T,N}} =
    SimpleMetaArray(data, metadata, colmetadata)

Construct a `SimpleMetaArray` with the given data, metadata and colmetadata.

# Example
```jldoctest
julia> s=SimpleMetaArray(SVector{3}(1,1,1), Dict("description" => ("test array", :entry)),
              Dict("unit" => ("m", :default)))
3-element SimpleMetaArray{Int64, 1} with indices SOneTo(3):
 1
 1
 1

julia> metadata(s)
Dict{String, String} with 1 entry:
  "description" => "test array"

julia> colmetadata(s)
Dict{Symbol, Dict{String, String}} with 3 entries:
  :y => Dict("unit"=>"m")
  :z => Dict("unit"=>"m")
  :x => Dict("unit"=>"m")
```
"""
SimpleMetaArray(
data::A,
metadata::DictOrNothing = nothing,
colmetadata::Union{NTuple{N, DictOrNothing}, DictOrNothing} = nothing
) where {T, N, A <: AbstractArray{T, N}} = SimpleMetaArray{T, N}(
    data, metadata, colmetadata)

"""
    SimpleMetaArray(T::Type, dims::Dims{N}, metadata::DictOrNothing=nothing, colmetadata::Union{NTuple{N,DictOrNothing},DictOrNothing}=nothing) where N
    SimpleMetaArray(A::Type{<:AbstractArray{T,N}}, dims::Dims{N}, metadata::DictOrNothing=nothing, colmetadata::Union{NTuple{N,DictOrNothing},DictOrNothing}=nothing) where {T,N}

Construct a `SimpleMetaArray` with the given type, dimensions, metadata and colmetadata. The type can be a concrete type or a comcrete subtype of `AbstractArray`.
"""
SimpleMetaArray(
T::Type,
dims::Dims{N},
metadata::DictOrNothing = nothing,
colmetadata::Union{NTuple{N, DictOrNothing}, DictOrNothing} = nothing
) where {N} = SimpleMetaArray{T, N}(similar(Array{T}, dims), metadata, colmetadata)

function SimpleMetaArray(
        A::Type{<:AbstractArray{T, N}},
        dims::Dims{N},
        metadata::DictOrNothing = nothing,
        colmetadata::Union{NTuple{N, DictOrNothing}, DictOrNothing} = nothing
) where {T, N}
    SimpleMetaArray{T, N}(A(undef, dims), metadata, colmetadata)
end

ColMetadataTrait(::Type{<:SimpleMetaArray}) = HasColMetadata()
