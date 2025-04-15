
function _metacomponent(m::A, key) where {A <: AbstractArray{T, N}} where {T, N}
    getfield(m, key)
end
const StyleEntry = Tuple{<:Any, Symbol}

@inline _convert_dictkey_to_string(d::Dict{S, K}) where {S <: AbstractString, K <: StyleEntry} = Dict{
    S, Tuple{Any, Symbol}}(d)
@inline function _convert_dictkey_to_string(d::Dict{S, K}) where {S <: AbstractString, K}
    return _convert_dictkey_to_string(Dict(keys(d) .=> tuple.(values(d), :default)))
end
@inline function _convert_dictkey_to_string(d::Dict{S, K}) where {S, K}
    return _convert_dictkey_to_string(Dict(string.(keys(d)) .=> values(d)))
end
@inline _convert_dictkey_to_string(::Nothing) = _convert_dictkey_to_string(Dict{
    String, Tuple{Any, Symbol}}())

@inline function _metadata_info(meta, key, default, style, col = "")
    if isempty(meta) || !haskey(meta, key)
        if default === MetaDataMissingDefault
            throw(ArgumentError("Key $key not found in $col metadata."))
        else
            return style ? (default, :default) : default
        end
    end
    return style ? meta[key] : meta[key][1]
end

@inline __create_colmeta(cd::Dict{S, K}) where {S <: Symbol, K <: MetaType} = cd

@inline __create_colmeta(
S::NTuple{N, Symbol},
colmeta::NM
) where {N, NM <: NTuple{N, <:MetaType}} = __create_colmeta(Dict(S .=> colmeta))

@inline function __create_colmeta(S::NTuple{N, Symbol}, colmeta::Tuple) where {N}
    @assert length(S)==length(colmeta) "length of colmeta must be equal to length of S"

    colmeta = map(x -> _convert_dictkey_to_string(x), colmeta)
    isempty(S) ? Dict{Symbol, ConcreteMetaType}() : __create_colmeta(Dict(S .=> colmeta))
end

@inline function __create_colmeta(
        S::NTuple{N, Symbol},
        colmeta::D
) where {N, D <: DictOrNothing}
    colmeta = _convert_dictkey_to_string(colmeta)
    isempty(S) ? Dict{Symbol, ConcreteMetaType}() :
    __create_colmeta(Dict(S .=> ntuple(_ -> copy(colmeta), N)))
end

@inline function _create_colmeta(::Type{T}, colmeta::C) where {C, T}
    S = fieldnames(T)
    isempty(S) ? Dict{Symbol, ConcreteMetaType}() : __create_colmeta(S, colmeta)
end

@inline function _create_colmeta(x::T, colmeta::C) where {T, C}
    S = propertynames(x)
    isempty(S) ? Dict{Symbol, ConcreteMetaType}() : __create_colmeta(S, colmeta)
end

function _create_metaarray(
        ::T,
        S,
        default_meta::DictOrNothing = nothing,
        default_colmeta = nothing
) where {T <: HasColMetadata}
    _meta = _convert_dictkey_to_string(default_meta)
    return (_meta,)
end

function _create_metaarray(
        ::T,
        S,
        default_meta::DictOrNothing = nothing,
        default_colmeta = nothing
) where {T <: NoColMetadata}
    _meta = _convert_dictkey_to_string(default_meta)
    _colmeta = _create_colmeta(S, default_colmeta)
    return (_meta, _colmeta)
end
