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
        filenameOut="data/out"
        BartIO.writecfl(filenameOut,im)
        ## Read back that files
        im2 = BartIO.readcfl(filenameOut)
        rm(filenameOut*".hdr")
        rm(filenameOut*".cfl")

        ## test
        @test im == im2
        
    end
end






