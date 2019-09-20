#include <stdio.h>
#include <math.h>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh>
#include <commonFunc.cuh>

__global__ void kernelBackCnnPoolingProp(const int cnnLayer);
extern __global__ void kernelBackCnnPoolingUpdate(const int cnnLayer, const int miniBatchIdxNums);

void backCnnPooling(const int cnnLayer){

//	puts("backCnnPooling start.");
//	struct timeval t1, t2, t3;
//	gettimeofday(&t1, NULL);
	int inputChannelNums = getCnnOutputNums(cnnLayer + 1);

	//カーネルの次元設定
	dim3 gridProp(getCnnOutputNums(cnnLayer), getMiniBatchNums());
	dim3 blockProp(getCnnP_xNums(cnnLayer), getCnnP_yNums(cnnLayer), 1); // 1ブロックcnnP_x * cnnP_yスレッド
	dim3 gridUpdate(getCnnOutputNums(cnnLayer), inputChannelNums); //cnnWの種類
	dim3 blockUpdate(getCnnW_xNums(), getCnnW_yNums(), 1); // 1ブロックcnnW_x * cnnW_yスレッド

	//次元チェック
	checkGridSize(gridProp);
	checkThreadSize(blockProp);
	checkGridSize(gridUpdate);
	checkThreadSize(blockUpdate);

	//シェアードメモリ確保
	int sharedSizeW = sizeof(float) * getCnnW_xNums() * getCnnW_yNums() * inputChannelNums; 

	//シェアードメモリチェック
	checkSharedMemorySize(sharedSizeW);

//	gettimeofday(&t2, NULL);
	//カーネル起動
//	puts("kernelBackCnnPoolingProp start.");
	cudaDeviceSynchronize();
	kernelBackCnnPoolingProp<<<gridProp, blockProp, sharedSizeW>>>(cnnLayer);
//	puts("kernelBackCnnPoolingProp end.");
//	puts("kernelBackCnnPoolingUpdate start.");
	cudaDeviceSynchronize();
	kernelBackCnnPoolingUpdate<<<gridUpdate, blockUpdate>>>(cnnLayer, getMiniBatchNums());
//	puts("kernelBackCnnPoolingUpdate end.");
//	gettimeofday(&t3, NULL);

//	puts("backCnnPooling end.");
//	printTime(t1,t2,t3);

}

__global__ void
kernelBackCnnPoolingProp(const int cnnLayer){
	int cnnP_x = threadIdx.x;
	int cnnP_y = threadIdx.y;
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;
	int cnnW_x, cnnW_y, input_x, input_y;
	float sum = 0;
	const int cnnLayerPlusOne = cnnLayer + 1;
	int inputIdx;
	int inputIdxNums = getCCnnOutputNums(cnnLayerPlusOne);
	int input_xNums = getCCnnWba_xNums(cnnLayerPlusOne);
	int input_yNums = getCCnnWba_yNums(cnnLayerPlusOne);

	//wをshared memoryにコピー
	extern __shared__ float sCnnW[];
	for(inputIdx = 0; inputIdx < inputIdxNums; inputIdx++){
		sCnnW[getDim3Idx(cnnP_x % getCCnnW_xNums(), cnnP_y % getCCnnW_yNums(), inputIdx, getCCnnW_xNums(), getCCnnW_yNums())]\
			= getDCnnW(cnnP_x % getCCnnW_xNums(), cnnP_y % getCCnnW_yNums(), outputIdx, inputIdx, cnnLayerPlusOne);
	}
	__syncthreads();

	//累積更新値取得:cnnP += cnnWb(0) * cnnW(0)
	for(inputIdx = 0; inputIdx < getCCnnOutputNums(cnnLayerPlusOne); inputIdx++){
		// 0 <= input_x,y < input_x,yNums の制約を持つ。
		//ただし、input_x,y < input_x,yNums は、for文中に書き込むとループ不足となってしまうため、別途制約クリアを実施
		for(cnnW_y = 0; cnnW_y < getCCnnW_yNums() && 0 <= cnnP_y - cnnW_y; cnnW_y++){
			for(cnnW_x = 0; cnnW_x < getCCnnW_xNums() && 0 <= cnnP_x - cnnW_x; cnnW_x++){
				input_x = cnnP_x - cnnW_x;
				input_y = cnnP_y - cnnW_y;
				sum += getDCnnWbBack(input_x, input_y, inputIdx, miniBatchIdx, cnnLayerPlusOne)\
				       * sCnnW[getDim3Idx(cnnW_x, cnnW_y, inputIdx, getCCnnW_xNums(), getCCnnW_yNums())]\
				       * (cnnP_y - cnnW_y < input_yNums) * (cnnP_x - cnnW_x < input_xNums); //後半の制約クリア
				/*
				if(outputIdx == 1 && cnnP_x == 1 &&cnnP_y == 2 && miniBatchIdx == 1){
					printf("sCnnW(%d,%d,%d,%d):%f\n", cnnW_x, cnnW_y, outputIdx, inputIdx, sCnnW[getDim3Idx(cnnW_x, cnnW_y, inputIdx, getCCnnW_xNums(), getCCnnW_yNums())]);
					printf("cnnWbBack(%d,%d,%d,%d):%f(sum=%f)\n", input_x, input_y, inputIdx, miniBatchIdx, getDCnnWbBack(input_x, input_y, inputIdx, miniBatchIdx, cnnLayerPlusOne),sum);
				}
				*/
			}
		}
	}
	//更新
	dCnnPBack[getDCnnPIdx(cnnP_x, cnnP_y, outputIdx, miniBatchIdx, cnnLayer)] = sum;
	/*
	if(outputIdx == 1 && cnnP_x == 1 &&cnnP_y == 2 && miniBatchIdx == 1){
		printf("cnnPBack(%d,%d,%d,%d)(%d):%f\n", cnnP_x, cnnP_y, outputIdx, miniBatchIdx, getDCnnPIdx(cnnP_x, cnnP_y, outputIdx, miniBatchIdx, cnnLayer),dCnnPBack[getDCnnPIdx(cnnP_x, cnnP_y, outputIdx, miniBatchIdx, cnnLayer)]);
	}
	*/
}

__global__ void
kernelBackCnnPoolingUpdate(const int cnnLayer, const int miniBatchIdxNums){
	int cnnW_x = threadIdx.x;
	int cnnW_y = threadIdx.y;
	int outputIdx = blockIdx.x;
	int inputIdx = blockIdx.y;
	int input_x, input_y, miniBatchIdx;
	float sum = 0.0;
	const int cnnLayerPlusOne = cnnLayer + 1;
	int input_xNums = getCCnnWba_xNums(cnnLayerPlusOne);
	int input_yNums = getCCnnWba_yNums(cnnLayerPlusOne);

	for(miniBatchIdx = 0; miniBatchIdx < miniBatchIdxNums; miniBatchIdx++){
		for(input_y = 0; input_y < input_yNums; input_y++){
			for(input_x = 0; input_x < input_xNums; input_x++){
				sum += getDCnnWbBack(input_x, input_y, inputIdx, miniBatchIdx, cnnLayerPlusOne)\
				       * getDCnnP(cnnW_x + input_x, cnnW_y + input_y, outputIdx, miniBatchIdx, cnnLayer);
				/*
				if(outputIdx == 1 && inputIdx == 1 &&cnnW_x == 1 && cnnW_y == 1){
					printf("cnnWbBack(%d,%d,%d,%d):%f\n", input_x, input_y, inputIdx, miniBatchIdx, getDCnnWbBack(input_x, input_y, inputIdx, miniBatchIdx, cnnLayerPlusOne));
					printf("cnnP(%d,%d,%d,%d):%f(%f)\n", cnnW_x + input_x, cnnW_y + input_y, outputIdx, miniBatchIdx, getDCnnP(cnnW_x + input_x, cnnW_y + input_y, outputIdx, miniBatchIdx, cnnLayer),sum);
				}
				*/
			}
		}
	}

	//更新
	dCnnW[getDCnnWIdx(cnnW_x, cnnW_y, outputIdx, inputIdx, cnnLayerPlusOne)] -= sum * getCLearningRate();
	//if(outputIdx == 1 && inputIdx == 1 &&cnnW_x == 1 && cnnW_y == 1){
//		printf("cnnW(%d,%d,%d,%d):%f  ", cnnW_x, cnnW_y, outputIdx, inputIdx, dCnnW[getDCnnWIdx(cnnW_x, cnnW_y, outputIdx, inputIdx, cnnLayerPlusOne)]);
	//}
}
