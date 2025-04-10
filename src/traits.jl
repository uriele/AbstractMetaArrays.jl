
abstract type ColMetadataTrait end
struct HasColMetadata <: ColMetadataTrait end
struct NoColMetadata  <: ColMetadataTrait end
struct ReadColMetadata <: ColMetadataTrait end
struct WriteColMetadata <: ColMetadataTrait end

ColMetadataTrait(::Type) = NoColMetadata()
ColMetadataTrait(x) = ColMetadataTrait(typeof(x))

# Need to implement if the subtype has colmetadatas

colmetadata_properties(x::Type{T}) where T = colmetadata_properties(ColMetadataTrait(T),x)
colmetadata_properties(x::T) where T = colmetadata_properties(ColMetadataTrait(T),x)
colmetadata_properties(::HasColMetadata,x) = (read=true,write=true)
colmetadata_properties(::NoColMetadata,x)  = (read=false,write=false)
colmetadata_properties(::ReadColMetadata,x) = (read=true,write=false)
colmetadata_properties(::WriteColMetadata,x) = (read=false,write=true)
