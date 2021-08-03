# BartIO.jl

BartIO.jl is a Julia package to load (implemented) and write (to do) arrays from/into files compatible with the [Berkeley Advanced Reconstruction Toolbox (BART)](https://mrirecon.github.io/bart/). 

To load BART data (stored in a .cfl and a .hdr header file), simply call `readcfl(filename)`, where `filename` can be either be without a filename extension, or it can include `.cfl` or `.hdr`. 

To write BART compatible files, implement the `writecfl(filename, x)` and create a pull request ;-). Hopefully, I'll get around to implement this one day...
