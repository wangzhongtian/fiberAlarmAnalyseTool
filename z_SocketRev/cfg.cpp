#include <string>
#include <stdio.h>

#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <iostream>

#include "cfg.h"

// char FileHeadStr[]= "FIlE Version %04u:CFGData%04u";
// unsigned int FIleVersion =0x00;
char IPaddress[] = "192.168.88.200";
//char IPaddress[] = "127.0.0.1";
unsigned int Port  = 19998;

// time_t getCurtime(){
//     time_t timer;
//     time(&timer);  /* get current time; same as: timer = time(NULL)  */
//    return timer;
// }

clsPacketdata::clsPacketdata(){
        this->bufferSize = 8192*512*4;
        datas = new char[bufferSize];
        // this->datas=NULL;
        SavedDataLen =0x00;
}
clsPacketdata::~clsPacketdata(){
        // if( this->datas != NULL){
        //     delete this->datas;
        // }
} 

unsigned short clsPacketdata::fileType(){
        return this->type;
}
// unsigned long long clsPacketdata::getSavedDataLen(){
//         return this->SavedDataLen;
// }
void clsPacketdata::clear( ){
        // if( this->datas != NULL){
        //     delete this->datas;
        // }
        // this->datas  =NULL;
        this->payloadlen =0x00;
}

bool clsPacketdata::getCHeckheadCode( ){
        this->isHeadOk =false;
        // printf("======??????????????????????????????readin_Frames=====\r\n");
 

        bool re = this->psocketObj->recvDatasinSize(sizeof(this->IDchars),(char *)this->IDchars );
        if (re ==false){
       //printf("======getCHeckheadCode===  failed==\r\n");
             return false ;
        }
        if ( IDchars[1] == (char)0xEB && IDchars[0] == (char)0x90  && IDchars[3] == (char)0xEB && IDchars[2] == (char)0x90) {
                this->isHeadOk =true;
       		// printf("======getCHeckheadCode= OKKKK====\r\n");
                return true;
        }
  //printf("======getCHeckheadCode===  failed= 2 =\r\n");
        return false;
}

bool clsPacketdata::getTypeCode( ) {
        bool re = this->psocketObj->recvDatasinSize(sizeof(this->type),(char *) &this->type );
        return re;
}

bool clsPacketdata::getcheckCode( ) {
        bool re = this->psocketObj->recvDatasinSize(sizeof(this->checkCode),(char *) &this->checkCode );
        return re;
}

bool clsPacketdata::getmachineName()  {
        bool re = this->psocketObj->recvDatasinSize(sizeof(this->machineName),(char *) this->machineName );
        if (re){
            ;
        }
        return re;
}
bool clsPacketdata::getDT()  {
        bool re = this->psocketObj->recvDatasinSize(sizeof(this->startDTStr),(char *) &this->startDTStr );
        return re;

}
bool clsPacketdata::getparas(){
        this->isNewCfgPara =false;
        struct paraCLs temparas;
        bool re = this->psocketObj->recvDatasinSize(sizeof(temparas),(char *) &temparas );
        if ( re ==true) {
                int r = memcmp(&this->paras ,&temparas ,sizeof(this->paras ));
                if( r != 0){
                    this->isNewCfgPara = true;
                }
        }
        memcpy(&this->paras ,&temparas ,sizeof(this->paras ) );
        return re;
}

bool clsPacketdata::getdataType(){
        bool re = this->psocketObj->recvDatasinSize(sizeof(this->dataType),(char *) &this->dataType );
        return re;
}
bool clsPacketdata::gettailCheckCode(){
        this->isTailOk = false;
        bool re = this->psocketObj->recvDatasinSize(sizeof(this->tailCheckCode),(char *) &this->tailCheckCode );
        if (re == true){
            if (this->tailCheckCode ==  0xFFFFFFFF){
                 this->isTailOk = true;
               }else{
		printf("  tail failed ,%ux\r\n",this->tailCheckCode );
               }
        }
        return re;
}
unsigned int clsPacketdata::calDataPacketLen(){
        int size1 =0;
        switch (this->dataType){
            case 0x01://01表示char，02表示uchar，
            case 0x02: 
                size1=0x01;break;
            case 0x03://03表示int16，04表示uint16，
            case 0x04:
                size1=2;break;
            case 0x05://05表示int32，06表示uint32，
            case 0x06:
                size1=4;break;
            case 0x07:////07表示float，08表示double
                size1 =4;break;
            case 0x08:
                size1=8;break;                
            defalt:
                size1 =0x00;
        }
        switch( this->type){
            case 0x01:
            case 0x02:
                this->datasize = size1* this->paras.calSamples * this->paras.SegNumber;
                break;
            case 0x03:
            case 0x04:
                this->datasize = size1* this->paras.SegNumber;
                break;   
            default:
                this->datasize =0x00;       
        }
        return this->datasize ;
}
bool clsPacketdata::getDataPayLoad() {
        unsigned long datasize =this->calDataPacketLen();
        bool re =false;
        this->payloadlen  =  datasize;
        if (datasize >  this->bufferSize  ) {
                printf("Error, data size big than the buffer in datas\r\n");
                return false;
        }
        re = this->psocketObj->recvDatasinSize(datasize,(char *) this->datas );
        if ( re == false ){
            this->payloadlen =0x00;
        }
        return re;
}  

bool clsPacketdata::readFrame(class socketInterface * socketObj){
        this->psocketObj =socketObj;

        if( false == this->getCHeckheadCode() ){
                printf("Head -------------------------------------------------Not Ok\r\n");
                return false;
        }

        if( false == this->getTypeCode() ){
  		printf("getTypeCode-------------------------------------------------Not Ok\r\n");
                return false;;
        }     
        
        if( false == this->getcheckCode() ){
  		printf("getcheckCode-------------------------------------------------Not Ok\r\n");
                return false;;
        }   

        if( false == this->getmachineName() ){
  		printf("getmachineName-------------------------------------------------Not Ok\r\n");
                return false; ;
        }  

        if( false == this->getDT() ){
                printf("getDT-------------------------------------------------Not Ok\r\n");
                return false; ;
        }  

        if( false == this->getparas() ){
                printf("getparas-------------------------------------------------Not Ok\r\n");
                return false; ;
        }     
                                
        if( false == this->getdataType() ){
                printf("getdataType-------------------------------------------------Not Ok\r\n");
                return false; 
        }      
        
        if( false == this->getDataPayLoad() ){
                printf("getDataPayLoad-------------------------------------------------Not Ok\r\n");
                return false;
                ;
        }  

        if( false == this->gettailCheckCode() ){
                printf("gettailCheckCode-------------------------------------------------Not Ok\r\n");
                return false;;
        }     

        rev_t1 =time(NULL);
        if (isHeadOk && isTailOk ){
		// printf("isHeadOk && isTailOk ------------------------------------------------ Ok\r\n");
        return true;
        }
		printf("isHeadOk && isTailOk ------------------------------------------------Failed\r\n");
        return false;       
}


bool clsPacketdata::showCHeckheadCode( ){
        std::cout<< IDchars << std::endl;
        return true;
}
bool clsPacketdata::showTypeCode( ){
        std::cout<< type << std::endl;
        return true;
}
bool clsPacketdata::showcheckCode( ){
      std::cout<< checkCode << std::endl;
      return true;
}
bool clsPacketdata::showmachineName(){
        char tem[100];
        memcpy( tem, machineName, 20);
        tem[20] =0x00;
        std::cout<< tem<< std::endl;
        return true;
        // std::cout<<  << std::endl;
}
bool clsPacketdata::showDT(){
        char tem[100];
        memcpy( tem, startDTStr.datetimeStr2, 14);
        tem[14] =0x00;
        std::cout<< tem<< std::endl;
        return true;
}
bool clsPacketdata::showparas(){
        std::cout<< paras.metersPerSeg<< std::endl;
        std::cout<< paras.chn2SegBegIdx<< std::endl;
        std::cout<< paras.reflectorFactor<< std::endl;
        std::cout<< paras.attenutionFactor<< std::endl; 
        std::cout<< paras.scanRate<< std::endl;
        std::cout<< paras.calSamples<< std::endl;
        std::cout<< paras.SegNumber<< std::endl;
        return true;
}
bool clsPacketdata::showdataType(){
        std::cout<< dataType<< std::endl;
        return true;
}
bool clsPacketdata::showtailCheckCode(){
        std::cout<< tailCheckCode<< std::endl;
        return true;
}
bool clsPacketdata::showDataPayLoad(){
        std::cout<< payloadlen<< std::endl;
        return true;
} 
