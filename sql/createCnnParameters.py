#!/usr/bin/env python
# -*- coding: utf-8 -*-

import MySQLdb
import sys

connection = MySQLdb.Connect(host="127.0.0.1", user="FX_USER", passwd="FX_USER", db="FX", charset="utf8", local_infile=1)
cursor = connection.cursor()

tableName = ["CNN_MLP_PARAS", "CNN_MLP_OUTPUT_NUMS", "CNN_MLP_W", "CNN_MLP_BN_PARAS"]
tableDef = [
	"("\
	"SEQ_NO bigint AUTO_INCREMENT,"\
	"CURRENCY varchar(6) NOT NULL,"\
	"PLUS_COUNT int(6) NOT NULL,"\
	"WAIT_COUNT int(6) NOT NULL,"\
	"MINUS_COUNT int(6) NOT NULL,"\
	"EPISODE_NUMS int(10) NOT NULL,"\
	"STEP_NUMS int(10) NOT NULL,"\
	"S_DATE varchar(12) NOT NULL,"\
	"E_DATE varchar(12) NOT NULL,"\
	"MINIBATCH_NUMS int(5) NOT NULL,"\
	"SV_DATA_NUMS int(10) NOT NULL,"\
	"SV_CHANNEL_NUMS int(5) NOT NULL,"\
	"SV_X_NUMS int(5) NOT NULL,"\
	"SV_Y_NUMS int(5) NOT NULL,"\
	"W_X_NUMS int(5) NOT NULL,"\
	"W_Y_NUMS int(5) NOT NULL,"\
	"POOLING_X_NUMS int(5) NOT NULL,"\
	"POOLING_Y_NUMS int(5) NOT NULL,"\
	"CNN_OUTPUT_NUMS_NUMS int(5) NOT NULL,"\
	"MLP_OUTPUT_NUMS_NUMS int(5) NOT NULL,"\
	"RGST_DATE_TIME varchar(14) NOT NULL,"\
	"PRIMARY KEY(SEQ_NO)"\
	");"
	,
	"("\
	"SEQ_NO bigint NOT NULL,"\
	"TYPE int(1) NOT NULL,"\
	"LAYER int(4) NOT NULL,"\
	"NUMS int(4) NOT NULL,"\
	"PRIMARY KEY(SEQ_NO, TYPE, LAYER)"\
	");"
	,
	"("\
	"SEQ_NO bigint NOT NULL,"\
	"TYPE int(1) NOT NULL,"\
	"IDX int(10) NOT NULL,"\
	"VALUE float NOT NULL,"\
	"PRIMARY KEY(SEQ_NO, TYPE, IDX, VALUE)"\
	");"
	,
	"("\
	"SEQ_NO bigint NOT NULL,"\
	"TYPE int(1) NOT NULL,"\
	"BN_TYPE int(2) NOT NULL,"\
	"IDX int(10) NOT NULL,"\
	"VALUE float NOT NULL,"\
	"PRIMARY KEY(SEQ_NO, TYPE, IDX, VALUE)"\
	");"
	]

if len(tableName) != len(tableDef):
	print "tableSize error."
	sys.exit()

for num in range(0, len(tableName)):
	#drop
	dropQueryTable = "DROP TABLE " + tableName[num] + ";"
	try:
		cursor.execute( dropQueryTable )
		print tableName[num] + " table is dropped."
	except MySQLdb.OperationalError, message:
		print tableName[num] + " table not exit, so that the table isn't dropped."

	#create
	createQueryTable = "CREATE TABLE " + tableName[num] + " " + tableDef[num] + ";"
	cursor.execute( createQueryTable )
	print tableName[num] + " table is created."

connection.commit()

cursor.close()
connection.close()
