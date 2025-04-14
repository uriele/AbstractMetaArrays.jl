module StructArraysExt
  using StructArrays
  using AbstractMetaArrays
  using Lazy: @forward
  using Tables
  import Base: getproperty
  # delegate the Tables interface to the underlying _data
  @forward AbstractMetaArray._data Tables.columns, Tables.schema, Tables.materializer, Tables.isrowtable, Tables.columnaccess

  # extend internal function _metacomponent
  function AbstractMetaArrays._metacomponent(x::S, key::Symbol) where S<:StructArray{T,N} where {T,N}
    @info "S: $S  and ext"
    getproperty(x, key)
  end

  function Base.showarg(io::IO, ma::MA,toplevel) where MA<:AbstractMetaArray{T,N,<:StructArray}  where {T,N}
    print(io, "$(typeof(ma).name.wrapper)")
    StructArrays.showfields(io, Tuple(StructArrays.components(ma._data)))
    toplevel && print(io, " with eltype ", T)
  end
end
