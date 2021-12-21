# BartIO.jl

[![Build Status](https://github.com/aTrotier/BartIO.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/aTrotier/BartIO.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/aTrotier/BartIO.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/aTrotier/BartIO.jl)

BartIO.jl is a Julia package to load and write arrays from/into files compatible with the [Berkeley Advanced Reconstruction Toolbox (BART)](https://mrirecon.github.io/bart/). 

To load BART data (stored in a .cfl and a .hdr header file), simply call `readcfl(filename)`, where `filename` can be either be without a filename extension, or it can include `.cfl` or `.hdr`. 

To write BART compatible files, call  `writecfl(filename, x)`, where `filename` can be either be without a filename extension, or it can include `.cfl` or `.hdr`. 
