package convolutional_neural_network.business;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.math.MathContext;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.ParseException;
import static convolutional_neural_network.values.Mt4Define.*;
import static convolutional_neural_network.values.Constants.*;
import static convolutional_neural_network.common.MnistService.*;
import convolutional_neural_network.business.ExchangeDataService;
import convolutional_neural_network.business.JnaIF;


class CnnTrainingService{

	public static int plsCount = 0;
	public static int mnsCount = 0;
	public static int eqlCount = 0;

	private CnnMlpParasService cnnMlpParasService= new CnnMlpParasService();
	private ExchangeDataService exchangeDataService = new ExchangeDataService();
	protected SimpleDateFormat sdf_yyyyMMddHHmmss = new SimpleDateFormat("yyyyMMddHHmmss");

	//コンストラクタ
	public CnnTrainingService(){
		//子クラスから呼び出される。
	}

	public void culculateAveMeanVar2(){

		float meanAve = 0;
		float var2Ave = 0;
		int betaGammaNums = 0;

		//cnnの母集合割り出し
		//beta,gammaの配列長と同じサイズになる。
		betaGammaNums = cnnBnBeta.length;
		for(int aveArrayIdx = 0; aveArrayIdx < betaGammaNums; aveArrayIdx++){
			meanAve = 0;
			var2Ave = 0;
			for(int i = 0; i < getEpisodeNums(); i++){
				//値が大きくなりすぎないように、逐一getEpisodeNums()で割る.
				meanAve += (float)(infCnnBnMean[aveArrayIdx + i * betaGammaNums] / getEpisodeNums());
				var2Ave += (float)(infCnnBnVar2[aveArrayIdx + i * betaGammaNums] / getEpisodeNums());
			}
			cnnBnAveMean[aveArrayIdx] = meanAve;
			cnnBnAveVar2[aveArrayIdx] = var2Ave * getMiniBatchNums() / (getMiniBatchNums() - 1); //計算式は既存研究に準じる
		}
		//mlpの母集合割り出し
		//beta,gammaの配列長と同じサイズになる。
		betaGammaNums = mlpBnBeta.length;
		for(int aveArrayIdx = 0; aveArrayIdx < betaGammaNums; aveArrayIdx++){
			meanAve = 0;
			var2Ave = 0;
			for(int i = 0; i < getEpisodeNums(); i++){
				//値が大きくなりすぎないように、逐一getEpisodeNums()で割る.
				meanAve += (float)(infMlpBnMean[aveArrayIdx + i * betaGammaNums] / getEpisodeNums());
				var2Ave += (float)(infMlpBnVar2[aveArrayIdx + i * betaGammaNums] / getEpisodeNums());
			}
			mlpBnAveMean[aveArrayIdx] = meanAve;
			mlpBnAveVar2[aveArrayIdx] = var2Ave * getMiniBatchNums() / (getMiniBatchNums() - 1); //計算式は既存研究に準じる。
		}
	}

	public void executeBefore(){

		if(getSeqNo() == getTrainingRandomSeqNo()){
			//初期パラメータをランダムにセット
			cnnMlpParasService.initLearningParaRandom();
		}
		else{
			//初期パラメータの論理チェック
			cnnMlpParasService.initConstParaCheck();
			//初期パラメータをSeqNoに応じてセット
			cnnMlpParasService.initLearnedPara();
		}

		if(getApplication() == getApplicationIsMnist()){
			//全教師データを取得する。
			getAllSvTeachMnist(mnistInputDataFile, mnistOutputDataFile);
		}
		else if(getApplication() == getApplicationIsExchangeData()){
			//対象の為替データを取得する。
			exchangeDataService.getAllSvTeachOutExchangeDataTraining();
		}
		else{
			System.out.println("application(" + getApplication() + ") error");
			System.exit(2);
		}

	}

	public void execute(){

		/*
		for(int i = 0; i< svAll.length; i++){
			System.out.print(svAll[i] + " ");
			if(((i + 1) % getSv_xNums()) == 0){
				System.out.println();
				if((i + 1) % (getSv_xNums() * getSv_yNums()) == 0){
					System.out.println();
				}
			}
		}
		for(int i = 0; i < teachOutAll.length; i++){
			System.out.print(teachOutAll[i] + " ");
			if((i + 1) % 3 == 0){
				System.out.println();
			}
		}
		System.exit(2);
		*/

		//JANにより学習開始
		System.out.println("JNA start");

		JnaIF jnaInterfaceInstance = JnaIF.INSTANCE;
		jnaInterfaceInstance.jnaInterface(
				getSv_xNums(), getSv_yNums(), getMiniBatchNums(), getSvChannelNums(), sv, svAll, teachOut, teachOutAll,

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
	}

	public void executeAfter(){

		System.out.println("training end.");

		//AveMean,AveVar2を割り出す
		culculateAveMeanVar2();

		//現時刻取得
		Date currentDateTime = new Date();
		String currentDateTimeStr = sdf_yyyyMMddHHmmss.format(currentDateTime);

		//学習結果をDBに保存する。
		//MNISTの場合には通貨欄に"MNIST"を入れる。
		String settingCurrency = null;
		if(getApplication() == getApplicationIsMnist()){
			settingCurrency = "MNIST";
		}
		else{
			settingCurrency = getCurrency();
		}
		cnnMlpParasService.preserveLearnedParas(plsCount, eqlCount, mnsCount, settingCurrency, currentDateTimeStr);
	}
}
