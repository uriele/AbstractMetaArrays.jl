# singleton to detect if no default metadata is provided from https://github.com/JuliaData/DataFrames.jl/
struct MetaDataMissingDefault end
#DataAPI.metadatasupport(::T) where T = DataAPI.metadatasupport(typeof(T))
DataAPI.metadatasupport(::Type{<:AbstractMetaArray}) = (read=true,write=true)
#DataAPI.colmetadatasupport(::T) where T = DataAPI.colmetadatasupport(typeof(T))
DataAPI.colmetadatasupport(::Type{A}) where A<:AbstractMetaArray = colmetadata_properties(A)


function DataAPI.metadata(ma::MA, key::AbstractString, default=MetaDataMissingDefault(); style::Bool=false) where MA<:AbstractMetaArray
  meta= getfield(ma, :_metadata)
  _metadata_info(meta,key,default,style)
end

function DataAPI.metadatakeys(ma::MA) where MA<:AbstractMetaArray
  meta= getfield(ma, :_metadata)
  isempty(meta) && return ()
  return keys(meta)
end

DataAPI.metadata(ma::MA; style::Bool=false) where MA<:AbstractMetaArray= Dict(map(key-> key=>metadata(ma, key; style=style), metadatakeys(ma)))

function DataAPI.metadata!(ma::MA, key::AbstractString, value; style::Symbol=:default) where MA<:AbstractMetaArray
  ma._metadata[key] = (value,style)
  return ma
end

function DataAPI.deletemetadata!(ma::MA, key::AbstractString) where MA<:AbstractMetaArray
  delete!(ma._metadata, key)
  return ma
end

function DataAPI.emptymetadata!(ma::MA) where MA<:AbstractMetaArray
  empty!(ma._metadata)
  return ma
end

function DataAPI.colmetadatakeys(ma::MA, col::Symbol) where MA<:AbstractMetaArray
  ColMetadataTrait(MA)==NoColMetadata() && throw(ArgumentError("Column metadata not supported for type $MA."))
  colmeta= getfield(ma, :_colmetadata)
  if !haskey(colmeta,col) || isempty(colmeta)
    throw(ArgumentError("Column $col not found in $MA."))
  end
  meta=colmeta[col]
  keys(meta)
end

function DataAPI.colmetadatakeys(ma::MA) where MA<:AbstractMetaArray
  ColMetadataTrait(MA)==NoColMetadata() && throw(ArgumentError("Column metadata not supported for type $MA."))
  return (col=> colmetadatakeys(ma, col) for col in keys(ma._colmetadata))
end


function DataAPI.colmetadata(ma::MA, col::Symbol, key::AbstractString, default=MetaDataMissingDefault(); style::Bool=false) where MA<:AbstractMetaArray
  ColMetadataTrait(MA)==NoColMetadata() && throw(ArgumentError("Column metadata not supported for type $MA."))
  colmeta= getfield(ma, :_colmetadata)
  if !haskey(colmeta,col) || isempty(colmeta)
    throw(ArgumentError("Column $col not found in $MA."))
  end
  meta=colmeta[col]
  _metadata_info(meta,key,default,style,col)
end
DataAPI.colmetadata(ma::MA, col::Symbol; style::Bool=false) where MA<:AbstractMetaArray = Dict(map(key-> key=>colmetadata(ma, col, key; style=style), colmetadatakeys(ma,col)))
DataAPI.colmetadata!(ma::MA; style::Bool=false) where MA<:AbstractMetaArray = Dict(map(col-> col=>colmetadata(ma, col; style=style), keys(ma._colmetadata)))

function DataAPI.colmetadata!(ma::MA, col::Symbol, key::AbstractString, value; style::Symbol=:default) where MA<:AbstractMetaArray
  ColMetadataTrait(MA)==NoColMetadata() && throw(ArgumentError("Column metadata not supported for type $MA."))
  colmeta= getfield(ma, :_colmetadata)
  if !haskey(colmeta,col) || isempty(colmeta)
    throw(ArgumentError("Column $col not found in $MA."))
  end
  meta=colmeta[col]
  meta[key] = (value,style)
  return ma
end

function DataAPI.deletecolmetadata!(ma::MA,col::Symbol, key::AbstractString) where MA<:AbstractMetaArray
  ColMetadataTrait(MA)==NoColMetadata() && throw(ArgumentError("Column metadata not supported for type $MA."))
  colmeta= getfield(ma, :_colmetadata)
  if !haskey(colmeta,col) || isempty(colmeta)
    throw(ArgumentError("Column $col not found in $MA."))
  end
  meta=colmeta[col]
  delete!(meta, key)
  return ma
end
function DataAPI.emptycolmetadata!(ma::MA,col::Symbol) where MA<:AbstractMetaArray
  ColMetadataTrait(MA)==NoColMetadata() && throw(ArgumentError("Column metadata not supported for type $MA."))
  colmeta= getfield(ma, :_colmetadata)
  if !haskey(colmeta,col) || isempty(colmeta)
    throw(ArgumentError("Column $col not found in $MA."))
  end
  delete!(colmeta, col)
  return ma
end

function DataAPI.emptycolmetadata!(ma::MA) where MA<:AbstractMetaArray
  ColMetadataTrait(MA)==NoColMetadata() && throw(ArgumentError("Column metadata not supported for type $MA."))
  colmeta= getfield(ma, :_colmetadata)
  empty!(colmeta)
  return ma
end
