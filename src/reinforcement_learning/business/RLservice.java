package reinforcement_learning.business;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.*;
import java.util.Random;
import java.math.BigDecimal;
import java.math.MathContext;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.ParseException;
import static reinforcement_learning.values.Constants.*;
import static reinforcement_learning.values.Variables.*;
import static reinforcement_learning.common.RBFNProcess.*;
import reinforcement_learning.common.WorkTableImpChkService;

class RLservice{

	public static int plsCount = 0;
	public static int mnsCount = 0;
	public static int eqlCount = 0;
	final private String startDateTime;
	final private String endDateTime;

	private BigDecimal sumReword;
	private int[] actTimes = new int[actType.length];

	private Random random = new Random();
	protected RLdao RLdao = new RLdao();
	protected WorkTableImpChkService workTableImpChkService = new WorkTableImpChkService();
	private PropertiesReader propReader = new PropertiesReader();
	protected SimpleDateFormat sdf_yyyyMMddHHmmss = new SimpleDateFormat("yyyyMMddHHmmss");

	//コンストラクタ
	public RLservice(){
		//子クラスから呼び出される。
		//子クラスのRLonlineServiceは以下2つの変数を使用しないので、適当な値を設定
		this.startDateTime = "99999999";
		this.endDateTime = "99999999";
	}

	//コンストラクタ
	public RLservice(String startDateTime, String endDateTime){
		this.startDateTime = startDateTime;
		this.endDateTime = endDateTime;
	}

	public void resetSumReword(){
		this.sumReword = new BigDecimal("0");
	}

	public BigDecimal getSumReword(){
		return (this.sumReword);
	}

	public void addSumReword(BigDecimal sumReword){
		this.sumReword = this.sumReword.add(sumReword);
	}

	public int getActTimes(byte act){
		return(this.actTimes[act]);
	}

	public void resetActTimes(byte act){
		this.actTimes[act] = 0;
	}

	public void addActTimes(byte act){
		this.actTimes[act]++;
	}

	private BigDecimal averageMu(){
		BigDecimal average = new BigDecimal("0");
		int count = 0;
		for(byte act = 0; act < actType.length ; act++){
			for(int k = 0; k < getUnits(act); k++){
				for(int i = 0; i < getStates(); i++){
					average = average.add(mu[act][k][i]);
					count ++;
				}
			}
		}
		return(average.divide(BigDecimal.valueOf(count), 3, BigDecimal.ROUND_HALF_UP));
	}

	private BigDecimal averageSigma(){
		BigDecimal average = new BigDecimal("0");
		int count = 0;
		for(byte act = 0; act < actType.length ; act++){
			for(int k = 0; k < getUnits(act); k++){
				average = average.add(sigma[act][k]);
				count ++;
			}
		}
		return(average.divide(BigDecimal.valueOf(count), 3, BigDecimal.ROUND_HALF_UP));
	}

	private BigDecimal averageW(){
		BigDecimal average = new BigDecimal("0");
		int count = 0;
		for(byte act = 0; act < actType.length ; act++){
			for(int k = 0; k < getUnits(act); k++){
				average = average.add(w[act][k]);
				count ++;
			}
		}
		return(average.divide(BigDecimal.valueOf(count), 3, BigDecimal.ROUND_HALF_UP));
	}

	protected BigDecimal sumRBF(byte act, ArrayList<BigDecimal> stateList){

		BigDecimal sum = new BigDecimal("0");
		for(int k = 0; k < getUnits(act); k++){
			sum = sum.add(w[act][k].multiply(getRBFN(act, k, stateList)));
		}
		return (sum);
	}

	//現ステップと次ステップ共に使用可能
	private void prcvStateActValue(){

		//現ステップの状態
		ArrayList<BigDecimal> stateList = new ArrayList<BigDecimal>();
		stateList.clear();
		stateList = RLdao.selectStateStep(getStep(),getHisStep());

		for(byte act = 0; act < (byte)actType.length; act++){
			q[act] = sumRBF(act, stateList);
			//System.out.println("q["+act+"]="+q[act]);
		}
	}

	private byte exploration(){

		return ((byte)(random.nextInt(actType.length)));
	}

	private byte argMaxQ(){

		byte max[];
		max = new byte[(byte)actType.length];

		for(byte act = 0; act < (byte)actType.length; act++){
			max[act] = 0;
		}
			
		byte count = 0;
		max[0] = 0;
		for(byte act = 1; act < (byte)actType.length; act++){
			if(q[max[0]].compareTo(q[act]) < 0){//test
				max[0] = act;
				count = 0;
			}
			else if(q[max[0]].compareTo(q[act]) == 0){
				max[count + 1] = act;
				count ++;
			}
		}

		return (max[random.nextInt(count + 1)]);
	}

	private byte epsilonGreedy(){
		//return(2);
		if(Math.random() < getEpsilon()){
			//System.out.println("ランダム選択によって");
			return (exploration());
		}
		else{
			//System.out.println("グリーディー選択によって");
			return (argMaxQ());
		}
	}

	public void selectAct(){

		setNowAct(epsilonGreedy());
		//System.out.println(getNowAct() + "を選択しました。");
		//TDerror更新時に使用
		setNowQ(q[getNowAct()]);
		//RLdao.updateAct(getStep(),getNowAct());
		addActTimes(getNowAct());
	}

	public void selectNextAct(){

		setNextAct(epsilonGreedy());
		//System.out.println(getNowAct() + "を選択しました。");
		//TDerror更新時に使用
		setNextQ(q[getNextAct()]);
		//RLdao.updateAct(getStep(),getNextAct());
		addActTimes(getNextAct());
	}

	protected void renwlXCth(byte act){

		BigDecimal exp = BigDecimal.valueOf(Math.exp((-1.0)/getRc())).setScale(seido, BigDecimal.ROUND_HALF_UP);
		BigDecimal newXCth = getXCth(act).multiply(exp);
		setXCth(newXCth, act);
	}

	private void multiThreadRenwlMu(BigDecimal TDerr, byte act, int k, ArrayList<BigDecimal> stateList){

		ExecutorService exec = Executors.newFixedThreadPool(getThreadSize());
		try{
			for(int i = 0; i < getStates(); i++){
				exec.submit(new MultiThreadRenwlMu(TDerr, act, k, i, stateList));
		//		BigDecimal m_diff = steepestDescentMu(act, k, i, TDerr, stateList);
		//		muTmp[act][k][i] = mu[act][k][i].add(m_diff);
				/*
				if(m_diff.compareTo(zero) > 0){
					System.out.println("m_diffは+です");
				}
				else if(m_diff.compareTo(zero) == 0){
					System.out.println("m_diffは0です");
				}
				else {
					System.out.println("m_dirrは-です");
				}
				*/
			}
			exec.shutdown();
			try {
				exec.awaitTermination(1, TimeUnit.MINUTES);
			} catch (InterruptedException e) {
				System.out.println("MultiThread execute error");
				e.printStackTrace();
				System.exit(2);
			}
			for(int i = 0; i < getStates(); i++){
				mu[act][k][i] = muTmp[act][k][i];
			}
		}catch(Exception e){
			System.out.println("MultiThread execute error");
			e.printStackTrace();
			System.exit(2);
		}
	}

	protected void renwlWSC(BigDecimal TDerr, byte act, ArrayList<BigDecimal> stateList){

		for(int k = 0; k < getUnits(act); k++){
			BigDecimal w_diff = steepestDescentW(act, k, TDerr, stateList);
			BigDecimal s_diff = steepestDescentSigma(act, k, TDerr, stateList); 
			//System.out.println(w_diff.setScale(5,BigDecimal.ROUND_HALF_UP)+"\t"+s_diff.setScale(5,BigDecimal.ROUND_HALF_UP));

			multiThreadRenwlMu(TDerr, act, k, stateList);

			w[act][k] = w[act][k].add(w_diff);
			sigma[act][k] = sigma[act][k].add(s_diff); 
		}
	}

	protected BigDecimal rewordBuy(){

		BigDecimal rwd = RLdao.selectNowStockValue(getStep()).subtract(RLdao.selectMinStockValue());
		return(rwd);
	}

	protected BigDecimal rewordWait(){

		BigDecimal rwd = new BigDecimal("0");
		return(rwd);
	}

	protected BigDecimal rewordSell(){

		BigDecimal rwd = RLdao.selectMaxStockValue().subtract(RLdao.selectNowStockValue(getStep()));
		return(rwd);
	}

	protected BigDecimal reword(){

//		System.out.println(getNowAct() + "\t" + getUnits(getNowAct()));
		//buy
		if(getNowAct() == 0){
			return(rewordBuy());
		}
		//keep
		else if(getNowAct() == 1){
			return(rewordWait());
		}
		//sell
		else if(getNowAct() == 2){
			return(rewordSell());
		}
		else{
			System.out.println("getNowAct : " + getNowAct() + "\nerror occur.");
			System.exit(2);
			return(null);
		}
	}

	protected BigDecimal culculateTDerr(){
		BigDecimal rwd = reword();
		addSumReword(rwd);
		BigDecimal tder = rwd.add(getGamma().multiply(getNextQ())).subtract(getNowQ());
		return(tder);
	}

	public void renwlPara(){

		BigDecimal TDerr = new BigDecimal("0");
		TDerr = culculateTDerr();
		//System.out.println("TD: " + TDerr.setScale(seido, BigDecimal.ROUND_HALF_UP));
		/*
		if(TDerr.compareTo(zero) > 0){
			System.out.println("TDは+です");
		}
		else {
			System.out.println("TDは-です");
		}
		*/
		//System.out.println("TD("+getNowAct()+")"+TDerr.setScale(10, BigDecimal.ROUND_HALF_UP));
	//	System.out.println("tder :" + TDerr + "    nowQ:"+ getNowQ());

		ArrayList<BigDecimal> stateList = new ArrayList<BigDecimal>();

		//1つ前のステップの状態取得
		stateList.clear();
		stateList = RLdao.selectStateStep((getStep() - 1),getHisStep());

		if(getUnits(getNowAct()) == 0){ //1つ前の行動のユニット数が0である。
			//1つ前の状態の値でRBFを作成
			//System.out.println("初期ステップのユニットを生成します。:"+getNowAct());
			addRBF(getNowAct(), TDerr, stateList);
		}

		renwlWSC(TDerr,getNowAct(), stateList); //w,s,cは同時に更新する必要があるため、1つの関数内で更新する。

		//System.out.print(getNowAct() + "\t" + TDerr.abs() + "\t" + getTDth() + "\t" + getMinNormXC(getNowAct(), stateList) + "\t" + getXCth(getNowAct()) + "\t");
		if((TDerr.abs()).compareTo(getTDth()) > 0 &&
			       	getMinNormXC(getNowAct(), stateList).compareTo(getXCth(getNowAct())) > 0 &&
					getUnits(getNowAct()) < getMaxUnits()){
			addRBF(getNowAct(), TDerr, stateList);
		}
//		System.out.println();

		if(getXCth(getNowAct()).compareTo(getXCmin()) > 0){
			//System.out.println("XCを減少させます。:"+getNowAct());
			renwlXCth(getNowAct());
		}
	}

	protected BigDecimal getMinNormXC(byte act, ArrayList<BigDecimal> stateList){
		//取得状態とユニットで、最も小さい値となるユークリッド距離を取得

		BigDecimal min = normXC(act, 0, stateList);
		for(int k = 1; k < getUnits(act); k++){
			BigDecimal TgtMin = normXC(act, k, stateList);
			if(min.compareTo(TgtMin) >= 0){
				min = TgtMin;
			}
		}
		return(min);
	}

	private void addRBFInitialSigma(byte act){
		int k = getUnits(act);
		sigma[act][k] = getOvrlp().multiply(getXCmax());
	}

	private void addRBFSigma(byte act, ArrayList<BigDecimal> stateList){
		int k = getUnits(act);
		sigma[act][k] = getOvrlp().multiply(getMinNormXC(act, stateList));
	}

	protected void addRBF(byte act, BigDecimal TDerr, ArrayList<BigDecimal> stateList){

		int k = getUnits(act);
		//System.out.println(getStates());
		//System.out.println(stateList.size());
		//System.out.println(stateCombination.length);
		//System.out.println(getHisStep());
		//System.out.println(rawTableList.size());
		w[act][k] = TDerr.multiply(getEta());
		//sigmaはmuより先に作らなければ、sigma=0となってしまう。
		if(k == 0){
			addRBFInitialSigma(getNowAct());
		}
		else{
			addRBFSigma(getNowAct(), stateList);
		}
		for(int i = 0; i < getStates(); i++){
			//System.out.println("state(" + i + ") : " + stateList.get(i));
			mu[act][k][i] = stateList.get(i);
		}

		addUnits(act);
	}

	public void shiftActQ(){

		setNowAct(getNextAct());
		setNowQ(getNextQ());
	}

	public void initiallizeLearningParameters(){

		for(byte act = 0; act < actType.length ; act++){
			setXCth(getXCmax(), act);
			q[act] = new BigDecimal("0");
			for(int k = 0; k < getUnits(act); k++){
				w[act][k] = new BigDecimal("0");
				sigma[act][k] = new BigDecimal("0");
				for(int i = 0; i < getStates(); i++){
					mu[act][k][i] = new BigDecimal("0");
					muTmp[act][k][i] = new BigDecimal("0");
				}
			}
		}

	}

	public void initiallize(String startDateTime, String endDateTime){

		workTableImpChkService.importCheckProcess(startDateTime, endDateTime);
	
		setEndStep(RLdao.selectEndStep());
		initiallizeLearningParameters();
	}

	public void outputPerStep(long ep, int step){
		System.out.print(ep + "\t" + step + "\t");
		for(byte act = 0; act < actType.length ; act++){
			System.out.print(getUnits(act) + "\t");
		}
		System.out.println(getNowAct() + "\t" + averageMu() + "\t" + averageSigma() + "\t" + averageW());
	}

	public void daoCloseConnection(){

		RLdao.closeConnection();
	}
	private String getStartDateTime(){
		return (this.startDateTime);
	}

	private String getEndDateTime(){
		return (this.endDateTime);
	}

	private void outputResult(long epsd){

		System.out.print(epsd + "\t" + getSumReword() + "\t");
		System.out.print(plsCount + "\t" + mnsCount + "\t" + eqlCount + "\t");
		for(byte act = 0; act < actType.length ; act++){
			System.out.print(getActTimes(act) + "\t");
		}
		for(byte act = 0; act < actType.length ; act++){
			System.out.print(getUnits(act) + "\t");
		}
//		System.out.print(mu[2][2][2]+"\t"+sigma[2][2]+"\t"+w[2][2]);
//		System.out.print(w[2][0].setScale(seido, BigDecimal.ROUND_HALF_UP));
		System.out.println();
	}

	private void outputPara(){
		for(byte act = 0; act < actType.length ; act++){
			System.out.println("q[" + act + "] : " + q[act] );
			for(int k = 0; k < getUnits(act); k++){
				System.out.println("w[" + act + "][" +  k + "] : " + w[act][k] );
				System.out.println("sigma[" + act + "][" + k + "] : " + sigma[act][k] );
				for(int i = 0; i < getStates(); i++){
					System.out.println("mu[" + act + "][" + k + "][" + i + "] : " + mu[act][k][i] );
				}
			}
		}
	}

	private void roundPara(){
		for(byte act = 0; act < actType.length ; act++){
			for(int k = 0; k < getUnits(act); k++){
				w[act][k] = w[act][k].setScale(seido, BigDecimal.ROUND_HALF_UP);
				sigma[act][k] = sigma[act][k].setScale(seido, BigDecimal.ROUND_HALF_UP);
				for(int i = 0; i < getStates(); i++){
					mu[act][k][i] = mu[act][k][i].setScale(seido, BigDecimal.ROUND_HALF_UP);
				}
			}
		}
	}

	protected void resetPara(){
		resetSumReword();
		for(byte act = 0; act < actType.length ; act++){
			resetActTimes(act);
		}
		plsCount = 0;
		mnsCount = 0;
		eqlCount = 0;
	}

	public void executeBefore(){

		initiallize(getStartDateTime(), getEndDateTime());
		//System.out.println("Episode\tSumRwd\tplsCount\tmnsCount\teqlCount\tActT(0)\tActT(1)\tActT(2)\tUnits(0~2)");

	}

	public void execute(long epsd){

		resetPara();
		//System.out.println("Episode\tStep\tUnits(0~2)\tNowAct\tMu\tSigma\tW");
		//Learning start
		int st = 0;
		setStep(st);
		//System.out.println("step " + getStep());
		prcvStateActValue();
		selectAct();
		for(st = 1; st <= getEndStep(); st++){
			setStep(st);
			//System.out.println("step " + getStep());
			prcvStateActValue();
			selectNextAct();
			renwlPara();
			roundPara();
	//		outputPerStep(epsd, st);
	//		System.out.println("step:" + getStep());
			//outputPara();
			shiftActQ();
//
		}
		outputResult(epsd);
//		daoCloseConnection();
		//Learning enepsdd
	}

	public void executeAfter(long episodes, String startDate, String endDate){
		//現時刻取得
		Date currentDateTime = new Date();
		String currentDateTimeStr = sdf_yyyyMMddHHmmss.format(currentDateTime);

		//学習したパラメータ（mu,sigma,w,xc,units）をテーブルに保存する。
		RLdao.insertRLparas(getCurrency(), plsCount, eqlCount, mnsCount, episodes, startDate, endDate, currentDateTimeStr, getHisStep());
		RLdao.insertUnits(currentDateTimeStr);
		RLdao.insertMu(currentDateTimeStr);
		RLdao.insertSigma(currentDateTimeStr);
		RLdao.insertW(currentDateTimeStr);
		RLdao.insertXCth(currentDateTimeStr);
	}
}

class PerDeal extends RLservice{
	public PerDeal(String startDateTime, String endDateTime){
		super(startDateTime, endDateTime);
	}

	@Override
	protected BigDecimal culculateTDerr(){
		BigDecimal rwd = reword();
		//System.out.println("報酬は" + rwd);
		addSumReword(rwd);
		BigDecimal tder = rwd.subtract(getNowQ());
		//System.out.println("TDERRは" + rwd +"\t-\t" + getNowQ());
		return(tder);
	}

	@Override
	protected BigDecimal rewordBuy(){
		BigDecimal rwd = new BigDecimal("0");
		//現ステップより、利益確定となる上値に届くステップ数
		int ocoTopStep = RLdao.selectTopOcoCheck(getStep(), getProfitPrc());
		//現ステップより、損切りとなる下値に届くステップ数
		int ocoBottomStep = RLdao.selectBottomOcoCheck(getStep(), getLossPrc());

		if (ocoTopStep == ocoBottomStep){
			//レンジで長引く、または変動が大きい。
			//ポジションを取るべきではなかったとする。
			rwd = getLossRwd();
			eqlCount++;
			System.out.println("BUY getStep:" + getStep());
			System.out.println("ocoTopStep:" + ocoTopStep);
			System.out.println("ocoBottomStep:" + ocoBottomStep);
		}
		else if(ocoTopStep < ocoBottomStep){
			//指値（利益確定）が先に発生
			rwd = getProfitRwd();
			plsCount++;
		}
		else if(ocoTopStep > ocoBottomStep){
			//逆指値（損切り）が先に発生
			rwd = getLossRwd();
			mnsCount++;
		}
//		System.out.println("buy");
		return(rwd);
	}

	@Override
	protected BigDecimal rewordWait(){
		BigDecimal rwd = new BigDecimal("0");
		rwd = getWaitRwd();
		return(rwd);
	}
	/*
	protected BigDecimal rewordWait(){
		//Waitの場合は、期間内に決済が完了しない場合に+の報酬を、
		//期間内に決済が完了する場合は-の報酬を与える。
		BigDecimal rwd = new BigDecimal("0");
		//現ステップより、利益確定/損切となる上値に届くステップ数
		int ocoTopStep = RLdao.selectTopOcoCheck(getStep(), getLossPrc());
		//現ステップより、利益確定/損切となる下値に届くステップ数
		int ocoBottomStep = RLdao.selectBottomOcoCheck(getStep(), getProfitPrc());

		//System.out.println("step : " + getStep() + ", top : " + ocoTopStep + ", bottom : " + ocoBottomStep);
		if (ocoTopStep == ocoBottomStep){
			//レンジで長引く、または変動が大きい。
			//ポジションを取るべきではなかったとする。何もしなくて利得を得たとする。
			rwd = getProfitRwd();
			plsCount++;
			System.out.println("aaaa");
		}
		else{
			rwd = getWaitRwd();
		}
//		System.out.println("wait");
		return(rwd);
	}
	*/

	@Override
	protected BigDecimal rewordSell(){
		BigDecimal rwd = new BigDecimal("0");
		//現ステップより、損切りとなる上値に届くステップ数
		int ocoTopStep = RLdao.selectTopOcoCheck(getStep(), getLossPrc());
		//現ステップより、利益確定となる下値に届くステップ数
		int ocoBottomStep = RLdao.selectBottomOcoCheck(getStep(), getProfitPrc());

		if (ocoTopStep == ocoBottomStep){
			//レンジで長引く、または変動が大きい。
			//ポジションを取るべきではなかったとする。
			rwd = getLossRwd();
			eqlCount++;
			System.out.println("SELL getStep:" + getStep());
			System.out.println("ocoTopStep:" + ocoTopStep);
			System.out.println("ocoBottomStep:" + ocoBottomStep);
		}
		else if(ocoTopStep < ocoBottomStep){
			//逆指値（損切り）が先に発生
			rwd = getLossRwd();
			mnsCount++;
		}
		else if(ocoTopStep > ocoBottomStep){
			//指値（利益確定）が先に発生
			rwd = getProfitRwd();
			plsCount++;
		}
//		System.out.println("sell");
		return(rwd);
	}
}
