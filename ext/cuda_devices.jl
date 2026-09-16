using Libdl

const driver = Libdl.dlopen("libcuda.so.1")

function check_cuda(status)
    status == 0 && return
    message = Ref{Cstring}()
    ccall(Libdl.dlsym(driver, :cuGetErrorString), Cint, (Cint, Ref{Cstring}), status, message)
    error("CUDA driver: ", unsafe_string(message[]))
end

status = ccall(Libdl.dlsym(driver, :cuInit), Cint, (Cuint,), 0)
status == 100 && exit() # CUDA_ERROR_NO_DEVICE
check_cuda(status)
count = Ref{Cint}()
check_cuda(ccall(Libdl.dlsym(driver, :cuDeviceGetCount), Cint, (Ref{Cint},), count))

for id in 0:count[]-1
    handle = Ref{Cint}()
    name = zeros(UInt8, 256)
    uuid = zeros(UInt8, 16)
    physical_uuid = zeros(UInt8, 16)
    check_cuda(ccall(Libdl.dlsym(driver, :cuDeviceGet), Cint, (Ref{Cint}, Cint), handle, id))
    check_cuda(ccall(Libdl.dlsym(driver, :cuDeviceGetName), Cint, (Ptr{UInt8}, Cint, Cint), name, length(name), handle[]))
    check_cuda(ccall(Libdl.dlsym(driver, :cuDeviceGetUuid_v2), Cint, (Ptr{UInt8}, Cint), uuid, handle[]))
    check_cuda(ccall(Libdl.dlsym(driver, :cuDeviceGetUuid), Cint, (Ptr{UInt8}, Cint), physical_uuid, handle[]))
    # The v2 API distinguishes MIG compute instances from their physical GPU.
    prefix = uuid == physical_uuid ? "GPU-" : "MIG-"
    hex = bytes2hex(uuid)
    identifier = prefix * join((hex[1:8], hex[9:12], hex[13:16], hex[17:20], hex[21:32]), '-')
    println(id, '\t', String(name[1:findfirst(iszero, name)-1]), '\t', identifier)
end
