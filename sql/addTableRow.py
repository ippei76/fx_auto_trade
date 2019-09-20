#!/usr/bin/env python
# -*- coding: utf-8 -*-

import MySQLdb
import mt4Define

addColumnName = "STOCHASTIC"
afterColumnName = "RSI"

connection = MySQLdb.Connect(host="127.0.0.1", user="FX_USER", passwd="FX_USER", db="FX", charset="utf8", local_infile=1)
cursor = connection.cursor()

for currency in mt4Define.getSymbolList():
	for perTime in mt4Define.getPerTimeList():
		alterQueryTable = "ALTER TABLE " + str(currency) + "_MT4_" + str(perTime) + "MIN ADD " + addColumnName + " int(3) AFTER " + afterColumnName + ";"
		alterQueryWorkTable = "ALTER TABLE " + str(currency) + "_MT4_W_" + str(perTime) + "MIN ADD " + addColumnName + " int(3) AFTER " + afterColumnName + ";"
		try:
			cursor.execute(alterQueryTable)
			print alterQueryTable + " OK."
	#		cursor.execute(alterQueryWorkTable)
			print alterQueryWorkTable + " OK."

		except MySQLdb.OperationalError, message:
			print addColumnName + " already exist, so that the column isn't altered."

		connection.commit()

cursor.close()
connection.close()
