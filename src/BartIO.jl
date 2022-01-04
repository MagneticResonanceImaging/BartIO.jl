module BartIO

using ConfParser
using PyCall

# Exported functions
export readcfl
export writecfl
export initBart

"""
    pybart::PyObject = initBart(path2bart::String="",path2bartpy::String="")
Initialize the installation of bart and to bartpy in order to make it available 
from the bartpy package through PyCall and store the path in a config file.
### Input Parameters
- path2bart : path to the BART folder
- path2bartpy : path to the bartpy folder
### output
- pybart : a wrapper to call bart from Julia through the python bartpy toolbox (see Example to learn how to use it)
# Example
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
"""
function initBart(path2bart::String="",path2bartpy::String="")
    println(pwd())
    conf_path=dirname(@__DIR__)*"/confs/config.ini"

    # check if file exists otherwise create it
    if(!isfile(conf_path))
        if !isdir() mkdir(dirname(conf_path)) end
        io = open(conf_path, "w")
        write(io,"[bart]\npathtobartpy=\npathtobart=\n")
        close(io)
    end

    conf = ConfParser.ConfParse(conf_path)
    parse_conf!(conf)

    pathtobart=CheckAndSetPath!(conf,"BART","pathtobart",path2bart)
    pathtobartpy=CheckAndSetPath!(conf,"BART","pathtobartpy",path2bartpy)

    BartIOPath = pwd()
    # Build PyBart
    python_pycall = PyCall.python

    run(`$python_pycall -m pip install numpy`)
    
    PyCall.py"""
    import os
    os.environ['TOOLBOX_PATH'] = $pathtobart
    print(os.environ['TOOLBOX_PATH'])
    os.chdir($pathtobartpy)
    os.system($python_pycall + " setup.py install --user")
    """
    cd(BartIOPath)

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