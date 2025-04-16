using AbstractMetaArrays
using StaticArrays
using Documenter

DocMeta.setdocmeta!(
    AbstractMetaArrays,
    :DocTestSetup,
    :(using AbstractMetaArrays);
    recursive = true
)

makedocs(;
    modules = [AbstractMetaArrays],
    authors = "uriele <menarini.marco@gmail.com> and contributors",
    sitename = "AbstractMetaArrays.jl",
    format = Documenter.HTML(;
        canonical = "https://uriele.github.io/AbstractMetaArrays.jl",
        edit_link = "master",
        assets = String[]
    ),
    pages = ["Home" => "index.md"]
)

deploydocs(; repo = "github.com/uriele/AbstractMetaArrays.jl", devbranch = "master")
