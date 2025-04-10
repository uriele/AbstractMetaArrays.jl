
@inline _metacomponent(m::MA, key) where MA<:AbstractMetaArray = getfield(m._data,key)
@inline _convert_dictkey_to_string(d::Dict{<:AbstractString,Tuple{<:Any,Symbol}}) = d


@inline function _convert_dictkey_to_string(d::Dict{S,V}) where {S<:AbstractString,V}
  dout=Dict{S,Tuple{V,Symbol}}()
  for (key,val) in d
    dout[string(key)]=(val,:default)
  end
  return dout
end
@inline _convert_dictkey_to_string(d::Dict{K,V}) where {K,V} = _convert_dictkey_to_string(Dict(string.(keys(d)) .=> (values(d))))
@inline _convert_dictkey_to_string(::Nothing) = _convert_dictkey_to_string(Dict{String,Tuple{Any,Symbol}}())



@inline function _metadata_info(meta,key,default,style,col="")
  if isempty(meta) || !haskey(meta, key)
    if default === MetaDataMissingDefault
      throw(ArgumentError("Key $key not found in $col metadata."))
    else
      return style ? (default,:default) : default
    end
  end
  return style ? meta[key] : meta[key][1]
end


@inline create_colmeta(::NTuple{N,Symbol},col_meta:: Dict{Symbol,<:MetaType}) where N= col_meta
@inline function create_colmeta(S::NTuple{N,Symbol},colmeta::NTuple{N,<:MetaType})  where N
  isempty(S) ? Dict{Symbol,MetaType}() :
  create_colmeta(S,Dict{Symbol,MetaType}(S .=> colmeta))
end

@inline function create_colmeta(S::NTuple{N,Symbol},colmeta::DictOrNothing)  where N
  colmeta= _convert_dictkey_to_string(colmeta)
  isempty(S) ? Dict{Symbol,MetaType}() :
  create_colmeta(S, ntuple(_-> colmeta, N))
end



@inline function create_colmeta(::Type{T}, colmeta::C) where {C,T}
  S= fieldnames(T)
  isempty(S) ? Dict{Symbol,MetaType}() :
  create_colmeta(S, colmeta)
end


@inline function create_colmeta(x::T, colmeta::C) where {T,C}
  S= propertynames(x)
  isempty(S) ? Dict{Symbol,MetaType}() :
  create_colmeta(S, colmeta)
end




"""
  create_metaarray(HasColMetadata(), A::AbstractArray, default_meta=nothing, default_colmeta=nothing)
  create_metaarray(NoColMetadata(), Type{S}, dims, default_meta=nothing, default_colmeta=nothing)

helper function to the metadata and colmetadata constructors
"""

function create_metaarray(trait::C, S,
  default_meta::DictOrNothing=nothing,
  default_colmeta=nothing) where {C<:ColMetadataTrait}
  _meta   = _convert_dictkey_to_string(default_meta)
  if  trait == NoColMetadata()
    return (_meta,)
  else
    _colmeta = create_colmeta(S, default_colmeta)
    return (_meta,_colmeta)
  end
end
