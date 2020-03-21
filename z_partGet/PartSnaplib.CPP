
#include "PartSnaplib.h"

#include <sys/types.h> 
#include <sys/stat.h> 

#include <unistd.h> 
#include  <iostream>
void getFT(struct tm  & ft,std::string & DTstr   ){
  //std::string   DTstr = DTstr1.replace("-","") ; 
   if (DTstr.length( ) < 14 ){
        ;//printf("string length too short %lu /14,_%s_\r\n",DTstr.length( ),DTstr.c_str() );
    }
   // printf("getFT1 string length too short %lu /14,_%s_\r\n",DTstr.length( ),DTstr.c_str() );
    ft.tm_year =atol(DTstr.substr(0,4).c_str() )- 1900; 
    ft.tm_mon = atol(DTstr.substr( 5,2).c_str() )-1; 
    ft.tm_mday = atol(DTstr.substr(8,2).c_str() )-1;
    ft.tm_hour = atol(DTstr.substr(11,2).c_str() );  
    ft.tm_min = atol(DTstr.substr(14,2).c_str() );
    ft.tm_sec = atol(DTstr.substr(17,2).c_str() );
}
void getFT1(struct tm  & ft,std::string & DTstr   ){
    //std::string   DTstr = DTstr1.replace("-","") ; 
   if (DTstr.length( ) < 14 ){
       ; //printf("string length too short %lu /14,_%s_\r\n",DTstr.length( ),DTstr.c_str() );
    }
    //printf(" getFT string length too short %lu /14,_%s_\r\n",DTstr.length( ),DTstr.c_str() );
    ft.tm_year =atol(DTstr.substr(0,4).c_str() )- 1900; 
    ft.tm_mon = atol(DTstr.substr( 4,2).c_str() )-1; 
    ft.tm_mday = atol(DTstr.substr(6,2).c_str() )-1;
    ft.tm_hour = atol(DTstr.substr(8,2).c_str() );  
    ft.tm_min = atol(DTstr.substr(10,2).c_str() );
    ft.tm_sec = atol(DTstr.substr(12,2).c_str() );
}

void  cfolderProcBase::setPara(const std::string & FileType1,long FilePeriod1){
        this->FileType = FileType1;
        this->FilePeriod = FilePeriod1;        
}

void cfolderProcBase::iterateEntry(){
//    std::cout<<"here is -----------------------\r\n"<<this->PT_RootFolder1<<" ,"<<  this->PT_RootFolder2<<std::endl;
    if (this->PT_RootFolder1.length() > 0){    this->iterateFolder(this->PT_RootFolder1);  }
       if (this->PT_RootFolder2.length() > 0  && this->PT_RootFolder1 != this->PT_RootFolder2 )
       {    this->iterateFolder(this->PT_RootFolder2); 
        }
    // this->iterateFolder(this->PT_RootFolder1);
    // this->iterateFolder(this->PT_RootFolder2);
}
void cfolderProcBase::iterateFolder(std::string & subfolder){
    DIR *dir=NULL;
    struct dirent* pDir=NULL;
    dir=opendir( subfolder.c_str() );
    if(dir == NULL){
        printf("Error! can't open this dir,%s\n",subfolder.c_str());
        return ;
    }
    while(1){
                pDir = readdir(dir);
                if (pDir == NULL)
			        break;
                this->fileProc(pDir ,  subfolder );
    }
    closedir(dir);   dir =NULL;
    
}
#ifdef LINUX
void cfolderProcBase::fileProc(struct dirent* pDir,std::string & subfolder){
    std::string filename=pDir->d_name;
                switch(pDir->d_type){
                    case DT_REG:{
                        // std::string filename =pDir ->d_name;
                        this->RawfilePuts(subfolder,filename);
                        break;
                    }
                    case DT_DIR:{
                        std::string subfolder1 =pDir->d_name;
                        if(  subfolder1 == std::string(".") or  subfolder1== std::string(".." ) ){
                        }
                        else{
                            //
                            std::string f= this->folderCombine( subfolder ,subfolder1);
                            this->iterateFolder(f );
                        }
                        break;
                    }
                    default:
                        break;
                    }
                    return ;
}
#endif



void cfolderProcBase::fileProc(struct dirent* pDir,std::string & subfolder){
    std::string filename=pDir->d_name;
    std::string f= this->folderCombine( subfolder ,filename);
    struct stat  buf;
    stat( f.c_str(), &buf);
    if ( buf.st_mode & S_IFDIR ) {
        // std::string subfolder1 =pDir->d_name;
        if(  filename == std::string(".") or  filename== std::string(".." ) ){
        }
        else{
        //
        this->iterateFolder(f );
        }
    }
    if ( buf.st_mode & S_IFREG) {

        this->RawfilePuts(subfolder,filename);

    }
                // switch(pDir->d_type){
                //     case DT_REG:{
                //         // std::string filename =pDir ->d_name;
                //         this->RawfilePuts(subfolder,filename);
                //         break;
                //     }
                //     case DT_DIR:{
                //         std::string subfolder1 =pDir->d_name;
                //         if(  subfolder1 == std::string(".") or  subfolder1== std::string(".." ) ){
                //         }
                //         else{
                //             //
                //             this->iterateFolder(f );
                //         }
                //         break;
                //     }
                //     default:
                //         break;
                //     }
                //     return ;
}

bool cfolderProcBase::isSameType(const std::string & filename){
    //Data^Ver00^SJZ-001^20180107134055^ID00.RAW1
    std::string extension ;
    std::string split = std::string( ".")+this->FileType;
    std::size_t pos =filename.find( split );
    int len  = filename.length();
    int len1 = split.length();

    if (pos == ( len -len1 ) ) 
        return true;
   // printf("nOt same type:%s,%s \r\n",filename.c_str() ,split.c_str() );
    return false;
}
void cfolderProcBase::RawfilePuts(std::string &subfolder ,std::string & filename ){
    if ( ! this->isSameType(filename) )
        return;
    std::string f1 = subfolder,f2 =filename ;
    std::multimap<std::string,std::string >::value_type val(f2,f1);
    this->files.insert( val  );
}
std::string cfolderProcBase::folderCombine( const std::string & root,const std::string & subfolder){

    std::string f1 = std::string("");
//    return root+ f1+ subfolder;
    
    //std::cout<< std::endl<<root <<std::endl;
    if(  root.length() > 1){
        std::string e = std::string( root.substr( root.length() - 1  ) );
        if (e !=std::string("/")){
            f1 =std::string("/");
        }

    }
    std::string f =  root+ f1+ subfolder;
    
    return f;
    
}

void cfolderProcBase::PostProcFiles( ){
    std::multimap<std::string,std::string>::iterator outerit;
    int i =0x00;
    for ( outerit = this->files.begin();outerit !=this->files.end() ;++ outerit  ){
        std::string fileName =this->folderCombine(  (*outerit).second, (*outerit).first );
        std::cout<<"\n"<<i++<<fileName<<std::endl;
        this->Proc1File(fileName);
    
    }
}
    
void cfolderProcBase::Proc1File(const std::string & Nextpart ){
        return ;
}   

///////////////////////////////////
void cFileProc::splitFileName( ){
    //std::string part1,Version,machineNID,datetime,ID ;
	std::string split="^",Nextpart= this->curFileName;
    
	//Data^Ver00^SJZ-001^20180107134055^ID00
	std::size_t pos =Nextpart.find( split );
	part1 = Nextpart.substr(0,pos); 	
	Nextpart = Nextpart.substr (pos+1);
		//std::cout<< Nextpart<<" ";
	pos =Nextpart.find( split );
	Version = Nextpart.substr(0,pos); 	
	Nextpart = Nextpart.substr (pos+1);
		//std::cout<< Nextpart<<" ";
	pos =Nextpart.find( split );
	machineNID = Nextpart.substr(0,pos); 	
	Nextpart = Nextpart.substr (pos+1);

	pos =Nextpart.find( split );
	datetime = Nextpart.substr(0,pos); 	
	Nextpart = Nextpart.substr (pos+1);
		//std::cout<< Nextpart<<" ";
	pos =Nextpart.find( "." );
	std::string part2 = Nextpart.substr(0,pos); 	
	ID = part2 ;//Nextpart.substr (pos);
}

std::string toDtStr( time_t & t1 ){
    struct tm * ft = localtime( &t1 ); 
    char tem[128];
    sprintf(tem,"%04u-%02u-%02u_%02u-%02u-%02u",ft->tm_year+1900,ft->tm_mon+1,ft->tm_mday+1,ft->tm_hour,ft->tm_min,ft->tm_sec );
    return std::string( tem);
}
void cFileProc::Proc1File(const std::string & filename ){
    curFileName = filename;
	std::string Orgfile =filename;
    this->splitFileName();
	struct tm ft  = {0};
    getFT1(ft, this->datetime);
  	this->t1 = mktime(&ft);
  //  # Data^Ver00^SJZ-001^20180112170420^ID00.RAW3
//	double seconds = difftime( t0,t1);
    std::string temstr ;
    
    bool val =this->isIntimeRange();
    if(true == val){
       // std::cout<<"--------------------------------------------------------------------"<<std::endl;
        std::string filename =std::string("Convert^")+this->machineNID+std::string("^")+toDtStr(this->t0)+ std::string("^")+
            std::to_string( this->TimePeriod ) +  std::string("^") +
            std::to_string( this->ChannelID ) + std::string("^") +
            std::to_string( this->StartFiberLength ) + std::string("^") +
            std::to_string( this->FLRange) ;
       
        std::string tgrFn = this->folderCombine(this->TgrFolder, filename);
        this-> pull2BinFile(tgrFn);
        //this->closefiles();
        this->pull2CsvFile(tgrFn);
      
    }else
    {
     //   std::cout<<"-----/++++++++++/---------"<<std::endl;
        
    }
}	
//////////////////////////////////////////////////////////////////////////////////
bool cFileProc::pull2BinFile(const std::string filename){
   // std::cout<<"--------------"<<filename<<std::endl; 
    return false;
}
bool cFileProc::pull2CsvFile(const std::string filename){
  //  std::cout<<"--------------"<<filename<<std::endl;
    return false;
}

bool cFileProc::isIntimeRange(){
    this->splitFileName();
	struct tm ft  = {0};
      getFT1(ft, this->datetime);

	this->t1 = mktime(&ft);
    
    unsigned long long ftb,fte;

    
    ftb = this->t1-this->toff;
    fte =ftb+ this->FilePeriod;
    
    this->Logtb = this->t0-this->toff;
    this->logte = Logtb +this->TimePeriod;
    doEffectData();
    bool b1,b2;
    b1= fte >= Logtb ;
    b2= ftb <= logte; 
    if (b1 && b2){
       // std::cout<< " ****in range*****"<<std::endl<<std::endl<<std::endl;
    }
    else{
       // std::cout<< " **** NOT in range*****"<<std::endl<<std::endl<<std::endl;
    }
    return b1 && b2;
}
