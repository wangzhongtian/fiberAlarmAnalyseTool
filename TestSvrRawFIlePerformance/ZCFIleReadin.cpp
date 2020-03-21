#include "ZCFIleReadin.h"
#include "readdatas.h"
#include <string>
clsPacketdata_ZC::clsPacketdata_ZC( ){
        this->type  = 0x03;
        //this->setPayload();
}

void clsPacketdata_ZC::readin_machineName(){
    memset(this->machineName,0x39,sizeof(this->machineName) );
    strcpy(this->machineName,"GYYS-0019999");
    // this-> "GYYS-001";
}
void clsPacketdata_ZC::readin_startDTStr(){
        if (feof(this->rawfileobj) ){
            throw std::string("end of file");
        }
        char tem[215];
        unsigned short temShort =0;
        memset((void *)tem,0x00,sizeof( tem) );
        fscanf(this->rawfileobj,"%14s",tem );
        fread( &temShort,sizeof( temShort),1,this->rawfileobj);
        memcpy( &this->startDTStr,tem,sizeof(this->startDTStr ));
        printf("READ DT:---%s---\r\n", tem);
}
void clsPacketdata_ZC::readin_paras(){
        if (feof(this->rawfileobj) ){
            throw std::string( "end of file");
        }
        fread( &this->paras.metersPerSeg,sizeof( this->paras.metersPerSeg),1,this->rawfileobj);
        fread( &this->paras.chn2SegBegIdx,sizeof( this->paras.chn2SegBegIdx),1,this->rawfileobj);
        fread( &this->paras.reflectorFactor,sizeof( this->paras.reflectorFactor),1,this->rawfileobj);
        fread( &this->paras.attenutionFactor,sizeof( this->paras.attenutionFactor),1,this->rawfileobj);
        fread( &this->paras.scanRate,sizeof( this->paras.scanRate),1,this->rawfileobj);
        fread( &this->paras.calSamples,sizeof( this->paras.calSamples),1,this->rawfileobj);
        fread( &this->paras.SegNumber,sizeof( this->paras.SegNumber),1,this->rawfileobj);
      
        // printf("%d,%d,%d\r\n",this->paras.metersPerSeg, this->paras.SegNumber, this->paras.calSamples);
}
void clsPacketdata_ZC::readin_datas(){
    if (feof(this->rawfileobj) ){
            throw std::string("end of file");
        }
    unsigned long size1 = calDataPacketLen();
    printf( "payload len is %lu \r\n",size1);
    short  int * shint = new short[size1 / 2];
    for( int i=0x00;i< size1/2;i++){
        fread( &shint[i],sizeof( shint[i]),1,this->rawfileobj);
    }
    this->datas = (char*) shint;
}