#!/usr/bin/env python
# -*- coding: utf-8 -*-

import MySQLdb

connection = MySQLdb.Connect(host="127.0.0.1", user="FX_USER", passwd="FX_USER", db="FX", charset="utf8", local_infile=1)
cursor = connection.cursor()

for perTime in [5, 10, 60]:
	query = "TRUNCATE TABLE EURUSD_RATE_RAW_" + str(perTime) + "MIN"
	cursor.execute( query )
	connection.commit()

	query = "LOAD DATA LOCAL INFILE '/root/projects/fx/get_his_data/gmo_data/" + str(perTime) + "min_EURUSD.dat' INTO TABLE EURUSD_RATE_RAW_" + str(perTime) + "MIN FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';"
	cursor.execute( query )
	connection.commit()

connection.close()
