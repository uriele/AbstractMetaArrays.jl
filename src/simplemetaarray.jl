struct SimpleMetaArray{T,N,A} <: AbstractMetaArray{T,N,A}
  _data::A
  _metadata:: MetaType
  _colmetadata:: Dict{Symbol,MetaType}
  function SimpleMetaArray{T,N}(data::A, metadata::DictOrNothing=nothing, colmetadata::Union{NTuple{N,DictOrNothing},DictOrNothing}=nothing) where {T,N,A<:AbstractArray{T,N}}
    metainfo=create_metaarray(ColMetadataTrait(SimpleMetaArray), data, metadata, colmetadata)
    new{T,N,A}(data, metainfo...)
  end
end



SimpleMetaArray(data::A, metadata::DictOrNothing=nothing, colmetadata::Union{NTuple{N,DictOrNothing},DictOrNothing}=nothing) where {T,N,A<:AbstractArray{T,N}} =
  SimpleMetaArray{T,N}(data, metadata, colmetadata)

SimpleMetaArray(T::Type, dims::Dims{N}, metadata::DictOrNothing=nothing, colmetadata::Union{NTuple{N,DictOrNothing},DictOrNothing}=nothing) where {N} =
  SimpleMetaArray{T,N}(similar(Array{T}, dims), metadata, colmetadata)

SimpleMetaArray(A::Type{<:AbstractArray{T,N}}, dims::Dims{N}, metadata::DictOrNothing=nothing, colmetadata::Union{NTuple{N,DictOrNothing},DictOrNothing}=nothing) where {T,N} =
  SimpleMetaArray{T,N}(A(undef,dims), metadata, colmetadata)



ColMetadataTrait(::Type{<:SimpleMetaArray}) = HasColMetadata()
