
# Compile : ipyc.exe /main:01-Autho.py 01-Autho.py  /target:exe   /standalone /platform:x86
#compile to DLL : ipyc Autho.py
import clr
import datetime
clr.AddReference('System.Data')
import System.Data
import  System.Data.OleDb
def mainEntry( ):
	a1 ="12345-W"

	def readinfo (conn):
		queryString="select * from " + "AuthorizationSetting";
		dbCmd =  System.Data.OleDb.OleDbCommand(queryString, conn);
		conn.Open();
		reader = dbCmd.ExecuteReader();
		while  reader.Read():
			a= str(reader[0])+","+str(reader[1]).replace(" ",",")+","+ \
			str(reader[2])+","+str(reader[3])+"," +str(reader[4]) +","+str( reader[5]) #+ \
			print a
		reader.Close();
		conn.Close();
	a2="12345-o2"
	def getCurDate():
		curDate = "2017" +"/"+"01"+"/"+ "01" + " 12:00:00"
		print curDate
		return curDate
	def updateInfo(conn,tgrDate ='2019/05/05 12:00:00'):
		queryString="update AuthorizationSetting set " + \
			"stopNow=false, cTimes= 10, aDate= '" + tgrDate + \
				"' ,cdate= '" + getCurDate()  \
					+"' where ID=1";
		dbCmd =  System.Data.OleDb.OleDbCommand(queryString, conn);
		print queryString
		conn.Open();
		dbCmd.ExecuteNonQuery();
		conn.Close();

	def getTgrDate(days=15):
		dt =  datetime.datetime.today() + datetime.timedelta( days=days)
		tgrDate = "" + str(dt.year)+"/"+ str(dt.month) +"/"+str(dt.day) + " 12:00:00"
		print tgrDate
		return tgrDate
	a3="340005-der"
	a4="125-ful"
	v= 366916
	def calPwss( a1 ):
		a= a1.split("-")
		return a[1]

	b1="1234-1"
	b2="tell-9"
	m3="io-8"
	m4="put-15"
	year = "20" + calPwss(b1) + calPwss(b2)
	month= calPwss(m3) 
	day = calPwss(m4) 
	t1 = datetime.datetime.today()
	t2= datetime.datetime( year= int(year),month = int(month),day =int(day ))
	# print t2  ,t1 
	ds =30

	if t2 < t1 :
		print "short period ...."
		ds =30
	pwss = raw_input("Please tell me your passwd:")
	if  pwss !="werty":
		import sys
		sys.exit()

	pwss = calPwss(a1) +calPwss(a2) +calPwss(a3) +calPwss(a4) + str(v)

	#Provider=Microsoft.ACE.OLEDB.16.0
	connectionString = "Provider=Microsoft.ACE.OLEDB.16.0;Data Source=.\xxxx\config\xxx.accdb;Persist Security Info=False;jet OLEDB:Database Password='"+ pwss +"'";
	conn =  System.Data.OleDb.OleDbConnection(connectionString);

	print " Org infos: "
	readinfo(conn)

	print " After modify,infos: "
	updateInfo(conn,getTgrDate( ds ))
	readinfo(conn)

def getMachineNameIP( ):
	a1 ="12345-W"

	def readinfo (pwss):
		connectionString = "Provider=Microsoft.ACE.OLEDB.16.0;Data Source=.\嘻嘻嘻\config\xxx.accdb;Persist Security Info=False;jet OLEDB:Database Password='"+ pwss +"'";
		conn =  System.Data.OleDb.OleDbConnection(connectionString);
		queryString="select ipAddr,hostName from " + "CommSetting";
		dbCmd =  System.Data.OleDb.OleDbCommand(queryString, conn);
		conn.Open();
		reader = dbCmd.ExecuteReader();
		reader.Read()
		a= str(reader[1]) +"-"+str(reader[0])
		print a
		reader.Close();
		conn.Close();
		return a
	a2="12345-on"
	a3="340005-der"
	a4="125-ful"
	v= 366916
	def calPwss( a1 ):
		a= a1.split("-")
		return a[1]

	b1="1234-1"
	b2="tell-9"
	m3="io-8"
	m4="put-15"
	year = "20"+calPwss(b1) + calPwss(b2)
	month= calPwss(m3) 
	day = calPwss(m4) 
	pwss = calPwss(a1) +calPwss(a2) +calPwss(a3) +calPwss(a4) + str(v)
	return  readinfo (pwss)
#mainEntry()