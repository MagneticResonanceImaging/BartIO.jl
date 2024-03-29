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
    if !haskey(ENV, "TOOLBOX_PATH") || isempty(ENV["TOOLBOX_PATH"])
        pathtobart = Sys.isapple() ? "/Users" : "/home"
        pathtobart *= "/runner/work/BartIO.jl/BartIO.jl/bart/bart"
        set_bart_path(pathtobart)
    end
    bart(0, "version")

    phant = bart(1, "phantom")
    @test size(phant) == (128, 128)

    # test kwargs
    traj = bart(1,"traj -x 128 -y 256 -r")
    k_phant = bart(1,"phantom -k",t=traj)
    @test size(k_phant) == (1,128,256)

    im_phant = bart(1,"nufft -i",traj,k_phant)
    @test size(im_phant) == (128,128)
end
