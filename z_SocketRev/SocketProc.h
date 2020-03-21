#ifndef ___DATASAVEPROC___
#define ___DATASAVEPROC___

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>

#include <queue> 
#include <semaphore.h>
#include <pthread.h>
#include <new>
#include <time.h>
#include <exception>

#include "socketCls.h"
#include "cfg.h"
// class clsPacketdata;

class clsSocketRecv:public socketCls
{
private: // datas
    int socketHandle;

private: // functions
    void run(const char *IPaddress,unsigned int port) throw();
public:
    clsSocketRecv();
    void init() throw();
    void postProc() throw();
    void postSocketProc();
    virtual bool recvDatasinSize(unsigned int size,char *buf);    
public:
void sendOutFlowControl();
    void SocketRevRun( const char *IPaddress,unsigned int port) throw();
    unsigned long readin_Frames( );
    unsigned int postDataProc(clsPacketdata * ppacketDataObj);

};

#endif
