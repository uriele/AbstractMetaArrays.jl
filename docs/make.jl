using AbstactMetaArrays
using Documenter

DocMeta.setdocmeta!(AbstactMetaArrays, :DocTestSetup, :(using AbstactMetaArrays); recursive=true)

makedocs(;
    modules=[AbstactMetaArrays],
    authors="uriele <menarini.marco@gmail.com> and contributors",
    sitename="AbstactMetaArrays.jl",
    format=Documenter.HTML(;
        canonical="https://marcom.github.io/AbstactMetaArrays.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/marcom/AbstactMetaArrays.jl",
    devbranch="master",
)
