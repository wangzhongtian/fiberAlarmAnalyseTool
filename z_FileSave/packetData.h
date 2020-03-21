#include <string>
#include <cstring>

#include "cfg.h"
#ifndef ___PACKETDATA___
#define ___PACKETDATA___

struct Packetdata // packet structure
{
    char IDchars [4];//EB90 EB90
    unsigned short type ; /*01表示原始数据，02表示滤波后数据，03表示过零数据，04表示能量数据    */
    unsigned short checkCode ;
    char machineName[20];// null terminated string，固定长度
    char startDTStr[14];
    struct paraCLs paras;
    unsigned short dataType;//01表示char，02表示uchar，03表示int16，04表示uint16，05表示int32，06表示uint32，07表示float，08表示double
    char * datas;
    unsigned int tailCheckCode; //FFFF FFFF
    unsigned int datasize;
private:
    unsigned long SavedDataLen;
    bool isNewCfgPara;

    unsigned int calDataPacketLen();
public:

    Packetdata();
    ~Packetdata();

public:
    unsigned short fileType();
    long saveCfgData( FILE * file1 );
    long savePayload(FILE *file1);
    void clear( );
    unsigned long long getSavedDataLen();
public:
    // bool readDatas(int Sockethandle1);
    bool isnewCfgParas();
    bool isNewData();
    std::string  getfileUNIQID( );
    std::string  getDTStr();
    bool isnewCfgParas( Packetdata * pSrc);

};

#endif