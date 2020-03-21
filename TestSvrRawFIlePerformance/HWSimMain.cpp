/*

 writer :SunZhi
 For: PT wangzhongtian

*/
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
#include "cfg.h"
#include "HWSim.h"
#include "readdatas.h"
#include <string>
#define MAX_LINE 256
// #define SERVER_PORT 5432
// gcc HWSim.cpp HWSimMain.cpp cfg.cpp   -lstdc++ -ob.out
#define defaultServerIP "192.168.1.114"
#define  defaultPort 19998
clsSockSIM simSocketObj;
void server_on_exit(void)
{
    printf("Program will exited out...\r\n");
    //do something when process exits
    simSocketObj.destroySocket();
    exit(-1);
}

void signal_crash_handler(int sig)
{
    printf("Program will exited out %d crash Handler..\r\n",sig);
    //server_backtrace(sig);
    simSocketObj.destroySocket();
    exit(-1);
}

void signal_exit_handler(int sig)
{
    printf("Program will exited out %d exitHandler..\r\n",sig);
    simSocketObj.destroySocket();
    exit(0);
}
    std::string fileReainCls::staticFilename ="";
//    // ignore SIGPIPE
//    signal(SIGPIPE, SIG_IGN);
int main( void){

    long c=0x00;
    // printf("------%ld\r\n",c);    
    // printf("------%ld\r\n",c);   
    // printf("------%ld\r\n",c); 
    // return 0;   
    atexit(server_on_exit);
    signal(SIGTERM, signal_exit_handler);
    signal(SIGINT, signal_exit_handler);

    // ignore SIGPIPE
    // #ifndef WINDOWS
    //     signal(SIGPIPE, SIG_IGN);
    //     signal(SIGBUS, signal_crash_handler);     // 总线错误
    // #endif
    signal(SIGSEGV, signal_crash_handler);    // SIGSEGV，非法内存访问
    signal(SIGFPE, signal_crash_handler);       // SIGFPE，数学相关的异常，如被0除，浮点溢出，等等
    signal(SIGABRT, signal_crash_handler);

    printf("------%ld\r\n",c);    
    const char * val1 = getenv("PT_RAWFileName");
    fileReainCls::staticFilename = val1;
    printf( "%s\r\n",fileReainCls::staticFilename.c_str() );
    const char * IPaddress1 = getenv("PT_ServerIP");
    const char * val = getenv("PT_ServerPort");

	unsigned int Port1=atol( val);
    // IPaddress1 = (const char *)defaultServerIP;
    // Port1 =defaultPort;
    simSocketObj.init(IPaddress1,Port1);
    for (int d =0;d<4;d++){
        simSocketObj.RAWS[d] =0;
    }
     simSocketObj.RAWS[2] =1;  //## send out the RAW3
    

    while(1){
        c+=1;
        printf("%ld\r\n",c);
        int ret = simSocketObj.PreProc();printf("%ld\r\n",c+1);
        if( ret != 0x00){
            sleep(1);
            continue;
        }

        printf("Enter into Procdata\r\n");
        simSocketObj.ProcData();
        printf("exit out from Procdata\r\n");
        printf("%ld\r\n",c+2);
        // printf("Exception happend\r\n");
        simSocketObj.postProcdata();
        printf("%ld\r\n",c+3);
       // break;
    }
    printf(" system exit!!\r\n");
    simSocketObj.destroySocket();
	return -1;
}

//-------------------------------------------------------------

extern int sleepMiliseconds;
extern "C" int mainJl( char * PT_RAWFileName ,char * PT_ServerIP,char * PT_ServerPort,int SleepMiliseconds){
    sleepMiliseconds =SleepMiliseconds;
    long c=0x00;
    fileReainCls::staticFilename = PT_RAWFileName;
    printf( "%s\r\n",fileReainCls::staticFilename.c_str() );
    const char * IPaddress1 =PT_ServerIP;// getenv("PT_ServerIP");
    const char * val =PT_ServerPort ;// getenv("PT_ServerPort");

	unsigned int Port1=atol( val);

    int ret= simSocketObj.init(IPaddress1,Port1);
    if ( ret < 0 ){
        return -1;
    }
    for (int d =0;d<4;d++){
        simSocketObj.RAWS[d] =0;
    }
    simSocketObj.RAWS[2] =1;  //## send out the RAW3

    while(1){
        c+=1;
        printf("%ld\r\n",c);
        int ret = simSocketObj.PreProc();
        printf("%ld\r\n",c+1);
        if( ret != 0x00){
            sleep(1);
            continue;
        }

        printf("Enter into Procdata\r\n");
        try {
            simSocketObj.ProcData();
        }
        catch (std::string &e){
            printf( "Exception happened:%s\r\n",e.c_str());
            break;
        }

    }
       simSocketObj.waitProcPost();
    printf(" system exit!!\r\n");
	return 0;
}


