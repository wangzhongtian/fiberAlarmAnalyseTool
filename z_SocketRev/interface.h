#ifndef __INTERFACE__
#define  __INTERFACE__
class socketInterface{
public:
    // virtual int  recvData(unsigned int size,char *buf ) = 0;
    virtual bool recvDatasinSize(unsigned int size,char *buf) =0;
};

#endif