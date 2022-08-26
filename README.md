# BartIO.jl

[![Build Status](https://github.com/aTrotier/BartIO.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/aTrotier/BartIO.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/aTrotier/BartIO.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/aTrotier/BartIO.jl)

BartIO.jl is a Julia package in order to interact with the [Berkeley Advanced Reconstruction Toolbox (BART)](https://mrirecon.github.io/bart/). 

This package offers the possibility to :
- read and write cfl/hdr files used by the BART Toolbox
- Call BART command (required to install the [BART toolbox](https://github.com/mrirecon/bart)

## IO to BART
To load BART data (stored in a .cfl and a .hdr header file), simply call `readcfl(filename)`, where `filename` can be either be without a filename extension, or it can include `.cfl` or `.hdr`. 

To write BART compatible files, call  `writecfl(filename, x)`, where `filename` can be either be without a filename extension, or it can include `.cfl` or `.hdr`. 

## Calling function from BART

**Requirements**
 - The BART toolbox need to be compiled.

**Usage**
```julia
bart = wrapper_bart(path2bartFolder)
bart(0,"version")
k_phan = bart(0,"phantom -x64 -k")
```

If you need help for the function you can either use :
```
bart(0,"pics -h")
```