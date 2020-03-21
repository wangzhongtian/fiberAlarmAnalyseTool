#include <string>
#include <stdio.h>
#include "cfg.h"
// #include <sys/select.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <iostream>

std::string glbCfg::getfolderB(){
        // std::cout<<"here is ------B-----------------\r\n"<<folderA<<" ,"<< folderB<<std::endl;
     // return getEnvString("PT_FolderB") ; 
        return folderB;

}

std::string glbCfg::getfolderA(){
        //   std::cout<<"here is --------A---------------\r\n"<<folderA<<" ,"<< folderB<<std::endl;
 
        return folderA;
}
void glbCfg::initStrs(struct CfgStrs & cfgStrObj ){
        folderB=cfgStrObj.folderB;
        folderA=cfgStrObj.folderA;

        StartTime=cfgStrObj.StartTime;//"StartTime");
        TimePeriod =cfgStrObj.TimePeriod;//"TimePeriod")  ;
        StartFiberLength = cfgStrObj.StartFiberLength;;//"StartFiberLength") ;
        FLRange =cfgStrObj.FLRange;//("FLRange") ; 
        ChannelID =cfgStrObj.ChannelID; ;//("ChannelID") ;
        TgrFolder= cfgStrObj.TgrFolder;//[1024];//  = getPart_TgrFolder();//
        
        std::cout<< "folderB:"<<folderB<<" ,"<<cfgStrObj.FLRange<<" TimePeriod:"<<TimePeriod<<",ChnID:"<<ChannelID<<","<< this->TgrFolder<<" "
        <<cfgStrObj.TgrFolder<< std::endl;
}


void glbCfg::initStrs(const char * folderB1,
                                const char * folderA1,
                                const char * StartTime1,
                                long TimePeriod1,
                                long StartFiberLength1,
                                long FLRange1,
                                long ChannelID1,
                                const char *  TgrFolder1 ){

        folderB=folderB1;
        folderA=folderA1;
//      std::cout<<"here is -----------ALL ------------\r\n"<<folderA<<" ,"<< folderB<<std::endl;
        StartTime=StartTime1;//"StartTime");
        TimePeriod =TimePeriod1;//"TimePeriod")  ;
        StartFiberLength = StartFiberLength1;;//"StartFiberLength") ;
        FLRange =FLRange1;//("FLRange") ; 
        ChannelID =ChannelID1; ;//("ChannelID") ;
        TgrFolder= TgrFolder1;//[1024];//  = getPart_TgrFolder();//
        
        // std::cout<< "folderB: "<<folderB<<" ,"<<FLRange<<" TimePeriod:"<<TimePeriod<<"ChnID: "<<ChannelID<<","<< this->TgrFolder<<" "
        // <<TgrFolder<< std::endl;
}
glbCfg glbCfgObj;
// struct CfgStrs CfgShellStrsObj;