
$toolRootFolder=$PSScriptRoot
$rootRel="$toolRootFolder/../../src/rawdataproc/"
$root=resolve-path $rootRel
rm -f ./Jl-Aux
rm -f  ./Jl-code  
rm -f  ./build
$link = New-Item -ItemType SymbolicLink -Path  ./Jl-Aux   -Target   $root/Jl-Aux
$link = New-Item -ItemType SymbolicLink -Path  ./Jl-code   -Target   $root/Jl-code
$link = New-Item -ItemType SymbolicLink -Path  ./build   -Target   $root/build
