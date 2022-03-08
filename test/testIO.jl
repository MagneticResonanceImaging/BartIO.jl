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
    pathtobartpy = "/home/runner/work/BartIO.jl/BartIO.jl/bartpy"

    if !(isdir(pathtobart) && isdir(pathtobartpy))
        @info("BART wrapper is only tested on github actions")
    else
        @testset "BART_files" begin
            @test isdir(pathtobart)
            @test isdir(pathtobartpy)

            strpy = readchomp(`python3 script.py`)
            @test strpy == "hello world"
        end

        @testset "BART_exec" begin

            BartIO.initBart(path2bart = pathtobart)
            bart = BartIO.wrapperBart()
            phant = bart.bart(1,"phantom")
            @test size(phant) == (128, 128)

            BartIO.initBart(path2bart = pathtobart, path2bartpy = pathtobartpy)

            bartpy = BartIO.wrapperBartpy()
            @test typeof(bartpy) == PyObject
            @test size(bartpy.phantom()) == (128, 128)
        end
    end
end






