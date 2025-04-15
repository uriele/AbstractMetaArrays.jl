
struct NoColMetaArray{T, N, A} <: AbstractMetaArray{T, N, A}
    _data::A
    _metadata::MetaType

    function NoColMetaArray{T, N}(
            data::A,
            metadata::DictOrNothing = nothing
    ) where {T, N, A <: AbstractArray{T, N}}
        metainfo = create_metaarray(NoColMetaArray, data, metadata, nothing)
        @show metainfo[1]
        new{T, N, A}(data, metainfo[1])
    end
end

function NoColMetaArray(
        data::A,
        metadata::DictOrNothing = nothing
) where {T, N, A <: AbstractArray{T, N}}
    NoColMetaArray{T, N}(data, metadata)
end
function NoColMetaArray(T::Type, dims::Dims{N}, metadata::DictOrNothing = nothing) where {N}
    NoColMetaArray{T, N}(similar(Array{T}, dims), metadata)
end
function NoColMetaArray(
        A::Type{<:AbstractArray{T, N}},
        dims::Dims{N},
        metadata::DictOrNothing = nothing
) where {T, N}
    NoColMetaArray{T, N}(A(undef, dims), metadata)
end

struct ColMetaArray{T, N, A} <: AbstractMetaArray{T, N, A}
    _data::A
    _metadata::MetaType
    _colmetadata::Dict{Symbol, <:MetaType}

    function ColMetaArray{T, N}(
            data::A,
            metadata::DictOrNothing = nothing,
            colmetadata::Union{Tuple, DictOrNothing} = nothing
    ) where {T, N, A <: AbstractArray{T, N}}
        metainfo = create_metaarray(ColMetaArray, data, metadata, colmetadata)
        new{T, N, A}(data, metainfo...)
    end
end

function ColMetaArray(
        data::A,
        metadata::DictOrNothing = nothing,
        colmetadata::Union{Tuple, DictOrNothing} = nothing
) where {T, N, A <: AbstractArray{T, N}}
    ColMetaArray{T, N}(data, metadata, colmetadata)
end
function ColMetaArray(
        T::Type,
        dims::Dims{N},
        metadata::DictOrNothing = nothing,
        colmetadata::Union{Tuple, DictOrNothing} = nothing
) where {N}
    ColMetaArray{T, N}(similar(Array{T}, dims), metadata, colmetadata)
end
function ColMetaArray(
        A::Type{<:AbstractArray{T, N}},
        dims::Dims{N},
        metadata::DictOrNothing = nothing,
        colmetadata::Union{Tuple, DictOrNothing} = nothing
) where {T, N}
    ColMetaArray{T, N}(A(undef, dims), metadata, colmetadata)
end

function AbstractMetaArrays.ColMetadataTrait(::Type{<:ColMetaArray})
    AbstractMetaArrays.HasColMetadata()
end

struct TestStruct{T}
    a::T
    b::T
end

simple = [1, 2, 3]
testst = [TestStruct(1, 2), TestStruct(3, 4)]
_meta_default = Dict("description" => "test array")
_meta_empty = Dict{String, Tuple{Any, Symbol}}()
_meta_nodefault = Dict{String, Tuple{Any, Symbol}}("description" => (
    "changed test array", :entry))
_meta_nodefault2 = Dict{String, Tuple{Any, Symbol}}(
    "description" => ("changed test array", :entry),
    "normalized" => (true, :bool)
)

_colmeta_test = (Dict("unit" => ("m", :default)), Dict("unit" => ("km", :entry)))
_colmeta_static = (
    Dict("unit" => ("m", :default)),
    Dict("unit" => ("km", :entry)),
    Dict("unit" => ("cm", :entry))
)

_colmeta_empty = Dict{Symbol, Dict{String, Tuple{Any, Symbol}}}()
_colmeta_changed = Dict{Symbol, Dict{String, Tuple{Any, Symbol}}}(
    :a => Dict("unit" => ("km", :default)),
    :b => Dict("unit" => ("km", :entry))
)
_colmeta_changed2 = Dict{Symbol, Dict{String, Tuple{Any, Symbol}}}(
    :a => Dict("unit" => ("km", :default)),
    :b => Dict("unit" => ("km", :entry), "normalized" => (true, :bool))
)

colmeta_empty = ColMetaArray(simple, _meta_empty, _colmeta_empty)
colmeta_simple = ColMetaArray(simple, _meta_default, _colmeta_test)
colmeta_test = ColMetaArray(StructArray(testst), _meta_nodefault, _colmeta_test)
colmeta_simplestatic = ColMetaArray(SVector{3}(simple), _meta_default, _colmeta_static)

nocolmeta_empty = NoColMetaArray(simple, _meta_empty)
nocolmeta_simple = NoColMetaArray(simple, _meta_default)
nocolmeta_test = NoColMetaArray(testst, _meta_nodefault)
nocolmeta_simplestatic = NoColMetaArray(SVector{3}(simple), _meta_default)

struct WriteOnlyColMetaArray{T, N, A} <: AbstractMetaArray{T, N, A}
    _data::A
    _metadata::MetaType
    _colmetadata::Dict{Symbol, MetaType}

    function WriteOnlyColMetaArray{T, N}(
            data::A,
            metadata::DictOrNothing = nothing,
            colmetadata::Union{NTuple{N, DictOrNothing}, DictOrNothing} = nothing
    ) where {T, N, A <: AbstractArray{T, N}}
        metainfo = create_metaarray(WriteOnlyColMetaArray, data, metadata, colmetadata)
        new{T, N, A}(data, metainfo...)
    end
end
function WriteOnlyColMetaArray(
        data::A,
        metadata::DictOrNothing = nothing,
        colmetadata::Union{NTuple{N, DictOrNothing}, DictOrNothing} = nothing
) where {T, N, A <: AbstractArray{T, N}}
    WriteOnlyColMetaArray{T, N}(data, metadata, colmetadata)
end

function AbstractMetaArrays.ColMetadataStyle(::Type{<:WriteOnlyColMetaArray})
    AbstractMetaArrays.WriteOnlyColMetadata()
end

struct ReadOnlyColMetaArray{T, N, A} <: AbstractMetaArray{T, N, A}
    _data::A
    _metadata::MetaType
    _colmetadata::Dict{Symbol, MetaType}

    function ReadOnlyColMetaArray{T, N}(
            data::A,
            metadata::DictOrNothing = nothing,
            colmetadata::Union{NTuple{N, DictOrNothing}, DictOrNothing} = nothing
    ) where {T, N, A <: AbstractArray{T, N}}
        metainfo = create_metaarray(ReadOnlyColMetaArray, data, metadata, colmetadata)
        new{T, N, A}(data, metainfo...)
    end
end
function ReadOnlyColMetaArray(
        data::A,
        metadata::DictOrNothing = nothing,
        colmetadata::Union{NTuple{N, DictOrNothing}, DictOrNothing} = nothing
) where {T, N, A <: AbstractArray{T, N}}
    ReadOnlyColMetaArray{T, N}(data, metadata, colmetadata)
end

function AbstractMetaArrays.ColMetadataStyle(::Type{<:ReadOnlyColMetaArray})
    AbstractMetaArrays.ReadOnlyColMetadata()
end

struct WriteOnlyMetaArray{T, N, A} <: AbstractMetaArray{T, N, A}
    _data::A
    _metadata::MetaType
    _colmetadata::Dict{Symbol, MetaType}

    function WriteOnlyMetaArray{T, N}(
            data::A,
            metadata::DictOrNothing = nothing,
            colmetadata::Union{NTuple{N, DictOrNothing}, DictOrNothing} = nothing
    ) where {T, N, A <: AbstractArray{T, N}}
        metainfo = create_metaarray(WriteOnlyMetaArray, data, metadata, colmetadata)
        new{T, N, A}(data, metainfo...)
    end
end
function WriteOnlyMetaArray(
        data::A,
        metadata::DictOrNothing = nothing,
        colmetadata::Union{NTuple{N, DictOrNothing}, DictOrNothing} = nothing
) where {T, N, A <: AbstractArray{T, N}}
    WriteOnlyMetaArray{T, N}(data, metadata, colmetadata)
end

function AbstractMetaArrays.MetadataStyle(::Type{<:WriteOnlyMetaArray})
    AbstractMetaArrays.WriteOnlyMetadata()
end

struct ReadOnlyMetaArray{T, N, A} <: AbstractMetaArray{T, N, A}
    _data::A
    _metadata::MetaType
    _colmetadata::Dict{Symbol, MetaType}

    function ReadOnlyMetaArray{T, N}(
            data::A,
            metadata::DictOrNothing = nothing,
            colmetadata::Union{NTuple{N, DictOrNothing}, DictOrNothing} = nothing
    ) where {T, N, A <: AbstractArray{T, N}}
        metainfo = create_metaarray(ReadOnlyMetaArray, data, metadata, colmetadata)
        new{T, N, A}(data, metainfo...)
    end
end
function ReadOnlyMetaArray(
        data::A,
        metadata::DictOrNothing = nothing,
        colmetadata::Union{NTuple{N, DictOrNothing}, DictOrNothing} = nothing
) where {T, N, A <: AbstractArray{T, N}}
    ReadOnlyMetaArray{T, N}(data, metadata, colmetadata)
end

function AbstractMetaArrays.MetadataStyle(::Type{<:ReadOnlyMetaArray})
    AbstractMetaArrays.ReadOnlyMetadata()
end
