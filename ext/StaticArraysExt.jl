using StaticArrays
using AbstractMetaArrays

_metacomponent(x::StaticArray, i::Int) = getindex(x, i)
function _metacomponent( m::MA, key::Symbol) where MA<:AbstractMetaArray{<:Union{SVector,SMatrix}}
  i = key == :x ? 1 :
      key == :y ? 2 :
      key == :z ? 3 :
      key == :w ? 4 :
      throw(ArgumentError("Invalid key: $key"))
  _metacomponent(m, i)
end

# disambiguation
Base.reshape(s::MA, d::Tuple{SOneTo, Vararg{SOneTo}}) where MA<:AbstractMetaArray{T} where {T} = begin
  meta = deepcopy(s._metadata)
  colmeta = ColMetadataTrait(MA)!=NoColMetaArray() ? deepcopy(s._colmetadata) : nothing
  MA(reshape(s._data, d), meta, colmeta)
end
