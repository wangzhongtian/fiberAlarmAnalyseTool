
#include <stdio.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <new>
#include <time.h>
#include <string>
#include <stdlib.h>
#include <iostream>
#include <signal.h>
#include <errno.h>
#include <pthread.h>
#include "socketCls.h"

int socketCls::ConnenctSVR(const char *IPaddress,unsigned int Port1 ) throw(){
    this->SvrIPaddressStr = IPaddress;
    this->SvrPeerPort =  Port1 ;
    boost::asio::ip::address ipadd = boost::asio::ip::make_address(this->SvrIPaddressStr);

    boost::asio::ip::tcp::endpoint  ep1(ipadd, this->SvrPeerPort );
    std::list<boost::asio::ip::tcp::endpoint> eps; 
    eps.push_back( ep1);
    this->p_socket =  new  tcp::socket(io_context);
    boost::system::error_code ec;
    boost::asio::connect(*(this->p_socket), eps,ec);
    if (ec){
       printf("Connet svr Failed...\r\n");
        return -1;
    }else{
  	printf("Connet svr OK  ...\r\n");
        return 0;
    }

}

int  socketCls::CloseSocket(){

        return -1;
}


int socketCls::initSocketLib( void ){

    return 0;
}

int socketCls::initSocketRecvBuffer( void ){

return 0;

}
int socketCls::initSocketSendBuffer( void )
{

    return 0;
}

int socketCls::bindNetworkInter( void ){

    return 0;
}

int socketCls::createSocket(){
return 0;
}

int  socketCls::connectSocket( ) {

  return 0;
}

int  socketCls::recvData(unsigned int size_in_bytes,char *data ){
    boost::asio::mutable_buffer  buf = boost::asio::buffer(
        (void *) data,
        (std::size_t )size_in_bytes);
      boost::system::error_code error;
      size_t len = boost::asio::read( *this->p_socket,buf, error);
    if (error){
        return -1;
    }else{
        return len;
    }

}


bool socketCls::isReady( int timeout1  ) {
    return true;

}

int  socketCls::sendoutData(unsigned int size,char *buf){ 
    return 0;
}
int  socketCls::sendoutData(unsigned char  bufferlen ){ 
  //  return 0;
   //    boost::asio::mutable_buffer  buf = boost::asio::buffer(
  ///      (void *) data,
  //      (std::size_t )size_in_bytes);
 //     boost::system::error_code error;
     // size_t len = boost::asio::read( *this->p_socket,buf, error);
try{
        boost::system::error_code ignored_error;
        this->p_socket->write_some(boost::asio::buffer(&bufferlen,1), ignored_error);
      //  std::size_t  this->p_socket.write_some(    const ConstBufferSequence & buffers);
}
catch( std::exception  ) //boost::asio::error & e )
{

}
    return -1;
}
