abstract type AbstractMetaArray{T,N,A<:AbstractArray{T,N}} <: AbstractArray{T,N} end
const AbstractMetaVector{T} = AbstractMetaArray{T,1}
const AbstractMetaMatrix{T} = AbstractMetaArray{T,2}

# Interfaces for AbstractMetaArray

@forward AbstractMetaArray._data Base.getindex, Base.setindex!, Base.size, Base.eltype, Base.parent, Base.axes, Base.iterate

Base.reshape(ma::MA, d::Dims{N}) where MA<:AbstractMetaArray{T} where {T,N} = begin
  meta = deepcopy(ma._metadata)
  data = reshape(ma._data, d)
  MA1  = typeof(ma).name.wrapper
  return  ColMetadataTrait(MA)!=NoColMetadata() ?
          MA1(data, meta, deepcopy(ma._colmetadata)) :
          MA1(data, meta)
end

# Define a custom `similar` method for MetaArray
function Base.similar(ma::AbstractMetaArray{T,N}, ::Type{S}, dims::Dims{N}) where {T,S, N}
  MA= typeof(ma).name.wrapper
  # Create a new MetaArray with the same metadata and the specified element type and dimensions
  return ColMetadataTrait(MA) == NoColMetadata() ?  MA(Array{S}(undef, dims), deepcopy(ma._metadata)) :
                                                    MA(Array{S}(undef, dims), deepcopy(ma._metadata), deepcopy(ma._colmetadata))
end




Base.sort!(ma::MA;kwargs...) where MA<:AbstractMetaArray{T,N} where {T,N} = begin
  sort!(ma._data; kwargs...)
end


function Base.similar(ma::MA, ::Type{S}) where MA<:AbstractMetaArray{T,N} where {T, S, N}
  similar(ma, S, size(ma))
end



function Base.getproperty(m::MA, key::Symbol) where MA<:AbstractMetaArray{T,N,A} where {T,N,A<:AbstractArray}
  if key == :_data || key == :_metadata || (key == :_colmetadata)
    return getfield(m, key)
 else
    return _metacomponent(m._data, key)
  end
end

Base.propertynames(ma::MA) where MA<:AbstractMetaArray = propertynames(ma._data)

function showfields(io::IO, fields::NTuple{N, Any}) where N
  print(io, "(")
  for (i, field) in enumerate(fields)
      Base.showarg(io, fields[i], false)
      i < N && print(io, ", ")
  end
  print(io, ")")
end

function Base.showarg(io::IO, ma::MA,toplevel) where MA<:AbstractMetaArray{T,N}  where {T,N}
  typeinfo=typeof(ma)
  print(io, typeinfo.name.wrapper, "{$(typeinfo.parameters[1]), $(typeinfo.parameters[2])}")
end
