
#include "DatasBuffer.h"
#include "packetData.h"
#include <mutex>


int clsDatas::FileNumber(){
    int a = sizeof(rawDFArray ) / sizeof( rawDFArray[0]);
    //printf("Arrary size is:%d\r\n",a);
    return a;
}

clsDatas::clsDatas(){
    for (int k=0;k<4 ;k++)
        rawDFArray[k]= NULL;
    // pthread_mutex_init(&mutex, NULL);

}
void clsDatas::init() throw(){
    t0=_getCurtime();
    dataLen=0;
    std::string typeRAW ("RAW1");
    rawDFArray[0]= 
        new simpleDataFileCLs( glbCfgObj.row12DataNumPerfile,typeRAW,"Data_",1 );
    typeRAW ="RAW2";
    rawDFArray[1]= 
        new simpleDataFileCLs(glbCfgObj.row12DataNumPerfile ,typeRAW,"Data_",2);
    typeRAW ="RAW3";
    rawDFArray[2]= 
        new simpleDataFileCLs(glbCfgObj.row34DataNumPerfile ,typeRAW,"Data_",3);
    typeRAW ="RAW4";
    rawDFArray[3]= 
        new simpleDataFileCLs(glbCfgObj.row34DataNumPerfile,typeRAW,"Data_",4);
}


Packetdata * clsDatas::poppacketdata(   ){
    //int w1;
   Packetdata * ppacketDataObj ;

    while(true){
        mutx1.lock( );
        int cnt =(int) this->pbuffpacketdata.size() ;
        if( cnt == 0 )
        {
            mutx1.unlock(); 
            // printf(".");
            usleep(500*1000);
            continue;
        }else{
            ppacketDataObj = this->pbuffpacketdata.front() ;
            this->pbuffpacketdata.pop();

            mutx1.unlock(); 
			//printf("_");

            return ppacketDataObj;
        }
    }
}


int clsDatas::getbufeddataCnt(){
        int tem=0;
        mutx1.lock( );
        tem = this->pbuffpacketdata.size() ;
        mutx1.unlock(); 
        return tem;
}
void  clsDatas::putpacketdata(  Packetdata * ppacketDataObj   ) {
    //Packetdata * ppacketDataObj ;
    while(true){
        mutx1.lock( );
        int cnt = this->pbuffpacketdata.size() ;
        // glbbufferdataLength = cnt;
        // setGlbCnt(cnt) ;
        // std::cerr<<"push  pre +++++++++++++ buffer Data Count is: "<< cnt <<std::endl;
        if( cnt > 200 )
        {
            std::cerr<<"buffer Data Count is: "<< cnt <<std::endl;
            printf("Full\r\n");
            mutx1.unlock(); 
            usleep(1000*1);
            continue;
        }else{
            // std::cerr<<"buffer Data Count is: "<< cnt <<std::endl;
            this->pbuffpacketdata.push(ppacketDataObj ) ;
            mutx1.unlock(); 
            return ;
        }
    }
}
// unsigned long long clsDatas::save1Pd2File(Packetdata  & packetDataObj,Packetdata * ppacketDataObjLast )
unsigned long long clsDatas::save1Pd2File(Packetdata  & packetDataObj,Packetdata * ppacketDataObjLast  )
{
    int typeID = packetDataObj.type ;
    switch(typeID)
    {
        case 0x01:
        case 0x02:
        case 0x03:
        case 0x04:
        {
            bool re1 = packetDataObj.isnewCfgParas( ppacketDataObjLast);
            int k=typeID-1;
            bool re2 = rawDFArray[k]->isneedNewfile( );

            if (re2  || re1 ) {
                std::string a =packetDataObj.getfileUNIQID( );
                // printf("%d,Create new file:%s\r\n",k,a.c_str() );
                rawDFArray[k]->Createfilehandle( a );
                FILE* f1 = rawDFArray[k]->getfileObj() ;
                
                if ( f1 == NULL ){
                    //   printf( "FUll Data .file handle is Error\r\n");
                }
                packetDataObj.saveCfgData( f1 );
            }

            FILE * fobj = rawDFArray[k]->getfileObj()  ; 
            packetDataObj.savePayload( fobj);
            packetDataObj.clear();
            // this->printflog(  k ,std::string(", ") +packetDataObj.getpacketRecvDtStr()+
            // std::string(" ,data Send at: ")+packetDataObj.getpacketDtStr() );
        }
    }
    return packetDataObj.getSavedDataLen();
}

unsigned long long  clsDatas::saveData2File() throw()
{
    return 0;
}
