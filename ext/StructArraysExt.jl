using StructArrays
using AbstractMetaArrays
using Lazy
using Tables

# delegate the Tables interface to the underlying _data
@forward AbstractMetaArray._data Tables.columns, Tables.schema, Tables.materializer, Tables.isrowtable, Tables.columnaccess, Tables.isrowtable

function Base.showarg(io::IO, ma::MA,toplevel) where MA<:AbstractMetaArray{T,N,<:StructArray}  where {T,N}
  print(io, "$(typeof(ma).name.wrapper)")
  StructArrays.showfields(io, Tuple(StructArrays.components(ma._data)))
  toplevel && print(io, " with eltype ", T)
end
