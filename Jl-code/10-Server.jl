using Sockets
# @async begin 
# Base.


fileName="D:\\fiber\\c\\Data^Ver00^xxxx-001^20190212131313^ID00.RAW3"
Port=19998
IPAddr="127.0.0.1"
IPAddr="192.168.0.109"
glbMachineName="xxxx-001"
include("socketinter.jl")
include("SvrTsk.jl")
const glbtypecode= 0x0003
println("File reader  begin :")
a= @async  SVrReadFileTsk(fileName)

println("Socket Server begin :")
b = SVrSendSocketTskEntry(Port, IPAddr)
println(a)

