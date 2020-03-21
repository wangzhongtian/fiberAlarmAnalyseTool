#include <string>
#include <stdio.h>
#include "cfg.h"
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <iostream>

#include  "DatasBuffer.h"


char FileHeadStr[]= "FIlE Version %04u:CFGData%04u";
unsigned int FIleVersion =0x00;

time_t _getCurtime(){
    time_t timer;
    time(&timer);  /* get current time; same as: timer = time(NULL)  */
   return timer;
}


std::string glbCfg::getLogfolder(){
    return Logfolder;
}

std::string glbCfg::getfolderB(){
    return folderB;
}

std::string glbCfg::getfolderA(){
   return folderA;
}


glbCfg glbCfgObj;
