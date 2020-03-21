#include <string>
#include <stdio.h>
#include "cfg.h"

char FileHeadStr[]= "FIlE Version %04u:CFGData%04u";
unsigned int FIleVersion =0x00;
char IPaddress[] = "192.168.88.200";
//char IPaddress[] = "127.0.0.1";
unsigned int Port  = 19998;
// #ifdef  WINDOWS
//     int closeSocket(SOCKET t ){ return closesocket(t  ) ;}
// #endif
int getEnvInt(const char * EnvName ){	
	char * val = getenv(EnvName);
	if (val ==NULL){
		char t[30];
		sprintf(t,"Env not found,%s\r\n",EnvName);
		throw t;
        }
 	int tem = atol( val);
	printf( "name %s =%d,%s\r\n",EnvName,tem,val);
	return tem;

}

std::string getEnvString( const char * EnvName){
	char * val = getenv(EnvName);
	if (val ==NULL){
		char t[30];
		sprintf(t,"Env not found%s\r\n",EnvName);
		throw t;
	}
 	std::string  tem = std::string( val);
	printf( "name %s =%s,%s\r\n",EnvName,tem.c_str(),val);
	return tem;
}

time_t getCurtime(){
    time_t timer;
    time(&timer);  /* get current time; same as: timer = time(NULL)  */
   return timer;
}
clsPacketdata::clsPacketdata(){
        this->datas=NULL;
        SavedDataLen =0x00;
}
clsPacketdata::~clsPacketdata(){
        if( this->datas != NULL){
            delete this->datas;
        }
}   

unsigned short clsPacketdata::fileType(){
        return this->type;
}
long  clsPacketdata::saveCfgData( FILE * file1 ){
        char tem[512];
        memset( tem,0x00,sizeof( tem));
        sprintf( tem,FileHeadStr,FIleVersion,sizeof(paras));
        fwrite( (void *) tem,1,sizeof(tem) ,file1);
        //printf("---Para is %d\r\n",paras.scanRate);
        fwrite((void *) &paras, 1,sizeof( paras),file1);
        //printf("str-- is %s\r\n",tem);
        long a= sizeof(tem)+ sizeof( paras);
        SavedDataLen +=a ;
        return a;
        //return true;
}
long clsPacketdata::savePayload(FILE *file1){
        fwrite((void *) &startDTStr, 1,sizeof( startDTStr),file1);
        fwrite((void *) &dataType, 1,sizeof( dataType),file1);
        fwrite((void *) datas, 1,this->datasize ,file1); 
        //printf("len is %ld,%ld\r\n",this->datasize,ftell(file1)  );
        //fflush( file1); 
        long a= sizeof( startDTStr) +sizeof( dataType)+this->datasize;
        SavedDataLen +=a ;
        return a;
}
unsigned long long clsPacketdata::getSavedDataLen(){
        return this->SavedDataLen;
}
void clsPacketdata::clear( ){
        if( this->datas != NULL){
            delete this->datas;
        }
        this->datas  =NULL;
        this->payloadlen =0x00;
}
bool clsPacketdata::getDatas(unsigned int size,char *buf) {           
     // printf("----size is:%d",size);
      unsigned int len=0;
      while(len < size){
                int l0 = recv(Sockethandle,buf,size-len,MSG_WAITALL);
                if (l0 == -1 || l0 ==0){
                    printf("--------------------------Error--------------------------------,exit out");
                    return false;//exit(-1);
                }
               // printf("----%d-%d\r\n" ,l0,size );
                len+=l0;
      }
    return true;
}

bool clsPacketdata::getCHeckheadCode( ){
        this->isHeadOk =false;
        bool re = getDatas(sizeof(this->IDchars),(char *)this->IDchars );
        //printf("ID chars is:%hhx %hhx %hhx %hhx",(unsigned int)IDchars[0],(unsigned int)IDchars[1],(unsigned int)IDchars[2],(unsigned int)IDchars[3]);
        if (re ==false){
             return false ;
        }
        if ( IDchars[1] == (char)0xEB && IDchars[0] == (char)0x90  && IDchars[3] == (char)0xEB && IDchars[2] == (char)0x90) {
                this->isHeadOk =true;
                return true;
            } 
        return false;
}

bool clsPacketdata::getTypeCode( ) {
        bool re = getDatas(sizeof(this->type),(char *) &this->type );
        return re;
}

bool clsPacketdata::getcheckCode( ) {
        bool re = getDatas(sizeof(this->checkCode),(char *) &this->checkCode );
        return re;
}

bool clsPacketdata::getmachineName()  {
        //memset(this->machineName ,0x00,sizeof( this->machineName) );
        bool re = getDatas(sizeof(this->machineName),(char *) this->machineName );
        if (re){
            ;
           // printf("get machine name ----------------+\r\n");
            //printf("name is %s\r\n", this->machineName );
        }
        return re;
}
bool clsPacketdata::getDT()  {
        bool re = getDatas(sizeof(this->startDTStr),(char *) &this->startDTStr );
        return re;

}
bool clsPacketdata::getparas(){
        this->isNewCfgPara =false;
        struct paraCLs temparas;
        bool re = getDatas(sizeof(temparas),(char *) &temparas );
        if ( re ==true) {
                int r = memcmp(&this->paras ,&temparas ,sizeof(this->paras ));
                //printf(" cfg is %d \r\n",r);
                if( r != 0){
                    this->isNewCfgPara = true;
               // return true;
                }
        }
      //  printf(":::---Para is %d,%d\r\n",paras.scanRate,temparas.scanRate);
        memcpy(&this->paras ,&temparas ,sizeof(this->paras ) );
        return re;
}

bool clsPacketdata::getdataType(){
        bool re = getDatas(sizeof(this->dataType),(char *) &this->dataType );
        return re;
}
bool clsPacketdata::gettailCheckCode(){
        this->isTailOk = false;
        bool re = getDatas(sizeof(this->tailCheckCode),(char *) &this->tailCheckCode );
        if (re == true){
            if (this->tailCheckCode ==  0xFFFFFFFF){
                 this->isTailOk = true;
               //  printf("Tail Ok !!!!!!!!!");
                 //return true;
               }else{

               // printf("Tail not  Ok !!!!!!!!!%x\r\n",this->tailCheckCode);
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
        //printf("data payload size is:%lu  %u %u %u %u\r\n", this->datasize ,size1,this->type,this->paras.calSamples,this->paras.SegNumber);
        return this->datasize ;
}
bool clsPacketdata::getDataPayLoad() {
        unsigned long datasize =this->calDataPacketLen();
        this->payloadlen  =  datasize;
        if (this->datas  != NULL ){
            delete this->datas;
        }
        this->datas = new char[ datasize];
        bool re = getDatas(datasize,(char *) this->datas );
        if ( re == false ){
            delete this->datas;
            this->datas = NULL;
            this->payloadlen =0x00;
        }
        return re;
}  


bool clsPacketdata::readDatas(SOCKET Sockethandle1){
        this->Sockethandle = Sockethandle1;
        while(true){
               // sleep(0.001);
                usleep(1000*1);
                if( false == this->getCHeckheadCode() ){
                        printf("Head -------------------------------------------------Not Ok\r\n");
                        return false;
               }

               if( false == this->getTypeCode() ){
                return false;continue;
               }     
         
               if( false == this->getcheckCode() ){
                return false;continue;
               }   

               if( false == this->getmachineName() ){
                return false; continue;
               }  

               if( false == this->getDT() ){
                       
                return false; continue;
               }  

               if( false == this->getparas() ){
                return false; continue;
               }     
                                       
               if( false == this->getdataType() ){
                return false; continue;
               }      
          
               if( false == this->getDataPayLoad() ){
               // printf( "  payload  is noyt ---- Ok\r\n");
               return false;continue;
               }  
 
               if( false == this->gettailCheckCode() ){
                return false;continue;
               }       
               rev_t1 =time(NULL);
            if (isHeadOk && isTailOk ){
              // printf( "all is Ok\r\n");
                return true;
            }
            printf( "all is not___+++ ----Ok\r\n");
            return false;
       }
      // printf( "all is not ----Ok\r\n");
       return false;
}
std::string   clsPacketdata::getDTStr(){
        char tem1[8];
        memset(tem1,0x00,sizeof(tem1));
        char *p1 =  &( ( char *)&this->startDTStr )[10];
        memcpy(tem1,p1,4);
        strcat(tem1,";");
        return std::string( tem1 );
}
bool clsPacketdata::isNewData(){
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
       printf("%s,%s\r\n",tem2,tem1);
       return isNew;
}
bool clsPacketdata::isnewCfgParas(){
        //bool isNew =isNewData() ;
        return this->isNewCfgPara ;//|| isNew ;
}
bool clsPacketdata::isnewCfgParas( clsPacketdata * pSrc){
        if (pSrc == NULL)
            return false;
        int re =  memcmp(&this->paras ,&pSrc->paras, sizeof(this->paras ));
        return re != 0; 
}
std::string clsPacketdata::getfileUNIQID( ) {
        std::string a = this->machineName;
        a+=std::string("^");
        char tem[ sizeof(this->startDTStr) +1];
        memcpy( tem,(void *)&this->startDTStr,sizeof(this->startDTStr ));
        tem[sizeof(tem)-1] =0x00;
        std::string b= tem;
        std::string  c =a+b;
        return c;
}

std::string clsDisk::SelectmntFolder(int ID){
        int mo = sizeof(NumberCnt0)/sizeof(NumberCnt0[0]) ;
        int Idx = ID %( mo );
        int m,cur=0;
        // k1= NumberCnt0[Idx];
        // k2= NumberCnt1[Idx];
        m =std::max(NumberCnt1[Idx],NumberCnt0[Idx] );
        if ( m == NumberCnt0[Idx] ){
                cur=1;
                NumberCnt1[Idx] += 1;
        }else{
                cur=0;
                NumberCnt0[Idx] += 1;  
        }
        std::string folder1 = /*rootFoler+std::string("/") + */ mntFolder[cur];
        return folder1;
}
clsDisk::clsDisk(std::string subfolder1,std::string subfolder2){
        mntFolder[0] = subfolder1;
        mntFolder[1] = subfolder2;
        //rootFoler = mntRootFolder;
        memset((char *) NumberCnt0 ,0x00, sizeof( NumberCnt0 ));
        memset((char *) NumberCnt1 ,0x00, sizeof( NumberCnt1 ));
        // NumberCnt1 =(0x00,0x00,0x00,0x00);
}


