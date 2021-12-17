@testset "IO" begin
    @testset "FileExist" begin
        @test isfile("data/in.cfl")
        @test isfile("data/in.hdr")
    end

    @testset "ReadWrite" begin
        ## Read bart files
        println(pwd())
        im = BartIO.readcfl("data/in")

        ## test writing to file
        filename="res/out"
        BartIO.writecfl(filename,im)

        ## Read back that files
        im2 = BartIO.readcfl(filename)

        ## test
        @test im == im2
    end
end






