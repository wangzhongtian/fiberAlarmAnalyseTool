#include "dataFileCls.h"
bool simpleDataFileCLs::addCount( const std::string  & UniqNameID ){
	 return false;
}

int simpleDataFileCLs::get_count() {
	return this->count;
}
int simpleDataFileCLs::get_MaxDataNum(){
	return this->_MaxDataNum;
}
simpleDataFileCLs::simpleDataFileCLs(unsigned int MaxDataNum,std::string & filetype,
	const char * NamePattern,unsigned int ID)
{
		this->_MaxDataNum =MaxDataNum  ;
		this->count =this->_MaxDataNum+10;
		this->filehandle =NULL;
		this->fileType=filetype;
		this->typeID = ID;
		curCount=0;	
		//this->minutesPerFile = minutesPerFile;
		t0= time(NULL);
		this->firstRunning = true;

		this->datafolder[0] = glbCfgObj.getfolderA() ;
		this->datafolder[1] = glbCfgObj.getfolderB()  ;
		this->PreStr ="PT-";
}

bool simpleDataFileCLs::isneedNewfile( ) throw() {
	    this->count += 1;
        if( this->count > this->_MaxDataNum){
            return true;
        }
        return false;
}
 bool simpleDataFileCLs::Createfilehandle( const std::string  & UniqNameID) {
		this->count=0;
		if( this->filehandle != NULL)
		{
			// fflush( this->filehandle);
			fclose( this->filehandle ) ;
			this->filehandle = NULL;
		}	 		
		std::string fullname = this->getFilename( UniqNameID );
		// printf(";;;;%s\r\n",fullname.c_str());
        this->filehandle = fopen( fullname.c_str(),"wb");
		
        if ( this->filehandle == NULL ){
            std::string a =  "File Created Error,:";
            a += fullname;
            FileCreateFail FileCreateFailObj( a);
            throw FileCreateFailObj;
            return false ;
        }
        return true;
}

std::string simpleDataFileCLs::getFilename( const std::string  & UniqNameID )  {
	int FIleVersion=0;
    std::string  name  ="" ;//this->rootFolder;
	char tem[200] ;
	int j = this->curCount ++ % 2;
	// printf("%d,%d\r\n",j, this->curCount);
		//return std::string( "as");
	sprintf(tem,"Data^Ver%02d^%s^ID%02d.%s",FIleVersion,UniqNameID.c_str(),0x00,this->fileType.c_str() );
	//return std::string( tem);
	name  = this->datafolder[ j ] +"/" + std::string( tem );
	// printf("===========%s\r\n",name.c_str() );
    return   name ;
}
FileCreateFail::FileCreateFail(const std::string&  __arg){
    this->_M_msg = __arg;
}
FileCreateFail::~FileCreateFail() throw(){
        
}
const char*  FileCreateFail::what() const throw(){
    return this->_M_msg.c_str();
}
