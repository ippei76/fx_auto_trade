#!/usr/bin/env python
# -*- coding: utf-8 -*-

import MySQLdb

connection = MySQLdb.Connect(host="127.0.0.1", user="FX_USER", passwd="FX_USER", db="FX", charset="utf8", local_infile=1)
cursor = connection.cursor()

query = "TRUNCATE TABLE USDJPY_RATE_RAW_1MIN"
cursor.execute( query )
connection.commit()

query = "LOAD DATA LOCAL INFILE '/root/projects/fx/get_his_data/data/USDJPY_1min.txt' INTO TABLE USDJPY_RATE_RAW_1MIN FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';"
cursor.execute( query )
connection.commit()

connection.close()
