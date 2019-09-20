#include <stdio.h>
#include <math.h>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh>


extern __global__ void kernelLossFunc(int mlpOutputNumsLastIdx);

void lossFunc(const int mlpOutputNumsLastIdx){

//	puts("lossFunc start.");
//	struct timeval t1, t2, t3;
//	gettimeofday(&t1, NULL);

	//ブロック・スレッド定義
	dim3 grid(getMlpOutputNums(mlpOutputNumsLastIdx), getMiniBatchNums());
	dim3 block(1, 1, 1);

	//次元チェック
	checkGridSize(grid);
	checkThreadSize(block);

//	gettimeofday(&t2, NULL);
	//カーネル起動
//	puts("kernelLossFunc start");
	cudaDeviceSynchronize();
	kernelLossFunc<<<grid, block>>>(mlpOutputNumsLastIdx);

//	puts("kernelLossFunc end");
//	gettimeofday(&t3, NULL);

//	puts("lossFunc end.");
//	printTime(t1,t2,t3);

}

__global__ void kernelLossFunc(int mlpOutputNumsLastIdx){
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;

	dMlpBnBack[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpOutputNumsLastIdx)] = getDMlpA(outputIdx, miniBatchIdx, mlpOutputNumsLastIdx) - getDTeachOut(outputIdx, miniBatchIdx);
	/*
	if(miniBatchIdx == miniBatchIdx){
		printf("mlpBnBack(%d,%d,%d) = %f\n",outputIdx, miniBatchIdx, mlpOutputNumsLastIdx, dMlpBnBack[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpOutputNumsLastIdx)]);
	}
	*/
}
