package reinforcement_learning.values;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
public class Constants{

	// privateコンストラクタでインスタンス生成を抑止
	private Constants(){}

	//constants
	final public static String currency = "USDJPY";

	final public static String[] actType = {"sell","keep","buy"};
	//final public static String[] actType = {"sell","buy"};

	final private static BigDecimal alpha = new BigDecimal("0.001");
	final private static BigDecimal beta = new BigDecimal("0.01");
	final private static BigDecimal eta = new BigDecimal("0.01");
//	final private static BigDecimal gamma = new BigDecimal("0.9");
	final private static BigDecimal gamma = new BigDecimal("0.0"); //ポジション獲得で、損切りも取得するため、報酬が遅れて発生しない。よって１つ先のQを知る必要はない。
	final private static BigDecimal rho = new BigDecimal("2.0");
	final private static short hisStep = 10;
	final private static BigDecimal XCmax = new BigDecimal("1000");
	final private static BigDecimal XCmin = new BigDecimal("50");
	final private static double rc = 50.0; //exp関数内での使用のためDouble型。exp計算後にBigDecimalにしている。
	final private static BigDecimal ovrlp = new BigDecimal("0.87");
	final private static BigDecimal TDth = new BigDecimal("2.0");
	final private static BigDecimal profitRwd = new BigDecimal("10");
	final private static BigDecimal waitRwd = new BigDecimal("-2");
	final private static BigDecimal lossRwd = new BigDecimal("-10");
	final private static int ocoLimitStep = 24;//例えば、24の場合は、5分足で数えて2時間分
	final private static BigDecimal profitPrc = new BigDecimal("100");//レートは1000倍して整数化するので、10pipsで利益確定
	final private static BigDecimal lossPrc = new BigDecimal("100");;//レートは1000倍して整数化するので、10pipsで損切り

	final private static int maxUnits = 100;
	final private static int threadSize = 10;

	final public static BigDecimal zero = new BigDecimal("0");
	final public static BigDecimal e = new BigDecimal("2.7182818284590");
	final public static int seido = 10;
	//etc
	final public static String[] stateCombination = {"DIFF_OPN","DIFF_HGHT","DIFF_LW","DIFF_CLS","EMAshrt","EMAlng","SIGMA_UP","SIGMA_DOWN","RSI"};
	//final public static String[] stateCombination = {"DIFF_OPN","DIFF_HGHT","DIFF_LW","DIFF_CLS","DIFF_EMA","EMAsgnl","SIGMA2"};
	//final public static String[] stateCombination = {"OPN_RATE","HGHT_PRC","LW_PRC","CLS_RATE"};
	//final public static String[] stateCombination = {"OPN_RATE","HGHT_PRC","LW_PRC"};
	//final public static String[] stateCombination = {"STEP"};
	
	public static ArrayList<String> rawTableList = 
		new ArrayList<String>(Arrays.asList(
				//	getCurrency() + "_RATE_RAW_5MIN" 
				//	getCurrency() + "_RATE_RAW_10MIN", 
				//	getCurrency() + "_RATE_RAW_60MIN"
					));
	public static ArrayList<String> mt4TableList = 
		new ArrayList<String>(Arrays.asList(
					getCurrency() + "_MT4_5MIN" 
				//	getCurrency() + "_MT4_10MIN", 
				//	getCurrency() + "_MT4_60MIN"
					));
	public static ArrayList<String> workTableList = 
		new ArrayList<String>(Arrays.asList(
					getCurrency() + "_MT4_W_5MIN" 
				//	getCurrency() + "_MT4_W_10MIN", 
				//	getCurrency() + "_MT4_W_60MIN"
				//	getCurrency() + "_RATE_W_RAW_5MIN" 
				//	getCurrency() + "_RATE_W_RAW_10MIN", 
				//	getCurrency() + "_RATE_W_RAW_60MIN"
					));

	//トレード情報を連携するインターフェーステーブル
	public static String syncTradeTable = "SYNC_TRADE";

	final private static int states = (int)(stateCombination.length * getHisStep() * mt4TableList.size());
	
	//学習パラメータ
	public static BigDecimal[] q = new BigDecimal[actType.length];
	public static BigDecimal[][] w = new BigDecimal[actType.length][getMaxUnits()];
	public static BigDecimal[][][] mu = new BigDecimal[actType.length][getMaxUnits()][getStates()];
	public static BigDecimal[][][] muTmp = new BigDecimal[actType.length][getMaxUnits()][getStates()];
	public static BigDecimal[][] sigma = new BigDecimal[actType.length][getMaxUnits()];

	//getter method
	public static String getCurrency(){
		return(currency);
	}

	public static BigDecimal getAlpha(){
		return(alpha);
	}

	public static BigDecimal getBeta(){
		return(beta);
	}

	public static BigDecimal getEta(){
		return(eta);
	}

	public static BigDecimal getGamma(){
		return(gamma);
	}

	public static BigDecimal getRho(){
		return(rho);
	}

	public static short getHisStep(){
		return(hisStep);
	}

	public static BigDecimal getXCmax(){
		return(XCmax);
	}

	public static BigDecimal getXCmin(){
		return(XCmin);
	}

	public static Double getRc(){
		return(rc);
	}

	public static BigDecimal getOvrlp(){
		return(ovrlp);
	}

	public static BigDecimal getTDth(){
		return(TDth);
	}

	public static BigDecimal getProfitRwd(){
		return(profitRwd);
	}

	public static BigDecimal getWaitRwd(){
		return(waitRwd);
	}

	public static BigDecimal getLossRwd(){
		return(lossRwd);
	}

	public static int getOcoLimitStep(){
		return(ocoLimitStep);
	}

	public static BigDecimal getProfitPrc(){
		return(profitPrc);
	}

	public static BigDecimal getLossPrc(){
		return(lossPrc);
	}

	public static int getStates(){
		return (states);
	}

	public static int getMaxUnits(){
		return(maxUnits);
	}

	public static int getThreadSize(){
		return(threadSize);
	}

	public static String getActTypeString(){
		String actTypeString = actType[0];
		for (int i = 1; i < actType.length; i++){
			actTypeString += "," + actType[i];
		}
		return(actTypeString);
	}

	public static String getRawTableListString(){
		String tableString = rawTableList.get(0);
		for (int i = 1; i < rawTableList.size(); i++){
			tableString += "," + rawTableList.get(i);
		}
		return(tableString);
	}

	public static String getMt4TableListString(){
		String tableString = mt4TableList.get(0);
		for (int i = 1; i < mt4TableList.size(); i++){
			tableString += "," + mt4TableList.get(i);
		}
		return(tableString);
	}

	public static String getStateCombinationString(){
		String stateString = stateCombination[0];
		for (int i = 1; i < stateCombination.length; i++){
			stateString += "," + stateCombination[i];
		}
		return(stateString);
	}

	public static int getBaseTimeRawTable(){
		String baseTime = rawTableList.get(0).replace(getCurrency() + "_RATE_RAW_", "");
		baseTime = baseTime.replace("MIN", "");
		return(Integer.parseInt(baseTime));
	}

	public static int getBaseTimeMt4Table(String mt4Table){
		String baseTime = mt4Table.replace(getCurrency() + "_MT4_", "");
		baseTime = baseTime.replace("MIN", "");
		return(Integer.parseInt(baseTime));
	}

	public static int getBaseTimeMt4WorkTable(String mt4Table){
		String baseTime = mt4Table.replace(getCurrency() + "_MT4_W_", "");
		baseTime = baseTime.replace("MIN", "");
		return(Integer.parseInt(baseTime));
	}
}
