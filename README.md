# BartIO.jl

![][docs-img]][docs-url]
[![Coverage](https://codecov.io/gh/MagneticResonanceImaging/BartIO.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/MagneticResonanceImaging/BartIO.jl)

BartIO.jl is a Julia package in order to interact with the [Berkeley Advanced Reconstruction Toolbox (BART)](https://mrirecon.github.io/bart/).

This package offers the possibility to
- read and write cfl/hdr files used by BART
- Call BART command (requires a [BART](https://github.com/mrirecon/bart) installation

## Input/Output files in the BART format (.cfl + .hdr)
To load BART data (stored in a .cfl and a .hdr header file), simply call `read_cfl(filename)`, where `filename` can be either be without a filename extension, or it can include `.cfl` or `.hdr`.

To write BART compatible files, call  `write_cfl(filename, x)`, where `filename` can be either be without a filename extension, or it can include `.cfl` or `.hdr` and `x` is the data.


## Calling BART functions
BartIO replicates the functionality of the [Python wrapper](https://github.com/mrirecon/bart/blob/master/python/bart.py)

### Requirements
BART has to be installed/compiled.

### Setup
You will have to tell BartIO.jl where to find the BART executable:
```julia
    using BartIO
    set_bart_path("/path/to/bart")
```

### How to use BartIO.jl
BART functions ca be called, e.g., by either of the to calls:
```julia
bart(0,"version")
k_phant = bart(1,"phantom -x64 -k")
```

In the first example, the leading argument `0` indicates that `bart` will not return anything. In the second example, the leading `1` indicates that `bart` will return 1 object. For certain functions, you will have provide BART with data, which can be done in the following way:
```julia
traj = bart(1,"traj -x 128 -y 256 -r")
k_phant = bart(1,"phantom -k -t", traj)
im_phant = bart(1,"nufft -i", traj, k_phant)
```
where `traj` and `k_phant` are arrays of `ComplexF32` (BART works with single precision). Note, if you pass multiple arguments, they are concatenated at the end of the command line. The last 2 lines are equivalent to the command line call
```bash
bart phantom -k -t traj k_phant
bart nufft -i traj k_phant im_phant
```

Alternatively you can pass optional arrays with keywords
```julia
k_phant = bart(1,"phantom -k", t=traj)
```

To print all available BART functions, you can call `bart()` without arguments:
```julia
bart()
```

If you need help for the function you can use:
```
bart(0,"pics -h")
```

### Alternatives
As an alternative, you can, from within Julia, manually perform a system call of BART:
```julia
pathto_bart_exec="/home/CODE/bart-master/bart"
run(`$pathto_bart_exec version`)
```

[docs-img]: https://img.shields.io/badge/docs-latest%20release-blue.svg
[docs-url]: https://magneticresonanceimaging.github.io/BartIO.jl/stable/
