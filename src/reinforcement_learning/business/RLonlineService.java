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

class RLonlineService extends RLservice{

	private long tgtSeqNo;

	private Date date = new Date();
	private SimpleDateFormat sdf_yyyyMMddHHmm = new SimpleDateFormat("yyyyMMddHHmm");
	private RLonlineDao RLonlineDao = new RLonlineDao();
	private SyncTradeInfoDao syncTradeInfoDao = new SyncTradeInfoDao();
	private RLparasDao RLparasDao = new RLparasDao();

	//状態リスト
	ArrayList<BigDecimal> stateMt4List = new ArrayList<BigDecimal>();

	private long getTgtSeqNo(){
		return(this.tgtSeqNo);
	}

	private void setTgtSeqNo(long tgtSeqNo){
		this.tgtSeqNo = tgtSeqNo;
	}

	//construct
	public RLonlineService(long tgtSeqNo){
		this.setTgtSeqNo(tgtSeqNo);
	}

	protected BigDecimal onlineReword(String currency, String tradeDateTime){
		//MT4がトレードした結果であるPROFIT_FLGを取得し、その収益に応じて報酬を与える。
		//waitを選択した場合は、最低限の報酬はもらえる。

		byte profitFlg = syncTradeInfoDao.selectProfitFlg(currency, tradeDateTime);
		if(profitFlg == 1){
			//+決済
			return(getProfitRwd());
		}

		else if(profitFlg == 2){
			//-決済
			return(getLossRwd());
		}
		else if(profitFlg == 3){
			//wait決済
			return(getWaitRwd());
		}
		else if(profitFlg == 0){
			//未決済はリスクが高まるため負の報酬とする。
			return(getLossRwd());
		}
		else{
			System.out.println("profit flag error.");
			System.exit(2);
		}
		return(zero);
	}

	protected BigDecimal culculateOnlineTDerr(String currency, String tradeDateTime){
		BigDecimal rwd = onlineReword(currency, tradeDateTime);
		addSumReword(rwd);
		BigDecimal tder = rwd.subtract(getNowQ());
		return(tder);
	}

	public void renwlOnlinePara(String currency, String tradeDateTime){

		BigDecimal TDerr = new BigDecimal("0");
		TDerr = culculateOnlineTDerr(currency, tradeDateTime);
		System.out.println("TD: " + TDerr.setScale(seido, BigDecimal.ROUND_HALF_UP));

		if(getUnits(getNowAct()) == 0){ //1つ前の行動のユニット数が0である。
			//1つ前の状態の値でRBFを作成
			//System.out.println("初期ステップのユニットを生成します。:"+getNowAct());
			super.addRBF(getNowAct(), TDerr, stateMt4List);
		}

		super.renwlWSC(TDerr,getNowAct(), stateMt4List); //w,s,cは同時に更新する必要があるため、1つの関数内で更新する。

		if((TDerr.abs()).compareTo(getTDth()) > 0 &&
			       	super.getMinNormXC(getNowAct(), stateMt4List).compareTo(getXCth(getNowAct())) > 0 &&
					getUnits(getNowAct()) < getMaxUnits()){
			addRBF(getNowAct(), TDerr, stateMt4List);
		}

		if(getXCth(getNowAct()).compareTo(getXCmin()) > 0){
			//System.out.println("XCを減少させます。:"+getNowAct());
			super.renwlXCth(getNowAct());
		}
	}

	private boolean chkSeqNoList(ArrayList<Long> recentSeqNoList){
		//過去hisStepシーケンスNoを参照した際にマイナス値となるか確認
		for(long recentSeqNo : recentSeqNoList){
			if(recentSeqNo - getHisStep() < 0){
				System.out.println("one table time is NG.");
				System.out.println("recentSeqNo : " + recentSeqNo);
				System.out.println("HisStep     : " + getHisStep());
				return(false);
			}
			else{
				System.out.println("one table time is OK.");
				System.out.println("recentSeqNo : " + recentSeqNo);
				System.out.println("HisStep     : " + getHisStep());
			}
		}
		return(true);
	}

	private long diffDateTime(String recentDateTime){
		//現時刻と引数時刻の差を求め、分で返す
		//現時刻取得し、long型に変換
		Date currentDateTime = new Date(System.currentTimeMillis());
		long currentDateTimeLong = currentDateTime.getTime();

		//引数の文字列時刻を日付型に変換、それをlong型に変換
		long recentDateTimeLong = 0;
		try{
			Date recentDateTimeDate = sdf_yyyyMMddHHmm.parse(recentDateTime);
			recentDateTimeLong = recentDateTimeDate.getTime();
		}catch(ParseException e){
			System.out.println("date time error. : " + recentDateTime);
			System.exit(2);
		}

		//(現時刻 - 引数時刻)を「分」で取得:計算値はミリ秒なので、60,000で割って分に直す。
		long diffDateTimeLong = (currentDateTimeLong - recentDateTimeLong) / 60000;

		return(diffDateTimeLong);
	}
		
	private boolean chkDateTimeList(){
		//MT4テーブルのデータが最新であることを確認
		for(String mt4Table : mt4TableList){
			//現在時刻との差がテーブル単位時刻以内でなければfalseを返す
			//resultTimeLong:yyyymmddhhmiss
			ArrayList<String> recentDateTimeList = new ArrayList<String>();
			recentDateTimeList = RLonlineDao.selectRecentDateTimeList(mt4Table, getHisStep());
			for(String recentDateTime : recentDateTimeList){
				//現時刻とテーブルから取得した時刻の差分を求める。
				long diffDateTimeLong = diffDateTime(recentDateTime);
				//テーブル名から単位時間（分）を求める。
				long tablePerMin = getBaseTimeMt4Table(mt4Table);
				//求めた差分がマイナスだった場合は異常終了する。(通常存在し得ない）
				if(diffDateTimeLong < 0){
					System.out.println("DB time error.");
					System.exit(2);
				}
				//求めた差分が単位時間（分）* 過去ステップ数よりも大きい場合は、長く更新されていないためエラーとする。
				else if(0 <= diffDateTimeLong && diffDateTimeLong > tablePerMin * getHisStep()){
					System.out.println("Table data is old.");
					System.out.println(mt4Table + "'s DATE || TIME : " + recentDateTime);
					return(false);
				}
			}
		}
		System.out.println("MT4 Table time diff is OK.");
		return(true);
	}

	private void sleepTime(int time){
		try{
			Thread.sleep(time * 1000);
		}
		catch(InterruptedException e){
			System.out.println("Interrupted!");
		}
	}

	private boolean chkRecentlyData(){
		//SEQ_NOとDATE||TIMEの論理チェックを実施
		//対象テーブルのSEQ_NOリスト
		ArrayList<Long> recentSeqNoList = new ArrayList<Long>();
		recentSeqNoList.clear();
		recentSeqNoList = RLonlineDao.selectMaxSeqNoList();
		if(!chkSeqNoList(recentSeqNoList)){
			//データに問題があるためエラー
			System.out.println("SEQ_NO is renewal. Please waite...");
			sleepTime(30);
			return(false);
		}

		//対象テーブルのDATE||TIMEリスト
		ArrayList<ArrayList<String>> tableRecentDateTimeList = new ArrayList<ArrayList<String>>();
		if(!chkDateTimeList()){
			//データに問題があるためエラー
			System.out.println("DATE||TIME is renewal. Please waite...");
			sleepTime(30);
			return(false);
		}
		return(true);
	}
			
	private void prcvOnlineStateActValue(){
		//最新のデータを取得する。
		//ただし、最新データでない場合または、DBに過去データがたまっていない場合はリトライする。
		boolean chkFlg = false;
		while(!chkFlg){
			chkFlg = chkRecentlyData();
		}

		//現在の状態リスト
		stateMt4List.clear();
		stateMt4List = RLonlineDao.selectCurrentState(getHisStep());

		for(byte act = 0; act < (byte)actType.length; act++){
			q[act] = super.sumRBF(act, stateMt4List);
		}
	}

	//MT4とのinterfaceであるテーブルを更新
	private boolean syncTradeInfoMT4(String currency, String tradeDateTime){

		//選択された行動をレコードにinsertする。
		syncTradeInfoDao.insertTradeInfo(currency, tradeDateTime, getNowAct());

		byte mt4PositionFlg = -1;
		int timeOutCount = 0;
		boolean retFlg = false;
		while(true){
			//MT4から指定行動の結果を確認
			mt4PositionFlg = syncTradeInfoDao.selectPositionFlg(currency, tradeDateTime);
			if(mt4PositionFlg == 0){
				//ポジション未取得
				//タイムアウトの確認
				if(timeOutCount == 120){
					System.out.println("time out!!");
					break;
				}
				//何もせず更新(ポジション取得)を待つ
				System.out.println("MT4 is getting Position. Please waite...");
				sleepTime(30);
			}
			else if(mt4PositionFlg == 1){
				//ポジション取得かつ、未決済
				System.out.println("MT4 has completed execution. Please waite for settlement...");
				sleepTime(30);
				timeOutCount++;
			}
			else if(mt4PositionFlg == 2){
				//異常発生によりポジション未取得
				//例えば、MT4での処理が遅れた場合には、情報が古いためPOSITION_FLG = 2を返して何もしない。
				System.out.println("Some problem occur.");
				retFlg = false;
				break;
			}
			else if(mt4PositionFlg == 3){
				//決済完了
				System.out.println("MT4 has been settlemented. OK!");
				retFlg = true;
				break;
			}
			else{
				System.out.println("PositionFlg error.");
				System.out.println("tradeDateTime : " + tradeDateTime + "\nPositionFlg : " + mt4PositionFlg);
				System.exit(2);
			}
		}
		return(retFlg);
	}

	public void executeOnline(long epsd){
		//On-Line learning 学習データによるトレーニング結果でリアルタイムトレードを実施する。

		//infinity loop
		while(true){	
			System.out.println("RL trade start");
			//トレード開始時刻取得
			//現時刻取得と通貨ペアを取得
			Date date = new Date();
			String tradeDateTime = sdf_yyyyMMddHHmm.format(date);
			String currency = getCurrency();
			//状態観測s_t
			prcvOnlineStateActValue();
			System.out.println("perceived state act value.");
			//行動選択a_t
			selectAct();
			System.out.println("selected act : " + getNowAct());
			//MT4との行動同期:選択行動の共有を売買完了通知
			System.out.println("During Synchronization with MT4...");
			boolean settlementFlg = syncTradeInfoMT4(currency, tradeDateTime);
			//報酬獲得による学習
			//決済が完了した場合のみ実施
			if(settlementFlg){
				System.out.println("learning...");
				renwlOnlinePara(currency, tradeDateTime);
				System.out.println("learning OK.");
			}
			else{
				System.out.println("This time no learning...");
			}
			System.out.println("One RL finish.");
			sleepTime(60);
		}
	}

	private void onlineParametersInitiallize(){
		long seqNo = getTgtSeqNo();

		//各行動のユニット数を取得する 
		for(byte act = 0; act < actType.length; act++){
			setUnits(act, RLparasDao.selectRLunits(seqNo, act));
		}

		//学習された「units,mu,w,sigma,XCth」を取得する。
		ArrayList<BigDecimal> muList = new ArrayList<BigDecimal>();
		ArrayList<BigDecimal> sigmaList = new ArrayList<BigDecimal>();
		ArrayList<BigDecimal> wList = new ArrayList<BigDecimal>();
		ArrayList<BigDecimal> xcList = new ArrayList<BigDecimal>();
		muList.clear();
		sigmaList.clear();
		wList.clear();
		xcList.clear();

		muList = RLparasDao.selectRLmuParas(seqNo);
		sigmaList = RLparasDao.selectRLsigmaParas(seqNo);
		wList = RLparasDao.selectRLwParas(seqNo);
		xcList = RLparasDao.selectRLxcParas(seqNo);

		//各項目はORDER BYで ACT, UNIT, STATE の優先順位でソートされている。
		//よって、下記の通りremove()で先頭から順に取り出せばよい。
		for(byte act = 0; act < actType.length ; act++){
			setXCth(xcList.remove(0), act);
			for(int k = 0; k < getUnits(act); k++){
				sigma[act][k] = sigmaList.remove(0);
				w[act][k] = wList.remove(0);
				for(int i = 0; i < getStates(); i++){
					mu[act][k][i] = muList.remove(0);
				}
			}
		}
	}

	public void executeOnlineBefore(){

		//学習パラメータを全て0で初期化
		initiallizeLearningParameters();
		//学習済みのパラメータ取得
		onlineParametersInitiallize();
		//指標値を0にセット
		super.resetPara();

	}

	public void executeOnlineAfter(){
	}
}
