#include "packetData.h"

Packetdata::Packetdata(){
        this->datas=NULL;
        SavedDataLen =0x00;
}
Packetdata::~Packetdata(){
        if( this->datas != NULL){
            delete this->datas;
        }
}   

unsigned short Packetdata::fileType(){
        return this->type;
}
long  Packetdata::saveCfgData( FILE * file1 ){
        char tem[512];
        memset( tem,0x00,sizeof( tem));
        sprintf( tem,FileHeadStr,FIleVersion,sizeof(paras));
        fwrite( (void *) tem,sizeof(tem),1 ,file1);
        //printf("---Para is %d\r\n",paras.scanRate);
        fwrite((void *) &paras,sizeof( paras), 1,file1);
        //printf("str-- is %s\r\n",tem);
        long a= sizeof(tem)+ sizeof( paras);
        SavedDataLen +=a ;
        return a;
        //return true;
}
long Packetdata::savePayload(FILE *file1){
        fwrite((void *) &startDTStr,sizeof( startDTStr), 1,file1);
        fwrite((void *) &dataType,sizeof( dataType), 1,file1);
        fwrite((void *) datas, this->datasize ,1,file1); 
        //printf("len is %ld,%ld\r\n",this->datasize,ftell(file1)  );
        fflush( file1); 
        long a= sizeof( startDTStr) +sizeof( dataType)+this->datasize;
        SavedDataLen +=a ;
        return a;
}
unsigned long long Packetdata::getSavedDataLen(){
        return this->SavedDataLen;
}
void Packetdata::clear( ){
        if( this->datas != NULL){
        //    printf("release mem\r\n");
            delete this->datas;
        }
        this->datas  =NULL;
        // this->payloadlen =0x00;
}

unsigned int Packetdata::calDataPacketLen(){
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
        //printf("data payload size is:%lu  %u %u %u %u\r\n", this->datasize ,size1,this->type,this->paras.calSamples,this->paras.SegNumber);
        return this->datasize ;
}

std::string   Packetdata::getDTStr(){
        char tem1[8];
        memset(tem1,0x00,sizeof(tem1));
        char *p1 =  &( ( char *)&this->startDTStr )[10];
        memcpy(tem1,p1,4);
        strcat(tem1,";");
        return std::string( tem1 );
}
bool Packetdata::isNewData(){
       return true;
       char tem1[8];
       char tem2[8];

       memset( tem1,0x00,sizeof( tem1) );
       memset( tem2,0x00,sizeof( tem2) );

       char *p1 =  &( ( char *)&this->startDTStr )[11];
       memcpy(tem1,p1,3);
       strcat(tem1,";");

       char *p =  &( ( char *)&this->startDTStr )[11];
       memcpy(tem2,p,3);
       strcat(tem2,";");

       bool isNew =false;

       switch( this->type) {
               case 0x01:
               case 0x02:
                       {
                        const char *  pIDStr1 = "000;200;400;600;800;"; 
                       const char *pos1 = strstr(pIDStr1  , tem1);
                       if ( pos1 != NULL ) {isNew = true;}
                       }
                       break;
               case 0x03:
               case 0x04:
               {
                       const char *  pIDStr2 = "000;200;400;600;800;"; //"000;"
                       const char *pos2 = strstr(pIDStr2  , tem2 );
                       if (pos2 != NULL ){ isNew = true;}
               }
                       break;   
               default:
                       isNew =false;
                       break;
       }
//        printf("%s,%s\r\n",tem2,tem1);
       return isNew;
}
bool Packetdata::isnewCfgParas(){
        //bool isNew =isNewData() ;
        return this->isNewCfgPara ;//|| isNew ;
}
bool Packetdata::isnewCfgParas( Packetdata * pSrc){
    if (pSrc == NULL)
        return false;
    int re =  memcmp(&this->paras ,&pSrc->paras, sizeof(this->paras ));
    return re != 0; 
}
std::string Packetdata::getfileUNIQID( ) {
    char tem[ sizeof(this->startDTStr) +1];
    std::string a = this->machineName;
    a+=std::string("^");

    memcpy( tem,(void *)&this->startDTStr,sizeof(this->startDTStr ));
    tem[sizeof(tem)-1] =0x00;
    std::string b= tem;
    std::string  c =a+b;
    return c;
}