#include <stdio.h>
#include <math.h>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh>
#include <commonFunc.cuh>

__global__ void kernelBackMlpActivateProp(const int mlpLayer);
__global__ void kernelBackMlpActivateUpdate(const int mlpLayer);

void backMlpActivate(const int mlpLayer){

//	puts("backMlpActivate start.");
//	struct timeval t1, t2, t3;
//	gettimeofday(&t1, NULL);

	//カーネルの次元設定
	dim3 gridProp(getMlpOutputNums(mlpLayer), getMiniBatchNums()); //"mlpLayer"に注意
	dim3 blockProp(1, 1, 1); // 1ブロック1スレッド
	dim3 gridUpdate(getMlpOutputNums(mlpLayer), getMlpOutputNums(mlpLayer + 1)); //"mlpLayer"に注意
	dim3 blockUpdate(1, 1, 1); // 1ブロック1スレッド

	//次元チェック
	checkGridSize(gridProp);
	checkThreadSize(blockProp);
	checkGridSize(gridUpdate);
	checkThreadSize(blockUpdate);

//	gettimeofday(&t2, NULL);
	//カーネル起動
//	puts("kernelBackMlpActivate start.");
	cudaDeviceSynchronize();
	kernelBackMlpActivateProp<<<gridProp, blockProp>>>(mlpLayer);
//	puts("kernelBackMlpActivate end.");
//	puts("kernelBackMlpActivateUpdate start.");
	cudaDeviceSynchronize();
	kernelBackMlpActivateUpdate<<<gridUpdate, blockUpdate>>>(mlpLayer);
//	puts("kernelBackMlpActivateUpdate end.");
//	gettimeofday(&t3, NULL);

//	puts("backMlpActivate end.");
//	printTime(t1,t2,t3);

}

__global__ void
kernelBackMlpActivateProp(const int mlpLayer){
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;
	int inputIdx;
	float sum = 0;
	const int mlpLayerPlusOne = mlpLayer + 1;

	//累積更新値取得:mlpA += mlpWb(mlpLayer+1) * mlpW(mlpLayer+1)
	for(inputIdx = 0; inputIdx < getCMlpOutputNums(mlpLayerPlusOne); inputIdx++){
		//inputとoutputの割り当てがfowardpropのときと逆であることに注意
		sum += getDMlpWbBack(inputIdx, miniBatchIdx, mlpLayerPlusOne) * getDMlpW(outputIdx, inputIdx, mlpLayerPlusOne);
		/*
		if(miniBatchIdx == 2){
			printf("mlpWbBack(%d,%d,%d):%f\n", inputIdx, miniBatchIdx, mlpLayerPlusOne, getDMlpWbBack(inputIdx, miniBatchIdx, mlpLayerPlusOne));
			printf("mlpW(%d,%d,%d,%d):%f\n", outputIdx, inputIdx,miniBatchIdx, mlpLayerPlusOne, getDMlpW(outputIdx, inputIdx, mlpLayerPlusOne));
		}
		*/
	}
	//更新
	dMlpABack[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)] = sum;
	/*
	if(miniBatchIdx == 2){
		printf("mlpABack(%d,%d,%d):%f\n", outputIdx, miniBatchIdx, mlpLayer, dMlpABack[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)]);
	}
	*/
}

__global__ void
kernelBackMlpActivateUpdate(const int mlpLayer){
	int outputIdx = blockIdx.x;
	int inputIdx = blockIdx.y;
	int miniBatchIdx;
	int miniBatchIdxNums = getCMiniBatchNums();
	float sum = 0;
	const int mlpLayerPlusOne = mlpLayer + 1;

	for(miniBatchIdx = 0; miniBatchIdx < miniBatchIdxNums; miniBatchIdx++){
		sum += getDMlpWbBack(inputIdx, miniBatchIdx, mlpLayerPlusOne) * getDMlpA(outputIdx, miniBatchIdx, mlpLayer);
		/*
		if(outputIdx == 2 && inputIdx == 1){
			printf("mlpWbBack(%d,%d,%d):%f\n", inputIdx, miniBatchIdx, mlpLayerPlusOne, getDMlpWbBack(inputIdx, miniBatchIdx, mlpLayerPlusOne));
			printf("mlpA(%d,%d,%d):%f\n", outputIdx, miniBatchIdx, mlpLayer, getDMlpA(outputIdx, miniBatchIdx, mlpLayer));
			printf("sum=%f\n",sum);
		}
		*/
	}

	//更新
	dMlpW[getDMlpWIdx(outputIdx, inputIdx, mlpLayerPlusOne)] -= sum * getCLearningRate();
	/*
	if(outputIdx == 2 && inputIdx == 1){
			printf("mlpW(%d,%d,%d,%d):%f\n", outputIdx, inputIdx,miniBatchIdx, mlpLayerPlusOne, getDMlpW(outputIdx, inputIdx, mlpLayerPlusOne));
			printf("mlpWidx:%d\n", getDMlpWIdx(outputIdx, inputIdx, mlpLayerPlusOne));
	}
	*/
}
