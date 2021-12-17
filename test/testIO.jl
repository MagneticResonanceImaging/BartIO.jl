@testset "IO" begin
    @testset "FileExist" begin
        @test isfile("test/data/in.cfl")
        @test isfile("test/data/in.hdr")
    end

    @testset "ReadWrite" begin
        ## Read bart files
        println(pwd())
        im = BartIO.readcfl("test/data/in")

        ## test writing to file
        filename="test/res/out"
        BartIO.writecfl(filename,im)

        ## Read back that files
        im2 = BartIO.readcfl(filename)

        ## test
        @test im == im2
    end
end






