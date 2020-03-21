
#include "PartSnaplib.h"
#include <iomanip>
////////////////////////////////
cRAW1FileProc::cRAW1FileProc(){
        this->FileType = "RAW1";
        this->subLineNum = 0x00;
        this->ConReadHeadLine = true;
        this->FilePeriod =2*60;
}
//virtual 
bool cRAW1FileProc::readDataType(){
    //bool Con = this->subLineNum ==1 || this->subLineNum == 0;
    //printf("--------------DT -subLineNum %lu --\r\n",subLineNum);
    if ( this->ConReadHeadLine == true ){
        bool re = cRAW3FileProc::readDataType();
    //printf("Proc time is : %04u%02u%02u%02u%02u%02u\r\n",ft.tm_year,ft.tm_mon,ft.tm_mday,ft.tm_hour,ft.tm_min,ft.tm_sec);
      //  printf( "-----------------------------------------datatype is ------%d\r\n",this->dataType);
        return re;
    }
    return true;
}

//virtual 
bool cRAW1FileProc::readinDT(){
  // printf("--------------DateTime -subLineNum %lu --\r\n",subLineNum);
   this->ConReadHeadLine = this->subLineNum == 0 ;
   this->subLineNum = (this->subLineNum  +1) %( this->paraS.calSamples );
    if ( this->ConReadHeadLine == true)  {
        size_t pos1 = ftell( this->fin );
        int r= fscanf( fin,"%04u%02u%02u%02u%02u%02u",&ft.tm_year,&ft.tm_mon,&ft.tm_mday,&ft.tm_hour,&ft.tm_min,&ft.tm_sec );
       // readDataType();
       if ( r == 6){

       }
        // printf("Proc time is :%04u%02u%02u %02u%02u%02u\r\n",ft.tm_year,ft.tm_mon,ft.tm_mday,ft.tm_hour,ft.tm_min,ft.tm_sec);
       else{
            printf(" : Error .cald\r\n");
       }

        return r == 6;
    }else
    {
        return true;
    }
}
long cRAW1FileProc::getSublineLength(){
   long SublineLength1=  this->paraS.SegNumber * factor *this->paraS.calSamples;
    this->SublineLength = SublineLength1;
   return SublineLength;
}  

void cRAW1FileProc::calParas(){
   cRAW3FileProc::calParas();
   calSubParas();
}
