#include <pthread.h>
#include "../z_FileSave/DataSaveEntry.h"
#include "SocketProc.h"
#include <string>
clsSocketRecv  SocketRecvObj ;

char IPaddress1[100] ="127.0.0.1";
unsigned int  port1=19998;

char Logfolder[1024]  = "f:/datas";
char folderA[1024]  =  "f:/datas/a";
char folderB[1024] = "f:/datas/b";
////////////////////////////////////
extern "C" void initSvrIP( char * IPaddress, unsigned int port  ){
    memcpy( IPaddress1, IPaddress,80);
    port1 = port;
    printf("%s,%d\r\n",IPaddress1,port1 );
    
}

void * threadReadData(void *p ){
  	int re1=  SocketRecvObj.ConnenctSVR( IPaddress1,  port1 );
    if( re1 == -1) {
       // sleep(0.001);
        exit(-1);
        printf("Connect Server Fail\r\n");
        SocketRecvObj.postProc();
        return NULL;
    }
	// printf("Connect Server Ok\r\n");
    try {
    SocketRecvObj.readin_Frames();
    SocketRecvObj.postProc();
    }
    catch( std::string &e)
    {
        printf("%s\r\n",e.c_str() );
        sleep(5);
        exit(-1);
    }
	return NULL;
}

//initSaveData( Logfolder, folderA,   folderB );
////////////////////////////////////    
extern "C" int startProcessRawData( )
{
    pthread_t id_1,id_2;  
	pthread_create( &id_1,NULL, threadReadData,NULL );
	// pthread_join( id_1,NULL);
	return 0;
}

int main( void ){
    char Logfolder[]  = "f:/datas";
    char folderA[]  =  "f:/datas/a";
    char folderB[]   =  "f:/datas/b";
    initSaveData( Logfolder, folderA,   folderB );

 	int re1=  SocketRecvObj.ConnenctSVR( IPaddress1,  port1 );
    if( re1 == -1) {
       // sleep(0.001);
        printf("Connect Server Fail\r\n");
        SocketRecvObj.postProc();
        return -1;
    }
	printf("will enter readin frame \r\n");
    SocketRecvObj.readin_Frames();
    SocketRecvObj.postProc();
	return 0;
	return 0;
}
