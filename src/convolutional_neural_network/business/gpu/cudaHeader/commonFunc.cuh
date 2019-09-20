#ifndef INCLUDED_COMMON_FUNC
#define INCLUDED_COMMON_FUNC

#include <stdio.h>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh>
#include <time.h>

void copyFloatArray(float *fromArray, float *toArray, int ArrayDataSize, int startIdx){
	int i;
	for(i = 0; i < ArrayDataSize / sizeof(float); i++){
		toArray[i+startIdx] = fromArray[i];
		//		printf("toArray[%d]: %f\n",startIdx+i,toArray[startIdx + i]);
	}
}

int getRandomInt(int minValue, int maxValue){
	int randomValue = rand() % maxValue + minValue;
	return(randomValue);
}

void printTime(struct timeval t1, struct timeval t2, struct timeval t3){
	printf("LOG:t1~t2 : %f\n", (t2.tv_sec - t1.tv_sec) + (t2.tv_usec - t1.tv_usec)*1.0E-6);
	printf("LOG:t2~t3 : %f\n", (t3.tv_sec - t2.tv_sec) + (t3.tv_usec - t2.tv_usec)*1.0E-6);
	printf("LOG:SUM   : %f\n", (t3.tv_sec - t1.tv_sec) + (t3.tv_usec - t1.tv_usec)*1.0E-6);
}

__device__
float floatSubtraction(const float val1Float, const float val2Float, const int layer, const char *functionName){
	float divideValue = val1Float + val2Float + 0.000001;
	if(abs(divideValue) < 0.00001){
		printf("warn:%f,%f [%s(%d)]\n", val1Float, val2Float, functionName, layer);
		return(val1Float - val2Float);
	}
	else{
		float digitFloatVal = ((val1Float * val1Float) - (val2Float * val2Float)) / divideValue;
		return(digitFloatVal);
	}
}
__device__
void floatSubtractionPrint(const float val1Float, const float val2Float){
	float digitFloatVal = ((val1Float * val1Float) - (val2Float * val2Float)) / (val1Float + val2Float + 0.000001);
	printf("val1F: %f, val2F: %f ==> %f\n", val1Float,val2Float,digitFloatVal);
}

//シェアードメモリに格納したデータの合計値を求める関数
__device__
float culcurateSum(const float *element, const int threadIdxNo){

	float sum = 0;
	int numDef = getCWarpNums();

	//途中計算用のメモリ
	__shared__ float s[warpNums];

	int i;
	for(i = 0; i < numDef; i++){
		//	printf("s[%d]=%f ",i,s[i]);
		s[i] = 0.0f;
	}
	__threadfence();

	//足し合わせる
	atomicAdd(&s[threadIdxNo % numDef], element[threadIdxNo]);
	__threadfence();
	/*
	if(threadIdxNo % numDef == 0 ||threadIdxNo % numDef == 31){
		printf("sum:%f element:%f(%d)\n", s[threadIdxNo], element[threadIdxNo], threadIdxNo);
	}
	*/

	sum = s[0] + s[1] +  s[2] +  s[3] +  s[4] +  s[5] +  s[6] +  s[7] +  s[8] +  s[9] +  s[10] +  s[11] +  s[12] +  s[13] +  s[14] +  s[15] +  s[16] +  s[17] +  s[18] +  s[19] +  s[20] +  s[21] +  s[22] +  s[23] +  s[24] +  s[25] +  s[26] +  s[27] +  s[28] +  s[29] +  s[30] +  s[31];

	/*
	if(threadIdxNo == 0){
		printf("sum[%d]=%f  ",threadIdxNo,sum);
		int i;
		for(i = 0; i < numDef; i++){
			printf("s[%d]=%f ",i,s[i]);
		}
	}
	*/
	return(sum);
}

void printResult(){

	int miniBatchIdx, outputIdx;
	for(miniBatchIdx = 0; miniBatchIdx < getMiniBatchNums(); miniBatchIdx++){
		for(outputIdx = 0; outputIdx < getMlpOutputNums(getMlpOutputNumsNums() - 1); outputIdx++){
			printf("result(%d,%d) = %f\n", miniBatchIdx, outputIdx, getResult(outputIdx, miniBatchIdx));
		}
	}
}

void printVar2(){

	float *hostCnnVar2;
	float *hostMlpVar2;

	int hostCnnVar2Size = sizeof(float) * getCnnOutputNumsSum();
	int hostMlpVar2Size = sizeof(float) * getMlpOutputNumsSum();

	hostCnnVar2 = (float *)malloc(hostCnnVar2Size);
	hostMlpVar2 = (float *)malloc(hostMlpVar2Size);

	//gpuErrchk(cudaMemcpy(hostCnnVar2, dCnnBnVar2, hostCnnVar2Size, cudaMemcpyDeviceToHost));
	gpuErrchk(cudaMemcpyFromSymbol(hostCnnVar2, dCnnBnVar2, hostCnnVar2Size));
	//gpuErrchk(cudaMemcpy(hostMlpVar2, dMlpBnVar2, hostMlpVar2Size, cudaMemcpyDeviceToHost));
	gpuErrchk(cudaMemcpyFromSymbol(hostMlpVar2, dMlpBnVar2, hostMlpVar2Size));

	int i;
	for(i = 0; i < hostCnnVar2Size / sizeof(float); i++){
		printf("cnnVar2[%d]=%f\n", i, hostCnnVar2[i]);
	}
	for(i = 0; i < hostMlpVar2Size / sizeof(float); i++){
		printf("mlpVar2[%d]=%f\n", i, hostMlpVar2[i]);
	}
}

void printCnnMlpBnBeta(){

	float *hostCnnBnBeta;
	float *hostMlpBnBeta;

	int hostCnnBnBetaSize = sizeof(float) * getCnnOutputNumsSum();
	int hostMlpBnBetaSize = sizeof(float) * getMlpOutputNumsSum();

	hostCnnBnBeta = (float *)malloc(hostCnnBnBetaSize);
	hostMlpBnBeta = (float *)malloc(hostMlpBnBetaSize);

	//gpuErrchk(cudaMemcpy(hostCnnVar2, dCnnBnVar2, hostCnnVar2Size, cudaMemcpyDeviceToHost));
	gpuErrchk(cudaMemcpyFromSymbol(hostCnnBnBeta, dCnnBnBeta, hostCnnBnBetaSize));
	//gpuErrchk(cudaMemcpy(hostMlpVar2, dMlpBnVar2, hostMlpVar2Size, cudaMemcpyDeviceToHost));
	gpuErrchk(cudaMemcpyFromSymbol(hostMlpBnBeta, dMlpBnBeta, hostMlpBnBetaSize));

	int i;
	for(i = 0; i < hostCnnBnBetaSize / sizeof(float); i++){
		printf("cnnBnBeta[%d]=%f\n", i, hostCnnBnBeta[i]);
	}
	for(i = 0; i < hostMlpBnBetaSize / sizeof(float); i++){
		printf("mlpBnBeta[%d]=%f\n", i, hostMlpBnBeta[i]);
	}
}

void printCnnMlpBnGamma(){

	float *hostCnnBnGamma;
	float *hostMlpBnGamma;

	int hostCnnBnGammaSize = sizeof(float) * getCnnOutputNumsSum();
	int hostMlpBnGammaSize = sizeof(float) * getMlpOutputNumsSum();

	hostCnnBnGamma = (float *)malloc(hostCnnBnGammaSize);
	hostMlpBnGamma = (float *)malloc(hostMlpBnGammaSize);

	//gpuErrchk(cudaMemcpy(hostCnnVar2, dCnnBnVar2, hostCnnVar2Size, cudaMemcpyDeviceToHost));
	gpuErrchk(cudaMemcpyFromSymbol(hostCnnBnGamma, dCnnBnGamma, hostCnnBnGammaSize));
	//gpuErrchk(cudaMemcpy(hostMlpVar2, dMlpBnVar2, hostMlpVar2Size, cudaMemcpyDeviceToHost));
	gpuErrchk(cudaMemcpyFromSymbol(hostMlpBnGamma, dMlpBnGamma, hostMlpBnGammaSize));

	int i;
	for(i = 0; i < hostCnnBnGammaSize / sizeof(float); i++){
		printf("cnnBnGamma[%d]=%f\n", i, hostCnnBnGamma[i]);
	}
	for(i = 0; i < hostMlpBnGammaSize / sizeof(float); i++){
		printf("mlpBnGamma[%d]=%f\n", i, hostMlpBnGamma[i]);
	}
}

void printCnnMlpW(){

	float *hostCnnW;
	float *hostMlpW;

	int hostCnnWSize = sizeof(float) * getCnnWDataNums();
	int hostMlpWSize = sizeof(float) * getMlpWDataNums();

	hostCnnW = (float *)malloc(hostCnnWSize);
	hostMlpW = (float *)malloc(hostMlpWSize);

	//gpuErrchk(cudaMemcpy(hostCnnVar2, dCnnBnVar2, hostCnnVar2Size, cudaMemcpyDeviceToHost));
	gpuErrchk(cudaMemcpyFromSymbol(hostCnnW, dCnnW, hostCnnWSize));
	//gpuErrchk(cudaMemcpy(hostMlpVar2, dMlpBnVar2, hostMlpVar2Size, cudaMemcpyDeviceToHost));
	gpuErrchk(cudaMemcpyFromSymbol(hostMlpW, dMlpW, hostMlpWSize));

	int i;
	for(i = 0; i < hostCnnWSize / sizeof(float); i++){
		printf("cnnW[%d]=%f  ", i, hostCnnW[i]);
	}
	printf("\n");
	for(i = 0; i < hostMlpWSize / sizeof(float); i++){
		printf("mlpW[%d]=%f  ", i, hostMlpW[i]);
	}
}

#endif
