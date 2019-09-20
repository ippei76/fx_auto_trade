#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <constraint.cuh>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh> 
#include <cudaCheck.cuh>

extern __global__ void kernelBackMlpMultiplyProp(const int mlpLayer, const float bnEps);
extern __global__ void kernelBackMlpMultiplyUpdate(const int mlpLayer, const int miniBatchIdxNums, const float bnEps);

void backMlpMultiply(const int mlpLayer){

//	puts("backMlpMultiply start.");
//	struct timeval t1, t2, t3;
//	gettimeofday(&t1, NULL);

	//ブロック・スレッド定義
	dim3 gridProp(getMlpOutputNums(mlpLayer), 1);
	dim3 blockProp(getMiniBatchNums(), 1, 1);
	dim3 gridUpdate(getMlpOutputNums(mlpLayer), 1);
	dim3 blockUpdate(1, 1, 1);

	//次元チェック
	checkGridSize(gridProp);
	checkThreadSize(blockProp);
	checkGridSize(gridUpdate);
	checkThreadSize(blockUpdate);

	//シェアードメモリ確保
	int miniBatchDataSize = sizeof(float) * getMiniBatchNums();
	int sharedSizeMlpBnTmp = miniBatchDataSize; 

	//シェアードメモリチェック
	checkSharedMemorySize(sharedSizeMlpBnTmp);

//	gettimeofday(&t2, NULL);
	//カーネル起動
//	puts("kernelBackMlpMultiply start");
	cudaDeviceSynchronize();
	kernelBackMlpMultiplyProp<<<gridProp, blockProp, sharedSizeMlpBnTmp>>>(mlpLayer, getBnEps());
//	puts("kernelBackMlpMultiply end");
//	puts("kernelBackMlpMultiplyUpdate start");
	cudaDeviceSynchronize();
	kernelBackMlpMultiplyUpdate<<<gridUpdate, blockUpdate>>>(mlpLayer, getMiniBatchNums(), getBnEps());
//	puts("kernelBackMlpMultiplyUpdate end");
//	gettimeofday(&t3, NULL);

//	puts("backMlpMultiply end.");
//	printTime(t1,t2,t3);

}

__global__ void
kernelBackMlpMultiplyProp(const int mlpLayer, const float bnEps){
	int outputIdx = blockIdx.x;
	int miniBatchIdx = threadIdx.x;
	int miniBatchIdxNums = blockDim.x;
	int z;
	float mean, var2;
	float del2Tmp = 0;
	float del3Tmp = 0;

	//平均値を取得
	mean = getDMlpBnMean(outputIdx, mlpLayer);
	//分散を取得
	var2 = getDMlpBnVar2(outputIdx, mlpLayer);
	//printf("mean[%d]:%f\n", outputIdx , mean);
	//printf("var2[%d]:%f\n", outputIdx , var2);

	//シェアードメモリにmlpBnTmpを代入する。
	extern __shared__ float sMlpBnTmp[];
	sMlpBnTmp[miniBatchIdx] = (getDMlpWb(outputIdx, miniBatchIdx, mlpLayer) - mean) * powf((var2 + bnEps), -0.5f);
	__syncthreads();

	//mlpWb更新要素の計算
	for(z = 0; z < miniBatchIdxNums; z++){
		//del2Tmp += getDMlpBnBack(outputIdx, z, mlpLayer) * sMlpBnTmp[getDim2Idx(outputIdx, z, outputIdxNums)];
		del2Tmp += getDMlpBnBack(outputIdx, z, mlpLayer) * sMlpBnTmp[z];
		/*
		if(outputIdx == 1){
			printf("mlpBnBack(%d,%d):%f\n", outputIdx, z, getDMlpBnBack(outputIdx, z, mlpLayer));
			printf("mlpWb(%d,%d):%f\n", outputIdx, z, getDMlpWb(outputIdx, z, mlpLayer));
			printf("sMLp(%d,%d):%f\n", outputIdx, z, sMlpBnTmp[z]);
			printf("mean[%d]:%f\n", outputIdx , mean);
			printf("var2[%d]:%f\n", outputIdx , var2);
		}
		*/
		del3Tmp += getDMlpBnBack(outputIdx, z, mlpLayer);
	}
	float del1 = miniBatchIdxNums * getDMlpBnBack(outputIdx, miniBatchIdx, mlpLayer);
	float del2 = del2Tmp * sMlpBnTmp[miniBatchIdx];
	float del3 = del3Tmp;
	//float subtractDel = floatSubtraction(floatSubtraction(del1, del2), del3);
	float subtractDel = del1 - del2 - del3;

	/*
	if(outputIdx == 1){
		printf("del1(%d,%d):%f\n", outputIdx, miniBatchIdx, del1);
		printf("del2(%d,%d):%f\n", outputIdx, miniBatchIdx, del2);
		printf("del3(%d,%d):%f\n", outputIdx, miniBatchIdx, del3);
	}
	*/

	dMlpWbBack[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)] =\
		subtractDel * getDMlpBnGamma(outputIdx, mlpLayer) * powf((var2 + bnEps), -0.5f) / miniBatchIdxNums;
//	if(miniBatchIdx == 2){
//		printf("subtractDel(%d,%d):%f\n", outputIdx, miniBatchIdx, subtractDel);
	//	printf("mlpWbBack(%d,%d):%f\n", outputIdx, miniBatchIdx, dMlpWbBack[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)]);
//	}
}

__global__ void
kernelBackMlpMultiplyUpdate(const int mlpLayer, const int miniBatchIdxNums, const float bnEps){

	int outputIdx = blockIdx.x;
	int z;
	float mean, var2, bnTmp;
	float sumGamma = 0, sumBeta = 0;

	//平均値を取得
	mean = getDMlpBnMean(outputIdx, mlpLayer);
	//分散を取得
	var2 = getDMlpBnVar2(outputIdx, mlpLayer);

	//更新値を計算
	for(z = 0; z < miniBatchIdxNums; z++){
		/*
		if(z == 0){
			printf("mlpBackMean[%d][%d]:%f\n", outputIdx , mlpLayer, mean);
			printf("mlpBackVar2[%d][%d]:%f\n", outputIdx , mlpLayer, var2);
		}
		*/
//		printf("mlpBnBack(%d,%d):%f  ", outputIdx, z, getDMlpBnBack(outputIdx, z, mlpLayer));
//		printf("mlpWb(%d,%d):%f  ", outputIdx, z, getDMlpWb(outputIdx, z, mlpLayer));
		bnTmp = (getDMlpWb(outputIdx, z, mlpLayer) - mean) / powf((var2 + bnEps), 0.5f);
		sumGamma += getDMlpBnBack(outputIdx, z, mlpLayer) * bnTmp;
		sumBeta += getDMlpBnBack(outputIdx, z, mlpLayer);
	}
	//更新
	dMlpBnGamma[getDMlpBnMeanVar2Idx(outputIdx, mlpLayer)] -= sumGamma * getCLearningRate();
	dMlpBnBeta[getDMlpBnMeanVar2Idx(outputIdx, mlpLayer)] -= sumBeta * getCLearningRate();
	//if(outputIdx == 1){
//		printf("mlpgamma(%d):%f  ", outputIdx, dMlpBnGamma[getDMlpBnMeanVar2Idx(outputIdx, mlpLayer)]);
//		printf("mlpbeta(%d):%f  ", outputIdx, dMlpBnBeta[getDMlpBnMeanVar2Idx(outputIdx, mlpLayer)]);
//	}
}
