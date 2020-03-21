keyword:
  Julia 、python、C++ Boost asio、powershell、linux、Windows、realtime processing of big data.

  
functions:
  fetch raw data in the fiber along the road via TCP socket,save to RAW file,and analysis the Raw data to identify the wind event and the intrusion event,log thess event to logfile.

folders:
  DBProc: iroonpython code to alternate the DB's licence DATE
  Jl-Aux: configuration file in julia code ;shared library compiled from C++ code;
  Jl-code: julia code.Algrithom code for the alarm analyse ;Wind Identificaltion algrithom code ;RAW file fetch code; RAW data snap code for offline Process; RAW file format transfer code ; excel Configuration data read code ;
  TestSvrRawFIlePerformance: RAW data generate  Server simulate code in C++.
  z_FileSave、z_SocketRev、z_partGet：C++ code for socket read/write code to the RAW server, call the BOOST ASIO library synchronize
  build:julia compile script; C++ code compile script;tesing script code in powershell or sh .
  
other information:
00-xxx~99-xxx.jl file: entry Julia code for testing;

enviroment:
  online processing: Ubuntu linux or docker ;julia 1.1.x
  offline simulate: Ubuntu linux or windows;julia 1.1.x
  simulation test server: Ubuntu linux or windows.

发布时：拷贝如下几个文件夹：
１　b
２　build: compiled julia code and the shared library
3  dataroot(可自动创建)
4  exec: powershell or bash scripts to call the julia code or julia compiled code 
5  log

如果是源代码方式发布，还需要如下文件夹：
１　Jl-Aux
2  Jl-code

如果是离线仿真，需要拷贝,并按照其下的ＲＥＡＤＭＥ文件说明，保存相应的ＲＡＷ３文件：
１　sjz004
