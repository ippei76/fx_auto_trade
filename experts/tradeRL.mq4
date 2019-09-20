//+------------------------------------------------------------------+
//|                                                     insertDB.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//外部関数のインポート
//-----------------------------------------------
//mport "insertDB.ex4"
//		string arrayCommaInt(int &commaArray[]);
//mport
//-----------------------------------------------
bool EAenable = true;

string readFileName = "tradeOrder.dat";
string writeFileName = "tradeResult.dat";

//注文情報
//-------------------------------
double profitPoint = 20;
double lossPoint = 10;
double lots = 1.0;
int slippage = 1;
string comment = NULL;
int magicNo = 0;
datetime expiration = 0;
color arrowColor = CLR_NONE;
//-------------------------------

//処理の重複を防ぐ変数
bool procStartFlg = true;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
		//---
		Print("OnInit() start");
		//20秒おきに起動
		EventSetTimer(20);
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

double culculateProfitPrice(string currency, double nowPrice){
		int minPoint = MarketInfo(currency, MODE_POINT);
		return(nowPrice + minPoint * profitPoint);
}

double culculateLossPrice(string currency, double nowPrice){
		int minPoint = MarketInfo(currency, MODE_POINT);
		return(nowPrice - minPoint * lossPoint);
}

int tradeStart(string currency, string tradeFlg){
		//約定したチケットナンバーを返す
		int ticketNumber = -1;
		//現在の価格
		double nowPrice = 0;
		if(tradeFlg == 0){
				//0:buy
				nowPrice = MarketInfo(currency, MODE_ASK);
				ticketNumber = OrderSend(currency, OP_BUY, lots, nowPrice, slippage, culculateLossPrice(currency, nowPrice), culculateProfitPrice(currency, nowPrice), comment, magicNo, expiration, arrowColor);
				return(true);
		}
		else if(tradeFlg == 1){
				//1:wait
				return(true);
		}
		else if(tradeFlg == 2){
				//2:sell
				nowPrice = MarketInfo(currency, MODE_BID);
				ticketNumber = OrderSend(currency, OP_SELL, lots, nowPrice, slippage, culculateLossPrice(currency, nowPrice), culculateProfitPrice(currency, nowPrice), comment, magicNo, expiration, arrowColor);
				return(true);
		}
		else{
				//error
				Print("tradeFlg error : " + tradeFlg);
		}
		return(ticketNumber);
}

bool timeChk(string yyyyMMdd, string hhmm){

		string yyyy = StringSubstr(yyyyMMdd, 0, 4);
		string MM = StringSubstr(yyyyMMdd, 4, 2);
		string dd = StringSubstr(yyyyMMdd, 4, 2);
		string hh = StringSubstr(hhmm, 0, 2);
		string mm = StringSubstr(hhmm, 2, 2);
		//orderTimeを時間型に変換
		datetime orderTime = StrToTime(yyyy + "." + MM + "." + dd + " " + hh + ":" + mm);

		//PC時刻取得
		datetime pcTime = TimeLocal();

		//PC時刻とorderTimeの差分チェック：orderから2分以内であればOK
		if(pcTime - orderTime < 120){
				Print("time check is OK!");
				Print("PC time : " + (string)pcTime);
				Print("order time : " + yyyyMMdd + hhmm);
				return(true);
		}
		else{
				Print("time check is ERROR!");
				Print("PC time : " + (string)pcTime);
				Print("order time : " + yyyyMMdd + hhmm);
				return(false);
		}
}
void outputWrite(int &outputArray[]){
		int handle = FileOpen(writeFileName, FILE_WRITE|FILE_CSV, ",");
		if(handle < 0){
				Print("FILE OPEN ERROR");
				Print("Error code:", GetLastError());
				FileClose(handle);
		}

		//カンマで配列を区切る
		//string outputArrayString = arrayCommaInt(outputArray);

		//ファイルに書き込み。
		FileWrite(handle, outputArrayString);
		FileClose(handle);
		Print("FILE WRITE " + writeFileName);
}
int bestAct(int tradeFlg, int profitFlg){
		int retBestAct = -1;
		if(profitFlg == 1){
				retBestAct = profitFlg;
		}
		else if(profitFlg == 2){
				retBestAct = profitFlg % 2;
		}
		else{
				Print("bestAct profitFlg error.");
		}
		return(retBestAct);
}
//整数配列をカンマで区切る
/*
string arrayCommaInt(int &commaArray[]){
		string commaArrayString = commaArray[0];
		int k;
		for(k = 1; k < ArraySize(commaArray); k ++){
				commaArrayString += "," + commaArray[k];
		}
		return(commaArrayString);
}
*/


//+------------------------------------------------------------------+
//| Expert OnTimer function                                          |
//+------------------------------------------------------------------+
//20秒ごとに実効される
void OnTimer(){
		if(procStartFlg == true){
				procStartFlg = false;

				//出力結果を保存する配列
				//     outputArray[0]:POSITION_FLG(1:ポジション取得  2:異常発生によりポジション未取得  3:約定完了)
				//     outputArray[1]:EXEC_TIME
				//     outputArray[2]:EXEC_PRICE
				//     outputArray[3]:SETT_TIME
				//     outputArray[4]:SETT_PRICE
				//     outputArray[5]:PROFIT
				//     outputArray[6]:PROFIT_FLG(0:未約定  1:(+)約定  2:(-)約定)
				//     outputArray[7]:BEST_ACT(0:buy  1:wait  1:sell)
				//     outputArray[8]:SEQ_NO
				int outputArray[9];

				outputArray[0] = -1;
				outputArray[6] = -1;
				outputArray[7] = -1;

				int ticketNumber = -1;
				int tradeFlg = -1;

				//ファイルの読み込み
				int readHandle = -1;
				Print("finding " + readFileName + "...");
				while(readHandle == -1){
						readHandle = FileOpen(readFileName, FILE_READ|FILE_CSV, ",");
				}
				Print(readFileName + " is opened success.");

				//通貨の取得
				string currency = FileReadString(readHandle);
				Print("Target currency is " + currency);

				//時刻チェック
				string yyyyMMdd = FileReadString(readHandle);
				string hhmm = FileReadString(readHandle);
				if(!timeChk(yyyyMMdd, hhmm)){
						Print("Time is late.");
						//異常による更新
						outputArray[0] = 2;
				}
				else{
						//時刻チェック問題なし
						Print("Time check is OK.");

						//トレード開始
						Print("Trade start.");
						tradeFlg = FileReadString(readHandle);
						ticketNumber = tradeStart(currency, tradeFlg);
						if(ticketNumber == -1){
								Print("trade execution is failed.");
								//異常による更新
								outputArray[0] = 2;
						}
						else{
								Print("tradea execution is successed.");
								outputArray[0] = 1;

								OrderSelect(ticketNumber, SELECT_BY_TICKET);
								//EXECUTION TIME
								outputArray[1] = OrderOpenTime();
								//EXECUTION PRICE
								outputArray[2] = OrderOpenPrice();
						}
				}

				//SEQ_NO取得
				outputArray[8] = FileReadString(readHandle);

				//outputArray結果出力
				outputWrite(outputArray);
				Print("execution info is writed.");

				//ファイル削除
				FileDelete(readFileName);
				Print(readFileName + " is deleted.");

				if(ticketNumber == -1){
						Print("Process is finished, because of trade exeution failed");
				}
				else{
						//決済確認
						Print("waiting for settlement...");
						while(true){
								OrderSelect(ticketNumber, SELECT_BY_TICKET);
								if(OrderCloseTime() != -1){
										Print("The execution is settlement!");
										//POSITION FLG 3:決済完了
										outputArray[0] = 3;
										//SETTLEMENT TIME
										outputArray[3] = OrderCloseTime();
										//SETTLEMENT PRICE
										outputArray[4] = OrderClosePrice();
										//PROFIT
										outputArray[5] = OrderProfit();
										if(outputArray[5] > 0){
												outputArray[6] = 1;
										}
										else{
												outputArray[6] = 2;
										}
										outputArray[7] = bestAct(tradeFlg, outputArray[6]);
										break;
								}
						}

						//ファイル存在確認
						//DBに取り込まれてファイルが存在していないことを確認する。
						bool fileIsExistFlg = true;
						while(fileIsExistFlg){
								fileIsExistFlg = FileIsExist(writeFileName);
						}
						Print(writeFileName + "(old) has been deleted.");

						//outputArray結果出力
						outputWrite(outputArray);
						Print("settlement info is writed.");

				}
				procStartFlg = true;
		}
		else{
				Print("procStart is " + procStartFlg + ", so please wait.");
		}
}
//+------------------------------------------------------------------+
