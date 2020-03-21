
#include "PartSnaplib.h"
////////////////////////////////////////////////////////////////////////////////
bool cRAW3FileProc::writeDataType(){
    fprintf(this->fout,"Para.Datatype %u" ,this->dataType);
    return true;
} 
bool cRAW3FileProc::writeDT(){
    fprintf(this->fout,"%04u;%02u;%02u;%02u;%02u;%02u;  ;" ,ft.tm_year,ft.tm_mon,ft.tm_mday,ft.tm_hour,ft.tm_min,ft.tm_sec);
    return true;
}

bool cRAW3FileProc::writeUint16Arrary( ){
    unsigned short int * p = (unsigned short int * ) this->data;
    long datacnt = this->dataLength/ sizeof(unsigned short int  );
    long i =0;
    for (  i =0;i < datacnt-1;i++){
        fprintf(this->fout,"%u;",p[i]);
    }
    fprintf(this->fout,"%u;\n",p[i]);
    return true;
}
bool cRAW3FileProc::writeUint8Arrary( ){
    unsigned char * p = (unsigned char * ) this->data;
    long datacnt = this->dataLength/ sizeof(unsigned char  );
    long i =0;
    for (  i =0;i < datacnt-1;i++){
        fprintf(this->fout,"%lu;",(unsigned long)p[i]);
    }
    fprintf(this->fout,"%lu;\n",(unsigned long)p[i]);
    return true;
}
bool cRAW3FileProc::writeUINT32Arrary( ){
    unsigned int * p = (unsigned  int * ) this->data;
    long datacnt = this->dataLength/ sizeof(unsigned   int  );
    long i =0;
    for (  i =0;i < datacnt-1;i++){
        fprintf(this->fout,"%lu;",(unsigned long)p[i]);
    }
    fprintf(this->fout,"%lu;\n",(unsigned long)p[i]);
    return true;
}

bool cRAW3FileProc::writeDatas(){
     writeUint16Arrary(); return true;

    switch( this->dataType){
        case 3:
        case 4:
               std::cout<<"."<<std::endl;
               writeUint16Arrary(); 
               return true;
        case 1:
        case 2:
                return false ;
                writeUint8Arrary();
                break;
        case 5:
        case 6:
            return false ;
            this->writeUINT32Arrary();
            break;
        case 7: 
            return false ;break;
        case 8:
            return false ;
             break;
        default:
            return false ;
            break;
    }   
} 
bool cRAW3FileProc::openfiles(const std::string & outfilemode){
    fin = fopen( this->curFileName.c_str(),"rb" );
    if (fin == NULL) {
        std::cout<<"+++++Error++++" <<this->curFileName<<" "<< std::endl;
        return false;
        
    }

    fout = fopen( this->curOutFilename.c_str(),outfilemode.c_str() );
    if ( fout == NULL) {
        std::cout<<"+++++Error++++" <<this->curOutFilename<<"      "<< outfilemode << std::endl;
        return false;  
    }else
        return true;
    
}
bool cRAW3FileProc::closefiles(){
    if (fin != NULL) 
        fclose(fin);
    if (fout != NULL )
        fclose(fout);
    fin =NULL;
    fout =NULL;
    return true;
}
bool cRAW3FileProc::readinDT(){

    int r = fscanf( fin,"%04u%02u%02u%02u%02u%02u",
      &ft.tm_year,&ft.tm_mon,&ft.tm_mday,&ft.tm_hour,&ft.tm_min,&ft.tm_sec );
    //printf( "%d\r\n",n);
    
    if ( r == 6)
	{
    //   printf("Proc time is :%04u%02u%02u %02u%02u%02u ,Pos =%ld\r\n",ft.tm_year,ft.tm_mon,ft.tm_mday,ft.tm_hour,ft.tm_min,ft.tm_sec,ftell(this->fin) );

	}
    else{
        printf("Proc time is : Error .cannot read in the whole Datetime Field\r\n");
    }

    return r == 6 ;
    //return true;

    //return 0  == ferror( fin );
}

void cRAW3FileProc::outparas(){
    return ;
    fprintf(stdout,"Head;%s\r\n" ,this->fileHead );
    fprintf(stdout,"Para.metersPerSeg;%u\n" ,this->paraS.metersPerSeg);
    fprintf(stdout,"Para.chn2SegBegIdx;%u\n" ,this->paraS.chn2SegBegIdx);
    fprintf(stdout,"Para.reflectorFactor;%u\n" ,this->paraS.reflectorFactor);
    fprintf(stdout,"Para.attenutionFactor;%u\n" ,this->paraS.attenutionFactor);
    fprintf(stdout,"Para.scanRate;%u\n" ,this->paraS.scanRate);
    fprintf(stdout,"Para.calSamples;%u\n" ,this->paraS.calSamples);
    fprintf(stdout,"Para.SegNumber;%u\n" ,this->paraS.SegNumber);
}

void cRAW3FileProc::writeEnvStr(){
    writeheadAs(std::string( "PT_RootFolder") , PT_RootFolder1 + "  and "+PT_RootFolder2  );
    writeheadAs(std::string( "StartTime" ) , StartTime  );
    writeheadAs(std::string( "TimePeriod") ,std::to_string(TimePeriod ));
    writeheadAs(std::string( "StartFiberLength") ,std::to_string(StartFiberLength ));
    writeheadAs(std::string( "FLRange") ,std::to_string(FLRange ));
    writeheadAs(std::string( "ChannelID") ,std::to_string(ChannelID ));
    writeheadAs(std::string("TgrFolder") , TgrFolder ,std::string("\r\n\r\n") );
}
bool cRAW3FileProc::writeheads(){
    if (NULL == this->fout){
        std::cout<<"error outfile\r\n";
    }
    fprintf(this->fout,"Head;%s\n" ,this->fileHead );
    fprintf(this->fout,"Para.metersPerSeg;%u\n" ,this->paraS.metersPerSeg);
    fprintf(this->fout,"Para.chn2SegBegIdx;%u\n" ,this->paraS.chn2SegBegIdx);
    fprintf(this->fout,"Para.reflectorFactor;%u\n" ,this->paraS.reflectorFactor);
    fprintf(this->fout,"Para.attenutionFactor;%u\n" ,this->paraS.attenutionFactor);
    fprintf(this->fout,"Para.scanRate;%u\n" ,this->paraS.scanRate);
    fprintf(this->fout,"Para.calSamples;%u\n" ,this->paraS.calSamples);
    fprintf(this->fout,"Para.SegNumber;%u\n\n" ,this->paraS.SegNumber);
    return true;
}
void cRAW3FileProc::writeheadAs(const std::string  Name ,const std::string  Val,const std::string endstr ){
    fprintf(this->fout,"%s ;%s ;%s" ,Name.c_str() ,Val.c_str(),endstr.c_str() );
   // fprintf(stdout,"%s ;%s ;%s",Name.c_str() ,Val.c_str() ,endstr.c_str());
}

bool cRAW3FileProc::readheads(){
    fread((void  *)fileHead,  1,sizeof( fileHead ) ,fin);
    int r= fread( (void  *) &paraS , 1,sizeof( paraS ),fin);
  //  printf("%d\r\n ",r);
    outparas();
    return 0  == ferror( fin );
}
bool cRAW3FileProc::readDataType(){
    int r= fread( (void  *) &dataType , 1,sizeof( dataType ),fin);
    return r  == sizeof( dataType );
    return 0  == ferror( fin );
}
bool cRAW3FileProc::readinDatas(){
     int r = fread( (void  *) data , 1,dataLength,fin);
         return r  == dataLength;
     return 0  == ferror( fin );
}   
 
bool cRAW3FileProc::moveNextData( ){
    fseek( fin, this->intervalPre ,SEEK_CUR);
    return 0  == ferror( fin );
}
bool cRAW3FileProc::moveNextHead( ){
  fseek( fin, this->intervalPost,SEEK_CUR);
  return 0  == ferror( fin );
}
bool cRAW3FileProc::pull2BinFile(const std::string filename){
   //std::cout<<filename+"."+ this->FileType+ ".BIN，暂不支持处理" <<std::endl;
   return false;
}
int  cRAW3FileProc::isDataInRange( ){
    struct tm   ft1 =this->ft ;
    ft1.tm_year -= 1900;
    ft1.tm_mon -= 1;
    ft1.tm_mday -= 1;  
    time_t curT = mktime(& ft1);
    if(  curT < this->t0 -1)
        return -1;
    if(  curT > (this->t0 + this->TimePeriod+1) )
        return 1; 
    return 0;  
}

bool cRAW3FileProc::writeTgrfileHeadInfo( ){
    bool ret =false;
    while( true){
        if (true == this->isNewTgrFile ){
            ret = openfiles(std::string("wt") );
        }else
        {
            ret = openfiles(std::string("at") );
           // std::cout<<" AT mode\r\n";
        }
        // std::cout<< ret  <<" 1 "<<std::endl;
        if (ret == false )
            break;

        ret  =  readheads();
        // std::cout<< ret <<" 2 "<<std::endl;
        if (ret == false )
            break;
        ret = this->readinDT(); 
        if( ret == false)
            break;

        ret = this->readDataType();
                        //std::cout<< ret <<" 4 "<<std::endl;
        if(  ret ==false) 
            break;


        this->calParas();  

        if (true == this->isNewTgrFile ){
            this->writeEnvStr();
            this->writeheads();
            this->writeCalDatas();
        }
        else{
            ;
        }
        this->isNewTgrFile =false;
        break;
    }
    return ret;
}

bool cRAW3FileProc::pullDatas( ){
    bool ret= false;
    long int c = 0;
 
    int step =1;
    while( true ) {
            step +=1;
        //    printf(".%d %ld  %d \r\n",step,ftell( this->fin) ,feof( this->fin ));    
            if( ferror( this->fin )!= 0x00 ) { // end of file 
                break;
            }

            ret = this->readinDT(); 
        //    if( step <=3)
        //        std::cout<< ret <<" DT readin  "<<step <<std::endl;
            if( ret == false) break;

            ret = this->readDataType();
            //std::cout<< ret <<" datatype readin  "<<step <<std::endl;
            if(  ret ==false) 
                break;

            ret =this->moveNextData();
            //std::cout<< ret <<"  "<< step <<std::endl;
            if ( ret == false) break;
           // fseek(fin, this->dataLength , SEEK_CUR);
           
 //           ret = true;// readinDatas(); //std:://cout<< ret <<" "<< step++<<std::endl;
            ret =  this->readinDatas(); //std:://cout<< ret <<" "<< step++<<std::endl;
           // std::cout<< ret <<" read in datas  "<< step <<std::endl;
            if ( ret == false )break;
         
            ret = this->moveNextHead();//std::cout<< ret <<" "<< step++<<std::endl;
            if ( ret == false )break;
           
            // c += 1;
            // if (c>200000) 
            //     return false;
            int kk = this->isDataInRange( ) ;
            if ( kk == 0 )
            {
                this->writeDT();
                this->writeDatas(); 
            }
            if ( kk > 0 )
            {
               std::cout<< " Reach the end of time range   " <<std::endl;
               break;
            } 

    } 
    return true;
}
bool cRAW3FileProc::pull2CsvFile(const std::string filename ){
  
    std::string outfilename = filename+"."+this->FileType +".CSV";
    std::cout<<"\r\n\r\nProcessing file :------------------------------------\r\n"<< filename<<std::endl;
    std::cout<<"outFile name : "<<outfilename<<std::endl;
    std::cout<<"OrgFile name : "<< this->curFileName<<std::endl<<std::endl;
    this->curOutFilename = outfilename;

    this->resetRead();///
  
    bool ret = this->writeTgrfileHeadInfo();
    if( ret == false){
        this->closefiles();
        return false ;
    }
    //fseek(fin, this->fileHeadEndPos , SEEK_SET);
  
    fseek(fin,this->fileBeginPos , SEEK_SET);
    //fseek(this->fileHeadEndPos )
    this->resetRead();///
   //std::cout<<" pull -------------------------------------------------------------------------------- data\r\n";
    ret = this->pullDatas( );
    this->closefiles();
    //this->resetRead();////
    return true;
} 


void cRAW3FileProc::calBasicParas(){
  //  std::cout<<"will  calculate\r\n";
    this-> segoffset =0,this->segEnd = this->paraS.chn2SegBegIdx-1;
    if( this->ChannelID != 1 ){
        this->segoffset =this->paraS.chn2SegBegIdx;
        this->segEnd = this->paraS.SegNumber-1;
    }
    //std::cout<<"have calculated----------------------------------------------\r\n";

    this->segMeter = this->paraS.metersPerSeg/5000.0; 
  
    int tem = (int )(segoffset+ this->StartFiberLength/ segMeter  )-1;
    this->segB = std::max(segoffset,tem);

    tem = (int )(segoffset+(this->StartFiberLength+ this->FLRange) /segMeter)+ 1;
    this->segE = std::min( segEnd, tem );
//printf("?????????????????--???????????????????? %ud--%d\r\n",segEnd,segE);  
    this->predataNum = segB;
    this->remainDataNum = this->paraS.SegNumber - segE-1;
   
    this->factor =1;
    // switch( this->dataType){
    //     case 1:
    //     case 2:
    //             factor=1;
    //             break;
    //     case 3:
    //     case 4:
    //             factor= 2;
    //                 break;
    //     case 5:
    //     case 6:
    //         factor=4;
    //         break;
    //     case 7:factor=4;break;
    //     case 8:
    //         factor=8;break;
    //     default:
    //         break;
    // }
    factor =2;
    this->intervalPre =  this->predataNum *factor ;
    this->intervalPost  = this->remainDataNum  *factor;
     
       // this->writeheads(std::string( "intervalPost" ),std::to_string( this->intervalPost)); 
    this->dataLength = (segE-segB+1)*factor;
    if (this->data  != NULL ){
        delete this->data  ;this->data  =NULL;
    }
                     
    this->data = new char[ this->dataLength ] ;
    
    this->fileHeadEndPos = sizeof( fileHead ) +sizeof( paraS );
} 

long cRAW3FileProc::getSublineLength(){
   long SublineLength =  this->paraS.SegNumber * factor ; //*this->paraS.calSamples;
   return SublineLength;
    
}
void cRAW3FileProc::calSubParas(){
    
    this->lineLength = sizeof( this->DTStruct)+ sizeof(dataType ) + this->getSublineLength();
    struct tm   ft1 =this->ft ;
    ft1.tm_year -= 1900;
    ft1.tm_mon -= 1;
    ft1.tm_mday -= 1;  
    this->t10 = mktime(& ft1);
    double LogcntPersecond =   1.0*this->paraS.scanRate / (double)this->paraS.calSamples ; 
    
    long int file1stLineDT = t10 -this->toff;
    if (file1stLineDT > this->Logtb){
        this->fileBeginPos =this->fileHeadEndPos ;
    }else
    {
        long long tem1 =  this->Logtb - file1stLineDT -1 ;
        long  long offCnt = (long  long) ( 1.0* tem1   *LogcntPersecond) ;
        //std::cout<<"have calculated----------------------------------------------\r\n";
        //if 
        this->fileBeginPos =  offCnt * this->lineLength + this->fileHeadEndPos; 
       // printf( "---%lld, count is %lld,line len is :%d \r\n",(long long )this->fileBeginPos ,offCnt,this->lineLength  ); 
            //long offCnt = abs( tem1 ) *LogcntPersecond;
    }

}


void  cRAW3FileProc::calParas( ){
    calBasicParas();

    calSubParas();

}

bool cRAW3FileProc::writeCalDatas(){
    this->writeheadAs(std::string( "Seg lineLength" ),std::to_string( this->lineLength ));  
    this->writeheadAs(std::string( "Time Toff " ),std::to_string( this->toff ));
    this->writeheadAs(std::string( "Time file First Line " ),std::to_string( this->t10 -this->toff ));
    this->writeheadAs(std::string( "Time Abs Logtb" ),std::to_string( this->Logtb )); 
    this->writeheadAs(std::string( "Time Abs File begin time:" ),std::to_string( this->t10 -this->toff )); 
    this->writeheadAs(std::string( "File Begin Pos:" ),std::to_string(this->fileBeginPos )); 
       
    this->writeheadAs(std::string( "segMeter" ),std::to_string(this-> segMeter));    
    this->writeheadAs(std::string( "seg offset" ),std::to_string( this->segoffset));
    this->writeheadAs(std::string( "segB:the start Seg ID " ),std::to_string( this->segB)); 
    this->writeheadAs(std::string( "segE:the end Seg ID " ),std::to_string( this->segE));
    this->writeheadAs(std::string( "segEnd:" ),std::to_string( this->segEnd)); 

    this->writeheadAs(std::string( "Seg predataNum" ),std::to_string( this->predataNum));        
    this->writeheadAs(std::string( "Seg remainDataNum" ),std::to_string( this->remainDataNum)); 

    this->writeheadAs(std::string( "factor:bytes aloted for 1 data ,should be 2" ),std::to_string( this->factor));    
    this->writeheadAs(std::string( "Pos intervalPre:the file Pos for he first Data byte ." ),std::to_string( this->intervalPre));        
    this->writeheadAs(std::string( "Pos intervalPost: the pos interval to the Segment End pos" ),std::to_string( this->intervalPost)); 

    this->writeheadAs(std::string( "dataLength:the seg number(from SegB to SegE) *2" ),std::to_string( this->dataLength),std::string("\r\n\r\n"));    
    return true;
}


////////////////////////////////
cRAW4FileProc::cRAW4FileProc(){
        this->FileType = "RAW4";
}

cRAW3FileProc::cRAW3FileProc(){
        this->FileType = "RAW3";
        this->FilePeriod =1*60*60;
        data = NULL;
        dataLength =0;
        haveCaled =false;
        isNewTgrFile=true;
        fin =NULL;
        fout =NULL;
}

/////////////////////////////////////////////////////////////

void   cRAW3FileProc::doEffectData(){
   // return;
    // if ( this->Logtb = this->t0-this->toff;
    // this->logte = Logtb +this->TimePeriod;
    return ;
    if ( this->Logtb > ConstDaySeconds) {
        
        printf("May have Error.Log is :%llu\r\n",this->logte);
        this->logte -= 30;
        this->t0  -= 35;
    }   
    return ;
}
