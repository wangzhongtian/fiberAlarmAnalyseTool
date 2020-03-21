
#ifndef __CFG__
#define __CFG__

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

#include "interface.h"
// #include "SocketProc.h"
extern char FileHeadStr[];
extern unsigned int FIleVersion ;
extern char IPaddress[] ;
extern unsigned int Port ;

time_t getCurtime();

// class clsSocketRecv;

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

class  clsPacketdata{
private:
  class socketInterface * psocketObj;
  bool isHeadOk;
  bool isTailOk;
  bool isNewCfgPara;
  unsigned long payloadlen;
  unsigned long datasize;
  unsigned long long SavedDataLen;
private:
    char IDchars [4];//EB90 EB90
    unsigned short type ; /*01表示原始数据，02表示滤波后数据，03表示过零数据，04表示能量数据    */
    unsigned short checkCode ;
    char machineName[20];// null terminated string，固定长度
    union datetimestr startDTStr;
    struct paraCLs paras;
    unsigned short dataType;//01表示char，02表示uchar，03表示int16，04表示uint16，05表示int32，06表示uint32，07表示float，08表示double
    unsigned long bufferSize;
    char  * datas ;

    unsigned int tailCheckCode; //FFFF FFFF
    time_t rev_t1;

public:
    unsigned short readtype() {return this->type; } ;
     char * readmachineName() { return this->machineName; };
     char *  readstartDTStr(){ return this->startDTStr.datetimeStr2 ;  };
     struct paraCLs & readparas(){  return this->paras ;};
    unsigned long readpayloadlen(){  return this->payloadlen ;};
     char  * readdatas(){ return this->datas;} ;
public:
    bool showCHeckheadCode( );
    bool showTypeCode( );
    bool showcheckCode( );
    bool showmachineName();
    bool showDT();
    bool showparas();
    bool showdataType();
    bool showtailCheckCode();
    bool showDataPayLoad(); 
    // unsigned int calDataPacketLen();

private:
    void clear( );    
private:
    bool getCHeckheadCode( );
    bool getTypeCode( );
    bool getcheckCode( );
    bool getmachineName();
    bool getDT();
    bool getparas();
    bool getdataType();
    bool gettailCheckCode();
    bool getDataPayLoad();
    unsigned int calDataPacketLen();

public:
    clsPacketdata();
    ~clsPacketdata();
public:
    unsigned short fileType();
    bool readFrame(class socketInterface* socketObj);
};
// extern int glbbufferdataLength;
extern int getGlbCnt();
#endif
