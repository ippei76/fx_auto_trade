#include <stdio.h>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh>

extern __global__ void kernelCnnPooling(const int cnnLayer);
extern __device__ void maxPooling(const int p_x, const int p_y, const int outputIdx, const int miniBatchIdx, const int cnnLayer);

void cnnPooling(const int cnnLayer){

//	puts("cnnPooling start.");
//	struct timeval t1, t2, t3;
//	gettimeofday(&t1, NULL);

	//カーネルの次元設定
	dim3 grid(getCnnOutputNums(cnnLayer), getMiniBatchNums());
	dim3 block(getCnnP_xNums(cnnLayer), getCnnP_yNums(cnnLayer), 1);

	//次元チェック
	checkGridSize(grid);
	checkThreadSize(block);

//	puts("kernelCnnPooling start.");
//	gettimeofday(&t2, NULL);
	//カーネル処理実行
	cudaDeviceSynchronize();
	kernelCnnPooling<<<grid, block>>>(cnnLayer);
//	puts("kernelCnnPooling end.");
//	gettimeofday(&t3, NULL);

//	puts("cnnPooling end.");
//	printTime(t1,t2,t3);
}

__global__ void
kernelCnnPooling(const int cnnLayer){
	int p_x = threadIdx.x;
	int p_y = threadIdx.y;
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;

	maxPooling(p_x, p_y, outputIdx, miniBatchIdx, cnnLayer);
}

__device__ void
maxPooling(const int p_x, const int p_y, const int outputIdx, const int miniBatchIdx, const int cnnLayer){
	int x, y;
	float tmp;
	float max = getDCnnA(p_x * getCCnnPooling_xNums(), p_y * getCCnnPooling_yNums(), outputIdx, miniBatchIdx, cnnLayer);

	for(y = 0; y < getCCnnPooling_yNums() && y + p_y * getCCnnPooling_yNums() < getCCnnWba_yNums(cnnLayer); y++){
		for(x = 0; x < getCCnnPooling_xNums() && x + p_x * getCCnnPooling_xNums() < getCCnnWba_xNums(cnnLayer); x++){
				tmp = getDCnnA(x + p_x * getCCnnPooling_xNums(), y + p_y * getCCnnPooling_yNums(), outputIdx, miniBatchIdx, cnnLayer);
				max = max * (max >= tmp) + tmp * (max < tmp);
		}
	}

	dCnnP[getDCnnPIdx(p_x, p_y, outputIdx, miniBatchIdx, cnnLayer)] = max;
	//if(outputIdx == 1){
		//printf("p(%d,%d,%d,%d,%d) = %f\n",p_x, p_y, outputIdx, miniBatchIdx, cnnLayer, dCnnP[getDCnnPIdx(p_x, p_y, outputIdx, miniBatchIdx, cnnLayer)]);
//	}
}
