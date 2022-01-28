module BartIO

using BufferedStreams
using ConfParser
using PyCall

# Exported functions
export readcfl
export writecfl
export initBart

"""
    bart = initBart(pathtobart::String,pathtobartpy::String)

Initialize the installation of bart and to bartpy in order to make it available 
from the bartpy package through PyCall and store the path in a config file

## Input Parameters
- 

## output

# Example
"""

function initBart(path2bart::String="",path2bartpy::String="")
    
    conf = ConfParser.ConfParse("confs/config.ini")
    parse_conf!(conf)

    pathtobart=CheckAndSetPath!(conf,"BART","pathtobart",path2bart)
    pathtobartpy=CheckAndSetPath!(conf,"BART","pathtobartpy",path2bartpy)

    # Build PyBart
    
    path2BartPython = pathtobart*"/python"
    py"""
    import sys
    import os
    sys.path.insert(0, $path2BartPython)
    os.environ['TOOLBOX_PATH'] = $pathtobart
    """
    python_pycall = PyCall.python

    cmd = `cd $pathtobartpy \; $python_pycall setup.py install`
    run(cmd)
    
    #@PyCall.pyimport bartpy.tools as bartpy #Equivalent to -> bartpy = pyimport("bartpy.tools") but does not work in module...
    bartpy = pyimport("bartpy.tools")
    bartpy.version()
    
    return bartpy
end

## Utility functions
function CheckAndSetPath!(conf::ConfParse,blockname::String,pathname::String,path::String)
        
    if isempty(path); 
        path = retrieve(conf,blockname,pathname)
        if isempty(path); error("$pathname is not defined ! Set it with the function : \n initBart(path2bart::String,path2bartpy::String)"); end
    else
        commit!(conf, blockname, pathname, path);
        save!(conf)
    end
        
    # check if path exists
    if !isdir(path)
        error(path*" is not a valid directory ! redefined it")
    end
    return path
end

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

    fid = BufferedInputStream(open(filename));

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

    fid = BufferedOutputStream(open(filename,"w"));
    write(fid,dataCfl)
    close(fid);
end

function writereconheader(filenameBase::String,dims::Array{Int})
    filename = string(filenameBase, ".hdr");

    fid = open(filename,"w");
    write(fid,"# Dimensions\n")
    a = length(dims)
    for i in 1:length(dims)
        write(fid,string(dims[i])*" ")
    end
    close(fid)
end



end # module
