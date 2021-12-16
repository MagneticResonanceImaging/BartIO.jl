include("/Users/aurelien/Nextcloud/_PARA/PROJECTS/2-SUPPORT/2021_learning_julia/working_with_bart/BartIO.jl/src/BartIO.jl")

## Read bart files
im = BartIO.readcfl("/Users/aurelien/Nextcloud/_PARA/PROJECTS/2-SUPPORT/2021_learning_julia/working_with_bart/BartIO.jl/test/data")

## test writing to file
filename="/Users/aurelien/Nextcloud/_PARA/PROJECTS/2-SUPPORT/2021_learning_julia/working_with_bart/BartIO.jl/test/test"
BartIO.writecfl(filename,im)

## Read back that files
im2 = BartIO.readcfl(filename)

## test
im == im2




