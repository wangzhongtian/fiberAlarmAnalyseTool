#include <string>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
// #include <sys/socket.h>
// #include <netinet/in.h>
// #include <netdb.h>
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

time_t _getCurtime();
struct datetimestrStruct {
    char year[4];
    char month[2];
    char day[2];
    char hour[2];
    char minute[2];
    char seconds[2];
}; 
struct  datetimestr{
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
// class clsDisk{
// private:
//     int NumberCnt0[4], NumberCnt1[4];
//     std::string mntFolder[2];
//    // std::string rootFoler;
// public:
//     std::string SelectmntFolder(int ID);
//     clsDisk(std::string subfolder1,std::string subfolder);
// };
// // 
// extern   clsDisk * clsDiskObj;

class glbCfg{
public:
    // unsigned long long  raw1max ;
    // unsigned  long long  raw2Max;
    // unsigned  long long  raw3Max;
    // unsigned  long long  raw4Max;
    std::string Logfolder;
    std::string folderB;
    std::string folderA;
    int row12DataNumPerfile;
    int row34DataNumPerfile;
public:
    // std::string getrawmaxfiles();
    std::string getLogfolder();
    std::string getfolderB();
    std::string getfolderA();
    
    glbCfg(){
       this->row12DataNumPerfile = (int) (1 * 60.0*(1200.0/512.0) );
       this->row34DataNumPerfile =  (int)( 30 *60.0*(1200.0/512.0) );
    };
};
extern glbCfg glbCfgObj;
#endif
