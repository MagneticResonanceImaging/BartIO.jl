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

@testset "BART" begin
    pathtobart = "/home/runner/work/BartIO.jl/BartIO.jl/bart"
    pathtobartpy = "/home/runner/work/BartIO.jl/BartIO.jl/bartpy"

    @testset "BART_files" begin
        @test isdir(pathtobart)
        @test isdir(pathtobartpy)

        strpy = readchomp(`python3 script.py`)
        @test strpy == "hello world"
    end

    @testset "BART_exec" begin
        #=
        python_pycall = PyCall.python
 
        PyCall.py"""
        import os
        os.environ['TOOLBOX_PATH'] = $pathtobart
        print(os.environ['TOOLBOX_PATH'])
        os.chdir($pathtobartpy)
        os.system($python_pycall + " setup.py install --user")
        """

        #@PyCall.pyimport bartpy.tools as bartpy #Equivalent to -> bartpy = pyimport("bartpy.tools") but does not work in module...
        bartpy = pyimport("bartpy.tools")
        bartpy.version()
        =#

        bartpy = BartIO.initBart(path2bart = pathtobart, path2bartpy = pathtobartpy)
        @test typeof(bartpy) == PyObject
        @test size(bartpy.phantom()) == (128, 128)

        bartpy2 = BartIO.initBart()
        @test size(bartpy2.phantom()) == (128, 128)
    end
end






