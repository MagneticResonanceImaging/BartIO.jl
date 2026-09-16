module BartIOCUDAExt

import BART_CUDA_jll
import BartIO
using BartIO: BARTCUDABackend

const selected_uuid = Ref{Union{Nothing,String}}(nothing)

function __init__()
    BartIO.BACKEND[] = BARTCUDABackend()
end

function BartIO.devices(::BARTCUDABackend)
    command = BART_CUDA_jll.bart()
    query = joinpath(@__DIR__, "cuda_devices.jl")
    # CUDA caches device visibility: query in a fresh process with BART's library environment.
    julia = `$(Base.julia_cmd()) --startup-file=no --history-file=no --compile=min -O0 $query`
    return map(readlines(addenv(Cmd(julia; env=command.env), "JULIA_LOAD_PATH" => "@stdlib"))) do line
        id, name, uuid = split(line, '\t'; limit=3)
        (; id=parse(Int, id), name=String(name), uuid=String(uuid))
    end
end

function BartIO.device(backend::BARTCUDABackend)
    uuid = selected_uuid[]
    isnothing(uuid) && return nothing
    visible = BartIO.devices(backend)
    index = findfirst(gpu -> gpu.uuid == uuid, visible)
    isnothing(index) && throw(ArgumentError("Selected GPU is no longer visible; call BartIO.device!(nothing) or select a visible device."))
    return visible[index]
end

function BartIO.device!(backend::BARTCUDABackend, id::Integer)
    visible = BartIO.devices(backend)
    index = findfirst(gpu -> gpu.id == id, visible)
    isnothing(index) && throw(ArgumentError("No visible CUDA device with ID $id. Use BartIO.devices() to list valid IDs."))
    selected_uuid[] = visible[index].uuid
    return nothing
end

function BartIO.device!(::BARTCUDABackend, ::Nothing)
    selected_uuid[] = nothing
    return nothing
end

function BartIO._bart_cmd(backend::BARTCUDABackend)
    command = BART_CUDA_jll.bart()
    gpu = BartIO.device(backend)
    return isnothing(gpu) ? command : addenv(command, "CUDA_VISIBLE_DEVICES" => gpu.uuid)
end

end
