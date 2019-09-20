//device処理系のグローバル変数定義
#ifndef INCLUDED_DEVICEVALUESACCESSER
#define INCLUDED_DEVICEVALUESACCESSER
#include <stdio.h>
#include <constraint.cuh>
#include <hostParameters.cuh>

__constant__ int cWarpNums = warpNums;
//ノード変数
//sv,teachOut
__device__ float dSv[maxInputDataNums];
__device__ float dTeachOut[maxOutputDataNums];
__device__ float dResult[maxOutputDataNums];
//cnn,cnnBack
__device__ float dCnnWb[maxCnnWbaDataNums];
__device__ float dCnnBn[maxCnnWbaDataNums];
__device__ float dCnnA[maxCnnWbaDataNums];
__device__ float dCnnP[maxCnnPDataNums];
__device__ float dCnnWbBack[maxCnnWbaDataNums];
__device__ float dCnnBnBack[maxCnnWbaDataNums];
__device__ float dCnnABack[maxCnnWbaDataNums];
__device__ float dCnnPBack[maxCnnPDataNums];
//mlp
__device__ float dMlpWb[maxMlpWbaDataNums];
__device__ float dMlpBn[maxMlpWbaDataNums];
__device__ float dMlpA[maxMlpWbaDataNums];
__device__ float dMlpWbBack[maxMlpWbaDataNums];
__device__ float dMlpBnBack[maxMlpWbaDataNums];
__device__ float dMlpABack[maxMlpWbaDataNums];

//学習変数
//cnn
__device__ float dCnnW[maxCnnWDataNums];
__device__ float dCnnBnBeta[maxCnnLayerNumsSum];
__device__ float dCnnBnGamma[maxCnnLayerNumsSum];
//mlp
__device__ float dMlpW[maxMlpWDataNums];
__device__ float dMlpBnBeta[maxMlpLayerNumsSum];
__device__ float dMlpBnGamma[maxMlpLayerNumsSum];

//各種値
//sv
__constant__ int cSvChannelNums; //配列だから、固定でMAX値を割り当てておく
__constant__ int cSv_xNums; //配列だから、固定でMAX値を割り当てておく
__constant__ int cSv_yNums; //配列だから、固定でMAX値を割り当てておく
//ノード数
__constant__ int cCnnOutputNums[maxCnnOutputNumsNums];
__constant__ int cMlpOutputNums[maxMlpOutputNumsNums];
__constant__ int cCnnOutputNumsNums;
__constant__ int cMlpOutputNumsNums;
//出力(wba, p)：
__constant__ int cCnnWba_xNums[maxCnnOutputNumsNums]; //配列だから、固定でMAX値を割り当てておく
__constant__ int cCnnWba_yNums[maxCnnOutputNumsNums]; //配列だから、固定でMAX値を割り当てておく
__constant__ int cCnnP_xNums[maxCnnOutputNumsNums]; //配列だから、固定でMAX値を割り当てておく
__constant__ int cCnnP_yNums[maxCnnOutputNumsNums]; //配列だから、固定でMAX値を割り当てておく
//cnnW
__constant__ int cCnnW_xNums;
__constant__ int cCnnW_yNums;
//cnnPooling
__constant__ int cCnnPooling_xNums;
__constant__ int cCnnPooling_yNums;
//その他
__constant__ int cMiniBatchNums;
//batch normalizationの計算途中で使用する「平均」「分散」を保存する。
//backで使用する。
__device__ float dCnnBnAverage_culcu1[maxCnnOutputNums * maxMiniBatchNums];
__device__ float dCnnBackDelTmp1_culcu[maxCnnOutputNums * maxMiniBatchNums];
__device__ float dCnnBackDelTmp2_culcu[maxCnnOutputNums * maxMiniBatchNums];
__device__ float dCnnBackDel2Tmp[maxCnnOutputNums];
__device__ float dCnnBackDel3Tmp[maxCnnOutputNums];
__device__ float dCnnBackDelGamma[maxCnnOutputNums];
__device__ float dCnnBackDelBeta[maxCnnOutputNums];
__device__ float dCnnBnMean[maxCnnLayerNumsSum];
__device__ float dCnnBnVar2[maxCnnLayerNumsSum];
__device__ float dMlpBnMean[maxMlpLayerNumsSum];
__device__ float dMlpBnVar2[maxMlpLayerNumsSum];

//オンラインにて使用するオンラインの平均,分散
__constant__ float cCnnBnAveMean[maxCnnLayerNumsSum];
__constant__ float cCnnBnAveVar2[maxCnnLayerNumsSum];
__constant__ float cMlpBnAveMean[maxMlpLayerNumsSum];
__constant__ float cMlpBnAveVar2[maxMlpLayerNumsSum];

//learning Rate
__constant__ float cLearningRate;

//extern
__device__ int getDCnnInputIdxNums(int cnnLayer);
__device__ int getDMlpInputIdxNums(int mlpLayer);

//アクセッサ
__device__ int getCWarpNums(){
	return(cWarpNums);
}
//sv
__device__ int getCSvChannelNums(){
	return(cSvChannelNums);
}
__device__ int getCSv_xNums(){
	return(cSv_xNums);
}
__device__ int getCSv_yNums(){
	return(cSv_yNums);
}
//ノード数
__device__ int getCCnnOutputNums(int cnnLayer){
		return(cCnnOutputNums[cnnLayer]);
}
__device__ int getCMlpOutputNums(int mlpLayer){
	return(cMlpOutputNums[mlpLayer]);
}
__device__ int getCCnnOutputNumsNums(){
		return(cCnnOutputNumsNums);
}
__device__ int getCMlpOutputNumsNums(){
	return(cMlpOutputNumsNums);
}
//出力(wba, p)：
__device__ int getCCnnWba_xNums(int cnnLayer){
       return(cCnnWba_xNums[cnnLayer]);
}
__device__ int getCCnnWba_yNums(int cnnLayer){
       return(cCnnWba_yNums[cnnLayer]);
}
__device__ int getCCnnP_xNums(int cnnLayer){
       return(cCnnP_xNums[cnnLayer]);
}
__device__ int getCCnnP_yNums(int cnnLayer){
       return(cCnnP_yNums[cnnLayer]);
}
//cnnW
__device__ int getCCnnW_xNums(){
       return(cCnnW_xNums);
}
__device__ int getCCnnW_yNums(){
       return(cCnnW_yNums);
}
//cnnPooling
__device__ int getCCnnPooling_xNums(){
       return(cCnnPooling_xNums);
}
__device__ int getCCnnPooling_yNums(){
       return(cCnnPooling_yNums);
}
//その他
__device__ int getCMiniBatchNums(){
	return(cMiniBatchNums);
}
__device__ float getCLearningRate(){
	return(cLearningRate);
}

//ノード変数のアクセッサ
//sv,teachOut
__device__ float getDSv(int x, int y, int inputIdx, int miniBatchIdx){
	int idx = getDim4Idx(x, y, inputIdx, miniBatchIdx, getCSv_xNums(), getCSv_yNums(), getCSvChannelNums());
	return(dSv[idx]);
}
__device__ float getDTeachOut(int outputIdx, int miniBatchIdx){
	int outputIdxNums = getCMlpOutputNums(getCMlpOutputNumsNums() - 1);
	int idx = getDim2Idx(outputIdx, miniBatchIdx, outputIdxNums);
	return(dTeachOut[idx]);
}
//cnn
__device__ int getDCnnWbaIdx(int x, int y, int outputIdx, int miniBatchIdx, int cnnLayer){
	int idx = 0;
	int layer;
	for(layer = 0; layer < cnnLayer; layer ++){
		idx += getCCnnWba_xNums(layer) * getCCnnWba_yNums(layer) * getCCnnOutputNums(layer) * getCMiniBatchNums();
	}
	idx += getDim4Idx(x, y, outputIdx, miniBatchIdx, getCCnnWba_xNums(cnnLayer), getCCnnWba_yNums(cnnLayer), getCCnnOutputNums(cnnLayer));
	return(idx);
}
__device__ int getDCnnPIdx(int x, int y, int outputIdx, int miniBatchIdx, int cnnLayer){
	int idx = 0;
	int layer;
	for(layer = 0; layer < cnnLayer; layer ++){
		idx += getCCnnP_xNums(layer) * getCCnnP_yNums(layer) * getCCnnOutputNums(layer) * getCMiniBatchNums();
	}
	idx += getDim4Idx(x, y, outputIdx, miniBatchIdx, getCCnnP_xNums(cnnLayer), getCCnnP_yNums(cnnLayer), getCCnnOutputNums(cnnLayer));
	return(idx);
}
__device__ float getDCnnWb(int x, int y, int outputIdx, int miniBatchIdx, int cnnLayer){
	return(dCnnWb[getDCnnWbaIdx(x, y, outputIdx, miniBatchIdx, cnnLayer)]);
}
__device__ float getDCnnA(int x, int y, int outputIdx, int miniBatchIdx, int cnnLayer){
	return(dCnnA[getDCnnWbaIdx(x, y, outputIdx, miniBatchIdx, cnnLayer)]);
}
__device__ float getDCnnBn(int x, int y, int inputIdx, int miniBatchIdx, int cnnLayer){
	return(dCnnBn[getDCnnWbaIdx(x, y, inputIdx, miniBatchIdx, cnnLayer)]);
}
__device__ float getDCnnP(int x, int y, int outputIdx, int miniBatchIdx, int cnnLayer){
	return(dCnnP[getDCnnPIdx(x, y, outputIdx, miniBatchIdx, cnnLayer)]);
}
__device__ float getDCnnWbBack(int x, int y, int outputIdx, int miniBatchIdx, int cnnLayer){
	return(dCnnWbBack[getDCnnWbaIdx(x, y, outputIdx, miniBatchIdx, cnnLayer)]);
}
__device__ float getDCnnABack(int x, int y, int outputIdx, int miniBatchIdx, int cnnLayer){
	return(dCnnABack[getDCnnWbaIdx(x, y, outputIdx, miniBatchIdx, cnnLayer)]);
}
__device__ float getDCnnBnBack(int x, int y, int inputIdx, int miniBatchIdx, int cnnLayer){
	return(dCnnBnBack[getDCnnWbaIdx(x, y, inputIdx, miniBatchIdx, cnnLayer)]);
}
__device__ float getDCnnPBack(int x, int y, int outputIdx, int miniBatchIdx, int cnnLayer){
	return(dCnnPBack[getDCnnPIdx(x, y, outputIdx, miniBatchIdx, cnnLayer)]);
}
//mlp
__device__ int getDMlpWbaIdx(int outputIdx, int miniBatchIdx, int mlpLayer){
	int idx = 0;
	int layer;
	for(layer = 0; layer < mlpLayer; layer ++){
		idx += getCMlpOutputNums(layer) * getCMiniBatchNums();
	}
	idx += getDim2Idx(outputIdx, miniBatchIdx, getCMlpOutputNums(mlpLayer));
	return(idx);
}
__device__ float getDMlpWb(int outputIdx, int miniBatchIdx, int mlpLayer){
	return(dMlpWb[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)]);
}
__device__ float getDMlpBn(int inputIdx, int miniBatchIdx, int mlpLayer){
	return(dMlpBn[getDMlpWbaIdx(inputIdx, miniBatchIdx, mlpLayer)]);
}
__device__ float getDMlpA(int outputIdx, int miniBatchIdx, int mlpLayer){
	return(dMlpA[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)]);
}
__device__ float getDMlpWbBack(int outputIdx, int miniBatchIdx, int mlpLayer){
	return(dMlpWbBack[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)]);
}
__device__ float getDMlpBnBack(int inputIdx, int miniBatchIdx, int mlpLayer){
	return(dMlpBnBack[getDMlpWbaIdx(inputIdx, miniBatchIdx, mlpLayer)]);
}
__device__ float getDMlpABack(int outputIdx, int miniBatchIdx, int mlpLayer){
	return(dMlpABack[getDMlpWbaIdx(outputIdx, miniBatchIdx, mlpLayer)]);
}

//学習変数のアクセッサ
//cnn
__device__ int getDCnnWIdx(int x, int y, int inputIdx, int outputIdx, int cnnLayer){
	int layer;
	int idx = 0;
	for(layer = 0; layer < cnnLayer; layer ++){
		idx += getCCnnW_xNums() * getCCnnW_yNums() * getDCnnInputIdxNums(layer) * getCCnnOutputNums(layer);
	}
	int inputIdxNums = getDCnnInputIdxNums(cnnLayer);
	idx += getDim4Idx(x, y, inputIdx, outputIdx, getCCnnW_xNums(), getCCnnW_yNums(), inputIdxNums);
	return(idx);
}
__device__ int getDCnnBnMeanVar2Idx(int outputIdx, int cnnLayer){
	int layer;
	int idx = 0;
	for(layer = 0; layer < cnnLayer; layer++){
		idx += getCCnnOutputNums(layer);
	}
	return(idx + outputIdx);
}
__device__ float getDCnnW(int x, int y, int inputIdx, int outputIdx, int cnnLayer){
	return(dCnnW[getDCnnWIdx(x, y, inputIdx, outputIdx, cnnLayer)]);
}
__device__ float getDCnnBnGamma(int outputIdx, int cnnLayer){
	return(dCnnBnGamma[getDCnnBnMeanVar2Idx(outputIdx, cnnLayer)]);
}
__device__ float getDCnnBnBeta(int outputIdx, int cnnLayer){
	return(dCnnBnBeta[getDCnnBnMeanVar2Idx(outputIdx, cnnLayer)]);
}
__device__ float getDCnnBnMean(int outputIdx, int cnnLayer){
	return(dCnnBnMean[getDCnnBnMeanVar2Idx(outputIdx, cnnLayer)]);
}
__device__ float getDCnnBnVar2(int outputIdx, int cnnLayer){
	return(dCnnBnVar2[getDCnnBnMeanVar2Idx(outputIdx, cnnLayer)]);
}
__device__ float getCCnnBnAveMean(int outputIdx, int cnnLayer){
	return(cCnnBnAveMean[getDCnnBnMeanVar2Idx(outputIdx, cnnLayer)]);
}
__device__ float getCCnnBnAveVar2(int outputIdx, int cnnLayer){
	return(cCnnBnAveVar2[getDCnnBnMeanVar2Idx(outputIdx, cnnLayer)]);
}
//mlp
__device__ int getDMlpWIdx(int inputIdx, int outputIdx, int mlpLayer){
	int layer;
	int idx = 0;
	for(layer = 0; layer < mlpLayer; layer ++){
		idx += getDMlpInputIdxNums(layer) * getCMlpOutputNums(layer);
	}
	int inputIdxNums = getDMlpInputIdxNums(mlpLayer);
	idx += getDim2Idx(inputIdx, outputIdx, inputIdxNums);
	return(idx);
}
__device__ int getDMlpBnMeanVar2Idx(int outputIdx, int mlpLayer){
	int layer;
	int idx = 0;
	for(layer = 0; layer < mlpLayer; layer++){
		idx += getCMlpOutputNums(layer);
	}
	return(idx + outputIdx);
}
__device__ float getDMlpW(int inputIdx, int outputIdx, int cnnLayer){
	return(dMlpW[getDMlpWIdx(inputIdx, outputIdx, cnnLayer)]);
}
__device__ float getDMlpBnGamma(int outputIdx, int mlpLayer){
	return(dMlpBnGamma[getDMlpBnMeanVar2Idx(outputIdx, mlpLayer)]);
}
__device__ float getDMlpBnBeta(int outputIdx, int mlpLayer){
	return(dMlpBnBeta[getDMlpBnMeanVar2Idx(outputIdx, mlpLayer)]);
}
__device__ float getDMlpBnMean(int outputIdx, int mlpLayer){
	return(dMlpBnMean[getDMlpBnMeanVar2Idx(outputIdx, mlpLayer)]);
}
__device__ float getDMlpBnVar2(int outputIdx, int mlpLayer){
	return(dMlpBnVar2[getDMlpBnMeanVar2Idx(outputIdx, mlpLayer)]);
}
__device__ float getCMlpBnAveMean(int outputIdx, int cnnLayer){
	return(cMlpBnAveMean[getDMlpBnMeanVar2Idx(outputIdx, cnnLayer)]);
}
__device__ float getCMlpBnAveVar2(int outputIdx, int cnnLayer){
	return(cMlpBnAveVar2[getDMlpBnMeanVar2Idx(outputIdx, cnnLayer)]);
}
//CNN層のinputの総数を取得する。
__device__ int getDCnnInputIdxNums(int cnnLayer){
	int inputIdxNums;
	if(cnnLayer == 0){
		inputIdxNums = getCSvChannelNums();
	}
	else{
		inputIdxNums = getCCnnOutputNums(cnnLayer - 1);
	}
	return(inputIdxNums);
}
//MLP層のinputの総数を取得する。
__device__ int getDMlpInputIdxNums(int mlpLayer){
	int inputIdxNums;
	if(mlpLayer == 0){
		int cnnOutputNumsLastIdx = getCCnnOutputNumsNums() - 1;
		inputIdxNums = getCCnnP_xNums(cnnOutputNumsLastIdx) * getCCnnP_yNums(cnnOutputNumsLastIdx) * getCCnnOutputNums(cnnOutputNumsLastIdx);
	}
	else{
		inputIdxNums = getCMlpOutputNums(mlpLayer - 1);
	}
	return(inputIdxNums);
}

#endif
