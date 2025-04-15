module StaticArraysExt
using StaticArrays
using AbstractMetaArrays

AbstractMetaArrays._metacomponent(x::StaticArray, i::Int) = getindex(x, i)

@eval @generated function AbstractMetaArrays._metacomponent(
        ::MA,
        key::Symbol
) where {MA <: Union{SVector{S}, MVector{S}}} where {S}
    vals = (:x, :y, :z, :w)
    exps = "i = "
    if S <= 4
        for i in 1:S
            exps *= "key == :$(vals[i]) ? $i : "
        end
    end
    exps *= "throw(ArgumentError(\"Invalid key: \$key\"))"
    Meta.parse(exps)
end

@eval @generated function Base.propertynames(
        ::MA,
) where {T, S, MA <: AbstractMetaArray{T, 1, <:Union{SVector{S}, MVector{S}}}}
    if S == 1
        return :((:x,))
    elseif S == 2
        return :((:x, :y))
    elseif S == 3
        return :((:x, :y, :z))
    elseif S == 4
        return :((:x, :y, :z, :w))
    end
    return :((:data,))
end

@eval @generated function AbstractMetaArrays._create_colmeta(
        ::A,
        colmeta::C
) where {A <: Union{SVector{S}, MVector{S}}, C} where {S}
    sym_tuple = if S == 1
        :((:x,))
    elseif S == 2
        :((:x, :y))
    elseif S == 3
        :((:x, :y, :z))
    elseif S == 4
        :((:x, :y, :z, :w))
    else
        :((:data,))
    end
    quote
        svec_tuple = $sym_tuple
        isempty(svec_tuple) ? Dict{Symbol, ConcreteMetaType}() :
        AbstractMetaArrays.__create_colmeta(svec_tuple, colmeta)
    end
end

# disambiguation
@generated function Base.reshape(
        s::MA, d::Dims) where {T, N, A, MA <: AbstractMetaArray{T, N, A}}
    exps = Expr[]
    push!(exps, :(meta = deepcopy(s._metadata)))
    if ColMetadataTrait(s) == HasColMetadata()
        push!(exps, :(colmeta = deepcopy(s._colmetadata)))
    end
    quote
        $(Expr(:block, exps...))
        MA(reshape(s._data, d), meta, colmeta)
    end
end
end
