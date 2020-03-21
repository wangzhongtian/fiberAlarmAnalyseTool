#include "HWSim.h"

class clsPacketdata_ZC:public clsPacketdata_base{
public:
    clsPacketdata_ZC( );
    virtual void readin_machineName();
    virtual void readin_startDTStr();
    virtual void readin_paras();
    virtual void readin_datas();
};
