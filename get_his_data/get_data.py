#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import datetime

def make_minutely_data():

	directory_archive = './archives/'
	directory_save = './data/'

	yobi = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"] 

	data = {}

	# create directory
	if not os.path.exists(directory_save):
		os.mkdir(directory_save)

	# load data from archive
	filename = "USDJPY_1min.txt"
	print directory_archive + filename
	inputf = open(directory_archive + filename, 'r')
	inputLine = inputf.readlines()
	for line in inputLine:
		inputList = line.split(',')

		inputList[0] = inputList[0].replace('/', '')
		inputList[0] = inputList[0].replace(':', '')
		inputList[0] = inputList[0].replace(' ', ',')
		tdatetime = datetime.datetime.strptime(inputList[0], '%Y%m%d,%H%M')
		inputList.insert(1, yobi[tdatetime.weekday()])

		outputf = open(directory_save + filename, 'a')
		outputf.write((",".join(inputList)).replace('\r\n', ',0,-1\n'))
		outputf.close()

	inputf.close()

if __name__ == '__main__':
    make_minutely_data()
