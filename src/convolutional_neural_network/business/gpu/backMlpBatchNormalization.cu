#include <stdio.h>
#include <math.h>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh>
#include <commonFunc.cuh>

extern __global__ void kernelBackMlpBatchNormalization(const int mlpLayer);
extern __device__ float reluDelA_bn(const int outputIdx, const int miniBatchIdx, const int mlpLayer);

void backMlpBatchNormalization(const int mlpLayer){

//	puts("backMlpBatchNormalization start.");
//	struct timeval t1, t2, t3;
//	gettimeofday(&t1, NULL);

	//カーネルの次元設定
	dim3 grid(getMlpOutputNums(mlpLayer), getMiniBatchNums()); //miniBatch毎の1ニューロンの出力を1ブロックとする。
	dim3 block(1, 1, 1); // 1ブロック1スレッド

	//次元チェック
	checkGridSize(grid);
	checkThreadSize(block);

//	gettimeofday(&t2, NULL);
//	puts("kernelBackMlpBatchNormalization start.");
	cudaDeviceSynchronize();
	kernelBackMlpBatchNormalization<<<grid, block>>>(mlpLayer);
//	puts("kernelBackMlpBatchNormalization end.");
//	gettimeofday(&t3, NULL);

//	puts("backMlpBatchNormalization end.");
//	printTime(t1,t2,t3);

}

__global__ void
kernelBackMlpBatchNormalization(const int mlpLayer){
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;

	dMlpBnBack[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)]\
		= getDMlpABack(outputIdx, miniBatchIdx, mlpLayer) * reluDelA_bn(outputIdx, miniBatchIdx, mlpLayer);
	/*
	if(miniBatchIdx == 2){
		printf("mlpABack(%d,%d,%d):%f\n", outputIdx, miniBatchIdx, mlpLayer, getDMlpABack(outputIdx, miniBatchIdx, mlpLayer));
		printf("mlpBn(%d,%d,%d):%f\n", outputIdx, miniBatchIdx, mlpLayer, getDMlpBn(outputIdx, miniBatchIdx, mlpLayer));
		printf("mlpBnBack(%d,%d,%d):%f\n", outputIdx, miniBatchIdx, mlpLayer, dMlpBnBack[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)]);
	}
	*/
}

__device__ float
reluDelA_bn(const int outputIdx, const int miniBatchIdx, const int mlpLayer){
	float val;
	val = (0 < getDMlpBn(outputIdx, miniBatchIdx, mlpLayer));
	return(val);
}
