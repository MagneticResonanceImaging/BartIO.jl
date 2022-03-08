module BartIO

using BufferedStreams
using PyCall
using Preferences

# Exported functions
export readcfl
export writecfl
export initBart
export checkPath
export wrapperBart
export wrapperBartpy

"""
    pybart::PyObject = initBart(path2bart::String="",path2bartpy::String="")
Initialize the installation of bart and to bartpy and store the path in a config file.
### Optionnal input Parameters
- path2bart : path to the BART folder
- path2bartpy : path to the bartpy folder
"""
function initBart(;path2bart::String="",path2bartpy::String="")

    @set_preferences!("bart" => path2bart)
    @set_preferences!("bartpy" => path2bartpy)
end

"""
bartpyWrap = wrapperBartpy()


### output
- bartpyWrap : a wrapper to call bart from Julia through the python bartpy toolbox (see Example to learn how to use it)

# Example
```julia
bartpy = BartIO.initBart(path2bart = path2bartFolder,path2bartpy = path2bartpyFolder)
bartpy.version()
k_phant = bartpy.phantom(x=64,k=1)
```
If you need help for the function you can either use :
```
run(`bart pics -h`)
```
or import with pycall the help function :
```julia
using PyCall
pyhelp = pybuiltin("help")
pyhelp(bartpy.phantom)
```
"""
function wrapperBartpy()
    bart,bartpy = checkPath()

    python_pycall = PyCall.python

    run(`$python_pycall -m pip install numpy`)
    
    PyCall.py"""
    import os
    os.environ['TOOLBOX_PATH'] = $bart
    print(os.environ['TOOLBOX_PATH'])
    os.chdir($bartpy)
    os.system($python_pycall + " setup.py install --user")
    """
    BartIOPath = pwd()
    cd(BartIOPath)

    #@PyCall.pyimport bartpy.tools as bartpy #Equivalent to -> bartpy = pyimport("bartpy.tools") but does not work in module...
    bartpyWrap = pyimport("bartpy.tools")
    bartpyWrap.version()
    
    return bartpyWrap
end

"""
    bartWrap = wrapperBart()

    ### output
    - bartWrap : a wrapper to call bart from Julia through the python functions from the bart repository.

    Example : 
    ````
    bartWrap = wrapperBart()
    bartWrap.bart(0,"version")

    bartWrap.bart(0,"phantom -h")
    bartWrap.bart(1,"phantom -k -x128")
    ````
"""
function wrapperBart()
    bart,bartpy = checkPath()
    
    python_pycall = PyCall.python

    run(`$python_pycall -m pip install numpy`)

    PyCall.py"""
    import os
    import sys
    os.environ['TOOLBOX_PATH'] = $bart
    path = os.environ["TOOLBOX_PATH"] + "/python/"
    sys.path.append(path)
    """

    bartWrap = pyimport("bart")
    bartWrap.bart(0,"version")
    
    return bartWrap
end

"""
    checkPath()

    Print the path store in the LocalPreference.toml for :
    - bart
    - bartpy
"""
function checkPath()
    pathname = ["bart","bartpy"]
    paths = String[]
    for i in pathname
        path = @load_preference(i)
        
        if isnothing(path)
            println("$i is empty")
            push!(paths,(i,""))
        else
            println("$i = $path")
            push!(paths,path)
        end
    end
    return paths[1], paths[2]
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
