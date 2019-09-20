#!/usr/bin/env python
# -*- coding: utf-8 -*-

import MySQLdb
import sys

connection = MySQLdb.Connect(host="127.0.0.1", user="FX_USER", passwd="FX_USER", db="FX", charset="utf8", local_infile=1)
cursor = connection.cursor()

tableName = ["RL_PARAS", "RL_UNITS", "RL_MU", "RL_SIGMA", "RL_W", "RL_XC"]
tableDef = [
	"("\
	"RL_SEQ_NO bigint AUTO_INCREMENT,"\
	"CURRENCY varchar(6) NOT NULL,"\
	"PLS_COUNT int(6) NOT NULL,"\
	"WAIT_COUNT int(6) NOT NULL,"\
	"MINUS_COUNT int(6) NOT NULL,"\
	"EPISODES int(10) NOT NULL,"\
	"SDATE varchar(12) NOT NULL,"\
	"EDATE varchar(12) NOT NULL,"\
	"STATES varchar(256) NOT NULL,"\
	"BAR_TABLE varchar(50) NOT NULL,"\
	"HIS_STEP int(2) NOT NULL,"\
	"RGST_DATE_TIME varchar(14) NOT NULL,"\
	"PRIMARY KEY(RL_SEQ_NO)"\
	");"
	,
	"("\
	"RL_SEQ_NO bigint NOT NULL,"\
	"ACT int(4) NOT NULL,"\
	"UNITS int(4) NOT NULL,"\
	"PRIMARY KEY(RL_SEQ_NO, ACT, UNITS)"\
	");"
	,
	"("\
	"RL_SEQ_NO bigint NOT NULL,"\
	"ACT int(4) NOT NULL,"\
	"UNIT int(4) NOT NULL,"\
	"STATE int(8) NOT NULL,"\
	"MU_VALUE DECIMAL(65, 5) NOT NULL,"\
	"PRIMARY KEY(RL_SEQ_NO, ACT, UNIT, STATE)"\
	");"
	,
	"("\
	"RL_SEQ_NO bigint NOT NULL,"\
	"ACT int(4) NOT NULL,"\
	"UNIT int(4) NOT NULL,"\
	"SIGMA_VALUE DECIMAL(65, 5) NOT NULL,"\
	"PRIMARY KEY(RL_SEQ_NO, ACT, UNIT)"\
	");"
	,
	"("\
	"RL_SEQ_NO bigint NOT NULL,"\
	"ACT int(4) NOT NULL,"\
	"UNIT int(4) NOT NULL,"\
	"W_VALUE DECIMAL(65, 5) NOT NULL,"\
	"PRIMARY KEY(RL_SEQ_NO, ACT, UNIT)"\
	");"
	,
	"("\
	"RL_SEQ_NO bigint NOT NULL,"\
	"ACT int(4) NOT NULL,"\
	"XC_VALUE DECIMAL(65, 5) NOT NULL,"\
	"PRIMARY KEY(RL_SEQ_NO, ACT)"\
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
