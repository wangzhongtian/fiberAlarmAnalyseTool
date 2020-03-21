# coding=UTF8

###*-* coding=UTF8
# ipy64  accdb.py


import clr
clr.AddReference('System.Data')
import System.Data

import  System.Data.OleDb

accdbFilename = "I:\\data\\xxxx.accdb"
connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source="+accdbFilename+";";
conn =  System.Data.OleDb.OleDbConnection(connectionString);

queryString="select * from " + "201902";
dbCmd =  System.Data.OleDb.OleDbCommand(queryString, conn);
conn.Open();
reader = dbCmd.ExecuteReader();
a= str("序号")+","+str( "日期,时间")+","+str("通道" )+","+str("光程" )+"," +str("持续范围" ) +","+str("报警类型"  ) +","+str("报警友好名" ).strip() +","
print a
while  reader.Read():
	a= str(reader[0])+","+str(reader[1]).replace(" ",",")+","+str(reader[2])+","+str(reader[3])+"," +str(reader[4]) +","+str( reader[5]) +","+str(reader[6]).strip() +","
	print a
	# break
reader.Close();
