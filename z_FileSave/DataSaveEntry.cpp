#include "DataSaveEntry.h"
#include <iostream>
#include <thread>
#include "cfg.h"
#include "DatasBuffer.h"
clsDatas * pgDatasBuffer1 ;// =NULL;





// explicit thread (Fn&& fn, Args&&... args);
void   threadSaveDataMainEntry(clsDatas  * pDatasBuffer);
void   threadSaveDataMainEntry(clsDatas * pDatasBuffer)
{   
    long long d=0;
    // clsDatas & DatasBuffer =*( (clsDatas *)pDatasBuffer);
    clsDatas & DatasBuffer = *(pDatasBuffer);
    Packetdata * pdatalast =NULL;
    while( true){
        if ( false == needSaveFile){
            sleep(10000);
           continue;
        }
        Packetdata * pcurpacketData =  DatasBuffer.poppacketdata( );
        unsigned long long  len = 
        DatasBuffer.save1Pd2File( * pcurpacketData , pdatalast  );
        if (NULL == pdatalast){ 
            pdatalast = pcurpacketData;
        }else
        {
            delete pdatalast;
            pdatalast = pcurpacketData;
        }
    }
}

// typedef  std::thread<class Fn, clsDatas *Args>  testThreadCls
int  initSaveData( char Logfolder[],char folderA[], char  folderB[] ){
    glbCfgObj.Logfolder= Logfolder;
    glbCfgObj.folderB=folderB;
    glbCfgObj.folderA=folderA;
    // std::cout<< "--------------"<<  raw1max <<std::endl;
    printf( "-----------------------------------------------------------r\n initSaveData:%s, %s, %s\r\n\r\n" ,folderA,folderB, Logfolder);
    // return true ;
    pgDatasBuffer1 = new clsDatas() ;
    pgDatasBuffer1->init();
    // pthread_t id_1;
    std::thread * pthread = new std::thread( threadSaveDataMainEntry, pgDatasBuffer1 );
	// int ret = pthread_create( &id_1,NULL, threadSaveDataMainEntry,(void *) pgDatasBuffer1 );

    return 1 ;
}


 bool Save2File( unsigned short rawDatatype,char machineName[] ,char startDTStr[],char cfgdata[ ],char * datas ,int datalen )
{
    //  printf("======readin_Frames=   6   ====\r\n");
        if ( false == needSaveFile){
             //printf("======readin_noT sAVE =\r\n");
        //sleep(10000);
          // continue;
          return false;
        }
// printf("________________________%d,%d\r\n",datalen,rawDatatype);
//  printf("======readin_Frames=   7   ====\r\n");
    Packetdata * pData =  new Packetdata( );
    pData->type = rawDatatype;
    memcpy( pData->machineName ,machineName, sizeof( pData->machineName )) ;// null terminated string，固定长度
    memcpy( pData->startDTStr ,startDTStr, sizeof( pData->startDTStr )) ;// ;
    memcpy( (char * ) & pData->paras ,cfgdata, sizeof( pData->paras  )) ;// ;
    pData->datas = new char[datalen ];
    memcpy(  pData->datas , datas ,datalen );
    pData->datasize = datalen;
    // return true;
    if( pgDatasBuffer1 != NULL){
        // printf("Prompt1 %ld\r\n",pgDatasBuffer1);
        pgDatasBuffer1->putpacketdata(  pData   );
    }else{
        printf("Error\r\n");
    }

    return true;
}