using AbstactMetaArrays
using Test
using Aqua

@testset "AbstactMetaArrays.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(AbstactMetaArrays)
    end
    # Write your tests here.
end
