#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <constraint.cuh>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh> 
#include <cudaCheck.cuh>

__global__ void kernelMlpBatchNormalizationTraining(int mlpLayer, float bnEps);
__global__ void kernelMlpBatchNormalizationOnline(int mlpLayer, float bnEps);

void mlpBatchNormalization(const int mlpLayer){

//	puts("mlpBatchNormalization start.");
//	struct timeval t1, t2, t3;
//	gettimeofday(&t1, NULL);

	//ブロック・スレッド定義
	dim3 grid(getMlpOutputNums(mlpLayer), getMiniBatchNums());
	dim3 block(1, 1, 1);

	//次元チェック
	checkGridSize(grid);
	checkThreadSize(block);

//	gettimeofday(&t2, NULL);
	//カーネル起動
//	puts("kernelMlpBatchNormalization start");
	cudaDeviceSynchronize();
	if(getExecFlg() == getExecFlgTraining()){
		kernelMlpBatchNormalizationTraining<<<grid, block>>>(mlpLayer, getBnEps());
	}
	else{
		kernelMlpBatchNormalizationOnline<<<grid, block>>>(mlpLayer, getBnEps());
	}
//	puts("kernelMlpBatchNormalization end");
//	gettimeofday(&t3, NULL);

//	puts("mlpBatchNormalization end.");
//	printTime(t1,t2,t3);

}

__global__ void kernelMlpBatchNormalizationTraining(int mlpLayer, float bnEps){
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;
	int miniBatchIdxNums = gridDim.y;
	int z;
	float sumMean = 0, sumVar2 = 0;
	float tmp, mean, var2, bnTmp;

	//平均を算出
	for(z = 0; z < miniBatchIdxNums; z++){
		tmp = getDMlpWb(outputIdx, z, mlpLayer);
		/*
		if(outputIdx == 2 &&miniBatchIdx == 1){
			//printf("tmp:%f\n", tmp);
			printf("dMlpWb(%d,%d,%d)(%d) = %f\n", outputIdx, z, mlpLayer, getDMlpWbaIdx(outputIdx, z, mlpLayer),getDMlpWb(outputIdx, z, mlpLayer));
		}
		*/
		sumMean = tmp + sumMean;
	}
	mean = sumMean / (miniBatchIdxNums);

	//分散を算出
	for(z = 0; z < miniBatchIdxNums; z++){
		tmp = getDMlpWb(outputIdx, z, mlpLayer);
		sumVar2 += powf(floatSubtraction(tmp, mean, mlpLayer, __func__), 2);
	}
	var2 = sumVar2 / miniBatchIdxNums;
		
	/*
	if(miniBatchIdx == 0){
//		printf("mean:%f",mean);
		printf("var2:%f",var2);
	}
	*/
	dMlpBnMean[getDMlpBnMeanVar2Idx(outputIdx, mlpLayer)] = mean;
	dMlpBnVar2[getDMlpBnMeanVar2Idx(outputIdx, mlpLayer)] = var2;
	/*
	if(miniBatchIdx == 1){
//		printf("mlpPropMean[%d][%d]:%f\n", outputIdx , mlpLayer, mean);
//		printf("mlpPropVar2[%d][%d]:%f\n", outputIdx , mlpLayer, var2);
		printf("bnGamma(%d,%d,%d) = %f\n",outputIdx, miniBatchIdx, mlpLayer, getDMlpBnGamma(outputIdx, mlpLayer));
		printf("bnBeta(%d,%d,%d) = %f\n",outputIdx, miniBatchIdx, mlpLayer, getDMlpBnBeta(outputIdx, mlpLayer));
	}
	*/

	bnTmp = (getDMlpWb(outputIdx, miniBatchIdx, mlpLayer) - mean) / powf((var2 + bnEps), 0.5f);

	//mlpBn更新
	dMlpBn[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)] = bnTmp * getDMlpBnGamma(outputIdx, mlpLayer) + getDMlpBnBeta(outputIdx, mlpLayer);
	/*
	if(true){
		printf("bnTmp(%d,%d,%d) = %f\n",outputIdx, miniBatchIdx, mlpLayer, bnTmp);
		printf("powf(%d,%d,%d) = %f\n",outputIdx, miniBatchIdx, mlpLayer, powf((var2 + bnEps), 0.5f));
		printf("var2'(%d,%d,%d) = %f\n",outputIdx, miniBatchIdx, mlpLayer, sumVar2 / (miniBatchIdxNums));
		printf("mean2'(%d,%d,%d) = %f\n",outputIdx, miniBatchIdx, mlpLayer, (mean * mean));
		printf("bnGamma(%d,%d,%d) = %f\n",outputIdx, miniBatchIdx, mlpLayer, getDMlpBnGamma(outputIdx, mlpLayer));
		printf("bnBeta(%d,%d,%d) = %f\n",outputIdx, miniBatchIdx, mlpLayer, getDMlpBnBeta(outputIdx, mlpLayer));
	}
	if(miniBatchIdx == 0){
		printf("mlpBn(%d,%d,%d) = %f\n",outputIdx, miniBatchIdx, mlpLayer, dMlpBn[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)]);
	}
	*/
}
__global__ void kernelMlpBatchNormalizationOnline(int mlpLayer, float bnEps){
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;
	float mean, var2, bnTmp;

	mean = getCMlpBnAveMean(outputIdx, mlpLayer);
	var2 = getCMlpBnAveVar2(outputIdx, mlpLayer);
	/*
	if(miniBatchIdx == 0){
		printf("mlpmean(%d):%f\n",outputIdx,mean);
		printf("mlpvar2(%d):%f\n",outputIdx, var2);
	}
	*/

	bnTmp = (getDMlpWb(outputIdx, miniBatchIdx, mlpLayer) - mean) / powf((var2 + bnEps), 0.5f);
	if(powf((var2 + bnEps), 0.5f) <=0 ){
		printf("mlpkoko:%f\n", powf((var2 + bnEps), 0.5f));
	}

	//mlpBn更新
	dMlpBn[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)] = bnTmp * getDMlpBnGamma(outputIdx, mlpLayer) + getDMlpBnBeta(outputIdx, mlpLayer);
	/*
	if(miniBatchIdx == 0){
		printf("mlpBn(%d,%d,%d) = %f\n",outputIdx, miniBatchIdx, mlpLayer, dMlpBn[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)]);
	}
	*/
}
