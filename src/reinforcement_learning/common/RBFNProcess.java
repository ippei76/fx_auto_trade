package reinforcement_learning.common;

import reinforcement_learning.business.RLdao;
import java.util.ArrayList;
import java.math.BigDecimal;
import java.math.MathContext;
import static reinforcement_learning.values.Constants.*;
import static reinforcement_learning.values.Variables.*;

public class RBFNProcess{
	
	RLdao RLdao = new RLdao();

	public static BigDecimal normXC(byte act, int unit, ArrayList<BigDecimal> stateList){
		//取得した状態とユニットとの距離を取得: ||input(x) - mu||^2

		BigDecimal sum = new BigDecimal("0");
		
		//状態数と取得した状態数を比較
		if(getStates() != stateList.size()){
			System.out.println("state size error");
			System.out.println("getStates() : " + getStates());
			System.out.println("stateList.size() : " + stateList.size());
			System.exit(2);
		}

		for(int i = 0; i < getStates(); i++){
//			System.out.println(i+"\t"+stateList.get(i)+"\t"+mu[act][unit][i]);
			BigDecimal v1 = stateList.get(i).subtract(mu[act][unit][i]);
			sum = sum.add(v1.multiply(v1));
			//System.out.print(" step : " + getStep() + "  i : " + i + "\t" + stateList.get(i));
		}
		return (sum);
	}

	public static BigDecimal getRBFN(byte act, int unit, ArrayList<BigDecimal> stateList){
		//RBFの値を取得:φ_k(s):exp[(・・・)]

		BigDecimal TgtNormXC = normXC(act, unit, stateList);
//		System.out.println("距離は:"+TgtNormXC);
		BigDecimal sig2 = sigma[act][unit].multiply(sigma[act][unit]);
		BigDecimal expo = BigDecimal.valueOf(-1).multiply(TgtNormXC).divide(sig2, 9, BigDecimal.ROUND_HALF_UP);
		//System.out.println("expo: "+expo);
		return (BigDecimal.valueOf(Math.exp(expo.doubleValue())));
	}

	// MultiThreadRenwlMuクラスで使用
	public static BigDecimal steepestDescentMu(byte act, int unit, int state, BigDecimal TDerr, ArrayList<BigDecimal> stateList){

		BigDecimal TgtNormXCi = stateList.get(state).subtract(mu[act][unit][state]);
		BigDecimal TgtExp = getRBFN(act, unit, stateList);
		BigDecimal sig2 = sigma[act][unit].multiply(sigma[act][unit]);
		BigDecimal v1 = BigDecimal.valueOf(2).multiply(TgtNormXCi).divide(sig2,9, BigDecimal.ROUND_HALF_UP);
		BigDecimal diffMu = TDerr.multiply(getAlpha()).multiply(TgtExp).multiply(w[act][unit]).multiply(v1);
//		System.out.println("M:  "+TgtExp);
		//System.out.println("MU:" + diffMu + "normxc:" + TgtNormXCi +"tgtexp:" + TgtExp + "sig2:" + sig2 + "v1:" + v1);
		//System.out.println("normxci:" + TgtNormXCi + "\tv1:" + v1 + "\t" + BigDecimal.valueOf(2) + "\tsig2: " + sig2);
		return (diffMu);
	}

	public static BigDecimal steepestDescentSigma(byte act, int unit, BigDecimal TDerr, ArrayList<BigDecimal> stateList){

		BigDecimal TgtNormXC = normXC(act, unit, stateList);
		BigDecimal TgtExp = getRBFN(act, unit, stateList);
		BigDecimal sig3 = sigma[act][unit].multiply(sigma[act][unit]).multiply(sigma[act][unit]);
		BigDecimal v1 = BigDecimal.valueOf(2).multiply(TgtNormXC).divide(sig3, 9, BigDecimal.ROUND_HALF_UP);
		//BigDecimal v1 = BigDecimal.valueOf(2).multiply(TgtNormXC).multiply(TgtNormXC).divide(sig3, 9, BigDecimal.ROUND_HALF_UP);
		BigDecimal diffSigma = TDerr.multiply(getBeta()).multiply(TgtExp).multiply(w[act][unit]).multiply(v1);

		//System.out.println(TgtNormXC + "\t" +  TgtExp + "\t" + sig3 + "\t" + v1 + "\t" + w[act][unit]);
		return (diffSigma);
	}

	public static BigDecimal steepestDescentW(byte act, int unit, BigDecimal TDerr, ArrayList<BigDecimal> stateList){

		BigDecimal TgtExp = getRBFN(act, unit, stateList);
		BigDecimal diffW = TDerr.multiply(getEta()).multiply(TgtExp);

//		System.out.println("W:  "+TgtExp);
//		System.out.println("W:" + diffW);
		return (diffW);
	}
}
