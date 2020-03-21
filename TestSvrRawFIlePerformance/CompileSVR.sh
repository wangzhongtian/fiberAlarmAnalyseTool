#!/bin/bash
echo $1
# if [  "$1" = "WINDOWS" ]; then
#     echo $1
#     echo "#define WINDOWS" > Os.h
# else
#     echo "#undef WINDOWS" > Os.h
# fi
tgrDll=../Jl-Aux/dll/SVRTest.so
#g++ HWSimMain.cpp cfg.cpp   HWSim.cpp readdatas.cpp ZCFIleReadin.cpp -lstdc++ -o $tgrDll --shared   -fPIC
FILES="HWSimMain.cpp cfg.cpp   HWSim.cpp readdatas.cpp ZCFIleReadin.cpp"
echo  $M_include
clang  $FILES $M_include -lc++ $M_lib -lpthread -l boost_filesystem  -o $tgrDll --shared -fPIC    
# cp ../Jl-Aux/dll/SVRTest.so  .
