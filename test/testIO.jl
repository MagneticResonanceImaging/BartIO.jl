@testset "IO" begin
    @testset "FileExist" begin
        @test isfile("data/in.cfl")
        @test isfile("data/in.hdr")
    end

    @testset "ReadWrite" begin
        ## Read bart files
        println(pwd())
        filenameIn = "data/in"
        im = BartIO.readcfl(filenameIn)

        ## test writing to file
        filenameOut = "data/out"
        BartIO.writecfl(filenameOut, im)
        ## Read back that files
        im2 = BartIO.readcfl(filenameOut)
        rm(filenameOut * ".hdr")
        rm(filenameOut * ".cfl")

        ## test
        @test im == im2

    end
end

@testset "BART" begin
    pathtobart = "/home/runner/work/BartIO.jl/BartIO.jl/bart"

    if Sys.isapple()
        @warn "BART execution is currently not tested on macOS version"

        @info "test pycall setup"
        python_pycall = PyCall.python
        run(`$python_pycall -m pip install numpy`)
        PyCall.py"""
        import os
        import sys
        os.environ['TOOLBOX_PATH'] = $pathtobart
        path = os.environ["TOOLBOX_PATH"] + "/python/"
        sys.path.append(path)
        """

    else
        @info "test whole wrapper"
        bart = BartIO.wrapperBart(pathtobart)
        phant = bart(1,"phantom")
        @test size(phant) == (128, 128)
    end
end
