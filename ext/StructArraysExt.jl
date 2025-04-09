using StructArrays
using AbstractMetaArrays
using Lazy
using DataAPI
using Tables

# delegate the Tables interface to the underlying _data
@forward AbstractMetaArray._data Tables.columns, Tables.schema, Tables.materializer, Tables.isrowtable, Tables.columnaccess, Tables.isrowtable
