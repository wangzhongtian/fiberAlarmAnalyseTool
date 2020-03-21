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

// #define WINDOWS
// #define WINDOWS
// #undef WINDOWS
#include "Os.h"
// #ifdef WINDOWS
//     #define PbuuferType const char *
//      #include   <Winsock2.h>  
//     // #define MSG_WAITALL 0x00 
//     int closeSocket(SOCKET t );
// #else
    #include <sys/socket.h>
    #include <netinet/in.h>
    #include <netdb.h>
    #define SOCKET int 
    #define PbuuferType const char *
    #define INVALID_SOCKET -1

    // #include <sys/socket.h>
    // #include <netinet/in.h>
    #include <netdb.h>
    #include <arpa/inet.h>

// #endif


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

class  clsPacketdata  {
private:
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
    char * datas;
    unsigned int tailCheckCode; //FFFF FFFF
    time_t rev_t1;
private:
    bool getDatas(unsigned int size,char *buf);
    SOCKET  Sockethandle;
private:
    bool getCHeckheadCode( );
    bool getTypeCode( );
    bool getcheckCode( );
    bool getmachineName();
    bool getDT();
    bool getparas();
    bool getdataType();
    bool gettailCheckCode();
    unsigned int calDataPacketLen();
    bool getDataPayLoad();

public:
    clsPacketdata();
    ~clsPacketdata();
    std::string getpacketDtStr(){ 
        char tem[24];
        memset(tem,0x00,sizeof( tem) );
        memcpy( tem, startDTStr.datetimeStr2 ,sizeof(startDTStr.datetimeStr2 ));
        return std::string( tem) ;
        }
    std::string getpacketRecvDtStr(){ 
        struct tm *tblock =localtime(&rev_t1); 
        char tem[96];
        sprintf(tem,"Packet Recved at:%02d%02d-%02d:%02d:%02d",
            tblock->tm_mon+1, 
            tblock->tm_mday ,tblock->tm_hour, tblock->tm_min,tblock->tm_sec );
        return std::string( tem);
        }  
public:
    unsigned short fileType();
    long  saveCfgData( FILE * file1 );
    long savePayload(FILE *file1);
    void clear( );
    unsigned long long getSavedDataLen();
public:
    bool readDatas(SOCKET Sockethandle1);
    bool isnewCfgParas();
    bool isNewData();
    std::string  getfileUNIQID( );
    std::string  getDTStr();
    bool isnewCfgParas( clsPacketdata * pSrc);
};

class clsDisk{
private:
    int NumberCnt0[4], NumberCnt1[4];
    std::string mntFolder[2];
   // std::string rootFoler;
public:
    std::string SelectmntFolder(int ID);
    clsDisk(std::string subfolder1,std::string subfolder);
};
// 
extern   clsDisk * clsDiskObj;

int getEnvInt(const char * EnvName );
std::string getEnvString( const char * EnvName);
#endif
