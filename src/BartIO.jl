module BartIO

export readcfl
export writecfl

"""
    readcfl(filename::String)

- readcfl(filename(no extension)) -> Array{ComplexF32,N} where N is defined the filename.hdr file
- readcfl(filename.cfl) -> Array{ComplexF32,N} where N is defined the filename.hdr file
- readcfl(filename.hdr) -> Array{ComplexF32,N} where N is defined the filename.hdr file

Reads complex data from files created by the Berkeley Advanced Reconstruction Toolbox (BART).
The output is an Array of ComplexF32 with the dimensions stored in a .hdr file.

## Parameters:
- filename:   path and filename of the cfl and hdr files, which can either be without extension, end on .cfl, or end on .hdr
"""
function readcfl(filename::String)

    if filename[end-3:end] == ".cfl"
        filenameBase = filename[1:end-4]
    elseif filename[end-3:end] == ".hdr"
        filenameBase = filename[1:end-4]
        filename = string(filenameBase, ".cfl");
    else
        filenameBase = filename
        filename = string(filenameBase, ".cfl");
    end

    dims = readreconheader(filenameBase);
    data = Array{ComplexF32}(undef, Tuple(dims))

    fid = open(filename);

    for i in eachindex(data)
        data[i] = read(fid, Float32) + 1im * read(fid, Float32)
    end

    close(fid);
    return data
end

function readreconheader(filenameBase::String)
    filename = string(filenameBase, ".hdr");
    fid = open(filename);
    
    line = ["#"]
    while line[1] == "#"
        line = split(readline(fid))
    end

    dims = parse.(Int, line)
    close(fid);
    return dims
end

"""
    writecfl(filename::String,dataCfl::Array{ComplexF32})

- writecfl(filename(no extension),Array{ComplexF32}) 
- writecfl(filename.cfl, Array{ComplexF32}) 
- writecfl(filename.hdr,Array{ComplexF32}) 

Write complex data to files following the convention of the Berkeley Advanced Reconstruction Toolbox (BART).
The input is an Array of ComplexF32 with the dimensions stored in a .hdr file.

## Parameters:
- filename:   path and filename of the cfl and hdr files, which can either be without extension, end on .cfl, or end on .hdr
- Array{ComplexF32,N}:   Array of ComplexF32 corresponding to image/k-space

"""
function writecfl(filename::String,dataCfl::Array{ComplexF32})

    if filename[end-3:end] == ".cfl"
        filenameBase = filename[1:end-4]
    elseif filename[end-3:end] == ".hdr"
        filenameBase = filename[1:end-4]
        filename = string(filenameBase, ".cfl");
    else
        filenameBase = filename
        filename = string(filenameBase, ".cfl");
    end

    dimTuple = size(dataCfl)
    dims = ones(Int,16,1)

    for i in 1:length(dimTuple)
        dims[i]=dimTuple[i];
    end

    writereconheader(filenameBase,dims);

    fid = open(filename,"w");
    write(fid,dataCfl)
    close(fid);
end

function writereconheader(filenameBase::String,dims::Array{Int})
    filename = string(filenameBase, ".hdr");

    fid = open(filename,"w");
    write(fid,"# Dimension\n")
    a = length(dims)
    for i in 1:length(dims)
        write(fid,string(dims[i])*" ")
    end
    close(fid)
end

end # module