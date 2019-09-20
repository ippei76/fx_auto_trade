#include <stdio.h>
#include <math.h>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh>

extern __global__ void kernelMlpActivate(const int mlpLayer);
extern __device__ float relu(const int outputIdx, const int miniBatchIdx, const int mlpLayer);
extern __global__ void kernelMlpActivateLastLayer(const int mlpLayer);
extern __device__ float softmax(const int outputIdx, const int outputIdxNums, const int miniBatchIdx, const int mlpLayer);

void mlpActivate(const int mlpLayer){

//	puts("mlpActivate start.");
//	struct timeval t1, t2, t3;
//	gettimeofday(&t1, NULL);

	if(mlpLayer != getMlpOutputNumsNums() - 1){
		//カーネルの次元設定
		dim3 grid(getMlpOutputNums(mlpLayer), getMiniBatchNums()); //miniBatch毎の1ニューロンの出力を1ブロックとする。
		dim3 block(1, 1, 1); // 1ブロック1スレッド

		//次元チェック
		checkGridSize(grid);
		checkThreadSize(block);

//		gettimeofday(&t2, NULL);
		cudaDeviceSynchronize();
		kernelMlpActivate<<<grid, block>>>(mlpLayer);
	}
	else{
		//カーネルの次元設定
		dim3 grid(getMlpOutputNums(mlpLayer), getMiniBatchNums()); //miniBatch毎の1ニューロンの出力を1ブロックとする。
		dim3 block(1, 1, 1); // 1ブロック1スレッド

		//次元チェック
		checkGridSize(grid);
		checkThreadSize(block);

//		gettimeofday(&t2, NULL);
		cudaDeviceSynchronize();
		kernelMlpActivateLastLayer<<<grid, block>>>(mlpLayer);
	}
//	puts("kernelMlpActivate end.");
//	gettimeofday(&t3, NULL);

//	puts("mlpActivate end.");
//	printTime(t1,t2,t3);

}

__global__ void
kernelMlpActivate(const int mlpLayer){
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;

	dMlpA[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)] = relu(outputIdx, miniBatchIdx, mlpLayer);
	/*
	if(outputIdx == 2){
		printf("mlpA(%d,%d,%d) = %f\n", outputIdx, miniBatchIdx, mlpLayer, dMlpA[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)]);
	}
	*/
}

__device__ float
relu(const int outputIdx, const int miniBatchIdx, const int mlpLayer){
	float val;
	val = getDMlpBn(outputIdx, miniBatchIdx, mlpLayer) *\
	      (0 < getDMlpBn(outputIdx, miniBatchIdx, mlpLayer));
	return(val);
}

__global__ void
kernelMlpActivateLastLayer(const int mlpLayer){
	int outputIdx = blockIdx.x;
	int outputIdxNums = gridDim.x;
	int miniBatchIdx = blockIdx.y;

	float val = softmax(outputIdx, outputIdxNums, miniBatchIdx, mlpLayer);
	dMlpA[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)] = val;
	//resultにも格納する
	dResult[getDim2Idx(outputIdx, miniBatchIdx, outputIdxNums)] = val;
	/*
	if(miniBatchIdx == 0){
		printf("soft_dResult(%d,%d,%d)[%f] = %f\n",outputIdx, miniBatchIdx, mlpLayer, getDMlpBn(outputIdx, miniBatchIdx, mlpLayer), dResult[getDim2Idx(outputIdx, miniBatchIdx, outputIdxNums)]);
	}
	*/
}

__device__ float
softmax(const int outputIdx, const int outputIdxNums, const int miniBatchIdx, const int mlpLayer){
	float val;
	float sumVal = 0;
	int i;
	//オーバーフローを防ぐために、最大値を求める。
	float maxMlpBn = getDMlpBn(0, miniBatchIdx, mlpLayer);
	for(i = 1; i < outputIdxNums; i++){
		float targetMlpBn = getDMlpBn(i, miniBatchIdx, mlpLayer);
		maxMlpBn = maxMlpBn * (maxMlpBn >= targetMlpBn) + targetMlpBn * (maxMlpBn < targetMlpBn);
	}

	//softmaxの分母を計算する。
	for(i = 0; i < outputIdxNums; i++){
		sumVal += expf(floatSubtraction(getDMlpBn(i, miniBatchIdx, mlpLayer), maxMlpBn, mlpLayer, __func__));
	}

	val = expf(floatSubtraction(getDMlpBn(outputIdx, miniBatchIdx, mlpLayer), maxMlpBn, mlpLayer, __func__)) / sumVal;
	/*
	if(miniBatchIdx == 0){
		printf("bn(%d,%d,%d) = %f\n",outputIdx, miniBatchIdx, mlpLayer,getDMlpBn(outputIdx, miniBatchIdx, mlpLayer));
		printf("sumval(%d,%d,%d) = %f\n",outputIdx, miniBatchIdx, mlpLayer,sumVal);
		printf("val(%d,%d,%d) = %f\n",outputIdx, miniBatchIdx, mlpLayer,val);
	}
	*/
	return(val);
}
