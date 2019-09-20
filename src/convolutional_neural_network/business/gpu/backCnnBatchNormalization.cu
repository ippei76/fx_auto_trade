#include <stdio.h>
#include <math.h>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh>
#include <commonFunc.cuh>

extern __device__ float reluDelA_bn(const int wba_x, const int wba_y, const int outputIdx, const int miniBatchIdx, const int cnnLayer);
extern __global__ void kernelBackCnnBatchNormalization(const int cnnLayer);

void backCnnBatchNormalization(const int cnnLayer){

//	puts("backCnnBatchNormalization start.");
//	struct timeval t1, t2, t3;
//	gettimeofday(&t1, NULL);

	//カーネルの次元設定
	dim3 grid(getCnnOutputNums(cnnLayer), getMiniBatchNums()); //miniBatch毎の1ニューロンの出力を1ブロックとする。
	dim3 block(getCnnWba_xNums(cnnLayer), getCnnWba_yNums(cnnLayer), 1);

	//次元チェック
	checkGridSize(grid);
	checkThreadSize(block);

//	gettimeofday(&t2, NULL);
//	puts("kernelBackCnnBatchNormalization start.");
	cudaDeviceSynchronize();
	kernelBackCnnBatchNormalization<<<grid, block>>>(cnnLayer);
//	puts("kernelBackCnnBatchNormalization end.");
//	gettimeofday(&t3, NULL);

//	puts("backCnnBatchNormalization end.");

}

__global__ void
kernelBackCnnBatchNormalization(const int cnnLayer){
	int wba_x = threadIdx.x;
	int wba_y = threadIdx.y;
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;

	dCnnBnBack[getDCnnWbaIdx(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer)]\
		= getDCnnABack(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer)\
		* reluDelA_bn(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer);
	/*
	if(miniBatchIdx == 1){
		printf("cnnABack(%d,%d,%d,%d,%d):%f\n", wba_x,wba_y,outputIdx, miniBatchIdx, cnnLayer, getDCnnABack(wba_x,wba_y,outputIdx, miniBatchIdx, cnnLayer));
		printf("cnnBn(%d,%d,%d,%d,%d):%f\n", wba_x,wba_y,outputIdx, miniBatchIdx, cnnLayer, getDCnnBn(wba_x,wba_y,outputIdx, miniBatchIdx, cnnLayer));
		printf("cnnBnBack(%d,%d,%d,%d,%d):%f\n", wba_x,wba_y,outputIdx, miniBatchIdx, cnnLayer, dCnnBnBack[getDCnnWbaIdx(wba_x,wba_y,outputIdx, miniBatchIdx, cnnLayer)]);
	}
	*/
}

__device__ float
reluDelA_bn(const int wba_x, const int wba_y, const int outputIdx, const int miniBatchIdx, const int cnnLayer){
	float val;
	val = (0 < getDCnnBn(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer));
	return(val);
}
