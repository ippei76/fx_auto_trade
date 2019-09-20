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

extern __global__ void kernelCnnConvolutionSv();
extern __global__ void kernelCnnConvolutionCnnP(const int cnnLayer);

void cnnConvolution(const int cnnLayer){

//	puts("cnnConvolution start.");
//	struct timeval t1, t2, t3;
//	gettimeofday(&t1, NULL);

	//ブロック・スレッド定義
	//各miniBatchのwbノード毎にブロックを定義
	//wbノードの1要素毎にスレッドを定義
	//シェアードメモリにwを割り当てる
	dim3 grid(getCnnOutputNums(cnnLayer), getMiniBatchNums());
	dim3 block(getCnnWba_xNums(cnnLayer), getCnnWba_yNums(cnnLayer), 1);

	//次元チェック
	checkGridSize(grid);
	checkThreadSize(block);

	//input,w相関チェック
	if(cnnLayer == 0){
		checkInputW(getSv_xNums(), getSv_yNums(), getCnnW_xNums(), getCnnW_yNums());
	}
	else{
		checkInputW(getCnnWba_xNums(cnnLayer - 1), getCnnWba_yNums(cnnLayer - 1), getCnnW_xNums(), getCnnW_yNums());
	}

	//シェアードメモリ確保
	int sharedSizeW;
	if(cnnLayer == 0){
		sharedSizeW = sizeof(float) * getCnnW_xNums() * getCnnW_yNums() * getSvChannelNums(); 
	}
	else{
		sharedSizeW = sizeof(float) * getCnnW_xNums() * getCnnW_yNums() * getCnnOutputNums(cnnLayer - 1); 
	}

	//シェアードメモリチェック
	checkSharedMemorySize(sharedSizeW);

//	gettimeofday(&t2, NULL);
	//カーネル起動
//	puts("kernelCnnConvolution start");
	if(cnnLayer == 0){
		kernelCnnConvolutionSv<<<grid, block, sharedSizeW>>>();
	}
	else{
		kernelCnnConvolutionCnnP<<<grid, block, sharedSizeW>>>(cnnLayer);
	}
//	puts("kernelCnnConvolution end");
//	gettimeofday(&t3, NULL);

//	puts("cnnConvolution end.");
	//printTime(t1,t2,t3);

}

__global__ void kernelCnnConvolutionSv(){
	int wba_x = threadIdx.x;
	int wba_y = threadIdx.y;
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;
	int x, y, inputIdx;
	float sum = 0;
	int inputChannelNums = getCSvChannelNums();
	int cnnLayerIsZero = 0;
	//wをshared memoryにコピー
	extern __shared__ float sCnnW[];
	for(inputIdx = 0; inputIdx < inputChannelNums; inputIdx++){
		sCnnW[getDim3Idx(wba_x % getCCnnW_xNums(), wba_y % getCCnnW_yNums(), inputIdx, getCCnnW_xNums(), getCCnnW_yNums())]\
			= getDCnnW(wba_x % getCCnnW_xNums(), wba_y % getCCnnW_yNums(), inputIdx, outputIdx, cnnLayerIsZero);
	}
	__syncthreads();

	//畳み込み処理
	for(inputIdx = 0; inputIdx < inputChannelNums; inputIdx++){
		for(y = 0; y < getCCnnW_yNums(); y++){
			for(x = 0; x < getCCnnW_xNums(); x++){
				//printf("x:%d\n",x);
				//printf("minib:%d,wba_x:%d,wba_y:%d,inputIdx:%d,outputIdx:%d\n",miniBatchIdx,wba_x,wba_y,inputIdx,outputIdx);
				sum += getDSv(x + wba_x, y + wba_y, inputIdx, miniBatchIdx)\
				       * sCnnW[getDim3Idx(x, y, inputIdx, getCCnnW_xNums(), getCCnnW_yNums())];
				
				/*
				if(miniBatchIdx == 0 && wba_x == 1 && wba_y == 1 && inputIdx == 0 && outputIdx == 1){
					//printf("x:%d\n",x);
					//printf("Sv(%d,%d,%d,%d,%d) = %f  ",wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayerIsZero,getDSv(x + wba_x, y + wba_y, inputIdx, miniBatchIdx));
					//printf("cnnW(%d,%d,%d,%d,%d) = %f  ",x, y, inputIdx, outputIdx, cnnLayerIsZero,sCnnW[getDim3Idx(x, y, inputIdx, getCCnnW_xNums(), getCCnnW_yNums())]);
			//		printf("sum(%d,%d,%d) = %f\n",inputChannelNums,getCCnnW_yNums(),getCCnnW_xNums(),sum);
				}
				*/
				
			}
		}
	}
	__syncthreads();

	//wb更新
	dCnnWb[getDCnnWbaIdx(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayerIsZero)] = sum;
	//if(wba_x==6 && wba_y==6 &&outputIdx == 2 &&miniBatchIdx == 2){
	/*
	if(outputIdx == 0){
		printf("svwb(%d,%d,%d,%d,%d) = %f\n",wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayerIsZero, sum);
	}
	*/
}

__global__ void kernelCnnConvolutionCnnP(const int cnnLayer){
	int wba_x = threadIdx.x;
	int wba_y = threadIdx.y;
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;
	int x, y, inputIdx;
	float sum = 0;
	int inputChannelNums = getCCnnOutputNums(cnnLayer - 1);
	//wをshared memoryにコピー
	extern __shared__ float sCnnW[];
	for(inputIdx = 0; inputIdx < inputChannelNums; inputIdx++){
		sCnnW[getDim3Idx(wba_x % getCCnnW_xNums(), wba_y % getCCnnW_yNums(), inputIdx, getCCnnW_xNums(), getCCnnW_yNums())]\
			= getDCnnW(wba_x % getCCnnW_xNums(), wba_y % getCCnnW_yNums(), inputIdx, outputIdx, cnnLayer);
	}
	__syncthreads();

	//畳み込み処理
	for(inputIdx = 0; inputIdx < inputChannelNums; inputIdx++){
		for(y = 0; y < getCCnnW_yNums(); y++){
			for(x = 0; x < getCCnnW_xNums(); x++){
				//printf("x:%d\n",x);
				sum += getDCnnP(x + wba_x, y + wba_y, inputIdx, miniBatchIdx, cnnLayer - 1)\
				       * sCnnW[getDim3Idx(x, y, inputIdx, getCCnnW_xNums(), getCCnnW_yNums())];
				//if(miniBatchIdx == 0 && wba_x == 1 && wba_y == 1 && inputIdx == 1 && outputIdx == 1){
				//if(miniBatchIdx == 0 && wba_x == 1 && wba_y == 1 && inputIdx == 1 && outputIdx == 1){
//					printf("p:%f  ",getDCnnP(x + wba_x, y + wba_y, inputIdx, miniBatchIdx, cnnLayer - 1));
				//	printf("scnnW:%f  ",sCnnW[getDim3Idx(x, y, inputIdx, getCCnnW_xNums(), getCCnnW_yNums())]);
				//}
			}
		}
	}
//	printf("cnnLayer:%d, wba_xNums:%d, getCCnnWba_xNums(cnnLayer):%d, getCCnnW_yNums():%d, inputChannelNums:%d\n", cnnLayer, blockDim.x,cWba_xNums[0], getCCnnW_yNums(), inputChannelNums);

	//wb更新
	dCnnWb[getDCnnWbaIdx(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer)] = sum;
	//if(wba_x==17 && wba_y==16 &&outputIdx == 1 &&miniBatchIdx == 2){
	/*
	if(outputIdx == 1){
		printf("pwb(%d,%d,%d,%d,%d) = %f\n",wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer, sum);
	}
	*/
}
