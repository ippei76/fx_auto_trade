#!/usr/bin/env python
# -*- coding: utf-8 -*-

import MySQLdb
import mt4Define

connection = MySQLdb.Connect(host="127.0.0.1", user="FX_USER", passwd="FX_USER", db="FX", charset="utf8", local_infile=1)
cursor = connection.cursor()

#               yyyyMMddhhmm
startDateTime = 201608091730
endDateTime   = 201608111400

limitStep = 30	#30min

upPrc = 100
downPrc = 100

date = 0
time = 1
openRate = 2
hghtPrc = 3
lwPrc = 4
clsRate = 5
profitAct = 6
seqNo = 7

buyAct = 0
sellAct = 1
waitAct = 2

def getSeqNoFromDateTime(dateTime, tableName):

	sql = "SELECT MAX(SEQ_NO) FROM " + tableName + " WHERE CONCAT(DATE, TIME) <= '" + str(dateTime) + "';"
	cursor.execute(sql)
	seqNo = cursor.fetchone()[0]
	return(seqNo)

def getProfitAct(oneDataList, tableName):
		
	profitActDownSql = "SELECT MIN(SEQ_NO) FROM " + tableName + " "\
			"WHERE " + str(oneDataList[seqNo]) + " <= SEQ_NO AND SEQ_NO < "  + str(oneDataList[seqNo])+ " +  " + str(limitStep) + " "\
			"AND " + str(int(oneDataList[openRate]) - downPrc) + " > LW_PRC;"
	cursor.execute(profitActDownSql)
	minSeqNoDown = cursor.fetchone()[0]
		
	profitActUpSql = "SELECT MIN(SEQ_NO) FROM " + tableName + " "\
			"WHERE " + str(oneDataList[seqNo]) + " <= SEQ_NO AND SEQ_NO < "  + str(oneDataList[seqNo])+ " +  " + str(limitStep) + " "\
			"AND " + str(int(oneDataList[openRate]) + upPrc) + " < HGHT_PRC;"
	cursor.execute(profitActUpSql)
	minSeqNoUp = cursor.fetchone()[0]

	#minSeqNoがNONEだった場合には、大きい値を設定する。
	if minSeqNoDown is None:
		#大きい数を設定
		minSeqNoDown = oneDataList[seqNo] + limitStep + 1
	if minSeqNoUp is None:
		#小さい数を設定
		minSeqNoUp = oneDataList[seqNo] + limitStep + 1
		
	#downとupの大小比較
	if minSeqNoDown < minSeqNoUp:
		return(sellAct)
	elif minSeqNoUp < minSeqNoDown:
		return(buyAct)
	else:
		return(waitAct)

def selectAllDataList(startSeqNo, endSeqNo, tableName):

	sql = "SELECT DATE, TIME, OPN_RATE, HGHT_PRC, LW_PRC, CLS_RATE, 'PROFIT_ACT', SEQ_NO FROM " + tableName
	sql += " WHERE '" + str(startSeqNo) + "' <= SEQ_NO AND SEQ_NO <= '" + str(endSeqNo) + "' ORDER BY SEQ_NO, DATE, TIME;"
	cursor.execute(sql)

	allDataList = cursor.fetchall()

	return(allDataList)

def deleteGarbageData(startSeqNo, endSeqNo, tableName):

	sql = "DELETE FROM " + tableName + " WHERE OPN_RATE = 0"
	sql += " AND '" + str(startSeqNo) + "' <= SEQ_NO AND SEQ_NO <= '" + str(endSeqNo) + "';"
	cursor.execute(sql)
	connection.commit()

def updateProfitAct(oneDataList, profitAct, tableName):

	sql = "UPDATE " + tableName + " SET PROFIT_ACT = " + str(profitAct) + " WHERE PROFIT_ACT = -1 AND DATE = '" + str(oneDataList[date]) + "' AND TIME = '" + str(oneDataList[time]) + "';"
	cursor.execute(sql)
	connection.commit()

def mainFunction():

	for currency in mt4Define.getSymbolList():
		#ProfitActは1分テーブルにだけつければ十分
		#for perTime in [1, 5, 10, 60]:
		#for perTime in [1]:
		for perTime in mt4Define.getPerTimeList():
			tableName = str(currency) + "_MT4_" + str(perTime) + "MIN "
			print tableName + " is target."

			#対象SEQ_NO取得
			startSeqNo = getSeqNoFromDateTime(startDateTime, tableName)
			endSeqNo = getSeqNoFromDateTime(endDateTime, tableName)

			#ゴミデータの削除
			deleteGarbageData(startSeqNo, endSeqNo, tableName)
			print tableName + " is completed on deleteFarbageData."

			#データ削除により、データ数が減少した可能性があるため、再度対象SEQ_NO取得
			startSeqNo = getSeqNoFromDateTime(startDateTime, tableName)
			endSeqNo = getSeqNoFromDateTime(endDateTime, tableName)

			#データリストを取得
			allDataList = selectAllDataList(startSeqNo, endSeqNo, tableName)
			print tableName + " is getted on allDataList."

			for oneDataList in allDataList:
				#Profit_ACTを求める。
				profitAct = getProfitAct(oneDataList, tableName)
				#Profit_ACTをセットする。
				updateProfitAct(oneDataList, profitAct, tableName)

			print tableName + " is completed on updating."

if __name__ == '__main__':
    mainFunction()
    connection.close()
