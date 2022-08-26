@testset "IO" begin
    @testset "FileExist" begin
        @test isfile("data/in.cfl")
        @test isfile("data/in.hdr")
    end

    @testset "ReadWrite" begin
        ## Read bart files
        println(pwd())
        filenameIn = "data/in"
        im = read_cfl(filenameIn)

        ## test writing to file
        filenameOut = "data/out"
        write_cfl(filenameOut, im)
        ## Read back that files
        im2 = read_cfl(filenameOut)
        rm(filenameOut * ".hdr")
        rm(filenameOut * ".cfl")

        ## test
        @test im == im2

    end
end

@testset "BART" begin
    if Sys.isapple()
        pathtobart ="/Users/runner/work/BartIO.jl/BartIO.jl/bart"
    else
        pathtobart = "/home/runner/work/BartIO.jl/BartIO.jl/bart"
    end

    bart = wrapper_bart(pathtobart)
    phant = bart(1,"phantom")
    @test size(phant) == (128, 128)
end
