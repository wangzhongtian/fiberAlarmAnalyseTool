

extern   bool needSaveFile;
extern   bool needJuliaSend;

extern "C"  int initSaveData(char Logfolder[],char folderA[], char  folderB[] );

// extern "C"  int initSaveDataFull( unsigned long long   raw1max,unsigned long  long raw2Max,unsigned long long raw3Max,unsigned long long raw4Max,char Logfolder[],char folderA[], char  folderB[] );
extern "C"  bool Save2File( unsigned short rawDatatype,char machineName[] ,char startDTStr[],char cfgdata[],char * datas ,int datalen );

extern "C" bool fetchJuliaFile( unsigned short *rawDatatype ,char machineName[] ,char startDTStr[],char cfgdata[ ],char * datas ,unsigned int * datalen );
bool Save2JuliaFile( unsigned short rawDatatype,char machineName[] ,char startDTStr[],char cfgdata[ ],char * datas ,int datalen );
// extern "C" int  initJuliaData( bool needSaveFile, bool needJuliaSend );
extern "C"  int  initJuliaData( bool needSaveFile1, bool needJuliaSend1 , bool needFlowControl1);