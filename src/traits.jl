
"""
  $(@__MODULE__).ColMetadataTrait(x::Type)
  $(@__MODULE__).ColMetadataTrait(x)

A trait function used to determine if a type or an instance `x` has column metadata associated with it.
This can be used to dispatch on types or instances that support column metadata. Default behavior is to return `NoColMetadata()`.

# Arguments
- `x::Type`: A type to check for column metadata support.
- `x`: An instance to check for column metadata support.

# Return
- `HasColMetadata()`: Indicates that the type or instance has column metadata support.
- `NoColMetadata()`: Indicates that the type or instance does not have column metadata support.
"""
abstract type ColMetadataTrait end
struct HasColMetadata <: ColMetadataTrait end
struct NoColMetadata <: ColMetadataTrait end

ColMetadataTrait(::Type) = NoColMetadata()
ColMetadataTrait(x) = ColMetadataTrait(typeof(x))

"""
  $(@__MODULE__).MetadataStyle(x::Type)
  $(@__MODULE__).MetadataStyle(x)

A trait function used to determine the metadata support of a type or an instance `x`. This is used by the implementation of `DataAPI.metadatasupport` implemented by this module, to
define reading and writing permissions for metadata. Default behavior is to return `ReadWriteMetadata()`.

# Arguments
- `x::Type`: A type to check for metadata support.
- `x`: An instance to check for metadata support.

# Return
- `ReadWriteMetadata()`: Indicates that the type or instance has read and write metadata support.
- `ReadOnlyMetadata()`: Indicates that the type or instance has read-only metadata support.
- `WriteOnlyMetadata()`: Indicates that the type or instance has write-only metadata support.
- `PrivateMetadata()`: Indicates that the type or instance does not have metadata support.

"""
abstract type MetadataStyle end

"""
  $(@__MODULE__).ColMetadataStyle(x::Type)
  $(@__MODULE__).ColMetadataStyle(x)

A trait function used to determine the column metadata support of a type or an instance `x`. This is used by the implementation of `DataAPI.colmetadatasupport` implemented by this module, to
define reading and writing permissions for column metadata. Default behavior is to return `ReadWriteColMetadata()`.

Note: If the ColMetadataTrait is `NoColMetadata`, this function will be ignored.

# Arguments
- `x::Type`: A type to check for column metadata support.
- `x`: An instance to check for column metadata support.

# Return
- `ReadWriteColMetadata()`: Indicates that the type or instance has read and write column metadata support.
- `ReadOnlyColMetadata()`: Indicates that the type or instance has read-only column metadata support.
- `WriteOnlyColMetadata()`: Indicates that the type or instance has write-only column metadata support.
- `PrivateColMetadata()`: Indicates that the type or instance does not have column metadata support.

See also: [`ColMetadataTrait`](@ref) for more information on column metadata support.
"""
abstract type ColMetadataStyle end

struct ReadWriteMetadata <: MetadataStyle end
struct ReadOnlyMetadata <: MetadataStyle end
struct WriteOnlyMetadata <: MetadataStyle end
struct PrivateMetadata <: MetadataStyle end

struct ReadWriteColMetadata <: ColMetadataStyle end
struct ReadOnlyColMetadata <: ColMetadataStyle end
struct WriteOnlyColMetadata <: ColMetadataStyle end
struct PrivateColMetadata <: ColMetadataStyle end

MetadataStyle(::Type) = ReadWriteMetadata()
MetadataStyle(x) = MetadataStyle(typeof(x))
ColMetadataStyle(::Type) = ReadWriteColMetadata()
ColMetadataStyle(x) = ColMetadataStyle(typeof(x))
