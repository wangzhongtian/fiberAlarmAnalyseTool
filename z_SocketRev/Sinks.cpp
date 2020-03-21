#include <iostream>

#include "SocketProc.h"
#include "cfg.h"
#include "interface.h"

#include "../z_FileSave/DataSaveEntry.h"
// 

// int initSaveData(char Logfolder[],char folderA[], char  folderB[] );
unsigned int clsSocketRecv::postDataProc(clsPacketdata * pObj ){
    unsigned short rawDatatype = pObj->readtype()  ;
    char * machineName = pObj->readmachineName()  ;
    char *  startDTStr = pObj->readstartDTStr() ;
    struct paraCLs & cfgdata =pObj-> readparas() ;
    unsigned long  datalen = pObj->readpayloadlen() ;
    char  * datas = pObj->readdatas()  ;
    // printf("======readin_Frames=   6   ====\r\n");
    Save2File( rawDatatype, machineName ,  startDTStr , (char*) &cfgdata , datas ,  datalen );
    Save2JuliaFile( rawDatatype, machineName ,  startDTStr , (char*) &cfgdata , datas ,  datalen );
    // printf("data Come\r\n");
    return 0;
}
