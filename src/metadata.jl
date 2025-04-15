# singleton to detect if no default metadata is provided from https://github.com/JuliaData/DataFrames.jl/
struct MetaDataMissingDefault end
#DataAPI.metadatasupport(::T) where T = DataAPI.metadatasupport(typeof(T))
function DataAPI.metadatasupport(T::Type{MA}) where {
        S, N, A, MA <: AbstractMetaArray{S, N, A}}
    if AbstractMetaArrays.MetadataStyle(T) isa ReadWriteMetadata
        return (read = true, write = true)
    elseif AbstractMetaArrays.MetadataStyle(T) isa ReadOnlyMetadata
        return (read = true, write = false)
    elseif AbstractMetaArrays.MetadataStyle(T) isa WriteOnlyMetadata
        return (read = false, write = true)
    end
    return (read = false, write = false)
end
#DataAPI.colmetadatasupport(::T) where T = DataAPI.colmetadatasupport(typeof(T))
function DataAPI.colmetadatasupport(T::Type{MA}) where {
        S, N, A, MA <: AbstractMetaArray{S, N, A}}
    if AbstractMetaArrays.ColMetadataStyle(T) isa ReadWriteColMetadata
        return (read = true, write = true)
    elseif AbstractMetaArrays.ColMetadataStyle(T) isa ReadOnlyColMetadata
        return (read = true, write = false)
    elseif AbstractMetaArrays.ColMetadataStyle(T) isa WriteOnlyColMetadata
        return (read = false, write = true)
    end
    return (read = false, write = false)
end

function DataAPI.metadata(
        ma::MA,
        key::AbstractString,
        default = MetaDataMissingDefault();
        style::Bool = false
) where {MA <: AbstractMetaArray}
    DataAPI.metadatasupport(MA).read ||
        throw(ArgumentError("Reading metadata not supported for type $MA."))
    meta = getfield(ma, :_metadata)
    _metadata_info(meta, key, default, style)
end

function DataAPI.metadatakeys(ma::MA) where {MA <: AbstractMetaArray}
    DataAPI.metadatasupport(MA).read ||
        throw(ArgumentError("Reading metadata not supported for type $MA."))
    meta = getfield(ma, :_metadata)
    isempty(meta) && return ()
    return keys(meta)
end

function DataAPI.metadata(ma::MA; style::Bool = false) where {MA <: AbstractMetaArray}
    Dict(
        metadatakeys(ma) .=> [metadata(ma, key; style = style) for key in metadatakeys(ma)],
    )
end

function DataAPI.metadata!(
        ma::MA,
        key::AbstractString,
        value;
        style::Symbol = :default
) where {MA <: AbstractMetaArray}
    DataAPI.metadatasupport(MA).write ||
        throw(ArgumentError("Writing metadata not supported for type $MA."))
    ma._metadata[key] = (value, style)
    return ma
end

function DataAPI.deletemetadata!(
        ma::MA, key::AbstractString) where {MA <: AbstractMetaArray}
    DataAPI.metadatasupport(MA).write ||
        throw(ArgumentError("Writing metadata not supported for type $MA."))
    delete!(ma._metadata, key)
    return ma
end

function DataAPI.emptymetadata!(ma::MA) where {MA <: AbstractMetaArray}
    DataAPI.metadatasupport(MA).write ||
        throw(ArgumentError("writing metadata not supported for type $MA."))
    empty!(ma._metadata)
    return ma
end

function DataAPI.colmetadatakeys(ma::MA, col::Symbol) where {MA <: AbstractMetaArray}
    (ColMetadataTrait(MA) isa NoColMetadata) &&
        throw(ArgumentError("Column metadata not supported for type $MA."))
    DataAPI.colmetadatasupport(MA).read ||
        throw(ArgumentError("reading column metadata not supported for type $MA."))
    colmeta = getfield(ma, :_colmetadata)
    if !haskey(colmeta, col) || isempty(colmeta)
        throw(ArgumentError("Column $col not found in $MA."))
    end
    meta = colmeta[col]
    keys(meta)
end

function DataAPI.colmetadatakeys(ma::MA) where {MA <: AbstractMetaArray}
    (ColMetadataTrait(MA) isa NoColMetadata) &&
        throw(ArgumentError("Column metadata not supported for type $MA."))
    DataAPI.colmetadatasupport(MA).read ||
        throw(ArgumentError("Reading column metadata not supported for type $MA."))
    return (col => colmetadatakeys(ma, col) for col in keys(ma._colmetadata))
end

function DataAPI.colmetadata(
        ma::MA,
        col::Symbol,
        key::AbstractString,
        default = MetaDataMissingDefault();
        style::Bool = false
) where {MA <: AbstractMetaArray}
    (ColMetadataTrait(MA) isa NoColMetadata) &&
        throw(ArgumentError("Column metadata not supported for type $MA."))
    DataAPI.colmetadatasupport(MA).read ||
        throw(ArgumentError("Reading column metadata not supported for type $MA."))
    colmeta = getfield(ma, :_colmetadata)
    if !haskey(colmeta, col) || isempty(colmeta)
        throw(ArgumentError("Column $col not found in $MA."))
    end
    meta = colmeta[col]
    _metadata_info(meta, key, default, style, col)
end
function DataAPI.colmetadata(
        ma::MA,
        col::Symbol;
        style::Bool = false
) where {MA <: AbstractMetaArray}
    Dict(
        colmetadatakeys(ma, col) .=>
        [colmetadata(ma, col, key; style = style) for key in colmetadatakeys(ma, col)],
    )
end

function DataAPI.colmetadata!(
        ma::MA,
        col::Symbol,
        key::AbstractString,
        value;
        style::Symbol = :default
) where {MA <: AbstractMetaArray}
    (ColMetadataTrait(MA) isa NoColMetadata) &&
        throw(ArgumentError("Column metadata not supported for type $MA."))
    DataAPI.colmetadatasupport(MA).write ||
        throw(ArgumentError("Writing column metadata not supported for type $MA."))
    colmeta = getfield(ma, :_colmetadata)
    if !haskey(colmeta, col) || isempty(colmeta)
        throw(ArgumentError("Column $col not found in $MA."))
    end
    meta = colmeta[col]
    meta[key] = (value, style)
    return ma
end

function DataAPI.deletecolmetadata!(
        ma::MA,
        col::Symbol,
        key::AbstractString
) where {MA <: AbstractMetaArray}
    (ColMetadataTrait(MA) isa NoColMetadata) &&
        throw(ArgumentError("Column metadata not supported for type $MA."))
    DataAPI.colmetadatasupport(MA).write ||
        throw(ArgumentError("Writing column metadata not supported for type $MA."))
    colmeta = getfield(ma, :_colmetadata)
    if !haskey(colmeta, col) || isempty(colmeta)
        throw(ArgumentError("Column $col not found in $MA."))
    end
    meta = colmeta[col]
    delete!(meta, key)
    return ma
end
function DataAPI.emptycolmetadata!(ma::MA, col::Symbol) where {MA <: AbstractMetaArray}
    (ColMetadataTrait(MA) isa NoColMetadata) &&
        throw(ArgumentError("Column metadata not supported for type $MA."))
    DataAPI.colmetadatasupport(MA).write ||
        throw(ArgumentError("Writing column metadata not supported for type $MA."))

    colmeta = getfield(ma, :_colmetadata)
    if !haskey(colmeta, col) || isempty(colmeta)
        throw(ArgumentError("Column $col not found in $MA."))
    end
    delete!(colmeta, col)
    return ma
end

function DataAPI.emptycolmetadata!(ma::MA) where {MA <: AbstractMetaArray}
    (ColMetadataTrait(MA) isa NoColMetadata) &&
        throw(ArgumentError("Column metadata not supported for type $MA."))
    DataAPI.colmetadatasupport(MA).write ||
        throw(ArgumentError(" Writing column metadata not supported for type $MA."))
    colmeta = getfield(ma, :_colmetadata)
    empty!(colmeta)
    return ma
end
