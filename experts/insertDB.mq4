//+------------------------------------------------------------------+
//|                                                     insertDB.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

bool EAenable = true;

string symbol[] = {"USDJPY", "EURJPY", "EURUSD", "AUDJPY", "NZDJPY"};
int timeframe[] = {PERIOD_M1, PERIOD_M5, PERIOD_M10, PERIOD_H1}; //時間で昇順にすること!!

//時刻を制御する変数
int timeCount = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
		//---
		Print("OnInit() start");
		EventSetTimer(60);
		//---
		return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
		//---
		EventKillTimer();
}

string strDayOfWeek(datetime t){
		int yobi = TimeDayOfWeek(t);
		string strYobi = "null";
		if(yobi == 0){
				strYobi = "Sun";
		}
		else if(yobi == 1){
				strYobi = "Mon";
		}
		else if(yobi == 2){
				strYobi = "Tue";
		}
		else if(yobi == 3){
				strYobi = "Wed";
		}
		else if(yobi == 4){
				strYobi = "Thu";
		}
		else if(yobi == 5){
				strYobi = "Fri";
		}
		else if(yobi == 6){
				strYobi = "Sat";
		}
		return(strYobi);
}

string arrayToStr(string &dateArray[], int &rateArray[], double &indicatorArray[]){
		string retStr;

		Print("yyyyddmm: " + dateArray[0]);

		string yyyyddmmString = TimeToStr(dateArray[0], TIME_DATE);
		Print("convert: " + yyyyddmmString);
		string hhmmssString = TimeToStr(dateArray[1], TIME_SECONDS);
		retStr = StringReplace(yyyyddmmString, ".", "");
		retStr += "," + StringReplace(hhmmssString, ".", "");
		retStr += "," + dateArray[2];
		int k;
		for(k = 0; k < ArraySize(rateArray); k ++){
				retStr += "," + DoubleToStr(rateArray[k], 0);
		}
		for(k = 0; k < ArraySize(indicatorArray); k ++){
				retStr += "," + DoubleToStr(indicatorArray[k], 0);
		}
		return(retStr);
}

//浮動小数配列をカンマで区切る
string arrayCommaDouble(double &commaArray[]){
		string commaArrayString = commaArray[0];
		int k;
		for(k = 1; k < ArraySize(commaArray); k ++){
				commaArrayString += "," + commaArray[k];
		}
		return(commaArrayString);
}

//整数配列をカンマで区切る
string arrayCommaInt(int &commaArray[]){
		string commaArrayString = commaArray[0];
		int k;
		for(k = 1; k < ArraySize(commaArray); k ++){
				commaArrayString += "," + commaArray[k];
		}
		return(commaArrayString);
}

//文字列配列をカンマで区切る
string arrayCommaString(string &commaArray[]){
		string commaArrayString = commaArray[0];
		int k;
		for(k = 1; k < ArraySize(commaArray); k ++){
				commaArrayString += "," + commaArray[k];
		}
		return(commaArrayString);
}

void writeFile(string &dateArray[], int &rateArray[], double &indicatorArray[], string symbol, int timeframe){
		string fileName = symbol + "_" + timeframe + "_" + dateArray[0] + dateArray[1] + ".dat";
		int handle = FileOpen(fileName, FILE_WRITE|FILE_CSV, ",");
		if(handle < 0){
				Print("FILE OPEN ERROR");
				Print("Error code:", GetLastError());
				FileClose(handle);
		}

		//カンマで配列を区切る
		string dateArrayString = arrayCommaString(dateArray);
		string rateArrayString = arrayCommaInt(rateArray);
		string indicatorArrayString = arrayCommaDouble(indicatorArray);

		//その他:ACT_FLG
		string etc = "0";

		//directory???
		Print("FILE WRITE " + symbol + IntegerToString(timeframe));
		//最後に","が余計についているので注意 ← DBにinsertするときにSEQ_NO文をnullにするため。
		FileWrite(handle, dateArrayString, rateArrayString, indicatorArrayString, etc, "");
		FileClose(handle);
}

//+------------------------------------------------------------------+
//| Expert OnTimer function                                          |
//+------------------------------------------------------------------+
//1分ごとに実効される
void OnTimer(){
		timeCount ++;
		int time;
		for(time = 0; time < ArraySize(timeframe); time ++){
				if(timeCount % timeframe[time] == 0){
						getData(time);

						//timeCountが大きくなりすぎないように、循環させる。
						timeCount = timeCount % timeframe[ArraySize(timeframe) - 1];
				}
		}
}

//OnTimerより時間単位で実効される。
void getData(int time){
		//---
		string dateArray[3];
		int rateArray[8];
		double indicatorArray[8];
		int i,j;
		for(i = 0; i < ArraySize(symbol); i ++){
				//PCの時刻を取得
				string localtime = TimeLocal();

				//年月日取得
				string yyyymmdd = TimeToStr(localtime, TIME_DATE);
				//StringReplaceは置換して、置換した数を返す。
				StringReplace(yyyymmdd, ".", "");
				dateArray[0] = yyyymmdd;

				//時刻取得
				string hhmi = TimeToStr(localtime, TIME_MINUTES);
				StringReplace(hhmi, ":", "");
				dateArray[1] = hhmi;

				//weekDay
				dateArray[2] = strDayOfWeek(TimeLocal());

				//OPN_RATE int(6)
				rateArray[0] = MathRound(iOpen(symbol[i], timeframe[time], 0) * 1000);
				//HGHT_PRC int(6)
				rateArray[1] = MathRound(iHigh(symbol[i], timeframe[time], 0) * 1000);
				//LW_PRC int(6)
				rateArray[2] = MathRound(iLow(symbol[i], timeframe[time], 0) * 1000);
				//CLS_RATE int(6)
				rateArray[3] = MathRound(iClose(symbol[i], timeframe[time], 0) * 1000);
				//DIFF_OPN int(6)
				rateArray[4] = rateArray[0] - (iOpen(symbol[i], timeframe[time], 1) * 1000);
				//DIFF_HGHT int(6) 
				rateArray[5] = rateArray[1] - (iHigh(symbol[i], timeframe[time], 1) * 1000);
				//DIFF_LW int(6)
				rateArray[6] = rateArray[2] - (iLow(symbol[i], timeframe[time], 1) * 1000);
				//DIFF_CLS int(6)
				rateArray[7] = rateArray[3] - (iClose(symbol[i], timeframe[time], 1) * 1000);

				//EMA_short 12priod ただし、1000倍して整数化する。
				indicatorArray[0] = MathRound(iMA(symbol[i], timeframe[time], 12, 0, MODE_EMA, PRICE_CLOSE, 0) * 1000);
				//EMA_long 20priod ただし、1000倍して整数化する。
				indicatorArray[1] = MathRound(iMA(symbol[i], timeframe[time], 20, 0, MODE_EMA, PRICE_CLOSE, 0) * 1000);
				//MACD = EMA_long - short
				indicatorArray[2] = MathRound(iMACD(symbol[i], timeframe[time], 12, 20, 9, PRICE_CLOSE, 0, 0) * 1000);
				//MACDsignal = 上記MACDの指数移動平均線の値
				indicatorArray[3] = MathRound(iMACD(symbol[i], timeframe[time], 12, 20, 9, PRICE_CLOSE, 1, 0) * 1000);
				//Bollinger Band(Middle)
				indicatorArray[4] = MathRound(iBands(symbol[i], timeframe[time], 9, 1, 0, PRICE_CLOSE, 0, 0) * 1000);
				//Bollinger Band(UP)
				indicatorArray[5] = MathRound(iBands(symbol[i], timeframe[time], 9, 1, 0, PRICE_CLOSE, 1, 0) * 1000);
				//Bollinger Band(DOWN)
				indicatorArray[6] = MathRound(iBands(symbol[i], timeframe[time], 9, 1, 0, PRICE_CLOSE, 2, 0) * 1000);
				//RSI
				indicatorArray[7] = MathRound(iRSI(symbol[i], timeframe[time], 9, PRICE_CLOSE, 0));

				//Write to File
				writeFile(dateArray, rateArray, indicatorArray, symbol[i], timeframe[time]);
		}
}
//+------------------------------------------------------------------+
