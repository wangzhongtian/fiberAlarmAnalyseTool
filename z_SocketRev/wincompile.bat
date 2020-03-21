REM gcc SocketProc.cpp socketCls.cpp A002-DataSaveProcMain.cpp cfg.cpp Sinks.cpp  ../RawDataSave.DLL  -lWs2_32 -lpthread -lWs2_32 -o ../RawProc.dll -lstdc++  -shared   -fPIC
echo #define WINDOWS >Os.h
echo //#undef WINDOWS >>Os.h

gcc SocketProc.cpp socketCls.cpp A002-DataSaveProcMain.cpp cfg.cpp Sinks.cpp ../z_FileSave/DatasBuffer.cpp ../z_FileSave/cfg.cpp   ../z_FileSave/packetData.cpp  ../z_FileSave/dataFileCls.cpp ../z_FileSave/DataSaveEntry.cpp  ../z_FileSave/toJuliaData.cpp     -lWs2_32 -lpthread -lWs2_32 -o ../Jl-Aux/dll/RawProc.dll -lstdc++  -shared   -fPIC
rem copy ../Jl/Jl/RawProc.so ../dll/RawProc.so
rem copy  RawProc.dll ../dll/RawProc.dll
pause