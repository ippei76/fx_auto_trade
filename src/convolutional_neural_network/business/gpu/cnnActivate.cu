#include <stdio.h>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh>

extern __global__ void kernelCnnActivate(const int cnnLayer);
extern __device__ float relu(const int wba_x, const int wba_y, const int outputIdx, const int miniBatchIdx, const int cnnLayer);

void cnnActivate(const int cnnLayer){

//	puts("cnnActivate start.");
//	struct timeval t1, t2, t3;
//	gettimeofday(&t1, NULL);

	//カーネルの次元設定
	dim3 grid(getCnnOutputNums(cnnLayer), getMiniBatchNums());
	dim3 block(getCnnWba_xNums(cnnLayer), getCnnWba_yNums(cnnLayer), 1);

	//次元チェック
	checkGridSize(grid);
	checkThreadSize(block);

//	gettimeofday(&t2, NULL);
//	puts("kernelCnnActivate start.");
	cudaDeviceSynchronize();
	//カーネル処理実行
	kernelCnnActivate<<<grid, block>>>(cnnLayer);
//	puts("kernelCnnActivate end.");
//	gettimeofday(&t3, NULL);

//	puts("cnnActivate end.");
//	printTime(t1,t2,t3);

}

__global__ void
kernelCnnActivate(const int cnnLayer){
	int wba_x = threadIdx.x;
	int wba_y = threadIdx.y;
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;

	dCnnA[getDCnnWbaIdx(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer)] = relu(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer);
	//if(wba_x==17 && wba_y==16 &&outputIdx == 1 &&miniBatchIdx == 2){
	//if(outputIdx == 1){
		//printf("cnnBn(%d,%d,%d,%d,%d) = %f  cnnA() = %f\n",wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer, getDCnnBn(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer), dCnnA[getDCnnWbaIdx(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer)]);
	//}
}

__device__ float
relu(const int wba_x, const int wba_y, const int outputIdx, const int miniBatchIdx, const int cnnLayer){
	float val;
	val = getDCnnBn(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer) *\
	      (0 < getDCnnBn(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer));
	
	return(val);
}
