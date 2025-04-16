
"""
  $(@__MODULE__).create_metaarray(::Type{MA}, A::AbstractArray, meta=nothing, colmeta=nothing) where {MA<:AbstractMetaArray}

helper function to the metadata and colmetadata constructors given a concrete implemetation of the AbstractMetaArray and of the AbstractArray it contains.
The function returns a tuple of metadata and colmetadata.
The metadata is a dictionary with string keys and values of type `Tuple{Any,Symbol}`.
The colmetadata is a dictionary with symbol keys and values of type `MetaType` if the MetaArray has column metadata,
otherwise it is return nothing.

Note: The format of the metatada is given bt the `MetaType` type as a dictionary with string keys and values of type `Tuple{Any,Symbol}`. If the dictionary provided
is in the value in not in the form of a Tuple{Any,Symbol} it will be converted to this format by appending the `:default` key to the value.


  # Arguments
  - `MA`: Type of the metaarray.
  - `A`: Abstract array to be wrapped.
  - `meta`: Default metadata to be used if not provided. It can be a Dict or Nothing.
  - `colmeta`: Default column metadata to be used if not provided. It can be a Dict or Nothing or a Tuple of Dicts.


  # Returns
  A tuple containing the metadata and colmetadata.

  # Example
  ```jldoctest
  julia> using StaticArrays
  julia> create_metaarray(SimpleMetaArray, SVector{3}(1,1,1), Dict("description" => ("test array", :entry)),
          Dict("unit" => ("m", :default)))
  (Dict("description" => ("test array", :entry)),
   Dict(:x => Dict("unit" => ("m", :default)), :y => Dict("unit" => ("m", :default)), :z => Dict("unit" => ("m", :default))))

  julia>create_metaarray(SimpleMetaArray, SVector{3}(1,1,1),Dict("description" => ("test array", :entry)),
          (Dict("unit" => ("m", :default)),
           Dict("unit" => ("km", :default)),
           Dict("unit" => ("cm", :default))))
(Dict("description" => ("test array", :entry)),
 Dict(:x => Dict("unit" => ("m", :default))),
      :y => Dict("unit" => ("km", :default)),
      :z => Dict("unit" => ("cm", :default)))
  ```
"""
function create_metaarray(
        ::MA,
        S,
        meta::DictOrNothing = nothing,
        colmeta = nothing
) where {MA <: Type}
    return _create_metaarray(ColMetadataTrait(MA), S, meta, colmeta)
end
