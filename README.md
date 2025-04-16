# AbstractMetaArrays

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://marcom.github.io/AbstactMetaArrays.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://marcom.github.io/AbstactMetaArrays.jl/dev/)
[![Build Status](https://github.com/marcom/AbstactMetaArrays.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/marcom/AbstactMetaArrays.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)


AbstractMetaArrays is a Julia package designed to provide a flexible and efficient framework for working with metadata-enriched arrays. It enables seamless integration of metadata with array operations, making it ideal for scientific computing and data analysis.

## Features

- Support for metadata-aware array operations.
- High performance and compatibility with Julia's array ecosystem.
- Easy-to-use API for defining and manipulating metadata.

## Installation

Install AbstractMetaArrays using Julia's package manager:

```julia
using Pkg
Pkg.add("AbstractMetaArrays")
```

## Usage

```julia
using AbstractMetaArrays, StructArrays
using Unitful: km, ustrip,uconvert,m
using CoordRefSystems

struct Ray{T}
    point_x::T
    point_y::T
    direction_x::T
    direction_y::T
end

rays=StructArray(Array{Ray{Float64},1}(undef,1000))
a= majoraxis(ellipsoid(WGS84Latest)) |>
   x-> uconvert(km,x) |> ustrip

# Example usage
meta_rays = SimpleMetaArray(rays, 
    Dict("datum" => (WGS84Latest,:datum),"major_axis" => (a,:normalization)),
    Dict("units"=>(km,:unit),"normalized"=>(false,:Bool)))
```

For more details, check out the [documentation](https://marcom.github.io/AbstactMetaArrays.jl/stable/).
