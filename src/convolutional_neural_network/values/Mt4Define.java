package convolutional_neural_network.values;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import static convolutional_neural_network.common.PropertiesReader.*;
public class Mt4Define{

	// privateコンストラクタでインスタンス生成を抑止
	private Mt4Define(){}

	//プロパティファイルの読み込み
	public static int goo = PropertiesOpen(); //プロパティファイルを参照できるようにする。ダミーのreturn値を持つ。voidはコンパイルエラー

	//取引対象通貨
	final private static String currency = properties.getProperty("currency_property");

	final private static int svColumnNums = Integer.parseInt(properties.getProperty("svColumnNums_property"));

	final public static ArrayList<String> itemNameList = 
		new ArrayList<String>(Arrays.asList(
			//		"OPN_RATE",
			//		"HGHT_PRC",
			//		"LW_PRC",
			//		"CLS_RATE",
			//		"DIFF_OPN",
			//		"DIFF_HGHT",
			//		"DIFF_LW",
			//		"DIFF_CLS",
			//		"DIFF_EMA",
			//		"SIGMA_MID",
			//		"SIGMA_UP",
			//		"SIGMA_DOWN",
					"STOCHASTIC",
					"RSI"
					));

	final public static ArrayList<String> currencyNameList = 
		new ArrayList<String>(Arrays.asList(
					"USDJPY",
					"EURJPY",
					"EURUSD",
					"AUDJPY",
					"NZDJPY",
					"CHFJPY",
					"GBPJPY"
					));

	final private static int inputBaseTime = 1;

	final private static String baseTimeString = String.valueOf(inputBaseTime);

	public static int getTargetCurrencyTableIdx(){
		int targetSv_yIdx = -1;
		for(int i = 0; i < mt4InputTableNameList.size(); i++){
			if(mt4InputTableNameList.get(i).indexOf(getCurrency()) != -1){
				targetSv_yIdx = i;
			}
		}
		return(targetSv_yIdx);
	}

	public static ArrayList<String> mt4InputTableNameList = 
		new ArrayList<String>(Arrays.asList(
					currencyNameList.get(0) + "_MT4_" + baseTimeString + "MIN"
					,currencyNameList.get(1) + "_MT4_" + baseTimeString + "MIN"
					,currencyNameList.get(2) + "_MT4_" + baseTimeString + "MIN"
					,currencyNameList.get(3) + "_MT4_" + baseTimeString + "MIN"
					,currencyNameList.get(4) + "_MT4_" + baseTimeString + "MIN"
				//	getCurrency() + "_MT4_" + baseTimeString + "MIN"
					));

	public static String getWorkTableName(String mt4InputTableName){
		return(mt4InputTableName.replace("_MT4_", "_MT4_W_"));
	}
	public static String getInputTableName(String workTableName){
		return(workTableName.replace("_MT4_W_", "_MT4_"));
	}

	//getters
	public static String getCurrency(){
		return(currency);
	}
	public static int getInputBaseTime(){
		return(inputBaseTime);
	}
	public static int getSvColumnNums(){
		return(svColumnNums);
	}

}
