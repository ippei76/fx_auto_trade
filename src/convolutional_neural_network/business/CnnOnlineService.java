package convolutional_neural_network.business;

import com.sun.jna.Library;
import com.sun.jna.Native;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.*;
import java.util.Random;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.math.MathContext;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.ParseException;
import static convolutional_neural_network.values.Constants.*;
import static convolutional_neural_network.common.MnistService.*;
import convolutional_neural_network.business.ExchangeDataService;
import convolutional_neural_network.business.CnnMlpParasService;
//import static convolutional_neural_network.values.Variables.*;


class CnnOnlineService{

	private static int plsCount = 0;
	private static int mnsCount = 0;
	private static int eqlCount = 0;
	private static int svAllDataIdx = 0;
	private static int teachOutAllDataIdx = 0;

	private CnnMlpParasService cnnMlpParasService = new CnnMlpParasService();
	private ExchangeDataService exchangeDataService = new ExchangeDataService();

	private Random random = new Random();
	protected SimpleDateFormat sdf_yyyyMMddHHmmss = new SimpleDateFormat("yyyyMMddHHmmss");

	//コンストラクタ
	public CnnOnlineService(){
	}

	private void setSvOnline(){
		//svAllからsvへ割り当てる。
		for(int miniBatchIdx = 0; miniBatchIdx < getMiniBatchNums(); miniBatchIdx++){
			for(int i = 0; i < getSv_xNums() * getSv_yNums() * getSvChannelNums(); i++){
				sv[i] = svAll[svAllDataIdx];
				svAllDataIdx++;
			}
		}

		//出力チェック
		/*
		   int k = 0;
		   for(int i = 0; i < sv.length; i++){
		   System.out.println("sv[" + i + "] = " + sv[i]);
		   if((i + 1)%(sv_xNums * sv_yNums * svChannelNums) == 0){
		   for(int j = 0; j < mlpOutputNums[mlpOutputNums.length - 1]; j++){
		   System.out.println("teachOut[" + k + "] = " + teachOut[k]);
		   k++;
		   }
		   }
		   }
		   */
	}

	private void setTeachOutMnist(){
		//teachOutAllからteachOutへ割り当てる。
		for(int i = 0; i < mlpOutputNums[mlpOutputNums.length - 1]; i++){
			teachOut[i] = teachOutAll[teachOutAllDataIdx];
			teachOutAllDataIdx++;
		}
	}

	private void culculateScore(){
		//scoreの計算
		//mlp最終層の出力のうち、最大値が閾値以上だった場合に、答えを選択するとする。
		//それが正解だった場合にはplusCount++, 不正解だった場合にはminusCount++,
		//閾値以下だった場合は、waitCount++とする。

		//mlp最終層の出力のうち、最大のインデックスを取得
		int maxIdx = 0;
		for(int i = 0; i < result.length; i++){
			if(result[maxIdx] < result[i]){
				maxIdx = i;
			}
		}
		int currect = 0;
		for(int j = 0; j < result.length; j++){
			if(teachOut[j] == 1){
				currect = j;
				break;
			}
		}

		//閾値の条件分岐:この値よりresultが大きければ行動を選択する。
		if(result[maxIdx] > getActThreshold()){
			if(maxIdx == currect){
				System.out.println("LOG:RESULT OK : currect = " + currect + "  result = " + maxIdx + " (" + result[maxIdx] + ")");
				plsCount++;
			}
			else{
				System.out.println("LOG:RESULT NG : currect = " + currect + "  result = " + maxIdx + " (" + result[maxIdx] + ")");
				mnsCount++;
			}
		}
		else{
			System.out.println("LOG:RESULT Wait : currect = " + currect + "  result = " + maxIdx + " (" + result[maxIdx] + ")");
			eqlCount++;
		}
		/*
		   for(int i =0; i < result.length; i++){
		   System.out.println("result[" + i + "] = " + result[i] + ", teachOut[" + i + "] = " + teachOut[i]);
		   }
		   */
	}

	public void executeBefore(){

		//初期パラメータの論理チェック
		cnnMlpParasService.initConstParaCheck();
		//学習済みパラメータをセットする。
		cnnMlpParasService.initLearnedPara();
		//MNISTの初期値セット
		if(getApplication() == getApplicationIsMnist()){
			//全svをセット
			getAllSvTeachMnist(mnistInputDataFileOnline, mnistOutputDataFileOnline);
		}
		//ExchangeDataの初期値セット
		else if(getApplication() == getApplicationIsExchangeData()){
			//テストモード
			if(getExchangeDataMode() == getExchangeDataModeIsTest()){
				System.out.println("exchangeData TestMode(" + getExchangeDataMode() + ") start");
				exchangeDataService.getAllSvTeachOutExchangeDataTestMode();
			}
			//リアルトレードモード
			else if(getExchangeDataMode() == getExchangeDataModeIsRealTrade()){
				System.out.println("exchangeData RealTradeMode(" + getExchangeDataMode() + ") start");
				System.exit(2);
			}
			else{
				System.out.println("exchangeDataMode(" + getExchangeDataMode() + ") error");
				System.exit(2);
			}
		}
		else{
			System.out.println("application(" + getApplication() + ") error");
			System.exit(2);
		}

	}

	public void execute(){

		//RealTradeでは、既にsvには、データが入っているので、以下は不要
		if(getApplication() == getApplicationIsExchangeData() && getExchangeDataMode() == getExchangeDataModeIsRealTrade()){
		}
		else{
			//全svの中から1データだけをsvにセットする。
			setSvOnline();
		}

		/*
		   for(int i = 0; i< w.length; i++){
		   System.out.println("w:[" + i +"]=" + w[i]);
		   }
		   for(int i = 0; i< mlpW.length; i++){
		   System.out.println("mlpW:[" + i+ "]=" + mlpW[i]);
		   }
		for(int i = 0; i < sv.length; i++){
			System.out.println("sv[" + i +"]" + sv[i]);
		   }
		   */
		//入力値を元にCNN出力値を計算する。
		System.out.println("JNA start");
		JnaIF jnaInterfaceInstance = JnaIF.INSTANCE;
		jnaInterfaceInstance.jnaInterface(
				getSv_xNums(), getSv_yNums(), getMiniBatchNums(), getSvChannelNums(), sv, svAll,

				teachOut, teachOutAll,

				cnnOutputNums, cnnOutputNums.length, 

				cnnBnBeta, cnnBnGamma, bnEps,

				getCnnW_xNums(), getCnnW_yNums(), cnnW, 

				getCnnPooling_xNums(), getCnnPooling_yNums(), 

				cnnWba_xNums, cnnWba_yNums, 

				cnnP_xNums, cnnP_yNums,

				mlpOutputNums, mlpOutputNums.length,

				mlpBnBeta, mlpBnGamma,

				mlpW,

				getStepNums(), getEpisodeNums(),

				sv.length, teachOut.length, getSvDataNums(),

				cnnWbaDataNums, cnnPDataNums, mlpWbaDataNums,

				cnnW.length, cnnBnBetaGammaDataNums,

				mlpW.length, mlpBnBetaGammaDataNums,

				infCnnBnMean, infCnnBnVar2, infMlpBnMean, infMlpBnVar2,

				//トレーニング時には、使用しない。
				cnnBnAveMean, cnnBnAveVar2, mlpBnAveMean, mlpBnAveVar2,

				//「トレーニング:0」「Online:1」
				getExecFlg(), result, getLearningRate()
					);
		System.out.println("JNA end");

		//正しい出力値を取得する。
		setTeachOutMnist();

		//CNN出力値と正しい出力値からスコアを計算する。
		culculateScore();

	}

	public void executeAfter(){
		//オンライン結果をDBに保存する。
		cnnMlpParasService.updateOnlineResult(plsCount, mnsCount, eqlCount, getSeqNo());

		System.out.println("online end.");
	}
}
