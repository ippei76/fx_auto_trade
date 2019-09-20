#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import shutil
import datetime

directory_archive = './gmo_archives/'
directory_save = './gmo_data/'

emaDayShort = 2
emaDayLong = 3
emaDaySignal = 2
bollingerDay = 4

# load data from archive
filename = "EURUSD.dat"

yobi = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"] 

def make_time_data():

	# create directory
	if os.path.exists(directory_save):
		shutil.rmtree(directory_save)
	os.mkdir(directory_save)

	print "INPUT:" + directory_archive + filename
	inputf = open(directory_archive + filename, 'r')
	inputLine = inputf.readlines()
	for line in inputLine:
		inputList = line.split(',')

		#inputList[0] = inputList[0].replace('/', '')
		#inputList[0] = inputList[0].replace(':', '')
		#inputList[0] = inputList[0].replace(' ', ',')
		tdatetime = datetime.datetime.strptime(inputList[0], '%Y%m%d%H%M%S')
		inputList.insert(1, yobi[tdatetime.weekday()])

		outputf = open(directory_save + filename, 'a')
		outputf.write((",".join(inputList)).replace('\r\n', '0,-1\n').replace('.', ''))#整数にする
		outputf.close()

	inputf.close()
	print "OUTPUT:" + directory_save + filename

def culcurate_bollinger_bind(endRateList,average):
	diffEndAveSum = 0
	for endRate in endRateList:
		diffEndAveSum += (int(endRate) - int(average)) ** 2
	Retval = float(diffEndAveSum) / (bollingerDay - 1)
	return(Retval ** 0.5)

def make_min_data(perTime):

	inputf = open(directory_save + filename, 'r')
	inputLine = inputf.readlines()
	count = 0
	outputList = [0] * 16
	beforeOutputList = [0] * 16
	beforeEndRateListLong = [emaDayLong]
	beforeEndRateListShort = [emaDayShort]
	beforeEndRateListSignal = [emaDaySignal]
	emaCount = 0
	week = "null"
	frstFlg = 0
	lineCount = 1
	emaSumTmpShort = 0
	emaSumTmpLong = 0
	emaSumTmpSignal = 0
	for line in inputLine:
		inputList = line.split(',')
		if(count == 0):
			outputList[0] = inputList[0][:8] + ',' + inputList[0][8:12]#日付,時刻
			outputList[1] = inputList[1]#曜日
			outputList[2] = inputList[2]#始値
			if(frstFlg == 0):
				outputList[6] = "0"#始値の差分:初回は0となる
			else:
				outputList[6] = str(int(inputList[2]) - int(beforeOutputList[2]))#始値の差分:初回は0となる
		#高値更新
		if(float(outputList[3]) == 0 or float(outputList[3]) < float(inputList[3])):
			outputList[3] = inputList[3]#高値
			if(frstFlg == 0):
				outputList[7] = "0"#高値の差分:初回は0となる
			else:
				outputList[7] = str(int(inputList[3]) - int(beforeOutputList[3]))#高値の差分:初回は0となる
		#安値更新
		if(float(outputList[4]) == 0 or float(outputList[4]) > float(inputList[4])):
			outputList[4] = inputList[4]#安値
			if(frstFlg == 0):
				outputList[8] = "0"#安値の差分:初回は0となる
			else:
				outputList[8] = str(int(inputList[4]) - int(beforeOutputList[4]))#安値の差分:初回は0となる
		#終値更新
		if(count == perTime - 1):
			outputList[5] = inputList[5]#終値
			if(frstFlg == 0):
				outputList[9] = "0"#終値の差分:初回は0となる
			else:
				outputList[9] = str(int(inputList[5]) - int(beforeOutputList[5]))#終値の差分:初回は0となる

			#EMA_short更新
			if(lineCount < emaDayShort - 1):
				beforeEndRateListShort.append(int(outputList[5]))
				outputList[10] = "0"
			elif(lineCount == emaDayShort - 1):
				emaSum = 0
				for endRate in beforeEndRateListShort:
					emaSum += endRate
				emaSumTmpShort = (int(outputList[5]) * 2 + emaSum) / (emaDayShort + 1)
				beforeEndRateListShort.append(int(outputList[5]))
				outputList[10] = str(emaSumTmpShort)
			else:
				emaSumTmpShort = (int(outputList[5]) * 2 + emaSumTmpShort * (emaDayShort - 1)) / (emaDayShort + 1)
				outputList[10] = str(emaSumTmpShort)
				beforeEndRateListShort.pop(0)
				beforeEndRateListShort.append(int(outputList[5]))

			#EMA_Long更新
			if(lineCount < emaDayLong - 1):
				beforeEndRateListLong.append(int(outputList[5]))
				outputList[11] = "0"
			elif(lineCount == emaDayLong - 1):
				emaSum = 0
				for endRate in beforeEndRateListLong:
					emaSum += endRate
				emaSumTmpLong = (int(outputList[5]) * 2 + emaSum) / (emaDayLong + 1)
				beforeEndRateListLong.append(int(outputList[5]))
				outputList[11] = str(emaSumTmpLong)
			else:
				emaSumTmpLong = (int(outputList[5]) * 2 + emaSumTmpLong * (emaDayLong - 1)) / (emaDayLong + 1)
				outputList[11] = str(emaSumTmpLong)
				beforeEndRateListLong.pop(0)
				beforeEndRateListLong.append(int(outputList[5]))

			outputList[12] = str(int(outputList[10]) - int(outputList[11]))

			sigma = 0
			if(lineCount >= bollingerDay):
				sigma = culcurate_bollinger_bind(beforeEndRateListLong, outputList[11])
			outputList[14] = str(round((1 * sigma), 4))
			outputList[15] = str(round((2 * sigma), 4))

			#EMA_Signal更新
			if(lineCount < emaDaySignal - 1):
				beforeEndRateListSignal.append(int(outputList[12]))
				outputList[13] = "0"
			elif(lineCount == emaDaySignal - 1):
				emaSum = 0
				for endRate in beforeEndRateListSignal:
					emaSum += endRate
				emaSumTmpSignal = (int(outputList[12]) * 2 + emaSum) / (emaDaySignal + 1)
				beforeEndRateListSignal.append(int(outputList[12]))
				outputList[13] = str(emaSumTmpSignal)
			else:
				emaSumTmpSignal = (int(outputList[12]) * 2 + emaSumTmpSignal * (emaDaySignal - 1)) / (emaDaySignal + 1)
				outputList[13] = str(emaSumTmpSignal)
				beforeEndRateListSignal.pop(0)
				beforeEndRateListSignal.append(int(outputList[12]))

		count = count + 1

		if(count == perTime):
			outputf = open(directory_save + str(perTime) + "min_" + filename, 'a')
			outputf.write((",".join(outputList)) + ',0,-1,-1\n')
			outputf.close()
			count = 0
			beforeOutputList = list(outputList)
			outputList = [0] * 16
			frstFlg = 1
			lineCount += 1

if __name__ == '__main__':
    make_time_data()
    make_min_data(5)
    make_min_data(10)
    make_min_data(60)
