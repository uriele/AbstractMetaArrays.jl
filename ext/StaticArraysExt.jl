module StaticArraysExt
  using StaticArrays
  using AbstractMetaArrays

  AbstractMetaArrays._metacomponent(x::StaticArray, i::Int) = getindex(x, i)


  @eval @generated function AbstractMetaArrays._metacomponent( ::MA, key::Symbol) where MA<:Union{SVector{S},MVector{S}} where S
    vals=(:x,:y,:z,:w)
    exps = "i = "
    if S<=4
      for i in 1:S
        exps*= "key == :$(vals[i]) ? $i : "
      end
    end
    exps*="throw(ArgumentError(\"Invalid key: \$key\"))"
    Meta.parse(exps)
  end


  @eval @generated function Base.propertynames(::MA) where MA<:AbstractMetaArray{T,1,<:Union{SVector{S},MVector{S}}} where {T,S}
    vals=(:x,:y,:z,:w)
    exps = "("
    if S<=4
      for i in 1:S
        exps*= ":$(vals[i]), "
      end
    else
      exps*=":data, "
    end
    exps*=")"
    Meta.parse(exps)
  end

  @eval @generated function AbstractMetaArrays._create_colmeta(x::A, colmeta::C) where {A<:Union{SVector{N},MVector{N}},C} where N
    exps="("
    if N<=4
      vals=(:x,:y,:z,:w)
      for i in 1:N
        exps*= ":$(vals[i]), "
      end
    end
    exps*=")"

    quote
      S=$(Meta.parse(exps))
      isempty(S) ? Dict{Symbol,MetaType}() :
      AbstractMetaArrays.__create_colmeta(S, colmeta)
    end
  end



  # disambiguation
  Base.reshape(s::MA, d::Tuple{SOneTo, Vararg{SOneTo}}) where MA<:AbstractMetaArray{T} where {T} = begin
    meta = deepcopy(s._metadata)
    colmeta = ColMetadataTrait(MA)!=NoColMetaArray() ? deepcopy(s._colmetadata) : nothing
    MA(reshape(s._data, d), meta, colmeta)
  end
end
