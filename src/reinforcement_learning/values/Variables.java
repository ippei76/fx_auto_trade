package reinforcement_learning.values;

import java.math.BigDecimal;
import static reinforcement_learning.values.Constants.*;
public class Variables{

	// public staticコンストラクタでインスタンス生成を抑止
	private Variables(){}

	//variables
	private static int step;
	private static int endStep;
	private static byte nowAct;
	private static byte nextAct;
	private static BigDecimal nowQ;
	private static BigDecimal nextQ;
	private static double epsilon = 0.3;
	
	public static int[] units = new int[actType.length];

	public static BigDecimal[] XCth = new BigDecimal[actType.length];

	//getter/setter method
	public static int getStep(){
		return(step);
	}

	public static void setStep(int st){
		step = st;
	}

	public static int getEndStep(){
		return(endStep);
	}

	public static void setEndStep(int st){
		endStep = st;
	}

	public static BigDecimal getXCth(byte act){
		return(XCth[act]);
	}

	public static void setXCth(BigDecimal xc, byte act){
		XCth[act] = xc;
	}

	public static byte getNowAct(){
		return (nowAct);
	}

	public static void setNowAct(byte a){
		nowAct = a;
	}

	public static byte getNextAct(){
		return (nextAct);
	}

	public static void setNextAct(byte a){
		nextAct = a;
	}

	public static BigDecimal getNowQ(){
		return (nowQ);
	}

	public static void setNowQ(BigDecimal q){
		nowQ = q;
	}

	public static BigDecimal getNextQ(){
		return (nextQ);
	}

	public static void setNextQ(BigDecimal q){
		nextQ = q;
	}

	public static int getUnits(byte act){
		return (units[act]);
	}

	public static void setUnits(byte act, int num){
		units[act] = num;
	}

	public static void addUnits(byte act){
		units[act]++;
	}

	public static double getEpsilon(){
		return(epsilon);
	}

	public static void setEpsilonZero(){
		epsilon = 0;
	}
}
