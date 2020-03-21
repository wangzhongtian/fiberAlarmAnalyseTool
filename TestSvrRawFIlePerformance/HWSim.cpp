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
//#include <arpa/inet.h>
#include <new>
#include <time.h>
#include <stdlib.h>  
#include <signal.h>
#include <errno.h>
#include "cfg.h"
#include "HWSim.h"
#include "ZCFIleReadin.h"
#include <iostream>



int sleepMiliseconds=100;
void clsPacketdata_base::setTime2Str(){
        time_t timer;
        time(&timer); 
        struct tm * timeinfo;
        timeinfo = localtime( &timer);
        char tem[215];
        sprintf(tem,"%04u%02u%02u%02u%02u%02u",timeinfo->tm_year+1900,timeinfo->tm_mon+1,timeinfo->tm_mday,
            timeinfo->tm_hour,timeinfo->tm_min ,timeinfo->tm_sec);
        memcpy( &this->startDTStr,tem,sizeof(this->startDTStr ));
}
unsigned int clsPacketdata_base::calDataPacketLen(){
       unsigned int size1 =0;
        switch (this->dataType){
            case 0x01://01表示char�?2表示uchar�?            case 0x02: 
                size1=0x01;break;
            case 0x03://03表示int16�?4表示uint16�?            case 0x04:
                size1=2;break;
            case 0x05://05表示int32�?6表示uint32�?            case 0x06:
                size1=4;break;
            case 0x07:////07表示float�?8表示double
                size1 =4;break;
            case 0x08:
                size1=8;break;                
            defalt:
                size1 =2;break;
        }
        switch( this->type){
            case 0x01:
            case 0x02:
                this->datasize = size1* this->paras.calSamples * this->paras.SegNumber;
                printf("--1~2:--%lu,%u,%u,%u\r\n",this->datasize,size1, this->paras.calSamples,this->paras.SegNumber );
                break;
            case 0x03:
            case 0x04:
                this->datasize = size1* this->paras.SegNumber;
                printf("-3~4:--%lu,%u,%u,%u\r\n",this->datasize,size1, this->paras.calSamples,this->paras.SegNumber );
                break; 
        }
        return this->datasize ;
    }

void clsPacketdata_base::setPayload(){
        unsigned long size1 = calDataPacketLen();
        printf( "payload len is %lu \r\n",size1);
        short  int * shint = new short[size1 / 2];
        for( int i=0x00;i< size1/2;i++){
            shint[i]=200;
        }
        this->datas = (char*) shint;
    }

clsPacketdata_base::~clsPacketdata_base(){
        if (this->datas != NULL ){
            //printf("/-");
            delete this->datas;
        }
    }
void clsPacketdata_base::cleardata(){
        if (this->datas != NULL ){
            //printf("/-");
            delete this->datas;
        }
}
clsPacketdata_base::clsPacketdata_base(){
        IDchars[1]=0xEB;IDchars[0]=0x90;IDchars[3]=0xEB;IDchars[2]=0x90;
        type  =0x01;
        checkCode =0x1234;
        memset(machineName,0x00,sizeof(machineName) );
        strcpy(machineName,"hsa121345");
        //printf("ma nameis:%s\r\n",machineName  );
        this->setTime2Str();
        this->paras.metersPerSeg= (unsigned short)4.003*5000;
        this->paras.chn2SegBegIdx= 3567;
        this->paras.reflectorFactor= 0.0001*10000;
        this->paras.attenutionFactor= 0.0001*10000;
        this->paras.scanRate= 1200;
        this->paras.calSamples= 512;
        this->paras.SegNumber= 8192;
        dataType=0x03;
        tailCheckCode=0xFFFFFFFF;
        datasize =0x00;
        datas = NULL;
    }  

void clsPacketdata_base::readin_machineName(){

}
void clsPacketdata_base::readin_startDTStr(){
    
}
void clsPacketdata_base::readin_paras(){
    
}
void clsPacketdata_base::readin_datas(){
    
}

long clsPacketdata_base::senddataOut(tcp::socket & p_socket){
        //send(int sockfd, const void *buf, size_t len, int flags);
        //printf("out data size is:%lx ", sizeof(this->IDchars));
        //printf("out data is:%lx-%hhx%hhx%hhx%hhx",sizeof(this->IDchars), this->IDchars[0],this->IDchars[1], this->IDchars[2],this->IDchars[3]);
        long len = 0;
        long ll=0;

        while(1){
            this->readin_startDTStr();
            this->readin_datas();
            ll=send_Data( p_socket, (PbuuferType) this->IDchars, sizeof(this->IDchars), 0);
            if (ll==0 || ll == -1)  break;
            len += ll;
            //printf("send out %ld bytes\r\n",len);
            len+=send_Data( p_socket, (PbuuferType) &this->type, sizeof(this->type), 0);       // printf("send out %ld bytes\r\n",len);
            if (ll==0 || ll == -1)  break;
            len += ll;
            len+=send_Data( p_socket,(PbuuferType) &this->checkCode, sizeof(this->checkCode), 0);     //   printf("send out %ld bytes\r\n",len);
            if (ll==0 || ll == -1)  break;
            len += ll;
            len+=send_Data( p_socket,(PbuuferType) this->machineName, sizeof(this->machineName), 0);    //    printf("send out %ld bytes\r\n",len);
            if (ll==0 || ll == -1)  break;
            len += ll;
            len+=send_Data( p_socket, (PbuuferType) &this->startDTStr, sizeof(this->startDTStr), 0);      //  printf("send out %ld bytes\r\n",len);
            if (ll==0 || ll == -1) break;
            len += ll;
            len+=send_Data( p_socket, (PbuuferType)& this->paras, sizeof(this->paras), 0);       // printf("send out %ld bytes\r\n",len);
            if (ll==0 || ll == -1)  break;
            len += ll;
            len+=send_Data( p_socket, (PbuuferType)& this->dataType, sizeof(this->dataType), 0);     //     printf("send out %ld bytes\r\n",len);    
            if (ll==0 || ll == -1)  break;
            len += ll;
            len+=send_Data( p_socket,(PbuuferType) this->datas, this->datasize, 0);       // printf("send payload  out %ld bytes\r\n",len);
            if (ll==0 || ll == -1)  break;
            len += ll;
            len+=send_Data( p_socket,(PbuuferType)& this->tailCheckCode, sizeof(this->tailCheckCode), 0);     //   printf("send out %ld bytes\r\n",len);
            if (ll==0 || ll == -1)  break;
            len += ll;
            break;
        }
        if(ll == -1){
            return -1;
        }
        //printf("send out:  %ld\r\n",len);
        return len;
    }
long clsPacketdata_base::send_Data(tcp::socket & socket, const char *  data , int size_in_bytes, int flag){
    boost::asio::const_buffer  buf = boost::asio::buffer(
        (const void *) data,
        (std::size_t )size_in_bytes);

    boost::system::error_code ignored_error;
    int ret = (long) boost::asio::write(socket, buf, ignored_error);
    if (ret  == size_in_bytes){
        return ret;
    }
    else{
        printf("Error data Send out\n");
        return -1;
    }
    // return (long)size_in_bytes;
}

clsPacketdata_RAW::clsPacketdata_RAW( ){//:clsPacketdata_base(){
  this->type  = 0x01;
  this->setPayload();
}


clsPacketdata_FILter::clsPacketdata_FILter( ){
   this-> type  = 0x02;
    this->setPayload();
}



clsPacketdata_EN::clsPacketdata_EN( ){
        this->type  = 0x04;
        this->setPayload();
}

clsSockSIM::clsSockSIM(){
        // listenfd = -1;
        // connfd = -1;
        for (int i =0;i<4;i++)
        {
           this->RAWS[i] = 0;
        }
}
int clsSockSIM::init(const char * IPaddress1 ,int Port1) {
    p_acceptor =  new tcp::acceptor(this->io_context, tcp::endpoint(tcp::v4(), Port1));  
    return 0;
}
int clsSockSIM::PreProc(){
    this->p_socket = new tcp::socket(this->io_context);
    p_acceptor->accept( *(this->p_socket ) );
    return 0;
}
void printDT()
{
        time_t rev_t1;
        time(&rev_t1); 
       struct tm *tblock =localtime(&rev_t1); 
        char tem[96];
        sprintf(tem,"\r\nPacket Send at :%02d %02d-%02d:%02d:%02d",
            tblock->tm_mon+1, 
            tblock->tm_mday ,tblock->tm_hour, tblock->tm_min,tblock->tm_sec   );
        std::cout<< std::string( tem)<<std::endl;

}


int clsSockSIM::sendoutRaws( int  raws[4])
{
        return 0x00;
}

int clsSockSIM::ProcSleep(){
        long  unit= 1000;//us

        long sleep_ms = sleepMiliseconds*unit;

        unsigned char bufferlen[1];
        unsigned char lastBuflen;
        bufferlen[0] = 0x00;
      // int len = socket.read_some(buffer(buf), ec);
        try{
               if (0<  this->p_socket->available() ){
                        boost::system::error_code ignored_error;
                        // std::cout<<"-----------enter into read "<<std::endl;
                        this->p_socket->read_some(boost::asio::buffer(bufferlen), ignored_error);
                        // std::cout<<"-------------Exit out  read "<<std::endl;
               }
                std::cout<< "---buf len is "<< (int) bufferlen[0]<<std::endl;
                lastBuflen  = bufferlen[0];
            //  std::size_t  this->p_socket.write_some(    const ConstBufferSequence & buffers);
        }
        catch( std::exception  ) //boost::asio::error & e )
        {

        }



        if ( sleepMiliseconds ==111110 ) {
                usleep(sleep_ms);
        }else {
                if (  lastBuflen  <30 )
                { sleep_ms = 2 * lastBuflen;}
               if (  lastBuflen  >=30  && lastBuflen <50)
                    { sleep_ms = 2 *2* lastBuflen;}
                       
               if (  lastBuflen  >=50  && lastBuflen <80)
                    { sleep_ms = 5 *3* lastBuflen;}
             if (  lastBuflen  >=80  && lastBuflen <110)
                    { sleep_ms = 5 *4* lastBuflen;}
             if (  lastBuflen  >=110)
                    { sleep_ms = 5 *5* lastBuflen;}

                    usleep(sleep_ms*unit);

            
        }

  return 0;
}


int clsSockSIM::waitProcPost(){
        long  unit= 1000;//us
        long sleep_ms = sleepMiliseconds*unit;
        // std::cout<<"-----------enter into post read loop "<<std::endl;
        unsigned char bufferlen[1];
        unsigned char lastBuflen;
        bufferlen[0] = 0x00;
        int waitmax=1*1000;
        int cntRet0 =0;
        while ( waitmax > 100 )
        {
            // std::cout<<"-----------in post read loop "<<std::endl;
                        try{
                            if (0<  this->p_socket->available() ){
                                        boost::system::error_code ignored_error;
                                        // std::cout<<"-----------enter into read "<<std::endl;
                                       int ret =  this->p_socket->read_some(boost::asio::buffer(bufferlen), ignored_error);
                                       if ( ret  ==0 )
                                       {
                                            cntRet0 ++;
                                            if (cntRet0 <10)   usleep(10*unit);
                                            else
                                            {
                                                return 0 ;
                                            }
                                            
                                            continue;
                                       }else{
                                           cntRet0 =0;
                                       }
                                        // std::cout<<"-------------Exit out  read "<<std::endl;
                            }
                                // std::cout<< "---buf len is "<< (int) bufferlen[0]<<std::endl;
                                lastBuflen  = bufferlen[0];
                            //  std::size_t  this->p_socket.write_some(    const ConstBufferSequence & buffers);
                        }
                        catch( std::exception  ) //boost::asio::error & e )
                        {
                                std::cout<< "--Exception -buf len is "<< (int)lastBuflen<<std::endl;
                                return 0;
                        }

                        if (  lastBuflen >0  )                { 
                            sleep_ms = 5 * 10;

                            usleep(sleep_ms*unit);
                            waitmax -= sleep_ms;
                            std::cout<<"waiting client exit!!!,remianed:  "<<waitmax/1000<<"seconds"<<std::endl;
                        }else
                        {
                            break;
                        }
                        
        }
        return 0;
}
int clsSockSIM::ProcData(){

        unsigned long long allLen =0;
        time_t t0 ,t1;
        time( &t0 ) ;
        long l0=0x00;
        long  unit= 1000;//us
        long sleep_ms = sleepMiliseconds*unit;
        printf( "---Sleep :  %d milliseconds\r\n",sleepMiliseconds);
        unsigned long long packets =0x00;

        for (int d=0;d<4;d++){
            printf( "RAWs: %d:%d\r\n",d,this->RAWS[d]);
        }
        printf("\r\n");

        clsPacketdata_ZC      r3;  
        r3.readin_paras();
        r3.readin_machineName();
        while(1){
            this->ProcSleep();
            //printDT();
            int k=0x00;
            long l =0;
        //    printf("\r\nready send new datas\r\n");
            k++;if( this->RAWS[0] > 0){ // RAW1
                clsPacketdata_RAW  r1;
                // printf("Signal is 0:---%d\r\n", this->RAWS[0]);
                l0 = r1.senddataOut( *p_socket );
                    printf("Send out ID %d\r\n",k);
                    if (l == -1 ) break;
                    //allLen += l;
                    l+=l0;
            }
            k++;if( this->RAWS[1] > 0){  // RAW2
            clsPacketdata_FILter r2;                    
                // printf("Signal is 1:---%d\r\n", this->RAWS[1]) ;  
                l0 = r2.senddataOut( *p_socket );
                    printf("Send out ID %d\r\n",k);
                    if (l == -1 ) break;
                    //allLen += l;
                    l+=l0;
            }
            k++;if( this->RAWS[2] > 0){    // RAW3
                 
                // printf("Signal is 2:---%d\r\n", this->RAWS[2])   ;  
                l0 = r3.senddataOut( *p_socket );
                        printf("Send out ID %d\r\n",k);
                        if (l == -1 ) break;
                        //allLen += l;
                        l+=l0;
            }
            k++;if( this->RAWS[3] > 0){  // RAW4
            clsPacketdata_EN      r4;                    
                // printf("Signal is 3:---%d\r\n", this->RAWS[3])    ;
                l0 = r4.senddataOut( *p_socket );
                printf("Send out ID %d\r\n",k);
            }
            packets++;
            time_t timer1;
            time(&timer1); 
            printf("Send out RAWS.at :%ld s\r\n",timer1);
            if (l0 == -1 ) break;
            l+=l0;
            allLen += l;
            time( &t1 ) ;
            printDT();
            printf("CLANG:send out %0.1f Kbytes,%0.1f Kbytes/s ,%0.1f Packets /s \r\n",l/1024.0,
               allLen/1024/1.0/(t1-t0) ,packets/1.0/( (t1-t0)  ) );

            printf("\r\n");            
        } //while 
        printf("send data loop exited \r\n");
        if (l0 ==-1){
            printf(" send data Error\r\n");
            return -1;
        }
        printf("--Send data Number counter %llu\r\n",allLen);


        return allLen;
    }
int clsSockSIM::postProcdata(){
        // if (connfd != -1 ) close(connfd);
        printf(" begin waiting new acceped Client\r\n" );
        return 0;
    }
int clsSockSIM::destroySocket(){
        // if (listenfd != -1 ) close(listenfd);
        return 0;
    }
