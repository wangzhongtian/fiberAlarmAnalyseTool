#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
// #include <sys/socket.h>
// #include <netinet/in.h>
// #include <netdb.h>
#include <queue> 
#include <semaphore.h>
#include <pthread.h>
#ifndef ___DatasBuffer___
#define ___DatasBuffer___
#include <new>
#include <time.h>
#include <exception>
#include "packetData.h"
// #include "fileMng.h"
#include "dataFileCls.h"
#include <mutex>
#include "cfg.h"
//////////////////////////////////////////////////////
//extern  dataBuf ;clsDatas
class clsDatas{
private:
    std::mutex  mutx1;
private:
    //char dataBuf[ 1024*1024*1024];
    std::queue< Packetdata * > pbuffpacketdata;
   // Packetdata * pbuffpacketdata[2000];// about 8 packets per seconds
    int curpacketdataPOS ;
    time_t t0,t1;
    // int socketHandle;
    long long dataLen;
   // std::string rootpath;
    simpleDataFileCLs * rawDFArray[4];
private:
    void printflog(int k,std::string dtstr );
    int FileNumber();

public:
  int getbufeddataCnt();
    void init() throw();

    clsDatas();

public:

    virtual void outDt(){return ;};

    void  putpacketdata( Packetdata * ppacketDataObj   );
    Packetdata * poppacketdata(    ) ;

    unsigned long long  saveData2File() throw();
    unsigned long long  save1Pd2File();
    unsigned long long  save1Pd2File(Packetdata  & packetDataObj,Packetdata * ppacketDataObjLast  );
};

#endif
