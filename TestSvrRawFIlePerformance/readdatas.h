

#ifndef __READDATAS__
#define __READDATAS__

#include <stdlib.h>
#include <string>
// using namespace std;
class fileReainCls{
public:
    static  std::string staticFilename;
public:
    std::string filename;
    FILE *rawfileobj;
// private:    
//     char machineName[20];// null terminated string，固定长度
//     union datetimestr startDTStr;
//     struct paraCLs paras;
//     char * datas;
public:
   fileReainCls( );
   ~fileReainCls();
   virtual void readin_machineName(){};
   virtual void readin_startDTStr(){};
   virtual void readin_paras(){};
   virtual void readin_datas(){};
};

#endif