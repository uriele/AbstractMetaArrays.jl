"""
    module AbstractMetaArrays

A Julia package providing an abstract interface and utilities for arrays with attached metadata and optional column metadata.

# Overview

`AbstractMetaArrays` defines the abstract type [`AbstractMetaArray`](@ref), which extends the standard `AbstractArray` interface to support:
- **Metadata**: Arbitrary key-value pairs describing the array as a whole.
- **Column Metadata**: Metadata associated with individual columns or components (optional).

Concrete implementations (such as [`SimpleMetaArray`](@ref)) inherit from `AbstractMetaArray` and provide storage and trait-based control over metadata support.

# Main Types

- [`AbstractMetaArray`](@ref): Abstract type for meta arrays.
- [`AbstractMetaVector`](@ref), [`AbstractMetaMatrix`](@ref): Aliases for 1D and 2D meta arrays.
- [`SimpleMetaArray`](@ref): A concrete implementation with full metadata and column metadata support.
- [`MetaType`](@ref): Alias for the metadata dictionary type.
- [`DictOrNothing`](@ref): Alias for `Union{Dict, Nothing}` for optional metadata arguments.

# Traits

- [`ColMetadataTrait`](@ref): Indicates if column metadata is supported.
- [`ColMetadataStyle`](@ref): Controls read/write access to column metadata.
- [`MetadataStyle`](@ref): Controls read/write access to array metadata.

# Utilities

- [`create_metaarray`](@ref): Helper for constructing metadata and column metadata dictionaries for new arrays.

# Integration

The package integrates with [DataAPI.jl](https://github.com/JuliaData/DataAPI.jl) for a standard metadata interface, and provides extensions for compatibility with packages like StaticArrays and StructArrays.

# Example

```julia
using AbstractMetaArrays, StaticArrays

arr = SimpleMetaArray(SVector{3}(1,2,3), Dict("description" => ("test", :entry)), Dict(:x => Dict("unit" => ("m", :default))))
desc = metadata(arr, "description")  # returns "test"
```

See the documentation for details on implementing custom meta arrays and extending metadata support.
"""
module AbstractMetaArrays
using Reexport
using Lazy: @forward
using DataAPI
@reexport import DataAPI: metadata, metadata!, metadatakeys, metadatasupport
@reexport import DataAPI: colmetadata, colmetadata!, colmetadatakeys, colmetadatasupport
@reexport import DataAPI:
                          deletemetadata!, emptymetadata!, deletecolmetadata!,
                          emptycolmetadata!
@reexport import DataAPI: colmetadatasupport, metadatasupport
# Write your package code here.
export AbstractMetaArray, AbstractMetaVector, AbstractMetaMatrix, SimpleMetaArray
#export HasColMetadata, NoColMetadata
#export ReadWriteMetadata, ReadOnlyMetadata, WriteOnlyMetadata,PrivateMetadata
#export ReadWriteColMetadata, ReadOnlyColMetadata, WriteOnlyColMetadata,PrivateColMetadata

export create_metaarray
export MetaType, DictOrNothing
# new types for dispaching on the metadata
"""
  MetaType<: Dict{<:AbstractString,Tuple{Any,Symbol}}

Alias for the metadata type. It is a dictionary with string keys and values of type `Tuple{Any,Symbol}`.
"""
const MetaType = Dict{<:AbstractString, Tuple{Any, Symbol}}
const ConcreteMetaType = Dict{String, Tuple{Any, Symbol}}
const DictOrNothing = Union{Dict, Nothing}

include("abstractmetaarray.jl")
include("traits.jl")
include("metadata.jl")
include("helpers.jl")
include("utility.jl")
include("simplemetaarray.jl")

end
