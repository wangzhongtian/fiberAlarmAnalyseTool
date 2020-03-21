#include "readdatas.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
fileReainCls::fileReainCls() //const char *Filename
{
   
    this->filename = staticFilename;//.replace("\"","");
    printf("FILE:%s\r\n",filename.c_str() );
    this->rawfileobj = fopen( filename.c_str() ,"rb");
    if (this->rawfileobj == NULL){
        printf("open erro.... \r\n" );
        return ;
    }
    char tem ;
    for (int i =0;i<512;i++){
        // fread( &this->paras.metersPerSeg,sizeof( this->paras.metersPerSeg),1,this->rawfileobj);
        fread( &tem,sizeof( tem) ,1,this->rawfileobj );
    }
    // fseek(this->rawfileobj,512,0); //  移动文件到512，文件数据开始位置；
    printf("CUR POS:%ld\r\n",ftell(this->rawfileobj  ));
}
fileReainCls::~fileReainCls(){
    if (this->rawfileobj != NULL){
        fclose( this->rawfileobj );
    }
}
