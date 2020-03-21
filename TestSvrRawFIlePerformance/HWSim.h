/*
 writer :SunZhi
 For: PT wangzhongtian
*/
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
// #include <sys/socket.h>
// #include <netinet/in.h>
// #include <netdb.h>
#include <new>
#include <time.h>
#include <stdlib.h>  
#include <signal.h>
#include <errno.h>

#include <ctime>
#include <iostream>
#include <string>
#include <boost/asio.hpp>

using boost::asio::ip::tcp;

// #define MAX_LINE 256
// #define SERVER_PORT 5432
// gcc HWSim.cpp   -lstdc++ -ob.out
// TCP作为传输协议,循环：客户端发-服务器端收并发-客户端收
#include "cfg.h"

#ifndef __HWSIM__
#define __HWSIM__
time_t getCurtime();
#include "readdatas.h"
class  clsPacketdata_base : public fileReainCls{
public:
    char IDchars [4];//EB90 EB90
    unsigned short type ; /*01表示原始数据，02表示滤波后数据，03表示过零数据，04表示能量数据    */
    unsigned short checkCode ;
    char machineName[20];// null terminated string，固定长度
    union datetimestr startDTStr;
    struct paraCLs paras;
    unsigned short dataType;//01表示char，02表示uchar，03表示int16，04表示uint16，05表示int32，06表示uint32，07表示float，08表示double
    char *datas;
    unsigned int tailCheckCode; //FFFF FFFF
private:    
    unsigned long datasize;
public:
    void setTime2Str();
    unsigned int calDataPacketLen();
protected:
    void setPayload();
public:
    ~clsPacketdata_base();
public:
    void cleardata();

public:
    clsPacketdata_base();
    long senddataOut(tcp::socket & p_socket);
    long send_Data(tcp::socket & p_socket, const char *  buf , int len, int flag);
protected:
   virtual void readin_machineName();
   virtual void readin_startDTStr();
   virtual void readin_paras();
   virtual void readin_datas();
};

class clsPacketdata_RAW:public clsPacketdata_base{
public:
    clsPacketdata_RAW( );
};
class clsPacketdata_FILter:public clsPacketdata_base{
public:
    clsPacketdata_FILter( );
};

class clsPacketdata_EN:public clsPacketdata_base{
public:
    clsPacketdata_EN( );
};

class clsSockSIM{
private:
    boost::asio::io_context io_context;
    tcp::acceptor * p_acceptor;  
    tcp::socket * p_socket; 
    // int    listenfd, connfd;
    // struct sockaddr_in     servaddr;
    char    buff[4096];
    int     n;
    time_t t0;
    time_t t1;
private:

public:
int waitProcPost();
    int   RAWS[4];
    clsSockSIM();
        int ProcSleep();

public:
    int init(const char * IPaddress1 ,int Port1);
    int PreProc();
    int ProcData();
    int postProcdata();
    int destroySocket();
    int sendoutRaws( int  raws[4]);
};

#endif
