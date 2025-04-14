module AbstractMetaArrays
using Reexport
using Lazy: @forward
using DataAPI
import DataAPI: metadata,metadata!, metadatakeys,metadatasupport
import DataAPI: colmetadata, colmetadata!, colmetadatakeys, colmetadatasupport
import DataAPI: deletemetadata!, emptymetadata!,deletecolmetadata!,emptycolmetadata!

export metadata,metadata!, metadatakeys,metadatasupport
export colmetadata, colmetadata!, colmetadatakeys, colmetadatasupport
export deletemetadata!, emptymetadata!,deletecolmetadata!,emptycolmetadata!
# Write your package code here.
export AbstractMetaArray, AbstractMetaVector,AbstractMetaMatrix,SimpleMetaArray
export HasColMetadata, NoColMetadata, ReadColMetadata, WriteColMetadata
export colmetadata_properties,ColMetadataTrait
export create_metaarray
export MetaType, DictOrNothing
# new types for dispaching on the metadata
const MetaType = Dict{<:AbstractString,<:Tuple{Any,Symbol}}
const DictOrNothing = Union{Dict,Nothing}

include("abstractmetaarray.jl")
include("traits.jl")
include("metadata.jl")
include("helpers.jl")
include("simplemetaarray.jl")


end
