#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <constraint.cuh>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh> 
#include <cudaCheck.cuh>

extern __global__ void kernelCnnBatchNormalizationTraining(int cnnLayer, float bnEps);
extern __global__ void kernelCnnBatchNormalizationOnline(int cnnLayer, float bnEps);

void cnnBatchNormalization(const int cnnLayer){

//	puts("cnnBatchNormalization start.");
	//struct timeval t1, t2, t3;

	//ブロック・スレッド定義
	dim3 grid(getCnnOutputNums(cnnLayer), getMiniBatchNums());
	dim3 block(getCnnWba_xNums(cnnLayer), getCnnWba_yNums(cnnLayer), 1);

	//次元チェック
	checkGridSize(grid);
	checkThreadSize(block);

	//カーネル起動
//	puts("kernelCnnBatchNormalization start");
	if(getExecFlg() == getExecFlgTraining()){
	//	gettimeofday(&t1, NULL);
	//	gettimeofday(&t2, NULL);
		cnnBatchNormalization_culcurationAveVar2(cnnLayer);
		cudaDeviceSynchronize();
		kernelCnnBatchNormalizationTraining<<<grid, block>>>(cnnLayer, getBnEps());
	//	gettimeofday(&t3, NULL);
	}
	else{
//		puts("online batchNormalization");
		cudaDeviceSynchronize();
		kernelCnnBatchNormalizationOnline<<<grid, block>>>(cnnLayer, getBnEps());
	}
//	puts("kernelCnnBatchNormalization end");

//	puts("cnnBatchNormalization end.");
//	printTime(t1,t2,t3);

}

__global__ void kernelCnnBatchNormalizationTraining(int cnnLayer, float bnEps){
	int wba_x = threadIdx.x;
	int wba_y = threadIdx.y;
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;
	float mean, var2, bnTmp;

	//	printf("aaOK");
	mean = dCnnBnMean[getDCnnBnMeanVar2Idx(outputIdx, cnnLayer)];
	var2 = dCnnBnVar2[getDCnnBnMeanVar2Idx(outputIdx, cnnLayer)];
	/*
	if(miniBatchIdx == 0 && wba_x == 0 && wba_y == 0){
//		printf("mean:%f",mean);
		printf("var2:%f",var2);
	}
	*/
	/*
	//平均を算出：miniBatch * wba_yNums * wba_xNums
	int x,y,z;
	float testmean,testvar2,tmp;
	float sumMean = 0;
	float sumVar2 = 0;
	int wba_xNums = blockDim.x;
	int wba_yNums = blockDim.y;
	int miniBatchIdxNums = gridDim.y;
	for(z = 0; z < miniBatchIdxNums; z++){
		for(y = 0; y < wba_yNums; y++){
			for(x = 0; x < wba_xNums; x++){
				tmp = getDCnnWb(x, y, outputIdx, z, cnnLayer);
				sumMean = tmp + sumMean;
			}
		}
	}
	testmean = sumMean / (miniBatchIdxNums * wba_yNums * wba_xNums);

	//分散を算出
	for(z = 0; z < miniBatchIdxNums; z++){
		for(y = 0; y < wba_yNums; y++){
			for(x = 0; x < wba_xNums; x++){
				tmp = getDCnnWb(x, y, outputIdx, z, cnnLayer);
				sumVar2 = powf(floatSubtraction(tmp, mean), 2) + sumVar2;
			}
		}
	}
	testvar2 = sumVar2 / (miniBatchIdxNums * wba_yNums * wba_xNums);
	printf("%d:mean:%f(%f)\n",cnnLayer,mean,testmean);
	printf("%d:var2:%f(%f)\n",cnnLayer,var2,testvar2);
	*/

	bnTmp = (getDCnnWb(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer) - mean) / powf((var2 + bnEps), 0.5f);
	if(powf((var2 + bnEps), 0.5f) <=0 ){
		printf("cnnkoko:%f\n", powf((var2 + bnEps), 0.5f));
	}

	//cnnBn更新
	dCnnBn[getDCnnWbaIdx(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer)] = bnTmp * getDCnnBnGamma(outputIdx, cnnLayer) + getDCnnBnBeta(outputIdx, cnnLayer);
	/*
	if(outputIdx == 1){
		printf("cnnmean[%d]:%f\n", outputIdx , mean);
		printf("cnnvar2[%d]:%f\n", outputIdx , var2);
		printf("cnnbntmp(%d,%d,%d,%d,%d) = %f\n",wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer, bnTmp);
		printf("cnnbn(%d,%d,%d,%d,%d) = %f\n",wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer, dCnnBn[getDCnnWbaIdx(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer)]);
	}
	*/
}

__global__ void kernelCnnBatchNormalizationOnline(int cnnLayer, float bnEps){
	int wba_x = threadIdx.x;
	int wba_y = threadIdx.y;
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;
	float mean, var2, bnTmp;

	mean = getCCnnBnAveMean(outputIdx, cnnLayer);
	var2 = getCCnnBnAveVar2(outputIdx, cnnLayer);
	/*
	if(miniBatchIdx == 0 && wba_x == 0 && wba_y == 0){
		printf("cnnPropMean(%d)(%d):%f\n",outputIdx,cnnLayer,mean);
		printf("cnnPropVar2(%d)(%d):%f\n",outputIdx,cnnLayer, var2);
	}
	*/

	bnTmp = (getDCnnWb(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer) - mean) / powf((var2 + bnEps), 0.5f);

	//cnnBn更新
	dCnnBn[getDCnnWbaIdx(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer)] = bnTmp * getDCnnBnGamma(outputIdx, cnnLayer) + getDCnnBnBeta(outputIdx, cnnLayer);
//	if(outputIdx == 1){
	//	printf("cnnmean[%d]:%f\n", outputIdx , mean);
	//	printf("cnnvar2[%d]:%f\n", outputIdx , var2);
	//	printf("cnnbntmp(%d,%d,%d,%d,%d) = %f  bnGamma() = %f  bnBeta() = %f bn = %f\n",wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer, bnTmp, getDCnnBnGamma(outputIdx, cnnLayer), getDCnnBnBeta(outputIdx, cnnLayer), dCnnBn[getDCnnWbaIdx(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer)]);
//	}
}
