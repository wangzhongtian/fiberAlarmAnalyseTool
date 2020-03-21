#ifndef ___DATAFILECLS___
#define ___DATAFILECLS___
#include <dirent.h>
#include <sys/types.h>
#include <stdio.h>
#include <string>
#include <set>
#include <map>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <iostream>
#include <time.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h> 
#include <exception>

#include "cfg.h"

static time_t t0;
static time_t t1;

class FileCreateFail:public std::exception{
private:
    std::string _M_msg;
public:
    explicit FileCreateFail(const std::string&  __arg);
    virtual ~FileCreateFail() throw();
    virtual const char*  what() const throw();
};


class simpleDataFileCLs  {
public:
	bool addCount( const std::string  & UniqNameID );
	// DataFileCLs(unsigned int MaxDataNum,std::string & filetype,const char * NamePattern,unsigned int ID,int maxFiles);
	int get_count() ;
	int get_MaxDataNum();
private:
	std::string getFilename( const std::string  & UniqNameID ) ;
private:
	FILE * filehandle;
	time_t t1;
	time_t t0;
	int minutesPerFile;
	bool firstRunning;
	std::string  rootFolder;
	std::string PreStr;
	int interval;
	std::string datafolder[2];
	//cfolderProc *folderProcObj[2];
	std::string fileType;
	int curCount;
	int count;
	unsigned int _MaxDataNum ;
	int typeID;
public:
	simpleDataFileCLs(unsigned int MaxDataNum,std::string & filetype, const char * NamePattern,unsigned int ID);;
public:
	virtual bool isneedNewfile( ) throw() ;
	virtual bool Createfilehandle(const std::string  & UniqNameID) ;
	FILE * getfileObj() { return filehandle; };
};

#endif