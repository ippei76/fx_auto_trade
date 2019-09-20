package convolutional_neural_network.values;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import static convolutional_neural_network.values.Mt4Define.*;
import static convolutional_neural_network.values.CulcuConstants.*;
import static convolutional_neural_network.common.PropertiesReader.*;
import java.text.SimpleDateFormat;
import java.text.DateFormat;
import java.util.Date;
import java.text.ParseException;

public class Constants{

	// privateコンストラクタでインスタンス生成を抑止
	private Constants(){}

	//プロパティファイルの読み込み
	public static int hoo = PropertiesOpen(); //プロパティファイルを参照できるようにする。ダミーのreturn値を持つ。voidはコンパイルエラー

	final private static String learnStartDateTime = properties.getProperty("learnStartDateTime_property");//yyyymmddssMi
	final private static String learnEndDateTime   = properties.getProperty("learnEndDateTime_property");//yyyymmddssMi
	final private static String testModeStartDateTime = properties.getProperty("testModeStartDateTime_property");//yyyymmddssMi
	final private static String testModeEndDateTime   = properties.getProperty("testModeEndDateTime_property");//yyyymmddssMi
	final private static int execFlg = Integer.parseInt(properties.getProperty("execFlg_property")); //「0:トレーニング」「1:オンライン」

	//エピソード数
	final private static int episodeNums = Integer.parseInt(properties.getProperty("episodeNums_property"));

	//学習ステップ数
	final private static int stepNums = Integer.parseInt(properties.getProperty("stepNums_property"));

	//sv_x,yNums, svChannelNums, mlpOutputNums[lastLayer]を決めるために、ここで定義する。
	final private static int applicationIsMnist = 0;
	final private static int applicationIsExchangeData = 1;
	final private static int application = Integer.parseInt(properties.getProperty("application_property"));

	//出力(チャネル)情報
	final public static int[] cnnOutputNums = {
//		50,	//cnn第0層の出力数
		20,	//cnn第1層の出力数
//		30,	//cnn第2層の出力数
		50,	//cnn第3層の出力数
	};
	//mlp最終層の要素数を計算する。
	final private static int mlpLastLayerOutputNums = getMlpLastLayerOutputNums();
	final public static int[] mlpOutputNums = {
		500,	//mlp第0層の出力数
		100,	//mlp第1層の出力数
//		50,	//mlp第2層の出力数
//		30,
		mlpLastLayerOutputNums   //mlp最終層の出力数
	};

	//教師データ情報

	final private static int miniBatchNums = Integer.parseInt(properties.getProperty("miniBatchNums_property")); //miniBatch数

	private static int sv_xNums; //教師データのx方向の要素数
	private static int sv_yNums; //教師データのy方向の要素数
	private static int svChannelNums; //教師データのチャネル数
	private static int svDataNums; //教師データ数
	private static int cnnW_xNums; //フィルタのx方向の要素数
	private static int cnnW_yNums; //フィルタのy方向の要素数
	private static int cnnPooling_xNums; //プーリングのx方向の要素数
	private static int cnnPooling_yNums; //プーリングのy方向の要素数

	public static int poo = setSvParas(); //プロパティファイルを参照できるようにする。ダミーのreturn値を持つ。voidはコンパイルエラー

	public static float[] sv = new float[sv_xNums * sv_yNums * svChannelNums * miniBatchNums]; //教師入力データ

	public static float[] svAll = new float[svDataNums * sv_xNums * sv_yNums * svChannelNums]; //教師入力データ

	public static float[] teachOutAll = new float[svDataNums * mlpOutputNums[(mlpOutputNums.length - 1)]]; //教師出力データ

	public static float[] teachOut = new float[mlpOutputNums[(mlpOutputNums.length - 1)] * miniBatchNums]; //教師出力データ



	//batch normalization 情報
	final public static float bnEps = 0.00001f;

	//中間処理情報
	public static int[] cnnWba_xNums = new int[cnnOutputNums.length]; //各層におけるwb・activate処理後のx方向の要素数
	public static int[] cnnWba_yNums = new int[cnnOutputNums.length]; //各層におけるwb・activate処理後のy方向の要素数

	public static int[] cnnP_xNums = new int[cnnOutputNums.length]; //各層におけるcnnPooling処理語のx方向の要素数
	public static int[] cnnP_yNums = new int[cnnOutputNums.length]; //各層におけるcnnPooling処理語のy方向の要素数

	public static int boo = initializeWbaP(); //下の要素数計算で必要なため、cnnWba,pの値を設定する。ダミーのreturn値を持つ。voidはコンパイルエラー

	//ここから:miniBatchをつける
	//[x][y][input][output][layer]におけるw,b 処理後の要素値
	public static float[] cnnBnBeta = new float[cnnBnBetaGamma_culcuElementCount(cnnOutputNums)]; //cnnBnBetaの要素値
	public static float[] cnnBnGamma = new float[cnnBnBetaGamma_culcuElementCount(cnnOutputNums)]; //cnnBnGammaの要素値
	public static float[] cnnW = new float[cnnW_culcuElementCount(cnnW_xNums, cnnW_yNums, svChannelNums, cnnOutputNums)]; //wの要素値

	//MLP
	public static float[] mlpBnBeta = new float[mlpBnBetaGamma_culcuElementCount(mlpOutputNums)]; //mlpBnBetaの要素値
	public static float[] mlpBnGamma = new float[mlpBnBetaGamma_culcuElementCount(mlpOutputNums)]; //mlpBnBetaの要素値
	public static float[] mlpW = new float[mlpW_culcuElementCount(cnnP_xNums, cnnP_yNums, cnnOutputNums, mlpOutputNums)]; //wの要素値
	public static float[] mlpA = new float[mlpWba_culcuElementCount(miniBatchNums, mlpOutputNums)];	//[x][y][output][layer]におけるactivate処理後の要素値

	//要素数
	public static int cnnWbaDataNums = cnnWba_culcuElementCount(cnnWba_xNums, cnnWba_yNums, miniBatchNums, cnnOutputNums);	//[x][y][output][layer]におけるactivate処理後の要素値
	public static int cnnPDataNums = cnnP_culcuElementCount(cnnP_xNums, cnnP_yNums, miniBatchNums, cnnOutputNums); //[x][y][output][layer]におけるcnnPooling処理後の要素値
	public static int cnnBnBetaGammaDataNums = cnnBnBetaGamma_culcuElementCount(cnnOutputNums); //cnnBnBetaの要素値
	public static int mlpWbaDataNums = mlpWba_culcuElementCount(miniBatchNums, mlpOutputNums);	//[x][y][output][miniBatch][layer]におけるconvolution処理後の要素数
	public static int mlpBnBetaGammaDataNums = mlpBnBetaGamma_culcuElementCount(mlpOutputNums); //mlpBnBetaの要素値

	//inference batch normalization
	public static float[] infCnnBnMean = new float[cnnBnBetaGamma_culcuElementCount(cnnOutputNums) * episodeNums];//1エピソードあたりの要素数は、BetaGammaと同じ
	public static float[] infCnnBnVar2 = new float[cnnBnBetaGamma_culcuElementCount(cnnOutputNums) * episodeNums];//1エピソードあたりの要素数は、BetaGammaと同じ
	public static float[] infMlpBnMean = new float[mlpBnBetaGamma_culcuElementCount(mlpOutputNums) * episodeNums];//1エピソードあたりの要素数は、BetaGammaと同じ
	public static float[] infMlpBnVar2 = new float[mlpBnBetaGamma_culcuElementCount(mlpOutputNums) * episodeNums];//1エピソードあたりの要素数は、BetaGammaと同じ
	//上記の配列から母集合のMean,Var2を出し、その結果を保存する配列
	//割り出しはAfterにて記載
	public static float[] cnnBnAveMean = new float[cnnBnBetaGamma_culcuElementCount(cnnOutputNums)]; //cnnBnBetaの要素値
	public static float[] cnnBnAveVar2 = new float[cnnBnBetaGamma_culcuElementCount(cnnOutputNums)]; //cnnBnGammaの要素値
	public static float[] mlpBnAveMean = new float[mlpBnBetaGamma_culcuElementCount(mlpOutputNums)]; //cnnBnBetaの要素値
	public static float[] mlpBnAveVar2 = new float[mlpBnBetaGamma_culcuElementCount(mlpOutputNums)]; //cnnBnGammaの要素値

	//最終出力結果
	public static float[] result = new float[mlpOutputNums[(mlpOutputNums.length - 1)] * miniBatchNums];

	//テスト用のMNISTデータ
	final public static String mnistInputDataFile = "/root/projects/fx/mnist/train-images.txt";
	final public static String mnistOutputDataFile = "/root/projects/fx/mnist/train-labels.txt";
	final public static String mnistInputDataFileOnline = "/root/projects/fx/mnist/t10k-images.txt";
	final public static String mnistOutputDataFileOnline = "/root/projects/fx/mnist/t10k-labels.txt";

	//コード定義
	final private static int execFlgIsTraining = 0;
	final private static int execFlgIsOnline = 1;
	final private static int typeIsCnn = 0;
	final private static int typeIsMlp = 1;
	final private static int bnTypeIsGamma = 0;
	final private static int bnTypeIsBeta = 1;
	final private static int bnTypeIsAveMean = 2;
	final private static int bnTypeIsAveVar2 = 3;
	final private static int profitActUnset = -1;
	final private static int exchangeDataModeIsTest = 0;
	final private static int exchangeDataModeIsRealTrade = 1;
	//トレーニング時に重みをランダムにセットする場合のSeqNo
	final private static int trainingRandomSeqNo = -1;

	//意思決定閾値
	final private static float actThreshold = 0.85f;
	final private static float learningRate = 1.0f;

	//大量データをDBに保存する場合にこのファイルを経由する
	final private static String loadDataFile = "/root/projects/fx/work/loadDataFile.dat";

	//トレード情報を連携するインターフェーステーブル
	public static String syncTradeTable = "SYNC_TRADE";

	final private static int exchangeDataMode = Integer.parseInt(properties.getProperty("exchangeDataMode_property"));
	final private static int seqNo = Integer.parseInt(properties.getProperty("seqNo_property")); //オンラインで使用するシーケンスNo

	//cnnWba_x,yは要素数計算に使用されるため、cnnWba_x,yはこのタイミングで設定する。
	private static int initializeWbaP(){
		//cnnWba_x,yNums[layer]の初期値を設定
		//cnnP_x,yNums[layer]の初期値を設定
		for(int cnnLayer = 0; cnnLayer < cnnOutputNums.length; cnnLayer++){
			if(cnnLayer == 0){
				cnnWba_xNums[cnnLayer] = sv_xNums - cnnW_xNums + 1;
				cnnWba_yNums[cnnLayer] = sv_yNums - cnnW_yNums + 1;
			}
			else{
				cnnWba_xNums[cnnLayer] = cnnP_xNums[cnnLayer - 1] - cnnW_xNums + 1;
				cnnWba_yNums[cnnLayer] = cnnP_yNums[cnnLayer - 1] - cnnW_yNums + 1;
			}
			cnnP_xNums[cnnLayer] = (cnnWba_xNums[cnnLayer] + cnnPooling_xNums - 1) / cnnPooling_xNums;
			cnnP_yNums[cnnLayer] = (cnnWba_yNums[cnnLayer] + cnnPooling_yNums - 1) / cnnPooling_yNums;
		}
		return(0);
	}

	private static int setSvParas(){
		if(getApplication() == getApplicationIsMnist()){
			sv_xNums = 28;
			sv_yNums = 28;
			svChannelNums = 1;
			if(getExecFlg() == getExecFlgIsTraining()){
				svDataNums = 60000;
			}
			else if(getExecFlg() == getExecFlgIsOnline()){
				svDataNums = 10000;
			}
			//MNISTのCNNフィルタ
			cnnW_xNums = 5; //フィルタのx方向の要素数
			cnnW_yNums = 5; //フィルタのy方向の要素数
			//MNISTのプーリング情報
			cnnPooling_xNums = 2; //プーリングのx方向の要素数
			cnnPooling_yNums = 2; //プーリングのy方向の要素数
		}
		else if(getApplication() == getApplicationIsExchangeData()){
			sv_xNums = getSvColumnNums();
			sv_yNums = mt4InputTableNameList.size();
			svChannelNums = itemNameList.size();

			//日付からsvDataNumsを求める。
			DateFormat df = new SimpleDateFormat("yyyyMMddHHmm");
			Date startDateTime = null;
			Date endDateTime = null;
			try {
				if(getExecFlg() == getExecFlgIsTraining()){
					startDateTime = df.parse(learnStartDateTime);
					endDateTime = df.parse(learnEndDateTime);
				}
				else if(getExecFlg() == getExecFlgIsOnline()){
					startDateTime = df.parse(testModeStartDateTime);
					endDateTime = df.parse(testModeEndDateTime);
				}
			} catch (ParseException e) {
				e.printStackTrace();
				System.exit(2);
			}
			long svDataNumsLong = (endDateTime.getTime() - startDateTime.getTime()) / (1000 * 60) + 1;
			if(svDataNumsLong > Integer.MAX_VALUE){
				System.out.println("svDataNums overflow(" + svDataNumsLong + ")");
			}
			svDataNums = (int)svDataNumsLong;
			//EXCHANGEDATAのCNNフィルタ
			cnnW_xNums = 2; //フィルタのx方向の要素数
			cnnW_yNums = 2; //フィルタのy方向の要素数
			//EXCHANGEDATAのプーリング情報
			cnnPooling_xNums = 2; //プーリングのx方向の要素数
			cnnPooling_yNums = 2; //プーリングのy方向の要素数
		}
		return(0);

	}

	private static int getMlpLastLayerOutputNums(){
		int mlpLastLayerOutputNums = -1;
		if(getApplication() == getApplicationIsMnist()){
			mlpLastLayerOutputNums = 10;
		}
		else if(getApplication() == getApplicationIsExchangeData()){
			mlpLastLayerOutputNums = 3;
		}
		return(mlpLastLayerOutputNums);
	}

	//getters

	public static int getApplication(){
		return(application);
	}
	public static int getApplicationIsMnist(){
		return(applicationIsMnist);
	}
	public static int getApplicationIsExchangeData(){
		return(applicationIsExchangeData);
	}
	public static int getEpisodeNums(){
		return(episodeNums);
	}
	public static int getStepNums(){
		return(stepNums);
	}
	public static int getExecFlg(){
		return(execFlg);
	}
	public static String getLearnStartDateTime(){
		return(learnStartDateTime);
	}
	public static String getLearnEndDateTime(){
		return(learnEndDateTime);
	}
	public static String getTestModeStartDateTime(){
		return(testModeStartDateTime);
	}
	public static String getTestModeEndDateTime(){
		return(testModeEndDateTime);
	}
	public static int getMiniBatchNums(){
		return(miniBatchNums);
	}
	public static int getSvDataNums(){
		return(svDataNums);
	}
	public static int getSvChannelNums(){
		return(svChannelNums);
	}
	public static int getSv_xNums(){
		return(sv_xNums);
	}
	public static int getSv_yNums(){
		return(sv_yNums);
	}
	public static int getCnnW_xNums(){
		return(cnnW_xNums);
	}
	public static int getCnnW_yNums(){
		return(cnnW_yNums);
	}
	public static int getCnnPooling_xNums(){
		return(cnnPooling_xNums);
	}
	public static int getCnnPooling_yNums(){
		return(cnnPooling_yNums);
	}
	public static int getExecFlgIsTraining(){
		return(execFlgIsTraining);
	}
	public static int getExecFlgIsOnline(){
		return(execFlgIsOnline);
	}
	public static int getTypeIsCnn(){
		return(typeIsCnn);
	}
	public static int getTypeIsMlp(){
		return(typeIsMlp);
	}
	public static int getBnTypeIsGamma(){
		return(bnTypeIsGamma);
	}
	public static int getBnTypeIsBeta(){
		return(bnTypeIsBeta);
	}
	public static int getBnTypeIsAveMean(){
		return(bnTypeIsAveMean);
	}
	public static int getBnTypeIsAveVar2(){
		return(bnTypeIsAveVar2);
	}
	public static float getActThreshold(){
		return(actThreshold);
	}
	public static String getLoadDataFile(){
		return(loadDataFile);
	}
	public static int getSeqNo(){
		return(seqNo);
	}
	public static int getProfitActUnset(){
		return(profitActUnset);
	}
	public static float getLearningRate(){
		return(learningRate);
	}
	public static int getTrainingRandomSeqNo(){
		return(trainingRandomSeqNo);
	}
	public static int getExchangeDataModeIsTest(){
		return(exchangeDataModeIsTest);
	}
	public static int getExchangeDataModeIsRealTrade(){
		return(exchangeDataModeIsRealTrade);
	}
	public static int getExchangeDataMode(){
		return(exchangeDataMode);
	}

}
