

#include "PartSnaplib.h"

extern "C" int snapPartdata1( struct CfgStrs & CfgShellStrsObj ){
    glbCfgObj.initStrs( CfgShellStrsObj );
    return 0x00;
    
    cRAW3FileProc cObj ;
    cObj.iterateEntry( );
    cObj.PostProcFiles();

    cRAW4FileProc cObj4 ;
    cObj4.iterateEntry( );
    cObj4.PostProcFiles();

    cRAW1FileProc cObj1 ;
    cObj1.iterateEntry( );
    cObj1.PostProcFiles();
    return 0;
}

extern "C" int snapPartdata(    const char * folderB,
                                const char * folderA,
                                const char * StartTime,
                                long TimePeriod,
                                long StartFiberLength,
                                long FLRange,
                                long ChannelID,
                                const char *  TgrFolder)
{
    glbCfgObj.initStrs( folderB,
                                 folderA,
                                 StartTime,
                                 TimePeriod,
                                 StartFiberLength,
                                 FLRange,
                                 ChannelID,
                                 TgrFolder );
    // return 0x00;
    
    cRAW3FileProc cObj ;
   printf( cObj.FileType.c_str() );
    cObj.iterateEntry( );
    cObj.PostProcFiles();

    cRAW4FileProc cObj4 ;
    printf( cObj4.FileType.c_str() );
    cObj4.iterateEntry( );
    cObj4.PostProcFiles();

    cRAW1FileProc cObj1 ;
    cObj1.iterateEntry( );
    cObj1.PostProcFiles();
    return 0;
}

const char folderB[]="G:\\dataroot\\a";
const char folderA[]="G:\\dataroot\\b";
const char StartTime[]="2019-03-06-08:51:16";
long TimePeriod=123;  
long StartFiberLength=344;
long FLRange=230;
long ChannelID=1;
const char TgrFolder[]="G:\\dataroot\\log";

int main(void){
int ret = snapPartdata(    folderB,
                            folderA,
                            StartTime,
                            TimePeriod,
                            StartFiberLength,
                            FLRange,
                            ChannelID,
                            TgrFolder);

}