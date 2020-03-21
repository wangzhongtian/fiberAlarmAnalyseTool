#include "DataSaveEntry.h"
#include <iostream>
#include <thread>
#include "cfg.h"
#include "DatasBuffer.h"
// static clsDatas * pgDatasBuffer1 ;// =NULL;#include "DataSaveEntry.h"
#include <iostream>
#include <thread>
#include "cfg.h"
#include "DatasBuffer.h"
// extern   clsDatas * juliaDatasBuffer1;// =NULL
 clsDatas * juliaDatasBuffer1 =NULL ;// =NULL
 bool needSaveFile=true;
 bool needJuliaSend=true;
 bool needFlowControl=false;



extern  clsDatas * pgDatasBuffer1 ;// =NULL;
// extern  clsDatas * juliaDatasBuffer1; //static

// int glbbufferdataLength; //for external use ,julia addjuest the send frame number 
// std::mutex glbmutx1;
int getGlbCnt(){
        int  juliaBuf = juliaDatasBuffer1->getbufeddataCnt();
        int  datasavebuf= pgDatasBuffer1->getbufeddataCnt();

        // std::cout<< "?? GET  "<<juliaBuf<< " " << datasavebuf<<std::endl;
        return std::max(juliaBuf,datasavebuf ) ;
}










 // z_FileSave\toJuliaData.cpp
// typedef  std::thread<class Fn, clsDatas *Args>  testThreadCls
int  initJuliaData( bool needSaveFile1, bool needJuliaSend1 , bool needFlowControl1){
    if ( needSaveFile1 == true)
    {
        printf("initJuliaData:true- ---\n"  );
    }else {
        printf("initJuliaData:false ,false----\n"  );
    }

    printf("initJuliaData:   here----\n"  );
    needSaveFile =needSaveFile1; 
    needJuliaSend = needJuliaSend1 ;
     needFlowControl=needFlowControl1;
    juliaDatasBuffer1 = new clsDatas() ;
    juliaDatasBuffer1->init();
    return 0;
}
static Packetdata * pcurpacketData ;

bool fetchJuliaFile( unsigned short *rawDatatype ,char machineName[] ,char startDTStr[],char cfgdata[ ],char * datas ,unsigned int * datalen ){

    if (false == needJuliaSend)
    {
        return false ;
    }
if ( juliaDatasBuffer1 ==NULL){
	printf("---NULL pointer   fetchJuliaFile-\r\n");
}else{
	// printf("---1-1 fetchJuliaFile-\r\n");
}
    Packetdata * pData =  juliaDatasBuffer1->poppacketdata( );
    // printf("---2  fetchJuliaFile-\r\n");
    *rawDatatype =(unsigned short ) pData->type ;

    memcpy( machineName, pData->machineName , sizeof( pData->machineName )) ;// null terminated string，固定长度
    memcpy( startDTStr, pData->startDTStr ,sizeof( pData->startDTStr )) ;// ;
	// printf("---3 fetchJuliaFile-\r\n");
    // printf("%lu--%u- machna size \n",sizeof( pData->machineName ),sizeof( pData->startDTStr ));
    // for (int c=0;c <14;c++){
    //     printf( "%c",startDTStr[c]);
    // }
    memcpy( cfgdata, (char * ) & pData->paras ,sizeof( pData->paras  )) ;// ;
    // pData->datas = new char[datalen ];
    *datalen = pData->datasize;
    // printf("-DataLen -%u--%u,%u\r\n",*rawDatatype ,*datalen ,pData->datasize );
    memcpy( datas , pData->datas , *datalen );
    delete pData;

    int nt =getGlbCnt();
    std::cout<<"data proc NUM is:"<< nt << std::endl;

    return true;
}

bool Save2JuliaFile( unsigned short rawDatatype,char machineName[] ,char startDTStr[],char cfgdata[ ],char * datas ,int datalen )
{
    if (false == needJuliaSend)
    {
        return false ;
    }
    Packetdata * pData =  new Packetdata( );
    pData->type = rawDatatype;
    memcpy( pData->machineName ,machineName, sizeof( pData->machineName )) ;// null terminated string，固定长度
    memcpy( pData->startDTStr ,startDTStr, sizeof( pData->startDTStr )) ;// ;
    memcpy( (char * ) & pData->paras ,cfgdata, sizeof( pData->paras  )) ;// ;
    pData->datas = new char[datalen ];
    memcpy(  pData->datas , datas ,datalen );
    pData->datasize = datalen;
    if( juliaDatasBuffer1 != NULL){
        // printf("Put to Julia Package Buffer \r\n");
        juliaDatasBuffer1->putpacketdata(  pData   );
    }else{
        printf("Can not juliaDatasBuffer1->putpacketdata(  pData   ); \r\n");
    }
    return true;
}
