#!/bin/bash
echo $1
if [  "$1" = "WINDOWS" ]; then
    echo $1
    echo "#define WINDOWS" > Os.h
else
    echo "#undef WINDOWS" > Os.h
fi
tgrDll=../Jl-Aux/dll/RawProc.so
FILES="SocketProc.cpp socketCls.cpp A002-DataSaveProcMain.cpp cfg.cpp Sinks.cpp  "
FILES="$FILES ../z_FileSave/DatasBuffer.cpp ../z_FileSave/cfg.cpp   ../z_FileSave/packetData.cpp "
FILES="$FILES  ../z_FileSave/toJuliaData.cpp  ../z_FileSave/dataFileCls.cpp ../z_FileSave/DataSaveEntry.cpp"


wangcc='clang -stdlib=libc++  -l c++ -fuse-ld=lld '


a=`which clang`
b=`dirname $a`


clangbase=`dirname $b`

# export CPLUS_INCLUDE_PATH=$clangbase/include/
# export C_INCLUDE_PATH=$clangbase/include/
# export LIBRARY_PATH=$clangbase/lib/:$clangbase/boostlib/
echo clang Path :$clangbase
#LD_LIBRARY_PATH # shared library path in running 
#sss
$wangcc $FILES -lpthread -lboost_filesystem  -o $tgrDll --shared -fPIC

#gcc $FILES    -lpthread  -o $tgrDll -lstdc++  -shared   -fPIC
