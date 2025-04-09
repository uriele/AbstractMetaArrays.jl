module AbstractMetaArrays
using Reexport
using Lazy
using DataAPI
@reexport import DataAPI: metadata,metadata!, metadatakeys,metadatasupport
@reexport import DataAPI: colmetadatas, colmetadata!, colmetadatakeys, colmetadatasupport
# Write your package code here.
export AbstractMetaArray, SimpleMetaArray
export HasColMetadata, NoColMetadata, ReadColMetadata, WriteColMetadata
export colmetadata_properties,ColMetadataTrait
abstract type AbstractMetaArray{T,N} <: AbstractArray{T,N} end
const AbstractVector{T} = AbstractArray{T,1}
const AbstractMatrix{T} = AbstractArray{T,2}

@forward AbstractMetaArray._data Base.getindex, Base.setindex!, Base.size, Base.eltype, Base.parent
@forward AbstractMetaArray._data Base.similar, Base.axes, Base.iterate

# Define a custom `similar` method for MetaArray
function Base.similar(x::A, ::Type{S}, dims::Dims{N}) where A<:AbstractMetaArray{T,N} where {T,S, N}
  # Create a new MetaArray with the same metadata and the specified element type and dimensions
  A(Array{T}(undef, dims), deepcopy(x.meta))
end
function Base.similar(x::A, ::Type{S}) where A<:AbstractMetaArray{T,N} where {T, S, N}
  similar(x, S, size(x))
end


_metacomponent(m::AbstractMetaArray, key) = getfield(m,key)

function Base.getproperty(m::AbstractMetaArray, key::Symbol)
  if key == :_data || key == :_metadata || (key == :_colmetadata && colmetadata_properties(m).read)
    return getfield(m, key)
    return m._data
  elseif key == :metadata
    return m._metadata
  elseif key == :colmetadata
    return m._colmetadata
  else
    return _metacomponent(m, key)
  end
end

const MetaType = Dict{<:AbstractString,<:Any}
const DictOrNothing = Union{Dict,Nothing}


_convert_dictkey_to_string(d::Dict{<:AbstractString}) = d


function _convert_dictkey_to_string(d::Dict{T}) where T
  dkey=string.(collect(keys(d)))
  dval=collect(values(d))
  d=Dict{String,Any}()
  for (key,val) in zip(dkey,dval)
    d[key]=val
  end
  return d
end
_convert_dictkey_to_string(::Nothing) = _convert_dictkey_to_string(Dict())


struct SimpleMetaArray{T,N} <: AbstractMetaArray{T,N}
    _data::AbstractArray{T,N}
    _metadata:: MetaType
    _colmetadata:: Dict{Symbol,MetaType}

    function SimpleMetaArray{T,N}(data::AbstractArray{T,N}, metadata::DictOrNothing=nothing, colmetadata::Union{Vector{DictOrNothing},DictOrNothing}=nothing) where {T,N}
      _metadata=_convert_dictkey_to_string(metadata)

      col=propertynames(data)
      if isempty(col)
        _colmetadata=_convert_dictkey_to_string(nothing)

      if isa(colmetadata, Vector{DictOrNothing})
        colmetadata=Dict(map(col->(col=>Dict()),zip()
      col= propertynames(data)
      _colmetadata=Dict(map(col->(col=>Dict()),col)...)
      new{T,N}(data, metadata, colmetadata)
    end

    function SimpleMetaArray{T,N}(data::AbstractArray{T,N}, metadata::Dict{<:AbstractString,<:Any}=Dict{String}(), colmetadata::Union{Dict{<:AbstractString},Nothing}=nothing) where {T,N}
      col= propertynames(data)
      _colmetadata=Dict(map(col->(col=>Dict()),col)...)
      new{T,N}(data, metadata, colmetadata)
    end


    SimpleMetaArray{T}(data::AbstractArray{T,N}, metadata::Dict{String,<:Any}=Dict{String,Any}()) where {T,N} = new{T,N}(data, metadata)

end
SimpleMetaArray(data::AbstractArray{T,N}; metadata::Dict{String,<:Any}=Dict{String,Any}(),  colmetadata::Dict{String,<:Any}=Dict{String,Any}()) where {T,N} = SimpleMetaArray{T}(data, metadata, colmetadata)
  # Holy Pattern to check if a MetaArray has colmetadata
abstract type ColMetadataTrait end
struct HasColMetadata <: ColMetadataTrait end
struct NoColMetadata  <: ColMetadataTrait end
struct ReadColMetadata <: ColMetadataTrait end
struct WriteColMetadata <: ColMetadataTrait end

ColMetadataTrait(::Type) = NoColMetadata()
ColMetadataTrait(x) = ColMetadataTrait(typeof(x))

# Need to implement if the subtype has colmetadata
ColMetadataTrait(::Type{<:SimpleMetaArray}) = HasColMetadata()

colmetadata_properties(x::Type{T}) where T = colmetadata_properties(ColMetadataTrait(T),x)
colmetadata_properties(x::T) where T = colmetadata_properties(ColMetadataTrait(T),x)
colmetadata_properties(::HasColMetadata,x) = (read=true,write=true)
colmetadata_properties(::NoColMetadata,x)  = (read=false,write=false)
colmetadata_properties(::ReadColMetadata,x) = (read=true,write=false)
colmetadata_properties(::WriteColMetadata,x) = (read=false,write=true)

DataAPI.metadatasupport(::T) where T = DataAPI.metadatasupport(typeof(T))
DataAPI.metadatasupport(::Type{<:AbstractMetaArray}) = (read=true,write=true)
DataAPI.colmetadatasupport(::T) where T = DataAPI.colmetadatasupport(typeof(T))
DataAPI.colmetadatasupport(::Type{A}) where A<:AbstractMetaArray = colmetadata_properties(A)

function DataAPI.metadatakeys(x::AbstractMetaArray)
  keys(x._metadata)
end

_colmetadatakeys(x<:AbstractVecOrMat, col::Int) =

_colproperties(x::)



function DataAPI.colmetadatakeys(x::AbstractMetaArray,col::Symbols)
  colmetadata_properties(x).read == false && return ()
  if col in keys(x._colmetadata)
    return keys(x._colmetadata[col])
  end
end
#  If col is not passed return an iterator of col => colmetadatakeys(x, col) pairs for all
# columns that have metadata, where col are Symbol. If x does not support column metadata
# return ().




end
