#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <constraint.cuh>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh> 
#include <cudaCheck.cuh>

extern __global__ void kernelMultiplyCnnP();
extern __global__ void kernelMultiplyMlpA(const int mlpLayer);

void mlpMultiply(const int mlpLayer){

//	printf("multiply start.\n");
//	struct timeval t1, t2, t3;
//	gettimeofday(&t1, NULL);

	//ブロック・スレッド定義
	//各miniBatchのwbノード毎にブロックを定義
	//wbノードの1要素毎にスレッドを定義
	//シェアードメモリにwを割り当てる
	dim3 grid(getMlpOutputNums(mlpLayer), getMiniBatchNums()); //miniBatch毎の1ニューロンの出力を1ブロックとする。
	dim3 block(1, 1, 1); // 1ブロック1スレッド

	//次元チェック
	checkGridSize(grid);
	checkThreadSize(block);

//	gettimeofday(&t2, NULL);
	//カーネル起動
//	puts("kernelMultiply start");
	cudaDeviceSynchronize();
	if(mlpLayer == 0){
		kernelMultiplyCnnP<<<grid, block>>>();
	}
	else{
		kernelMultiplyMlpA<<<grid, block>>>(mlpLayer);
	}
//	puts("kernelMultiply end");
//	gettimeofday(&t3, NULL);

//	puts("multiply end.");
//	printTime(t1,t2,t3);

}

__global__ void kernelMultiplyCnnP(){
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;
	int cnnLastLayerIdx = getCCnnOutputNumsNums() - 1;
	int x, y, inputIdx;
	int xNums = getCCnnP_xNums(cnnLastLayerIdx);
	int yNums = getCCnnP_yNums(cnnLastLayerIdx);
	int inputChannelNums = getCCnnOutputNums(cnnLastLayerIdx);
	int mlpLayerIsZero = 0;
	float sum = 0;

	//掛け合わせ処理
	for(inputIdx = 0; inputIdx < inputChannelNums; inputIdx++){
		for(y = 0; y < yNums; y++){
			for(x = 0; x < xNums; x++){
				sum += getDCnnP(x, y, inputIdx, miniBatchIdx, cnnLastLayerIdx)\
				       * getDMlpW(getDim3Idx(x, y, inputIdx, xNums, yNums), outputIdx, mlpLayerIsZero);
				/*
				if(miniBatchIdx == 1){
					printf("cnnP(%d,%d,%d):%f\n",x,y,inputIdx,getDCnnP(x, y, inputIdx, miniBatchIdx, cnnLastLayerIdx));
					printf("mlpW(%d,%d,%d):%f\n",x,y,inputIdx,getDMlpW(getDim3Idx(x, y, inputIdx, xNums, yNums), outputIdx, mlpLayerIsZero));
				}
				*/
			}
		}
	}

	//wb更新
	dMlpWb[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayerIsZero)] = sum;
	/*
	if(outputIdx == 1){
		printf("cnnpwb(%d,%d,%d) = %f\n",outputIdx, miniBatchIdx, mlpLayerIsZero, sum);
	}
	*/
}
__global__ void kernelMultiplyMlpA(const int mlpLayer){
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;
	int inputIdx;
	int inputChannelNums = getCMlpOutputNums(mlpLayer - 1);
	float sum = 0;

	//掛け合わせ処理
	for(inputIdx = 0; inputIdx < inputChannelNums; inputIdx++){
		sum += getDMlpA(inputIdx, miniBatchIdx, mlpLayer - 1)\
		       * getDMlpW(inputIdx, outputIdx, mlpLayer);
		/*
		if(miniBatchIdx == 1){
			printf("mlpA(%d):%f\n",inputIdx,getDMlpA(inputIdx, miniBatchIdx, mlpLayer - 1));
			printf("mlpW(%d):%f\n",inputIdx,getDMlpW(inputIdx, outputIdx, mlpLayer));
		}
		*/
	}

	//wb更新
	dMlpWb[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)] = sum;
	/*
	if(outputIdx == 1){
		printf("cnnmlpAwb(%d,%d,%d) = %f\n",outputIdx, miniBatchIdx, mlpLayer, sum);
	}
	*/
}
