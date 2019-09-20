#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <constraint.cuh>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh> 
#include <cudaCheck.cuh>

extern __global__ void kernelInferenceBnMeanVar2Cnn(float *d_infCnnBnMeanOutput, float *d_infCnnBnVar2Output);
extern __global__ void kernelInferenceBnMeanVar2Mlp(float *d_infMlpBnMeanOutput, float *d_infMlpBnVar2Output);

void inferenceBnMeanVar2(const int episode, float *infCnnBnMean, float *infCnnBnVar2, float *infMlpBnMean, float *infMlpBnVar2){

//	puts("inferenceBnMeanVar2 start.");

	float *d_infCnnBnMeanOutput;
	float *d_infCnnBnVar2Output;
	float *d_infMlpBnMeanOutput;
	float *d_infMlpBnVar2Output;

	//1エピソード分のサイズを計算
	int infCnnBnMeanVar2DataSize = sizeof(float) * getCnnOutputNumsSum();
	int infMlpBnMeanVar2DataSize = sizeof(float) * getMlpOutputNumsSum();
//	printf("epiNums:%d\n",episode);
//	printf("cnnsize:%d\n",infCnnBnMeanVar2DataSize);
//	printf("mlpsize:%d\n",infMlpBnMeanVar2DataSize);
	//GPUの動的確保
	gpuErrchk(cudaMalloc((void**)&d_infCnnBnMeanOutput, infCnnBnMeanVar2DataSize));
	gpuErrchk(cudaMalloc((void**)&d_infCnnBnVar2Output, infCnnBnMeanVar2DataSize));
	gpuErrchk(cudaMalloc((void**)&d_infMlpBnMeanOutput, infMlpBnMeanVar2DataSize));
	gpuErrchk(cudaMalloc((void**)&d_infMlpBnVar2Output, infMlpBnMeanVar2DataSize));

	//使用データをデバイスにコピー
	//何も必要なし。計算済みのmean,var2をホストに移すだけだからである。

	//cnnのブロック・スレッド定義
	dim3 gridCnn(getCnnOutputNumsSum(), 1, 1);
	dim3 blockCnn(1, 1, 1);
	//mlpのブロック・スレッド定義
	dim3 gridMlp(getMlpOutputNumsSum(), 1, 1);
	dim3 blockMlp(1, 1, 1);

	//次元チェック
	checkGridSize(gridCnn);
	checkThreadSize(blockCnn);
	checkGridSize(gridMlp);
	checkThreadSize(blockMlp);

	//カーネル起動
//	puts("kernelInferenceBnMeanVar2 start");
	kernelInferenceBnMeanVar2Cnn<<<gridCnn, blockCnn>>>(d_infCnnBnMeanOutput, d_infCnnBnVar2Output);
	kernelInferenceBnMeanVar2Mlp<<<gridMlp, blockMlp>>>(d_infMlpBnMeanOutput, d_infMlpBnVar2Output);
	cudaDeviceSynchronize();
//	puts("kernelInferenceBnMeanVar2 end");

	//デバイスからホストへメモリ転送
	//GPUメモリより、更新されたデータをメモリにコピー
	float *h_infCnnBnMeanOutput; //host
	float *h_infCnnBnVar2Output; //host
	float *h_infMlpBnMeanOutput; //host
	float *h_infMlpBnVar2Output; //host
	//上記変数の動的確保
	h_infCnnBnMeanOutput = (float *)malloc(infCnnBnMeanVar2DataSize); 
	h_infCnnBnVar2Output = (float *)malloc(infCnnBnMeanVar2DataSize); 
	h_infMlpBnMeanOutput = (float *)malloc(infMlpBnMeanVar2DataSize);
	h_infMlpBnVar2Output = (float *)malloc(infMlpBnMeanVar2DataSize);
	//GPUからh_*にコピー
	gpuErrchk(cudaMemcpy(h_infCnnBnMeanOutput, d_infCnnBnMeanOutput, infCnnBnMeanVar2DataSize, cudaMemcpyDeviceToHost));
	gpuErrchk(cudaMemcpy(h_infCnnBnVar2Output, d_infCnnBnVar2Output, infCnnBnMeanVar2DataSize, cudaMemcpyDeviceToHost));
	gpuErrchk(cudaMemcpy(h_infMlpBnMeanOutput, d_infMlpBnMeanOutput, infMlpBnMeanVar2DataSize, cudaMemcpyDeviceToHost));
	gpuErrchk(cudaMemcpy(h_infMlpBnVar2Output, d_infMlpBnVar2Output, infMlpBnMeanVar2DataSize, cudaMemcpyDeviceToHost));
	//inf*にh_*をコピー
	//infCnnBnMeanVar2DataSizeが常に一定であるため以下の通り記述できる。floatでわることを忘れずに。
	copyFloatArray(h_infCnnBnMeanOutput, infCnnBnMean, infCnnBnMeanVar2DataSize, (infCnnBnMeanVar2DataSize * episode / sizeof(float)));
	copyFloatArray(h_infCnnBnVar2Output, infCnnBnVar2, infCnnBnMeanVar2DataSize, (infCnnBnMeanVar2DataSize * episode / sizeof(float)));
	copyFloatArray(h_infMlpBnMeanOutput, infMlpBnMean, infMlpBnMeanVar2DataSize, (infMlpBnMeanVar2DataSize * episode / sizeof(float)));
	copyFloatArray(h_infMlpBnVar2Output, infMlpBnVar2, infMlpBnMeanVar2DataSize, (infMlpBnMeanVar2DataSize * episode / sizeof(float)));

	//メモリの解放
	free(h_infCnnBnMeanOutput);
	free(h_infCnnBnVar2Output);
	free(h_infMlpBnMeanOutput);
	free(h_infMlpBnVar2Output);
	gpuErrchk(cudaFree(d_infCnnBnMeanOutput));
	gpuErrchk(cudaFree(d_infCnnBnVar2Output));
	gpuErrchk(cudaFree(d_infMlpBnMeanOutput));
	gpuErrchk(cudaFree(d_infMlpBnVar2Output));

//	puts("inferenceBnMeanVar2 end.");

}

__global__ void kernelInferenceBnMeanVar2Cnn(float *d_infCnnBnMeanOutput, float *d_infCnnBnVar2Output){

	int cnnOutputNumsIdx = blockIdx.x;

	d_infCnnBnMeanOutput[cnnOutputNumsIdx] = dCnnBnMean[cnnOutputNumsIdx];
	d_infCnnBnVar2Output[cnnOutputNumsIdx] = dCnnBnVar2[cnnOutputNumsIdx];

}

__global__ void kernelInferenceBnMeanVar2Mlp(float *d_infMlpBnMeanOutput, float *d_infMlpBnVar2Output){

	int mlpOutputNumsIdx = blockIdx.x;

	d_infMlpBnMeanOutput[mlpOutputNumsIdx] = dMlpBnMean[mlpOutputNumsIdx];
	d_infMlpBnVar2Output[mlpOutputNumsIdx] = dMlpBnVar2[mlpOutputNumsIdx];

}
