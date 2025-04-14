
struct NoColMetaArray{T,N,A} <: AbstractMetaArray{T,N,A}
  _data::A
  _metadata::MetaType

  function NoColMetaArray{T,N}(data::A, metadata::DictOrNothing=nothing) where {T,N,A<:AbstractArray{T,N}}
    metainfo=create_metaarray(ColMetadataTrait(NoColMetaArray), data, metadata,nothing)
    @show metainfo[1]
    new{T,N,A}(data, metainfo[1])
  end
end

NoColMetaArray(data::A, metadata::DictOrNothing=nothing) where {T,N,A<:AbstractArray{T,N}} =
NoColMetaArray{T,N}(data, metadata)
NoColMetaArray(T::Type, dims::Dims{N}, metadata::DictOrNothing=nothing) where {N} =
NoColMetaArray{T,N}(similar(Array{T}, dims), metadata)
NoColMetaArray(A::Type{<:AbstractArray{T,N}}, dims::Dims{N}, metadata::DictOrNothing=nothing) where {T,N} =
NoColMetaArray{T,N}(A(undef,dims), metadata)



struct ColMetaArray{T,N,A} <: AbstractMetaArray{T,N,A}
  _data::A
  _metadata::MetaType
  _colmetadata::Dict{Symbol,MetaType}

  function ColMetaArray{T,N}(data::A, metadata::DictOrNothing=nothing, colmetadata::Union{Tuple,DictOrNothing}=nothing) where {T,N,A<:AbstractArray{T,N}}
    metainfo=create_metaarray(ColMetadataTrait(ColMetaArray), data, metadata, colmetadata)
    new{T,N,A}(data, metainfo...)
  end
end


ColMetaArray(data::A, metadata::DictOrNothing=nothing, colmetadata::Union{Tuple,DictOrNothing}=nothing) where {T,N,A<:AbstractArray{T,N}} =
ColMetaArray{T,N}(data, metadata, colmetadata)
ColMetaArray(T::Type, dims::Dims{N}, metadata::DictOrNothing=nothing, colmetadata::Union{Tuple,DictOrNothing}=nothing) where {N} =
ColMetaArray{T,N}(similar(Array{T}, dims), metadata, colmetadata)
ColMetaArray(A::Type{<:AbstractArray{T,N}}, dims::Dims{N}, metadata::DictOrNothing=nothing, colmetadata::Union{Tuple,DictOrNothing}=nothing) where {T,N} =
ColMetaArray{T,N}(A(undef,dims), metadata, colmetadata)


AbstractMetaArrays.ColMetadataTrait(::Type{<:ColMetaArray}) = HasColMetadata()

struct TestStruct{T}
  a::T
  b::T
end
