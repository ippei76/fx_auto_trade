package reinforcement_learning.business;

import java.util.ArrayList;
import java.math.BigDecimal;
import static reinforcement_learning.values.Constants.*;
import static reinforcement_learning.values.Variables.*;
import static reinforcement_learning.common.RBFNProcess.*;

public class MultiThreadRenwlMu implements Runnable{

	final private BigDecimal TDerr;
	final private byte act;
	final private int unit;
	final private int state;

	ArrayList<BigDecimal> stateListMu;

	public MultiThreadRenwlMu(BigDecimal TDerr, byte act, int k, int i, ArrayList<BigDecimal> stateList){
		this.TDerr = new BigDecimal(TDerr.toString());
		this.act = act;
		this.unit = k;
		this.state = i;
		this.stateListMu = new ArrayList<BigDecimal>(stateList);
	}

	private BigDecimal getTDerrMu(){
		return(this.TDerr);
	}

	private byte getActMu(){
		return(this.act);
	}

	private int getUnitMu(){
		return(this.unit);
	}

	private int getStateMu(){
		return(this.state);
	}

	@Override
	public void run(){

//		System.out.println("thread: " + Thread.currentThread().getId());
//		System.out.println(getActMu() + "\t" + getUnitMu() + "aaaa\t" + getStateMu() + "\t" + getTDerrMu());
		muTmp[getActMu()][getUnitMu()][getStateMu()] = mu[getActMu()][getUnitMu()][getStateMu()].add(steepestDescentMu(getActMu(), getUnitMu(), getStateMu(), getTDerrMu(), stateListMu));
	}
}
