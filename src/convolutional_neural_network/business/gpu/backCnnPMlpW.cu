#include <stdio.h>
#include <math.h>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh>
#include <commonFunc.cuh>

extern __global__ void kernelBackCnnPMlpWProp(const int cnnLastLayer);
extern __global__ void kernelBackCnnPMlpWUpdate(const int cnnLastLayer, const int miniBatchIdxNums);

void backCnnPMlpW(const int cnnLastLayer){

//	puts("backCnnPMlpW start.");
//	struct timeval t1, t2, t3;
//	gettimeofday(&t1, NULL);

	int mlpLayerIsZero = 0;
	int inputChannelNums = mlpOutputNums[mlpLayerIsZero];
	//カーネルの次元設定
	dim3 gridProp(getCnnOutputNums(cnnLastLayer), getMiniBatchNums()); //"cnnLastLayer"に注意
	dim3 blockProp(getCnnP_xNums(cnnLastLayer), getCnnP_yNums(cnnLastLayer), 1); // 1ブロックp_x * p_yスレッド
	dim3 gridUpdate(getCnnOutputNums(cnnLastLayer), inputChannelNums); //"cnnLastLayer"に注意
	dim3 blockUpdate(getCnnP_xNums(cnnLastLayer), getCnnP_yNums(cnnLastLayer), 1); // 1ブロックp_x * p_yスレッド

	//次元チェック
	checkGridSize(gridProp);
	checkThreadSize(blockProp);
	checkGridSize(gridUpdate);
	checkThreadSize(blockUpdate);

//	gettimeofday(&t2, NULL);
	//カーネル起動
//	puts("kernelBackCnnPMlpWProp start.");
	cudaDeviceSynchronize();
	kernelBackCnnPMlpWProp<<<gridProp, blockProp>>>(cnnLastLayer);
//	puts("kernelBackCnnPMlpWProp end.");
//	puts("kernelBackCnnPMlpWUpdate start.");
	cudaDeviceSynchronize();
	kernelBackCnnPMlpWUpdate<<<gridUpdate, blockUpdate>>>(cnnLastLayer, getMiniBatchNums());
//	puts("kernelBackCnnPMlpWUpdate end.");
//	gettimeofday(&t3, NULL);

//	puts("backCnnPMlpW end.");
	//printTime(t1,t2,t3);

}

__global__ void
kernelBackCnnPMlpWProp(const int cnnLastLayer){
	int p_x = threadIdx.x;
	int p_xNums = blockDim.x;
	int p_y = threadIdx.y;
	int p_yNums = blockDim.y;
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;
	int inputIdx;
	float sum = 0;
	const int mlpLayerIsZero = 0;

	//累積更新値取得:cnnP += mlpWb(0) * mlpW(0)
	for(inputIdx = 0; inputIdx < getCMlpOutputNums(mlpLayerIsZero); inputIdx++){
		//inputとoutputの割り当てがfowardpropのときと逆であることに注意
		sum += getDMlpWbBack(inputIdx, miniBatchIdx, mlpLayerIsZero)\
		       * getDMlpW(getDim3Idx(p_x, p_y, outputIdx, p_xNums, p_yNums), inputIdx, mlpLayerIsZero);
		/*
		if(miniBatchIdx == 2){
			printf("mlpWbBack(%d,%d,%d):%f\n", inputIdx, miniBatchIdx, mlpLayerIsZero, getDMlpWbBack(inputIdx, miniBatchIdx, mlpLayerIsZero));
			printf("mlpW(%d,%d,%d,%d,%d,%d):%f\n", p_x,p_y,outputIdx, inputIdx,miniBatchIdx, mlpLayerIsZero, getDMlpW(getDim3Idx(p_x, p_y, outputIdx, p_xNums, p_yNums), inputIdx, mlpLayerIsZero));
		}
		*/
	}
	//更新
	dCnnPBack[getDCnnPIdx(p_x, p_y, outputIdx, miniBatchIdx, cnnLastLayer)] = sum;
	/*
	if(miniBatchIdx == 2){
		printf("cnnPBack(%d,%d,%d):%f\n", outputIdx, miniBatchIdx, cnnLastLayer, dCnnPBack[getDCnnPIdx(p_x, p_y, outputIdx, miniBatchIdx, cnnLastLayer)]);
	}
	*/
}

__global__ void
kernelBackCnnPMlpWUpdate(const int cnnLastLayer, const int miniBatchIdxNums){
	int p_x = threadIdx.x;
	int p_xNums = blockDim.x;
	int p_y = threadIdx.y;
	int p_yNums = blockDim.y;
	int outputIdx = blockIdx.x;
	int inputIdx = blockIdx.y;
	int miniBatchIdx;
	float sum = 0;
	const int mlpLayerIsZero = 0;

	for(miniBatchIdx = 0; miniBatchIdx < miniBatchIdxNums; miniBatchIdx++){
		sum += getDMlpWbBack(inputIdx, miniBatchIdx, mlpLayerIsZero)\
		       * getDCnnP(p_x, p_y, outputIdx, miniBatchIdx, cnnLastLayer);
		/*
		if(p_x==1 &&p_y==1 &&outputIdx == 1 && inputIdx == 1){
			printf("mlpWbBack(%d,%d,%d):%f\n", inputIdx, miniBatchIdx, mlpLayerIsZero, getDMlpWbBack(inputIdx, miniBatchIdx, mlpLayerIsZero));
			printf("P(%d,%d,%d,%d,%d):%f\n", p_x,p_y,outputIdx, miniBatchIdx, cnnLastLayer, getDCnnP(p_x, p_y, outputIdx, miniBatchIdx, cnnLastLayer));
			printf("sum=%f\n",sum);
		}
		*/
	}

	//更新
	dMlpW[getDMlpWIdx(getDim3Idx(p_x, p_y, outputIdx, p_xNums, p_yNums), inputIdx, mlpLayerIsZero)] -= sum * getCLearningRate();
	//if(p_x==1 &&p_y==1 &&outputIdx == 1 && inputIdx == 1){
//			printf("mlpW(%d,%d,%d,%d):%f  ", outputIdx, inputIdx,miniBatchIdx, mlpLayerIsZero, dMlpW[getDMlpWIdx(getDim3Idx(p_x, p_y, outputIdx, p_xNums, p_yNums), inputIdx, mlpLayerIsZero)]);
//	}
}
