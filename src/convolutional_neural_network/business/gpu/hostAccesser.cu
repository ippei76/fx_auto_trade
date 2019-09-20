//host処理系のグローバル変数定義
#ifndef INCLUDED_HOSTVALUESACCESSER
#define INCLUDED_HOSTVALUESACCESSER
#include <stdio.h>

int cnnOutputNumsNums;
int *cnnOutputNums;

int execFlg;
int execFlgTraining = 0;
int execFlgOnline = 1;

int sv_xNums;
int sv_yNums;
int svChannelNums;
int miniBatchNums;

float *cnnBnBeta;
float *cnnBnGamma;
float bnEps;

int cnnW_xNums;
int cnnW_yNums;
int cnnWDataNums;
float *cnnW;

int *cnnWba_xNums;
int *cnnWba_yNums;

int *cnnP_xNums;
int *cnnP_yNums;

int cnnPooling_xNums;
int cnnPooling_yNums;

int mlpOutputNumsNums;
int *mlpOutputNums;

float *mlpBnBeta;
float *mlpBnGamma;
int mlpWDataNums;
float *mlpW;

float *teachOut;
float *result;

float learningRate;

float E = 0;

extern __device__ __host__ int getDim2Idx(int x, int y, int X);
extern __device__ __host__ int getDim4Idx(int x, int y, int z, int a, int X, int Y, int Z);
extern int getCnnInputIdxNums(int cnnLayer);
extern int getMlpInputIdxNums(int cnnLayer);
extern int getMlpOutputNumsNums();
extern int getMlpOutputNums(int mlpLayer);
extern int getCnnWba_xNums(int cnnLayer);
extern int getCnnWba_yNums(int cnnLayer);
extern int getHMlpWbaIdx(int outputIdx, int miniBatchIdx, int mlpLayer);
extern int getHCnnWbaIdx(int x, int y, int outputIdx, int miniBatchIdx, int cnnLayer);

void setExecFlg(int execFlg_arg){
	execFlg = execFlg_arg;
}
int getExecFlg(){
	return(execFlg);
}
int getExecFlgTraining(){
	return(execFlgTraining);
}
int getExecFlgOnline(){
	return(execFlgOnline);
}
void setSv_xNums(int sv_xNums_arg){
	sv_xNums = sv_xNums_arg;
}
int getSv_xNums(){
	return(sv_xNums);
}
void setSv_yNums(int sv_yNums_arg){
	sv_yNums = sv_yNums_arg;
}
int getSv_yNums(){
	return(sv_yNums);
}
void setMiniBatchNums(int miniBatchNums_arg){
	miniBatchNums = miniBatchNums_arg;
}
int getMiniBatchNums(){
	return(miniBatchNums);
}
void setSvChannelNums(int svChannelNums_arg){
	svChannelNums = svChannelNums_arg;
}
int getSvChannelNums(){
	return(svChannelNums);
}
void setCnnOutputNumsNums(int cnnOutputNumsNums_arg){
	cnnOutputNumsNums = cnnOutputNumsNums_arg;
}
int getCnnOutputNumsNums(){
	return(cnnOutputNumsNums);
}
void setCnnOutputNums(int *cnnOutputNums_arg){
	cnnOutputNums = cnnOutputNums_arg;
}
int getCnnOutputNums(int cnnLayer){
	return(cnnOutputNums[cnnLayer]);
}
void setCnnBnBeta(float *cnnBnBeta_arg){
	cnnBnBeta = cnnBnBeta_arg;
}
void setLearningRate(float learningRate_arg){
	learningRate = learningRate_arg;
}
float getLearningRate(){
	return(learningRate);
}
int getHCnnBnBetaGammaIdx(int outputIdx, int cnnLayer){
	int layer;
	int idx = 0;
	for(layer = 0; layer < cnnLayer; layer ++){
		idx += getCnnOutputNums(layer);
	}
	idx += outputIdx;
	return(idx);
}
float getCnnBnBeta(int outputIdx, int cnnLayer){
	return(cnnBnBeta[getHCnnBnBetaGammaIdx(outputIdx, cnnLayer)]);
}
void setCnnBnGamma(float *cnnBnGamma_arg){
	cnnBnGamma = cnnBnGamma_arg;
}
float getCnnBnGamma(int outputIdx, int cnnLayer){
	return(cnnBnGamma[getHCnnBnBetaGammaIdx(outputIdx, cnnLayer)]);
}
void setBnEps(float bnEps_arg){
	bnEps = bnEps_arg;
}
float getBnEps(){
	return(bnEps);
}
void setCnnW_xNums(int cnnW_xNums_arg){
	cnnW_xNums = cnnW_xNums_arg;
}
int getCnnW_xNums(){
	return(cnnW_xNums);
}
void setCnnW_yNums(int cnnW_yNums_arg){
	cnnW_yNums = cnnW_yNums_arg;
}
int getCnnW_yNums(){
	return(cnnW_yNums);
}
void setCnnWDataNums(int cnnWDataNums_arg){
	cnnWDataNums = cnnWDataNums_arg;
}
int getCnnWDataNums(){
	return(cnnWDataNums);
}
void setCnnW(float *cnnW_arg){
	cnnW = cnnW_arg;
}
int getHCnnWIdx(int x, int y, int inputIdx, int outputIdx, int cnnLayer){
	int layer;
	int idx = 0;
	for(layer = 0; layer < cnnLayer; layer ++){
		idx += getCnnW_xNums() * getCnnW_yNums() * getCnnInputIdxNums(layer) * getCnnOutputNums(layer);
	}
	int inputIdxNums = getCnnInputIdxNums(cnnLayer);
	idx += getDim4Idx(x, y, inputIdx, outputIdx, getCnnW_xNums(), getCnnW_yNums(), inputIdxNums);
	return(idx);
}
float getCnnW(int x, int y, int inputIdx, int outputIdx, int cnnLayer){
	return(cnnW[getHCnnWIdx(x, y, inputIdx, outputIdx, cnnLayer)]);
}
void setCnnWba_xNums(int *cnnWba_xNums_arg){
	cnnWba_xNums = cnnWba_xNums_arg;
}
int getCnnWba_xNums(int cnnLayer){
	return(cnnWba_xNums[cnnLayer]);
}
void setCnnWba_yNums(int *cnnWba_yNums_arg){
	cnnWba_yNums = cnnWba_yNums_arg;
}
int getCnnWba_yNums(int cnnLayer){
	return(cnnWba_yNums[cnnLayer]);
}
int getHCnnWbaIdx(int x, int y, int outputIdx, int miniBatchIdx, int cnnLayer){
	int idx = 0;
	int layer;
	for(layer = 0; layer < cnnLayer; layer ++){
		idx += getCnnWba_xNums(layer) * getCnnWba_yNums(layer) * getCnnOutputNums(layer) * getMiniBatchNums();
	}
	idx += getDim4Idx(x, y, outputIdx, miniBatchIdx, getCnnWba_xNums(cnnLayer), getCnnWba_yNums(cnnLayer), getCnnOutputNums(cnnLayer));
	return(idx);
}
void setCnnP_xNums(int *cnnP_xNums_arg){
	cnnP_xNums = cnnP_xNums_arg;
}
int getCnnP_xNums(int cnnLayer){
	return(cnnP_xNums[cnnLayer]);
}
void setCnnP_yNums(int *cnnP_yNums_arg){
	cnnP_yNums = cnnP_yNums_arg;
}
int getCnnP_yNums(int cnnLayer){
	return(cnnP_yNums[cnnLayer]);
}
void setCnnPooling_xNums(int cnnPooling_xNums_arg){
	cnnPooling_xNums = cnnPooling_xNums_arg;
}
int getCnnPooling_xNums(){
	return(cnnPooling_xNums);
}
void setCnnPooling_yNums(int cnnPooling_yNums_arg){
	cnnPooling_yNums = cnnPooling_yNums_arg;
}
int getCnnPooling_yNums(){
	return(cnnPooling_yNums);
}
void setMlpOutputNumsNums(int mlpOutputNumsNums_arg){
	mlpOutputNumsNums = mlpOutputNumsNums_arg;
}
int getMlpOutputNumsNums(){
	return(mlpOutputNumsNums);
}
void setMlpOutputNums(int *mlpOutputNums_arg){
	mlpOutputNums = mlpOutputNums_arg;
}
int getMlpOutputNums(int mlpLayer){
	return(mlpOutputNums[mlpLayer]);
}
void setMlpBnBeta(float *mlpBnBeta_arg){
	mlpBnBeta = mlpBnBeta_arg;
}
int getHMlpBnBetaGammaIdx(int outputIdx, int mlpLayer){
	int layer;
	int idx = 0;
	for(layer = 0; layer < mlpLayer; layer ++){
		idx += getMlpOutputNums(layer);
	}
	idx += outputIdx;
	return(idx);
}
float getMlpBnBeta(int outputIdx, int mlpLayer){
	return(mlpBnBeta[getHMlpBnBetaGammaIdx(outputIdx, mlpLayer)]);
}
void setMlpBnGamma(float *mlpBnGamma_arg){
	mlpBnGamma = mlpBnGamma_arg;
}
float getMlpBnGamma(int outputIdx, int mlpLayer){
	return(mlpBnGamma[getHMlpBnBetaGammaIdx(outputIdx, mlpLayer)]);
}
void setMlpWDataNums(int mlpWDataNums_arg){
	mlpWDataNums = mlpWDataNums_arg;
}
int getMlpWDataNums(){
	return(mlpWDataNums);
}
void setMlpW(float *mlpW_arg){
	mlpW = mlpW_arg;
}
int getHMlpWIdx(int inputIdx, int outputIdx, int mlpLayer){
	int layer;
	int idx = 0;
	for(layer = 0; layer < mlpLayer; layer ++){
		idx += getMlpInputIdxNums(layer) * getMlpOutputNums(layer);
	}
	int inputIdxNums = getMlpInputIdxNums(mlpLayer);
	idx += getDim2Idx(inputIdx, outputIdx, inputIdxNums);
	return(idx);
}
float getMlpW(int inputIdx, int outputIdx, int mlpLayer){
	return(mlpW[getHMlpWIdx(inputIdx, outputIdx, mlpLayer)]);
}
int getHMlpWbaIdx(int outputIdx, int miniBatchIdx, int mlpLayer){
	int idx = 0;
	int layer;
	for(layer = 0; layer < mlpLayer; layer ++){
		idx += getMlpOutputNums(layer) * getMiniBatchNums();
	}
	idx += getDim2Idx(outputIdx, miniBatchIdx, getMlpOutputNums(mlpLayer));
	return(idx);
}
void setResult(float *result_arg){
	result = result_arg;
}
void setTeachOut(float *teachOut_arg){
	teachOut = teachOut_arg;
}
int getTeachOutResultIdx(int outputIdx, int miniBatchIdx){
	return(getDim2Idx(outputIdx, miniBatchIdx, getMlpOutputNums(getMlpOutputNumsNums() - 1)));
}
float getResult(int outputIdx, int miniBatchIdx){
	return(result[getTeachOutResultIdx(outputIdx, miniBatchIdx)]);
}
float getTeachOut(int outputIdx, int miniBatchIdx){
	return(teachOut[getTeachOutResultIdx(outputIdx, miniBatchIdx)]);
}

__device__ __host__
int getDim2Idx(int x, int y, int X){
	return(x + y * X);
}
__device__ __host__
int getDim3Idx(int x, int y, int z, int X, int Y){
	return(getDim2Idx(x, y, X) + z * X * Y);
}
__device__ __host__
int getDim4Idx(int x, int y, int z, int a, int X, int Y, int Z){
	return(getDim3Idx(x, y, z, X, Y) + a * X * Y * Z);
}
__device__ __host__
int getDim5Idx(int x, int y, int z, int a, int b, int X, int Y, int Z, int A){
	return(getDim4Idx(x, y, z, a, X, Y, Z) + b * X * Y * Z * A);
}
//CNN層のinputの総数を取得する。
int getCnnInputIdxNums(int cnnLayer){
	int inputIdxNums;
	if(cnnLayer == 0){
		inputIdxNums = getSvChannelNums();
	}
	else{
		inputIdxNums = getCnnOutputNums(cnnLayer - 1);
	}
	return(inputIdxNums);
}
//MLP層のinputの総数を取得する。
int getMlpInputIdxNums(int mlpLayer){
	int inputIdxNums;
	if(mlpLayer == 0){
		int cnnOutputNumsLastIdx = getCnnOutputNumsNums() - 1;
		inputIdxNums = getCnnP_xNums(cnnOutputNumsLastIdx) * getCnnP_yNums(cnnOutputNumsLastIdx) * getCnnOutputNums(cnnOutputNumsLastIdx);
	}
	else{
		inputIdxNums = getMlpOutputNums(mlpLayer - 1);
	}
	return(inputIdxNums);
}
//CNN層の全outputの合計値を取得する。
int getCnnOutputNumsSum(){
	int layer;
	int count = 0;
	for(layer = 0; layer < getCnnOutputNumsNums(); layer++){
		count += getCnnOutputNums(layer);
	}
	return(count);
}
//MLP層の全outputの合計値を取得する。
int getMlpOutputNumsSum(){
	int layer;
	int count = 0;
	for(layer = 0; layer < getMlpOutputNumsNums(); layer++){
		count += getMlpOutputNums(layer);
	}
	return(count);
}
#endif
