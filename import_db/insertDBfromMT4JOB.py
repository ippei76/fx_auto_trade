#!/usr/bin/env python
# -*- coding: utf-8 -*-

import MySQLdb

connection = MySQLdb.Connect(host="127.0.0.1", user="FX_USER", passwd="FX_USER", db="FX", charset="utf8", local_infile=1)
cursor = connection.cursor()

for currency in ["USDJPY", "EURJPY", "EURUSD", "AUDJPY", "NZDJPY"]:
	for perTime in [1, 5, 10, 60]:
		query = "LOAD DATA LOCAL INFILE '/root/projects/fx/work/" + str(currency) + "/min" + str(perTime) + "/min" + str(perTime) + "_" + str(currency) + ".dat' INTO TABLE " + str(currency( + "_MT4_" + str(perTime) + "MIN FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';"
		cursor.execute( query )
		connection.commit()

connection.close()
