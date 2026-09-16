# CPU by default. To enable CUDA locally, run from the repository root:
# using Pkg
# Pkg.activate("test"); Pkg.add("BART_CUDA_jll"); Pkg.activate(".")
# Pkg.test("BartIO"; test_args=["CUDA"])
# Do not commit the optional test dependency.

using Test
using BartIO

include("testIO.jl");
if "CUDA" in ARGS
    import BART_CUDA_jll
end
include("testRecon.jl")
