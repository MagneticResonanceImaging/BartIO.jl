# BartIO.jl

[![Build Status](https://github.com/aTrotier/BartIO.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/aTrotier/BartIO.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/aTrotier/BartIO.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/aTrotier/BartIO.jl)

BartIO.jl is a Julia package in order to interact iwth the [Berkeley Advanced Reconstruction Toolbox (BART)](https://mrirecon.github.io/bart/). 

This package offers the possibility to :
- read and write cfl/hdr files used by the BART Toolbox
- Call BART command (required to install the [BART toolbox](https://github.com/mrirecon/bart) and to download [BARTPY](https://github.com/mrirecon/bartpy) (it will be install the initBart function from this package)

## IO to BART
To load BART data (stored in a .cfl and a .hdr header file), simply call `readcfl(filename)`, where `filename` can be either be without a filename extension, or it can include `.cfl` or `.hdr`. 

To write BART compatible files, call  `writecfl(filename, x)`, where `filename` can be either be without a filename extension, or it can include `.cfl` or `.hdr`. 

## Calling function from BART

**Requirements**
 - The BART toolbox need to be compiled.
 - bartpy is already downloaded

**Usage**
```julia
bartpy = BartIO.initBart(path2bartFolder,path2bartpyFolder)
bartpy.version()
k_phant = bartpy.phantom(x=64,k=1)
```

If you need help for the function you can either use :
```
run(`bart pics -h`)
```

or import with pycall the help function :
```julia
pyhelp = pybuiltin("help")
pyhelp(bartpy.phantom)
```