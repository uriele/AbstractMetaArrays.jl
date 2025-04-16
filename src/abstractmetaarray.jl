"""
  AbstractMetaArray{T,N,A<:AbstractArray{T,N}} <: AbstractArray{T,N}

  AbstractMetaArray is an abstract type that represents a meta array with metadata and optional column metadata.
  It is a subtype of AbstractArray and provides a common interface for all meta arrays. All the concrete implementations of
  AbstractMetaArray should inherit from this type.
  The type parameters are:
  - `T`: The element type of the array.
  - `N`: The number of dimensions of the array.
  - `A`: The concrete type of the array. It should be a subtype of AbstractArray{T,N}.

  The concrete implementations of AbstractMetaArray should define the following fields:
  - `_data`: The underlying data of the array. It should be a subtype of AbstractArray{T,N}.
  - `_metadata`: The metadata of the array. It should be a dictionary with string keys and values of type `Tuple{Any,Symbol}`.
  - `_colmetadata`: The column metadata of the array. It should be a dictionary with symbol keys and values of type `MetaType`.

  The concrete implementations of AbstractMetaArray should also define the following traits:
  - `ColMetadataTrait`: Defines if the meta array supports column metadata or not. It should be a subtype of ColMetadataTrait. By default, it is NoColMetadata().
  - `ColMetadataStyle`: Defines the access to the column metadata (reading, writing, both, or none). It should be a subtype of ColMetadataStyle.
  - `MetadataTrait`: Defines if the meta array supports metadata or not. It should be a subtype of MetadataTrait. By default, it is NoMetadata().

  For simplicity a non exported function `create_metaarray` is defined to create the metadata and colmetadata for the meta array.
  It is used in the constructor of the meta array.


  See also [`SimpleMetaArray`](@ref) for a concrete implementation of the AbstractMetaArray.
    [`create_metaarray`](@ref) for a helper function to create the metadata and colmetadata for the meta array.
    [`ColMetadataTrait`](@ref) for the trait that defines if the meta array supports column metadata or not.
    [`ColMetadataStyle`](@ref) for the trait that defines the access to the column metadata.
    [`MetadataStyle`](@ref) for the trait that defines the access to the metadata.

"""
abstract type AbstractMetaArray{T, N, A <: AbstractArray{T, N}} <: AbstractArray{T, N} end
"""
    AbstractMetaVector{T}

Alias for `AbstractMetaArray{T,1}`. Represents a 1-dimensional meta array.
"""
const AbstractMetaVector{T} = AbstractMetaArray{T, 1}
"""
    AbstractMetaMatrix{T}

Alias for `AbstractMetaArray{T,2}`. Represents a 2-dimensional meta array.
"""
const AbstractMetaMatrix{T} = AbstractMetaArray{T, 2}

# Interfaces for AbstractMetaArray

@forward AbstractMetaArray._data Base.getindex,
Base.setindex!,
Base.size,
Base.eltype,
Base.parent,
Base.axes,
Base.iterate

function Base.reshape(ma::MA, d::Dims{N}) where {MA <: AbstractMetaArray{T}} where {T, N}
    meta = deepcopy(ma._metadata)
    data = reshape(ma._data, d)
    MA1 = typeof(ma).name.wrapper
    return ColMetadataTrait(MA) != NoColMetadata() ?
           MA1(data, meta, deepcopy(ma._colmetadata)) : MA1(data, meta)
end

# Define a custom `similar` method for MetaArray
function Base.similar(
        ma::MA,
        ::Type{S},
        dims::Dims{N}
) where {T, S, N, A, MA <: AbstractMetaArray{T, N, A}}
    # Create a new MetaArray with the same metadata and the specified element type and dimensions

    return ColMetadataTrait(MA) == NoColMetadata() ?
           MA.name.wrapper(similar(parent(ma), S, dims), deepcopy(ma._metadata)) :
           MA.name.wrapper(
        similar(parent(ma), S, dims),
        deepcopy(ma._metadata),
        _collectvalues(ma._colmetadata)
    )
end

function Base.sort!(ma::MA; kwargs...) where {MA <: AbstractMetaArray{T, N}} where {T, N}
    sort!(ma._data; kwargs...)
end

function Base.similar(
        ma::MA, ::Type{S}) where {MA <: AbstractMetaArray{T, N}} where {T, S, N}
    similar(ma, S, size(ma))
end

function Base.getproperty(
        m::MA,
        key::Symbol
) where {MA <: AbstractMetaArray{T, N, A}} where {T, N, A <: AbstractArray}
    if key == :_data || key == :_metadata
        return getfield(m, key)
    elseif key == :_colmetadata
        return (ColMetadataTrait(MA) isa HasColMetadata) ? getfield(m, key) : nothing
    else
        return _metacomponent(m._data, key)
    end
end

Base.propertynames(ma::MA) where {MA <: AbstractMetaArray} = propertynames(ma._data)

function showfields(io::IO, fields::NTuple{N, Any}) where {N}
    print(io, "(")
    for (i, field) in enumerate(fields)
        Base.showarg(io, fields[i], false)
        i < N && print(io, ", ")
    end
    print(io, ")")
end

function Base.showarg(
        io::IO,
        ma::MA,
        toplevel
) where {MA <: AbstractMetaArray{T, N}} where {T, N}
    typeinfo = typeof(ma)
    print(
        io,
        typeinfo.name.wrapper,
        "{$(typeinfo.parameters[1]), $(typeinfo.parameters[2])}"
    )
end

@inline _collectvalues(x) = deepcopy(tuple(collect(values(x))...))

# copy that creates a new instance of the same type with the same data and metadata
function Base.copy(ma::MA) where {MA <: AbstractMetaArray{T, N}} where {T, N}
    if ColMetadataTrait(MA) isa NoColMetadata
        return MA.name.wrapper(copy(ma._data), deepcopy(ma._metadata))
    else
        return MA.name.wrapper(
            copy(ma._data),
            deepcopy(ma._metadata),
            _collectvalues(ma._colmetadata)
        )
    end
end

function Base.copyto!(
        dest::MA,
        src::MB
) where {MA <: AbstractMetaArray{T, N}, MB <: AbstractMetaArray{T, N}} where {T, N}
    copyto!(dest._data, src._data)
    emptymetadata!(dest)
    emptycolmetadata!(dest)
    for (k, v) in src._metadata
        dest._metadata[k] = deepcopy(v)
    end
    if (ColMetadataTrait(MA) isa HasColMetadata && ColMetadataTrait(MB) isa HasColMetadata)
        for (k, v) in src._colmetadata
            dest._colmetadata[k] = deepcopy(v)
        end
    end
    return dest
end
