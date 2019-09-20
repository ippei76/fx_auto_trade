package convolutional_neural_network.business;

import com.sun.jna.Library;
import com.sun.jna.Native;

interface JnaIF extends Library {
	// loadLibraryの第一引数はあとで作成するlib***.soの***と一致させる。
	JnaIF INSTANCE = (JnaIF) Native.loadLibrary("JnaInterface", JnaIF.class);

	void jnaInterface(
			int sv_xNums, int sv_yNums, int miniBatchNums, int svChannelNums, float[] sv, float[] svAll, float[] teachOut, float[] teachOutAll,

			int[] cnnOutputNums, int cnnOutputNumsNums, 

			float[] cnnBnBeta, float[] cnnBnGamma, float bnEps,

			int cnnW_xNums, int cnnW_yNums, float[] cnnW, 

			int cnnPooling_xNums, int cnnPooling_yNums, 

			int[] cnnWba_xNums, int[] cnnWba_yNums, 

			int[] cnnP_xNums, int[] cnnP_yNums,

			int[] mlpOutputNums, int mlpOutputNumsNums,

			float[] mlpBnBeta, float[] mlpBnGamma,

			float[] mlpW,

			int stepNums, int episodeNums,

			int oneSvDataNums, int oneTeachOutDataNums, int allDataNums,

			int cnnWbaDataNums, int cnnPDataNums, int mlpWbaDataNums,

			int cnnWDataNums, int cnnBnBetaGammaDataNums,

			int mlpWDataNums, int mlpBnBetaGammaDataNums,

			float[] infCnnBnMean, float[] infCnnBnVar2, float[] infMlpBnMean, float[] infMlpBnVar2,

			//トレーニング時には、使用しない。
			float[] cnnBnAveMean, float[] cnnBnAveVar2, float[] mlpBnAveMean, float[] mlpBnAveVar2,

			//「トレーニング:0」「Online:1」
			int execFlg, float[] result, float learningRate

				);
}
