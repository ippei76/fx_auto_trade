package convolutional_neural_network.values;

public class CulcuConstants{

	// privateコンストラクタでインスタンス生成を抑止
	private CulcuConstants(){}

	//cnnBnの要素数を計算する。
	public static int cnnBn_culcuElementCount(int[] cnnWba_xNums, int[] cnnWba_yNums, int miniBatchNums, int[] cnnOutputNums){

		int elementCount = 0;

		for(int layer = 0; layer < cnnOutputNums.length; layer++){
			elementCount += cnnWba_xNums[layer] * cnnWba_yNums[layer] * miniBatchNums * cnnOutputNums[layer];
		}

		return(elementCount);
	}

	//cnnBn_beta,gammaの要素数を計算する。
	public static int cnnBnBetaGamma_culcuElementCount(int[] cnnOutputNums){

		int elementCount = 0;

		for(int layer = 0; layer < cnnOutputNums.length; layer++){
			elementCount += cnnOutputNums[layer];
		}

		return(elementCount);
	}

	//cnnWの要素数を計算する。
	public static int cnnW_culcuElementCount(int cnnW_xNums, int cnnW_yNums, int svChannelNums, int[] cnnOutputNums){

		int oneWCount = cnnW_xNums * cnnW_yNums; //1フィルタの要素数
		int elementCount = oneWCount * svChannelNums * cnnOutputNums[0];

		for(int layer = 1; layer < cnnOutputNums.length; layer++){
			elementCount += oneWCount * cnnOutputNums[layer - 1] * cnnOutputNums[layer];
		}

		return(elementCount);
	}

	//wb,aの要素数を計算する。
	public static int cnnWba_culcuElementCount(int[] cnnWba_xNums, int[] cnnWba_yNums, int miniBatchNums, int[] cnnOutputNums){

		int elementCount = 0;

		for(int layer = 0; layer < cnnOutputNums.length; layer++){
			elementCount += cnnWba_xNums[layer] * cnnWba_yNums[layer] * miniBatchNums * cnnOutputNums[layer];
		}

		return(elementCount);
	}

	//pの各層における要素数を計算する。
	public static int cnnP_culcuElementCount(int[] cnnP_xNums, int[] cnnP_yNums, int miniBatchNums, int[] cnnOutputNums){

		int elementCount = 0;

		for(int layer = 0; layer < cnnOutputNums.length; layer++){
			elementCount += cnnP_xNums[layer] * cnnP_yNums[layer] * miniBatchNums * cnnOutputNums[layer];
		}

		return(elementCount);
	}

	//mlpBnの要素数を計算する。
	public static int mlpBn_culcuElementCount(int miniBatchNums, int[] mlpOutputNums){

		int elementCount = 0; 

		for(int layer = 0; layer < mlpOutputNums.length; layer++){
			elementCount += miniBatchNums * mlpOutputNums[layer];
		}

		return(elementCount);
	}

	//mlpBn_beta,gammaの要素数を計算する。
	public static int mlpBnBetaGamma_culcuElementCount(int[] mlpOutputNums){

		int elementCount = 0;

		for(int layer = 0; layer < mlpOutputNums.length; layer++){
			elementCount += mlpOutputNums[layer];
		}

		return(elementCount);
	}

	//mlpWの要素数を計算する。
	public static int mlpW_culcuElementCount(int[] cnnP_xNums, int[] cnnP_yNums, int[] cnnOutputNums, int[] mlpOutputNums){

		int lastCnnOutputNumsIdx = cnnOutputNums.length - 1;
		int elementCount = cnnP_xNums[lastCnnOutputNumsIdx] * cnnP_yNums[lastCnnOutputNumsIdx] * cnnOutputNums[lastCnnOutputNumsIdx] * mlpOutputNums[0];
		for(int layer = 1; layer < mlpOutputNums.length; layer++){
			elementCount += mlpOutputNums[layer - 1] * mlpOutputNums[layer];
		}

		return(elementCount);
	}

	//mlpWb,mlpAの要素数を計算する。
	public static int mlpWba_culcuElementCount(int miniBatchNums, int[] mlpOutputNums){

		int elementCount = 0;

		for(int layer = 0; layer < mlpOutputNums.length; layer++){
			elementCount += mlpOutputNums[layer] * miniBatchNums;
		}

		return(elementCount);
	}

}
