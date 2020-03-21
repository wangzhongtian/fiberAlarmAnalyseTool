import clr
import datetime
clr.AddReference('System.Data')
import System.Data
import  System.Data.OleDb

# from __future__ import print_function

import clr

import System
import System.IO

dllname=r"""G:\\a\\NSBD_USB\\ipy\\ACCDBExpired\\Autho.dll""" ;
dllname=r"""Autho.dll""" ;
clr.AddReferenceToFileAndPath( dllname   )
# dllname=r"""AppAssembly.dll""" ;clr.AddReferenceToFileAndPath( getFullNames(dllname) )
import  Autho

def introOutAlarm( dt,connectionString ):
	conn =  System.Data.OleDb.OleDbConnection(connectionString);
	month = str(dt.month)
	if len( month ) == 1:
		month ="0"+ month
	tbname = str( dt.year  ) + month 
	print tbname 
	queryString="select * from " + tbname;
	dbCmd =  System.Data.OleDb.OleDbCommand(queryString, conn);
	conn.Open();
	reader = dbCmd.ExecuteReader();
	import codecs
	filename =  machinenameIP+"-"+tbname+".csv"
	fo = codecs.open(filename, "w",encoding="utf_8_sig") 
	#fo = open( machinenameIP+"-"+tbname+".csv","w")
	while  reader.Read():
		a= str(reader[0])+","+str(reader[1]).replace(" ",",")+","+str(reader[2])+","+str(reader[3])+"," +str(reader[4]) +","+str( reader[5]) +","+str(reader[6]).strip() +"\r\n"
		fo.write( a)
	reader.Close();
	fo.close()
	conn.Close()
machinenameIP = Autho.getMachineNameIP()
connectionString = "Provider=Microsoft.ACE.OLEDB.16.0;Data Source=.\\xxx\\xxxx\\xxx.accdb;";

dt =datetime.datetime.today() 
introOutAlarm( dt,connectionString )

dt1 = dt + datetime.timedelta(-1)
if dt.year != dt1.year or dt.month != dt1.month :
	introOutAlarm( dt1,connectionString )