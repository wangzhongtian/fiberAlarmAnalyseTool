
#include <dirent.h>
#include <sys/types.h>
#include <stdio.h>
#include <string>
#include <set>
#include <map>

#include <iostream>
#include <time.h>
#include <stdlib.h> 

#include "cfg.h"

std::string toDtStr( time_t & t1 );
#define ConstDaySeconds  200*1*24*60*60
/////////////////////////////////////////////////////////////
class cfolderProcBase{
protected :
	std::multimap<std::string,std::string> files;
    std::string  PT_RootFolder1;
    std::string  PT_RootFolder2;
    std::string  StartTime;
    int TimePeriod ;
    int StartFiberLength ;
    int FLRange ; 
    int ChannelID;
    std::string  TgrFolder ;

public:
    std::string  FileType; 
    long FilePeriod;   
public:
	cfolderProcBase(){
        this->PT_RootFolder1 =glbCfgObj.getfolderB() ;
        this->PT_RootFolder2 =glbCfgObj.getfolderA() ;//getEnvString("PT_RootFolder");
        this->StartTime =glbCfgObj.getPart_StartTime();
        this->TimePeriod = glbCfgObj.getPart_TimePeriod()  ;
        this->StartFiberLength=glbCfgObj.getPart_StartFiberLength() ;
        this->FLRange =glbCfgObj.getPart_FLRange() ; 
        this->ChannelID=glbCfgObj.getPart_ChannelID() ;
        this->TgrFolder  = glbCfgObj.getPart_TgrFolder();        
        this->FileType = "RAW3";
        this->FilePeriod =1*60*60;
}
public:
    void iterateEntry( );
    void setPara(const std::string & FileType1,long FilePeriod1);
private:
	void iterateFolder(std::string & subfolder);
private:
	void RawfilePuts(std::string &subfolder ,std::string & foldername);
    bool isSameType(const std::string & foldername);
protected:
    std::string folderCombine( const std::string & root,const std::string & subfolder);
    void fileProc(struct dirent* pDir,std::string & subfolder);
public:
	void PostProcFiles();
    
private:
    virtual void Proc1File(const std::string & Nextpart );
};
void getFT1(struct tm  & ft,std::string & DTstr   );
void getFT(struct tm  & ft,std::string & DTstr   );
///////////////////////////////////////////////////////////////////////
class cFileProc: public cfolderProcBase {
public:
    cFileProc( ): cfolderProcBase( ) {
        struct tm ft  = {0};

//        iterateEntry
    //2018-01-12-18:23:30
        getFT(ft, this->StartTime);
        this->t0 = mktime(&ft);
                // printf("------------------------------\n");
       // std::cout<< ft.tm_year+1900 << "Y " << ft.tm_mon +1<< "m " << ft.tm_mday +1<< "d " << ft.tm_hour << "H " << ft.tm_min << "M " << ft.tm_sec << "S " <<std::endl;
        this->toff = 151566*10000;
        
}  ;
public:  
    virtual void Proc1File( const std::string & Nextpart );
    virtual bool pull2BinFile(const std::string filename);
    virtual bool pull2CsvFile(const std::string filename);  
protected:
    std::string part1,Version,machineNID,datetime,ID ;
    long toff ;//= 151566*10000;
    unsigned long long Logtb,logte;
    virtual void  doEffectData(){ return ; };
protected:
    std::string curFileName;
protected:
    void splitFileName( );
    time_t t1, t0;
    bool isIntimeRange();
};

////////////////////////////////////////////////////////////////////////////////
class cRAW3FileProc: public cFileProc{
protected:
    int  lineLength;
    time_t t10;
    double segMeter;
    int segoffset ,segEnd;
    long segB;
    long segE;
    int factor;
protected:
    FILE * fin,  * fout;
    size_t pos1 ;
    size_t intervalPre ,intervalPost ;
    size_t curFP ;
    std::string curOutFilename;
    long predataNum,remainDataNum;
    bool haveCaled ;
    bool isNewTgrFile;
protected:
    struct paraCLs  paraS;
    char  fileHead[512];
    char * data ;
    long dataLength;
    struct tm   ft ;
    struct datetimestrStruct  DTStruct;  
    unsigned short dataType;
    size_t fileBeginPos;

public:
    virtual bool pull2BinFile(const std::string filename);
    virtual bool pull2CsvFile(const std::string filename);  
    virtual void resetRead(){ };
protected :

    bool openfiles(const std::string &filename);
    bool closefiles();
    bool readheads();
    bool moveNextData( );
    bool moveNextHead( );
    bool readinDatas();
protected:
    virtual bool readDataType();
    virtual bool readinDT();
    virtual void calParas();
    void    calBasicParas();
protected:
    bool writeheads();
    bool writeDataType();
    bool writeDT();
    bool writeDatas(); 
protected:
    bool pullDatas( );
    bool writeUint16Arrary( );
    bool writeUint8Arrary( );
    bool writeUINT32Arrary( );
    void outparas();
    void writeheadAs(const std::string  Name ,const std::string  Val,const std::string endstr=std::string("\n"));
    void writeEnvStr();
    int  isDataInRange( );
private:
    bool writeTgrfileHeadInfo( );
    bool writeCalDatas();
public:
    cRAW3FileProc();
protected:
    virtual void doEffectData();
protected:
    size_t fileHeadEndPos;
    virtual  void calSubParas();
    virtual long getSublineLength();
};

class cRAW4FileProc: public cRAW3FileProc{
public:
    cRAW4FileProc();
};
//////////////cRAW1FileProc   111  111 //////////////////  
class cRAW1FileProc: public cRAW3FileProc{
public:
    cRAW1FileProc();
protected:
    virtual bool readDataType();
    virtual bool readinDT();
    virtual void calParas();
protected :
    unsigned long  subLineNum ;
    long SublineLength;
    bool ConReadHeadLine ;
//virtual  void calSubParas();
public:
    virtual void resetRead(){ subLineNum =0; };
    virtual long getSublineLength();
};

class cRAW2FileProc: public cRAW3FileProc{
public:
    cRAW2FileProc();
protected:
    virtual bool readDataType();
    virtual bool readinDT();
    virtual void calParas();
};
