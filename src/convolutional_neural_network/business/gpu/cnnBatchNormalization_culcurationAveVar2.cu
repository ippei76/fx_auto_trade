#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <constraint.cuh>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh> 
#include <cudaCheck.cuh>

extern __global__ void kernelCnnCulcu1(const int cnnLayer, const int meanVar2Flg);
extern __global__ void kernelCnnCulcu2(const int cnnLayer, const int meanVar2Flg);

void cnnBatchNormalization_culcurationAveVar2(const int cnnLayer){

	//MEAN
	int meanFlg = 0;
	//Culcu1###############################################################################################
	//ブロック・スレッド定義
	dim3 gridCulcu1(getCnnOutputNums(cnnLayer), getMiniBatchNums());
	dim3 blockCulcu1(getCnnWba_xNums(cnnLayer), getCnnWba_yNums(cnnLayer), 1);

	//次元チェック
	checkGridSize(gridCulcu1);
	checkThreadSize(blockCulcu1);

	//シェアードメモリ確保
	int sharedSizeCnnWba_xyNums;
	sharedSizeCnnWba_xyNums = sizeof(float) * getCnnWba_xNums(cnnLayer) * getCnnWba_yNums(cnnLayer); 

	//シェアードメモリチェック
	checkSharedMemorySize(sharedSizeCnnWba_xyNums);

	kernelCnnCulcu1<<<gridCulcu1, blockCulcu1, sharedSizeCnnWba_xyNums>>>(cnnLayer, meanFlg);
	cudaDeviceSynchronize();
	//#####################################################################################################

	//Culcu2###############################################################################################
	//ブロック・スレッド定義
	dim3 gridCulcu2(getCnnOutputNums(cnnLayer), 1);
	dim3 blockCulcu2(getMiniBatchNums(), 1, 1);

	//次元チェック
	checkGridSize(gridCulcu2);
	checkThreadSize(blockCulcu2);

	//シェアードメモリ確保
	int sharedSizeMiniBatchNums;
	sharedSizeMiniBatchNums = sizeof(float) * getMiniBatchNums(); 

	//シェアードメモリチェック
	checkSharedMemorySize(sharedSizeMiniBatchNums);

	cudaDeviceSynchronize();
	kernelCnnCulcu2<<<gridCulcu2, blockCulcu2, sharedSizeMiniBatchNums>>>(cnnLayer, meanFlg);
	//#####################################################################################################

	//VAR2
	int var2Flg = 1;
	//Culcu1###############################################################################################
	kernelCnnCulcu1<<<gridCulcu1, blockCulcu1, sharedSizeCnnWba_xyNums>>>(cnnLayer, var2Flg);
	cudaDeviceSynchronize();
	//#####################################################################################################
	//Culcu2###############################################################################################
	cudaDeviceSynchronize();
	kernelCnnCulcu2<<<gridCulcu2, blockCulcu2, sharedSizeMiniBatchNums>>>(cnnLayer, var2Flg);
	//#####################################################################################################
}

//本来kernelでの分岐はふさわしくないが、ワープ内の全てのレーンで同じ処理を実施するため、速度低下は発生しないはず。
//http://news.mynavi.jp/series/kepler_gpu/002/

__global__ void kernelCnnCulcu1(const int cnnLayer, const int meanVar2Flg){
	int wba_x = threadIdx.x;
	int wba_y = threadIdx.y;
	int miniBatchIdx = blockIdx.y;
	int outputIdx = blockIdx.x;
	int outputNums = gridDim.x;

	int threadIdxNo = getDim3Idx(threadIdx.x, threadIdx.y, threadIdx.z, blockDim.x, blockDim.y);
	int threadNums = blockDim.x * blockDim.y * blockDim.z;
	int culcu1BlockIdxNo = getDim2Idx(outputIdx, miniBatchIdx, outputNums);

	/*
	if(blockIdx.x == 0 && blockIdx.y == 0){
		printf("dCnnWb(%d,%d,%d,%d,%d)(%d) = %f  ",wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer, getDCnnWbaIdx(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer),getDCnnWb(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer));
	}
	*/
	//cnnWbをshared memoryにコピー
	extern __shared__ float sCnnWb[];
	if(meanVar2Flg == 0){
		//MEAN
		sCnnWb[threadIdxNo] = getDCnnWb(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer);
	}
	else{
		//VAR2
		sCnnWb[threadIdxNo] = powf(floatSubtraction(getDCnnWb(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer), dCnnBnMean[getDCnnBnMeanVar2Idx(outputIdx, cnnLayer)], cnnLayer, __func__), 2);
	}
	__threadfence_block();
	dCnnBnAverage_culcu1[culcu1BlockIdxNo] = culcurateSum(sCnnWb, threadIdxNo) / threadNums;
}

__global__ void kernelCnnCulcu2(const int cnnLayer, const int meanVar2Flg){
	int miniBatchIdx = threadIdx.x;
	int outputIdx = blockIdx.x;
	int outputNums = gridDim.x;

	int threadIdxNo = getDim3Idx(threadIdx.x, threadIdx.y, threadIdx.z, blockDim.x, blockDim.y);
	int threadNums = blockDim.x * blockDim.y * blockDim.z;
	int culcu1BlockIdxNo = getDim2Idx(outputIdx, miniBatchIdx, outputNums);

	//cnnWbをshared memoryにコピー
	extern __shared__ float sCnnBnAverage_culcu1[];
	//culcu1の結果を取得
	sCnnBnAverage_culcu1[miniBatchIdx] = dCnnBnAverage_culcu1[culcu1BlockIdxNo];
	__threadfence_block();
	if(meanVar2Flg == 0){
		dCnnBnMean[getDCnnBnMeanVar2Idx(outputIdx, cnnLayer)] = culcurateSum(sCnnBnAverage_culcu1, threadIdxNo) / threadNums;
	}
	else{
		dCnnBnVar2[getDCnnBnMeanVar2Idx(outputIdx, cnnLayer)] = culcurateSum(sCnnBnAverage_culcu1, threadIdxNo) / threadNums;
	}

	/*
	if(blockIdx.x == 0 && blockIdx.y == 0){
		printf("culcu1 = %f  ", sCnnBnAverage_culcu1[miniBatchIdx]);
		printf("ave = %f  ", dCnnBnMean[getDCnnBnMeanVar2Idx(outputIdx, cnnLayer)]);
	}
	*/
}
