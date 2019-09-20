#!/usr/bin/env python
# -*- coding: utf-8 -*-

import MySQLdb

connection = MySQLdb.Connect(host="127.0.0.1", user="FX_USER", passwd="FX_USER", db="FX", charset="utf8", local_infile=1)
cursor = connection.cursor()

tableName = "SYNC_TRADE"
tableDef = "("\
	"CURRENCY varchar(6) NOT NULL,"\
	"DATE varchar(8) NOT NULL,"\
	"TIME varchar(4) NOT NULL,"\
	"TRADE_FLG int(1) NOT NULL,"\
	"POSITION_FLG int(1) NOT NULL,"\
        "PROFIT_FLG int(1),"\
        "BEST_ACT int(1),"\
	"PROFIT int(6),"\
	"EXEC_PRICE int(6),"\
	"SETT_PRICE int(6),"\
	"EXEC_TIME int(6),"\
	"SETT_TIME int(6),"\
	"LINK_FLG int(1),"\
	"REMARKS varchar(30),"\
	"SEQ_NO bigint AUTO_INCREMENT,"\
	"UPDATE_TIME TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,"\
	"PRIMARY KEY(SEQ_NO)"\
	");"

#	"TRADE_FLG int(1) NOT NULL,"\ 0:buy  1:wait  2:sell
#	"POSITION_FLG int(1) NOT NULL,"\ 0:ポジション未取得  1:ポジション取得  2:異常発生によりポジション未取得  3:決済完了
#       "PROFIT_FLG int(1),"\ 0:未決済  1:(+)決済  2:(-)決済
#       "BEST_ACT int(1),"\ 0:buy  1:wait  2:sell
#	"LINK_FLG int(1),"\ 0:未連動  1:MT4連動済み

#drop
dropQueryTable = "DROP TABLE " + tableName + ";"
try:
	cursor.execute( dropQueryTable )
	print tableName + " table is dropped."
except MySQLdb.OperationalError, message:
	print tableName + " table not exit, so that the table isn't dropped."

#create
createQueryTable = "CREATE TABLE " + tableName + " " + tableDef + ";"
cursor.execute( createQueryTable )
print tableName + " table is created."

connection.commit()

cursor.close()
connection.close()
