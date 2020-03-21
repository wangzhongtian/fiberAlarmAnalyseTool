set path=%cd%;%path%

set dbpath="D:\xxxx"
if not exist HW ( mklink /J HW %dbpath% )
REM ipy 01-main.py

start cmd /k 
rem pause