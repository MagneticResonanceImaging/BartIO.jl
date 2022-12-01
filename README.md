# BartIO.jl

[![Build Status](https://github.com/MagneticResonanceImaging/BartIO.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/MagneticResonanceImaging/BartIO.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/MagneticResonanceImaging/BartIO.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/MagneticResonanceImaging/BartIO.jl)

BartIO.jl is a Julia package in order to interact with the [Berkeley Advanced Reconstruction Toolbox (BART)](https://mrirecon.github.io/bart/). 

This package offers the possibility to :
- read and write cfl/hdr files used by the BART Toolbox
- Call BART command (required to install the [BART toolbox](https://github.com/mrirecon/bart)

## Input/Output files in BART format (.cfl + .hdr)
To load BART data (stored in a .cfl and a .hdr header file), simply call `readcfl(filename)`, where `filename` can be either be without a filename extension, or it can include `.cfl` or `.hdr`. 

To write BART compatible files, call  `writecfl(filename, x)`, where `filename` can be either be without a filename extension, or it can include `.cfl` or `.hdr`. 

## Calling function from BART

BartIO copy the functionnality of the Python wrapper in BART : https://github.com/mrirecon/bart/blob/master/python/bart.py
### Requirements
 - The BART toolbox need to be compiled.

### Setup

Define the path to the bart executable :
```julia
    set_bart_path("/home/CODE/bart-master/bart")
```

### How to use BartIO

The first integer correspond to the number of output files expected. 0 -> no return
```julia
bart(0,"version")
k_phant = bart(1,"phantom -x64 -k")
```

If you want to pass an array (needs to be in `ComplexF32` format) as args : 

```julia
traj = bart(1,"traj -x 128 -y 256 -r")
k_phant = bart(1,"phantom -k -t",traj)
im_phant = bart(1,"nufft -i",traj,k_phant) 
```
Note if you pass multiple arguments, they are concatenated at the end of the command line. The last 2 lines are equivalent to :

```bash
bart phantom -k -t traj k_phant
bart nufft -i traj k_phant im_phant
```

Alternatively you can pass optional arrays with keywords
```julia
k_phant = bart(1,"phantom -k",t=traj)
```

Alternatively you can pass 



If you want to know the available function in BART :
```julia
bart()
```

If you need help for the function you can use :
```
bart(0,"pics -h")
```

### Alternatively
BART can be called from the terminal :
```julia
pathto_bart_exec="/home/CODE/bart-master/bart"
run(`$pathto_bart_exec version`)
```