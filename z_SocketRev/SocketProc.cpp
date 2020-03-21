#include <iostream>

#include "SocketProc.h"
#include "cfg.h"

#include "interface.h"
extern bool needFlowControl;
clsSocketRecv::clsSocketRecv(){
}
void clsSocketRecv::init() throw(){
}

void clsSocketRecv::postProc() throw(){
    // printf("Post Proc Socket Ok\r\n");
    // this->CloseSocket();
}
void clsSocketRecv::postSocketProc(){
    // this->CloseSocket();
}

 bool clsSocketRecv::recvDatasinSize(unsigned int size,char *buf) {  
        int l0 = this->recvData( size , buf );
        if (l0  <=  0){
                printf("\r\n-Error-want %d bytes,actual Received %d bytes----,exit out\r\n",size,l0);
                return false;//exit(-1);
        }
       return true;


}
 
void clsSocketRecv::sendOutFlowControl(){

    if  ( needFlowControl==false){
        return ;
    }
            int curlength = getGlbCnt();
          //  std::cout<<"??buffer Data Count is "<< curlength<<std::endl;
                        unsigned char  bufferlen = 250;
                        if (curlength < 250 ){
                                bufferlen =  (unsigned char )curlength;
                        }
                    int  ret= socketCls::sendoutData(bufferlen );

}
void clsSocketRecv::SocketRevRun(const char *IPaddress1,unsigned int port1) throw(){
    // printf("======readin_Frames1 =====\r\n");
    int re1=  this->ConnenctSVR( IPaddress1,  port1 );
    if( re1 == -1) {
       // sleep(0.001);
        printf("Connect Server Fail\r\n");
        this->postProc();
        return;
    }
    // printf("======readin_Frames 2 =====\r\n");
    this->readin_Frames();
    this->postProc();
}
//  unsigned long readin_Frames( );
unsigned long clsSocketRecv::readin_Frames( ) {
    // printf("======??????????????????????????????readin_Frames=====\r\n");
    // printf("======readin_Frames= 3====\r\n");
    // return 0;

    clsPacketdata  packetDataObj;
    while( true ){
            bool re = packetDataObj.readFrame( this );
            // printf("======readin_Frames= 4====\r\n");
            if( re == false) {
                // int curlength = getGlbCnt();
                // std::cout<<"\r\n FUNC:readin_Frames:----  "<< "read data error,data Remains:"<<curlength<<std::endl;
                // while(  curlength >0  ) {
                //     // this->sendOutFlowControl();
                //         usleep(4200);
                //         std::cout<<"\r\n FUNC:readin_Frames:----  "<< "waiting  data proc ending"<<curlength<<std::endl;
                //     //     int cnt = this->pbuffpacketdata.size() ;
                //  //        glbbufferdataLength = cnt;
                // }
                usleep(1000*1000);
                exit(-1);
                return -1;
            }else      {


                this->sendOutFlowControl();
            
                        // printf("===========\r\n");
            }
            // printf("======readin_Frames= 5====\r\n");
            this->postDataProc(  &packetDataObj   );
        }
    return -1;
}
