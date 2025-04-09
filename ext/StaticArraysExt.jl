using StaticArrays
using AbstractMetaArrays

_metacomponent(x::StaticArray, i::Int) = getindex(x, i)
function _metacomponent( m::AbstractMetaArray{<:Union{SVector,SMatrix}}, key::Symbol)
  i = key == :x ? 1 :
      key == :y ? 2 :
      key == :z ? 3 :
      key == :w ? 4 :
      throw(ArgumentError("Invalid key: $key"))
  _metacomponent(m, i)
end
