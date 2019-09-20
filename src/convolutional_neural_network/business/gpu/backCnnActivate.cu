#include <stdio.h>
#include <math.h>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh>
#include <commonFunc.cuh>

__global__ void kernelBackCnnActivateProp(const int cnnLayer);

void backCnnActivate(const int cnnLayer){

//	puts("backCnnActivate start.");
//	struct timeval t1, t2, t3;
//	gettimeofday(&t1, NULL);

	//カーネルの次元設定
	dim3 gridProp(getCnnOutputNums(cnnLayer), getMiniBatchNums());
	dim3 blockProp(getCnnWba_xNums(cnnLayer), getCnnWba_yNums(cnnLayer), 1); // 1ブロックp_x * p_yスレッド

	//次元チェック
	checkGridSize(gridProp);
	checkThreadSize(blockProp);

//	gettimeofday(&t2, NULL);
	//カーネル起動
//	puts("kernelBackCnnActivateProp start.");
	cudaDeviceSynchronize();
	kernelBackCnnActivateProp<<<gridProp, blockProp>>>(cnnLayer);
//	puts("kernelBackCnnActivateProp end.");
//	gettimeofday(&t3, NULL);

//	puts("backCnnActivate end.");
//	printTime(t1,t2,t3);

}

__global__ void
kernelBackCnnActivateProp(const int cnnLayer){
	int cnnWba_x = threadIdx.x;
	int cnnWba_y = threadIdx.y;
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;
	int cnnP_x = cnnWba_x / getCCnnPooling_xNums();
	int cnnP_y = cnnWba_y / getCCnnPooling_yNums();

	float tgtCnnA = getDCnnA(cnnWba_x, cnnWba_y, outputIdx, miniBatchIdx, cnnLayer);
	float tgtCnnP = getDCnnP(cnnP_x, cnnP_y, outputIdx, miniBatchIdx, cnnLayer);

	//更新
	dCnnABack[getDCnnWbaIdx(cnnWba_x, cnnWba_y, outputIdx, miniBatchIdx, cnnLayer)] = getDCnnPBack(cnnP_x, cnnP_y, outputIdx, miniBatchIdx, cnnLayer) * (tgtCnnA == tgtCnnP);
	/*
	if(outputIdx == 1 && miniBatchIdx == 1){
		printf("cnnABack(%d,%d,%d,%d,%d):%f\n",cnnWba_x,cnnWba_y,outputIdx,miniBatchIdx,cnnLayer,dCnnABack[getDCnnWbaIdx(cnnWba_x, cnnWba_y, outputIdx, miniBatchIdx, cnnLayer)]);
	}
	*/
}
