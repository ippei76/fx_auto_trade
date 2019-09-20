#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <constraint.cuh>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh> 
#include <cudaCheck.cuh>
#include <sys/time.h>
#include <commonFunc.cuh>


extern __global__ void kernelDynamicAllocateDeviceMemory(float *d_cnnW, float *d_mlpW);

void dynamicAllocateDeviceMemory(float *cnnW, const int cnnWDataNums, float *mlpW, const int mlpWDataNums){

	puts("dynamicAllocateDeviceMemory start.");
	struct timeval t1, t2, t3;
	gettimeofday(&t1, NULL);

	float *d_cnnW;
	float *d_mlpW;

	//サイズ算出
	int cnnWDataSize =  cnnWDataNums * sizeof(float)
	int mlpWDataSize =  mlpWDataNums * sizeof(float)

	//deviceメモリ確保
	gpuErrchk(cudaMalloc((void**)&d_cnnW, cnnWDataSize));
	gpuErrchk(cudaMalloc((void**)&d_mlpW, mlpWDataSize));

	//メモリコピー
	gpuErrchk(cudaMemcpy(d_cnnW, cnnW, cnnWDataSize, cudaMemcpyHostToDevice));
	gpuErrchk(cudaMemcpy(d_mlpW, mlpW, mlpWDataSize, cudaMemcpyHostToDevice));

	//ブロック・スレッド定義
	//各miniBatchのwbノード毎にブロックを定義
	//wbノードの1要素毎にスレッドを定義
	//シェアードメモリにwを割り当てる
	dim3 grid(1, 1);
	dim3 block(1, 1, 1);

	//次元チェック
	checkGridSize(grid);
	checkThreadSize(block);

	gettimeofday(&t2, NULL);
	//カーネル起動
	puts("kernelDynamicAllocateDeviceMemory start");
	kernelDynamicAllocateDeviceMemory<<<grid, block>>>(d_cnnW, d_mlpW);
	cudaDeviceSynchronize();
	puts("kernelDynamicAllocateDeviceMemory end");
	gettimeofday(&t3, NULL);

	//メモリの解放は最後に実施

	puts("dynamicAllocateDeviceMemory end.");
	printTime(t1,t2,t3);
}

__global__ void kernelDynamicAllocateDeviceMemory(float *d_cnnW, float *d_mlpW){
	dCnnW = d_cnnW;
	dMlpW = d_mlpW;
}
