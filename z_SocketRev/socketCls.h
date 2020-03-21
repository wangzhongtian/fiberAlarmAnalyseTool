#ifndef __SOCKETCLS__
#define __SOCKETCLS__
// #include "Os.h"
#include <iostream>
#include <boost/array.hpp>
#include <boost/asio.hpp>
#include<list>
using boost::asio::ip::tcp;

// #ifndef WINDOWS
//     #include <sys/socket.h>
//     #include <netinet/in.h>
//     #include <netdb.h>
// #else
//     #include <Windows.h>
// #endif

#include <string>
#include "cfg.h"

#include "interface.h"

class socketCls:public socketInterface{
private: // datas
// #ifndef WINDOWS 
//     int socketHandle;
//     struct sockaddr_in sockaddr;
// #else
//     SOCKET  socketHandle;
//     struct sockaddr_in  servaddr;
// #endif
    std::string SvrIPaddressStr  ;
    unsigned int SvrPeerPort ; 
    boost::asio::io_context io_context;  
   tcp::socket * p_socket  ;


public:
    int  connectSocket( );
    int  createSocket( );
    int  CloseSocket();
    virtual  int  recvData(unsigned int size,char *buf );
    int  sendoutData(unsigned int size,char *buf) ;
    int  sendoutData(unsigned char  bufferlen );
    bool isReady(int timeout1 );    
public:
    int bindNetworkInter( void );
    int initSocketSendBuffer( void );
    int initSocketRecvBuffer( void );
    int initSocketLib( void );
    int ConnenctSVR(const char *IPaddress,unsigned int port ) throw();
};

// #ifndef WINDOWS 
// #define  INVALID_SOCKET -1
// #endif

#endif