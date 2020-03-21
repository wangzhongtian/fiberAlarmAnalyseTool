#include <string>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>


#include <new>
#include <time.h>
#include <stdlib.h>  
#include <signal.h>
#include <errno.h>
#ifndef __CFG__
#define __CFG__

extern char FileHeadStr[];
extern unsigned int FIleVersion ;
extern char IPaddress[] ;
extern unsigned int Port ;

time_t getCurtime();
struct datetimestrStruct {
    char year[4];
    char month[2];
    char day[2];
    char hour[2];
    char minute[2];
    char seconds[2];
}; 
union datetimestr{
struct datetimestr1 {
    char year[4];
    char month[2];
    char day[2];
    char hour[2];
    char minute[2];
    char seconds[2];
};
char datetimeStr2[14];
// not Null terminated strings: YYYYMMDDHHMMSS
};
struct paraCLs{
    unsigned short metersPerSeg ;//空间分辨率	2BYTE	UINT16 每数据点表征的米数 = 该字段数据/5000 
    unsigned short chn2SegBegIdx;// 第二通道起始点	2BYTE	第一通道的数据点为0 到 【本字段数据-1】。第二通道的数据点为本字段数据 到空间点数-1
    unsigned short reflectorFactor ;//折射率系数	2BYTE	UINT16 真实的折射率 = 该字段数据/10000
    unsigned short attenutionFactor ;//衰减补偿系数	2BYTE	UINT16 真实的补偿系数 = 该字段数据/10000
    unsigned short scanRate ;// 扫描速度	2BYTE	UINT16 默认1200Hz
    unsigned short calSamples ;//扫描次数	2BYTE	UINT16 默认512
    unsigned short SegNumber ;//空间点数	2BYTE	UINT16 默认8192
};


struct CfgStrs{
    char  folderB[1024];
    char  folderA[1024];
    char StartTime[125];//"StartTime");
    long TimePeriod; //"TimePeriod")  ;
    long StartFiberLength ;//"StartFiberLength") ;
    long FLRange ;//("FLRange") ; 
    long ChannelID  ;//("ChannelID") ;
    char TgrFolder[1024];//  = getPart_TgrFolder();//
};

class glbCfg{
private:
    std::string folderB;
    std::string folderA;

    std::string StartTime;
    long TimePeriod; // in seconds 
    long StartFiberLength; // in meters 
    long FLRange; // in meters
    int ChannelID;
    std::string TgrFolder;
public:
    void initStrs(struct CfgStrs & cfgStrObj );
    void initStrs(const char * folderB,
                                const char * folderA,
                                const char * StartTime,
                                long TimePeriod,
                                long StartFiberLength,
                                long FLRange,
                                long ChannelID,
                                const char *  TgrFolder );
public:
    const std::string &  getPart_StartTime(){
            return this->StartTime;
    };//"StartTime");
    long getPart_TimePeriod(){
        return this->TimePeriod;
    };//"TimePeriod")  ;
    long getPart_StartFiberLength(){
        return this->StartFiberLength;
    };//"StartFiberLength") ;
    long getPart_FLRange(){
        return this->FLRange;
    };//("FLRange") ; 
    int getPart_ChannelID() {
        return this->ChannelID;
    };//("ChannelID") ;
    const std::string & getPart_TgrFolder(){
        return this->TgrFolder;
    };//

    void setPart_StartTime(const char * startTime ){
        this->StartTime= startTime;
    };//"StartTime");
    void setPart_TimePeriod(long timeperiod){
        this->TimePeriod= timeperiod;
    } ;//"TimePeriod")  ;
    void setPart_StartFiberLength(long  fiberlength){
        this->StartFiberLength =fiberlength ;
    };//"StartFiberLength") ;
    void setPart_FLRange(long  Flrange ){
        this->FLRange = Flrange;
    };//("FLRange") ; 
    void setPart_ChannelID(int chnID){
        this->ChannelID = chnID;
    } ;//("ChannelID") ;
    void setPart_TgrFolder(const char *  tgrFolder){
        this->TgrFolder = tgrFolder;
    };//

    void  setfolderB(const char *  folder_B){
            this->folderB =folder_B;
    };
    void  setfolderA(const char *  folder_A){
        this->folderA =folder_A;
    };


    std::string getfolderB();
    std::string getfolderA();

};

extern glbCfg glbCfgObj;
extern struct CfgStrs CfgShellStrsObj;
#endif
