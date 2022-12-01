module BartIO

using BufferedStreams

# Exported functions
export read_cfl, write_cfl, read_recon_header
export set_bart_path, get_bart_path, bart


"""
    set_bart_path(pathToBart::String)

Define the path to the BART toolbox (store in ENV["TOOLBOX_PATH"])
"""
function set_bart_path(pathToBart::String)
    ENV["TOOLBOX_PATH"]=pathToBart
    return pathToBart
end

function get_bart_path()
        # Check bart toolbox path
        bart_path = ENV["TOOLBOX_PATH"]
        if isempty(bart_path)
            if isfile("/usr/local/bin/bart")
                bart_path = "/usr/local/bin"
            elseif isfile("/usr/bin/bart")
                bart_path = "/usr/bin"
        end
    end
    return bart_path
end

"""
    bart = wrapper_bart(pathtobart::String)
    Args are concatenated at the end of the command.

    ### output
    - bart : a wrapper to call bart from Julia through the python functions from the bart repository.

    TO DO :
    - add kwargs support like in the python wrapper https://github.com/mrirecon/bart/pull/295

    Example :
    ````
    bart = wrapper_bart(pathtobart)
    bart(0,"version")

    bart(0,"phantom -h")
    bart(1,"phantom -k -x128")
    ````
"""
function bart(nargout::Int,cmd,args::Vararg{Array{ComplexF32}};kwargs...)
    # Check input variables
    if isdispatchtuple(args) || isempty(cmd) nargout < 0
        @warn "Usage: bart(<nargout>,<command>, <arguments...>\n\n"
        return nothing
    end

    # Check bart toolbox path
    bart_path = get_bart_path()
    if isempty(bart_path)
        @error "BART path not detected.\n Use : `set_bart_path(pathToBart)`"
    end

    nargin = length(args)
    name = mktempdir(tempdir(); prefix="jl_", cleanup=true)
    infiles = [name * "/in" * string(idx) for idx in 1:nargin]

    for idx in 1:nargin
        write_cfl(infiles[idx], args[idx])
    end

    ## kwargs
    args_kw = ""

    for idx in 1:length(kwargs)
        key = string(keys(kwargs)[idx])
        infiles_kw = name * "/in_" * key
        write_cfl(infiles_kw, collect(values(kwargs))[idx])

        args_kw = args_kw*"-" * key * " " * infiles_kw *" "
    end

    outfiles = [name*"/out"*string(idx) for idx in 1:nargout]

    shell_cmd = bart_path*"/bart"
    cmd_split = split(cmd)
    args_split = split(args_kw)

    run(`$shell_cmd $cmd_split $args_split $infiles $outfiles`)

    output = Vector{Array{ComplexF32}}(undef, length(outfiles))
    for idx in eachindex(output, outfiles)
        output[idx] = read_cfl(outfiles[idx])
    end

    rm(name, recursive=true)

    if length(output)==0
        return
    elseif length(output)==1
        return(output[1])
    else
        return output
    end
end

function bart()
    # Check bart toolbox path
    bart_path = get_bart_path()
    if isempty(bart_path)
        @error "BART path not detected.\n Use : `set_bart_path(pathToBart)`"
    end
    shell_cmd = bart_path*"/bart"

    run(Cmd(`$shell_cmd`,ignorestatus=true))
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
    if length(filename) >= 4
        if filename[(end - 3):end] == ".cfl"
            filenameBase = filename[1:(end - 4)]
        elseif filename[(end - 3):end] == ".hdr"
            filenameBase = filename[1:(end - 4)]
            filename = string(filenameBase, ".cfl")
        else
            filenameBase = filename
            filename = string(filenameBase, ".cfl")
        end
    else
        filenameBase = filename
        filename = string(filenameBase, ".cfl")
    end

    dims = read_recon_header(filenameBase)

    # remove singleton dimensions from the end
    n = prod(dims)
    dims_prod = cumprod(dims)
    dims = dims[1:searchsorted(dims_prod, n)[1]]

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
    if length(filename) >= 4
        if filename[(end - 3):end] == ".cfl"
            filenameBase = filename[1:(end - 4)]
        elseif filename[(end - 3):end] == ".hdr"
            filenameBase = filename[1:(end - 4)]
            filename = string(filenameBase, ".cfl")
        else
            filenameBase = filename
            filename = string(filenameBase, ".cfl")
        end
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
