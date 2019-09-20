#include <stdio.h>
#include <math.h>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh>
#include <commonFunc.cuh>

extern __global__ void kernelBackCnnSvUpdate(const int miniBatchIdxNums);

void backCnnSv(const int cnnLayer){

//	puts("backCnnSv start.");
//	struct timeval t1, t2, t3;
//	gettimeofday(&t1, NULL);
	int inputChannelNums = getCnnOutputNums(cnnLayer + 1);

	//カーネルの次元設定
	dim3 gridUpdate(getSvChannelNums(), inputChannelNums); //cnnWの種類
	dim3 blockUpdate(getCnnW_xNums(), getCnnW_yNums(), 1); // 1ブロックcnnW_x * cnnW_yスレッド

	//次元チェック
	checkGridSize(gridUpdate);
	checkThreadSize(blockUpdate);

//	gettimeofday(&t2, NULL);
	//カーネル起動
//	puts("kernelBackCnnSvUpdate start.");
	cudaDeviceSynchronize();
	kernelBackCnnSvUpdate<<<gridUpdate, blockUpdate>>>(getMiniBatchNums());
	cudaDeviceSynchronize();
//	puts("kernelBackCnnSvUpdate end.");
//	gettimeofday(&t3, NULL);

//	puts("backCnnSv end.");
//	printTime(t1,t2,t3);

}

__global__ void
kernelBackCnnSvUpdate(const int miniBatchIdxNums){
	int cnnW_x = threadIdx.x;
	int cnnW_y = threadIdx.y;
	int outputIdx = blockIdx.x;
	int inputIdx = blockIdx.y;
	int input_x, input_y, miniBatchIdx;
	float sum = 0.0;
	const int cnnLayerIsZero = 0;
	int input_xNums = getCCnnWba_xNums(cnnLayerIsZero);
	int input_yNums = getCCnnWba_yNums(cnnLayerIsZero);

	for(miniBatchIdx = 0; miniBatchIdx < miniBatchIdxNums; miniBatchIdx++){
		for(input_y = 0; input_y < input_yNums; input_y++){
			for(input_x = 0; input_x < input_xNums; input_x++){
				sum += getDCnnWbBack(input_x, input_y, inputIdx, miniBatchIdx, cnnLayerIsZero)\
				       * getDSv(cnnW_x + input_x, cnnW_y + input_y, outputIdx, miniBatchIdx);
				/*
				if(outputIdx == 0 && inputIdx == 0){
					printf("input_xNums():%d\n", input_xNums);
					printf("input_yNums():%d\n", input_yNums);
					printf("outputNums():%d\n", gridDim.x);
					printf("inputNums():%d\n", gridDim.y);
					printf("cnnWbBack(%d,%d,%d,%d):%f\n", input_x, input_y, inputIdx, miniBatchIdx, getDCnnWbBack(input_x, input_y, inputIdx, miniBatchIdx, cnnLayerIsZero));
					printf("cnnsv(%d,%d,%d,%d):%f(%f)\n", cnnW_x + input_x, cnnW_y + input_y, outputIdx, miniBatchIdx, getDSv(cnnW_x + input_x, cnnW_y + input_y, outputIdx, miniBatchIdx),sum);
				}
				*/
			}
		}
	}

	//更新
	dCnnW[getDCnnWIdx(cnnW_x, cnnW_y, outputIdx, inputIdx, cnnLayerIsZero)] -= sum * getCLearningRate();
	//printf("cnnUpdateSvW(%d,%d,%d,%d):%f  ", cnnW_x, cnnW_y, outputIdx, inputIdx, dCnnW[getDCnnWIdx(cnnW_x, cnnW_y, outputIdx, inputIdx, cnnLayerIsZero)]);
	//if(outputIdx == 0 && inputIdx == 1 &&cnnW_x == 1 && cnnW_y == 1){
	/*
	if(outputIdx == 0 && inputIdx == 0 &&cnnW_x == 0 && cnnW_y == 0){
		//printf("cnnW(%d,%d,%d,%d):%f  ", cnnW_x, cnnW_y, outputIdx, inputIdx, dCnnW[getDCnnWIdx(cnnW_x, cnnW_y, outputIdx, inputIdx, cnnLayerIsZero)]);
		printf("learningRate:%f  ", getCLearningRate());
	}
	*/
}
