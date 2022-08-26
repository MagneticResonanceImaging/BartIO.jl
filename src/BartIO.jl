module BartIO

using BufferedStreams
using PyCall

# Exported functions
export read_cfl
export write_cfl
export wrapper_bart

"""
    bart = wrapper_bart(pathtobart::String)

    ### output
    - bart : a wrapper to call bart from Julia through the python functions from the bart repository.

    Example :
    ````
    bart = wrapper_bart(pathtobart)
    bart(0,"version")

    bart(0,"phantom -h")
    bart(1,"phantom -k -x128")
    ````
"""
function wrapper_bart(pathtobart::String)
    if !isdir(pathtobart)
        @warn "BART folder does not exists"
    end

    python_pycall = PyCall.python

    run(`$python_pycall -m pip install numpy`)

    PyCall.py"""
    import os
    import sys
    os.environ['TOOLBOX_PATH'] = $pathtobart
    path = os.environ["TOOLBOX_PATH"] + "/python/"
    sys.path.append(path)
    """

    bartWrap = pyimport("bart")
    bartWrap.bart(0, "version")

    return bartWrap.bart
end

"""
    read_cfl(filename::String)

- read_cfl(filename(no extension)) -> Array{ComplexF32,N} where N is defined the filename.hdr file
- read_cfl(filename.cfl) -> Array{ComplexF32,N} where N is defined the filename.hdr file
- read_cfl(filename.hdr) -> Array{ComplexF32,N} where N is defined the filename.hdr file

Reads complex data from files created by the Berkeley Advanced Reconstruction Toolbox (BART).
The output is an Array of ComplexF32 with the dimensions stored in a .hdr file.

## Parameters:
- filename:   path and filename of the cfl and hdr files, which can either be without extension, end on .cfl, or end on .hdr
"""
function read_cfl(filename::String)
    if filename[(end - 3):end] == ".cfl"
        filenameBase = filename[1:(end - 4)]
    elseif filename[(end - 3):end] == ".hdr"
        filenameBase = filename[1:(end - 4)]
        filename = string(filenameBase, ".cfl")
    else
        filenameBase = filename
        filename = string(filenameBase, ".cfl")
    end

    dims = read_recon_header(filenameBase)
    data = Array{ComplexF32}(undef, Tuple(dims))

    fid = BufferedInputStream(open(filename))

    for i in eachindex(data)
        data[i] = read(fid, Float32) + 1im * read(fid, Float32)
    end

    close(fid)
    return data
end

function read_recon_header(filenameBase::String)
    filename = string(filenameBase, ".hdr")
    fid = open(filename)

    line = ["#"]
    while line[1] == "#"
        line = split(readline(fid))
    end

    dims = parse.(Int, line)
    close(fid)
    return dims
end

"""
    write_cfl(filename::String,dataCfl::Array{ComplexF32})

- write_cfl(filename(no extension),Array{ComplexF32})
- write_cfl(filename.cfl, Array{ComplexF32})
- write_cfl(filename.hdr,Array{ComplexF32})

Write complex data to files following the convention of the Berkeley Advanced Reconstruction Toolbox (BART).
The input is an Array of ComplexF32 with the dimensions stored in a .hdr file.

## Parameters:
- filename:   path and filename of the cfl and hdr files, which can either be without extension, end on .cfl, or end on .hdr
- Array{ComplexF32,N}:   Array of ComplexF32 corresponding to image/k-space

"""
function write_cfl(filename::String, dataCfl::Array{ComplexF32})
    if filename[(end - 3):end] == ".cfl"
        filenameBase = filename[1:(end - 4)]
    elseif filename[(end - 3):end] == ".hdr"
        filenameBase = filename[1:(end - 4)]
        filename = string(filenameBase, ".cfl")
    else
        filenameBase = filename
        filename = string(filenameBase, ".cfl")
    end

    dimTuple = size(dataCfl)
    dims = ones(Int, 16, 1)

    for i in eachindex(dimTuple)
        dims[i] = dimTuple[i]
    end

    write_recon_header(filenameBase, dims)

    fid = BufferedOutputStream(open(filename, "w"))
    write(fid, dataCfl)
    return close(fid)
end

function write_recon_header(filenameBase::String, dims::Array{Int})
    filename = string(filenameBase, ".hdr")

    fid = open(filename, "w")
    write(fid, "# Dimensions\n")
    a = length(dims)
    for i in 1:length(dims)
        write(fid, string(dims[i]) * " ")
    end
    return close(fid)
end

end # module
