#!/usr/bin/env python
# -*- coding: utf-8 -*-

import MySQLdb
import mt4Define

connection = MySQLdb.Connect(host="127.0.0.1", user="FX_USER", passwd="FX_USER", db="FX", charset="utf8", local_infile=1)
cursor = connection.cursor()

tableDef = "("\
	"DATE varchar(8) NOT NULL,"\
	"TIME varchar(4) NOT NULL,"\
	"WDAY varchar(3) NOT NULL,"\
	"OPN_RATE int(6) NOT NULL,"\
	"HGHT_PRC int(6) NOT NULL,"\
	"LW_PRC int(6) NOT NULL,"\
	"CLS_RATE int(6) NOT NULL,"\
	"DIFF_OPN int(6) NOT NULL,"\
	"DIFF_HGHT int(6) NOT NULL,"\
	"DIFF_LW int(6) NOT NULL,"\
	"DIFF_CLS int(6) NOT NULL,"\
	"EMAshrt int(6) NOT NULL,"\
	"EMAlng int(6) NOT NULL,"\
	"DIFF_EMA int(6) NOT NULL,"\
	"EMAsgnl int(6) NOT NULL,"\
	"SIGMA_MID int(6) NOT NULL,"\
	"SIGMA_UP int(6) NOT NULL,"\
	"SIGMA_DOWN int(6) NOT NULL,"\
	"RSI int(3) NOT NULL,"\
	"STOCHASTIC int(3) NOT NULL,"\
	"PROFIT_ACT int(2),"\
	"TRGT_FLG int(1),"\
	"SEQ_NO bigint AUTO_INCREMENT,"\
	"RGST_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"\
	"PRIMARY KEY(SEQ_NO, DATE, TIME)"\
	");"

tickTableDef = "("\
	"DATE varchar(8) NOT NULL,"\
	"TIME varchar(4) NOT NULL,"\
	"WDAY varchar(3) NOT NULL,"\
	"OPN_RATE int(6) NOT NULL,"\
	"HGHT_PRC int(6) NOT NULL,"\
	"LW_PRC int(6) NOT NULL,"\
	"CLS_RATE int(6) NOT NULL,"\
	"DIFF_OPN int(6) NOT NULL,"\
	"DIFF_HGHT int(6) NOT NULL,"\
	"DIFF_LW int(6) NOT NULL,"\
	"DIFF_CLS int(6) NOT NULL,"\
	"EMAshrt int(6) NOT NULL,"\
	"EMAlng int(6) NOT NULL,"\
	"DIFF_EMA int(6) NOT NULL,"\
	"EMAsgnl int(6) NOT NULL,"\
	"SIGMA_MID int(6) NOT NULL,"\
	"SIGMA_UP int(6) NOT NULL,"\
	"SIGMA_DOWN int(6) NOT NULL,"\
	"RSI int(3) NOT NULL,"\
	"STOCHASTIC int(3) NOT NULL,"\
	"PROFIT_ACT int(2),"\
	"TRGT_FLG int(1),"\
	"SEQ_NO bigint AUTO_INCREMENT,"\
	"RGST_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"\
	"PRIMARY KEY(SEQ_NO, DATE, TIME)"\
	");"

workTableDef = "("\
	"STEP int(10) NOT NULL,"\
	"DATE varchar(8) NOT NULL,"\
	"TIME varchar(4) NOT NULL,"\
	"WDAY varchar(3) NOT NULL,"\
	"OPN_RATE int(6) NOT NULL,"\
	"HGHT_PRC int(6) NOT NULL,"\
	"LW_PRC int(6) NOT NULL,"\
	"CLS_RATE int(6) NOT NULL,"\
	"DIFF_OPN int(6) NOT NULL,"\
	"DIFF_HGHT int(6) NOT NULL,"\
	"DIFF_LW int(6) NOT NULL,"\
	"DIFF_CLS int(6) NOT NULL,"\
	"EMAshrt int(6) NOT NULL,"\
	"EMAlng int(6) NOT NULL,"\
	"DIFF_EMA int(6) NOT NULL,"\
	"EMAsgnl int(6) NOT NULL,"\
	"SIGMA_MID int(6) NOT NULL,"\
	"SIGMA_UP int(6) NOT NULL,"\
	"SIGMA_DOWN int(6) NOT NULL,"\
	"RSI int(3) NOT NULL,"\
	"STOCHASTIC int(3) NOT NULL,"\
	"PROFIT_ACT int(2),"\
	"PRIMARY KEY(STEP)"\
	");"


for currency in mt4Define.getSymbolList():
	
	for perTime in mt4Define.getPerTimeList():
		#drop------------------------------------------------------------------------------------------------------------------------
		dropQueryTable = "DROP TABLE " + str(currency) + "_MT4_" + str(perTime) + "MIN;"
		dropQueryTickTable = "DROP TABLE " + str(currency) + "_MT4_T_" + str(perTime) + "MIN;"
		dropQueryWorkTable = "DROP TABLE " + str(currency) + "_MT4_W_" + str(perTime) + "MIN;"
		#tableDef###########################################################################################################
		try:
#			cursor.execute(dropQueryTable)
			print str(currency) + "_MT4_" + str(perTime) + "MIN table is dropped."
		except MySQLdb.OperationalError, message:
			print str(currency) + "_MT4_" + str(perTime) + "MIN table not exists, so that the table isn't dropped."

		#tickTableDef########################################################################################################
		try:
			cursor.execute(dropQueryTickTable)
			print str(currency) + "_MT4_T_" + str(perTime) + "MIN table is dropped."
		except MySQLdb.OperationalError, message:
			print str(currency) + "_MT4_T_" + str(perTime) + "MIN table not exists, so that the table isn't dropped."
		#workTableDef#########################################################################################################
		try:
			cursor.execute(dropQueryWorkTable)
			print str(currency) + "_MT4_W_" + str(perTime) + "MIN table is dropped."
		except MySQLdb.OperationalError, message:
			print str(currency) + "_MT4_W_" + str(perTime) + "MIN table not exists, so that the table isn't dropped."
		#----------------------------------------------------------------------------------------------------------------------------

		#create--------------------------------------------------------------------------------------------------------------------
		createQueryTable = "CREATE TABLE " + str(currency) + "_MT4_" + str(perTime) + "MIN " + tableDef + ";"
		createQueryTickTable = "CREATE TABLE " + str(currency) + "_MT4_T_" + str(perTime) + "MIN " + tickTableDef + ";"
		createQueryWorkTable = "CREATE TABLE " + str(currency) + "_MT4_W_" + str(perTime) + "MIN " + workTableDef + ";"
		#tableDef##########################################################################################################
		try:
			cursor.execute(createQueryTable)
			print str(currency) + "_MT4_" + str(perTime) + "MIN table is created."
		except MySQLdb.OperationalError, message:
			print str(currency) + "_MT4_" + str(perTime) + "MIN table alredy exists, so that the table isn't created."

		#tickTableDef#####################################################################################################
		cursor.execute(createQueryTickTable)
		print str(currency) + "_MT4_T_" + str(perTime) + "MIN table is created."
		#workTableDef####################################################################################################
		cursor.execute(createQueryWorkTable)
		print str(currency) + "_MT4_W_" + str(perTime) + "MIN table is created."
		#-------------------------------------------------------------------------------------------------------------------------------

		connection.commit()

cursor.close()
connection.close()
