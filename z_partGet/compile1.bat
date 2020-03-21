
REM 
gcc PartSnapMain.CPP PartSnapRAW34lib.cpp PartSnapRAW12lib.cpp  PartSnaplib.CPP cfg.cpp -o partSnap.dll -shared -lstdc++  -std=c++11 -fPIC


rem gcc PartSnapMain.CPP PartSnapRAW34lib.cpp PartSnapRAW12lib.cpp  PartSnaplib.CPP cfg.cpp -o bb.exe  -lstdc++   
move partSnap.dll  ..\jl\ 

pause