//device処理系のグローバル変数定義
#ifndef INCLUDED_DEVICEVALUESACCESSER
#define INCLUDED_DEVICEVALUESACCESSER
#include <stdio.h>
#include <constraint.cuh>
#include <check.cuh>

//Beforeにて事前にコンスタントメモリに割り当てる。
//~~~~~ここから~~~~
extern __constant__ int cSvChannelNums;
//cnnOutputNums
extern __constant__ int cCnnOutputNumsNums;
//出力(wba, p)：
//w_xy
extern __constant__ int cW_xNums;
extern __constant__ int cW_yNums;
//pooling_xy
extern __constant__ int cPooling_xNums;
extern __constant__ int cPooling_yNums;

//~~~~~ここまで~~~~

//1各層分だけ確保し、各層で入れ替えて共有する。
extern __constant__ int cInputChannelNums;
//extern __constant__ float cInputData[INPUTDATASIZE];
extern __device__ float cInputData[INPUTDATASIZE];
extern __constant__ float cB[maxInputSize];
extern __constant__ int cWba_xNums[CNNLAYER];
extern __constant__ int cWba_yNums[CNNLAYER];
extern __constant__ int cP_xNums[CNNLAYER];
extern __constant__ int cP_yNums[CNNLAYER];
extern __constant__ float cMlpB[MLPBSIZE];

extern __device__ int getCWba_xNums(int cnnLayer);
extern __device__ int getCWba_yNums(int cnnLayer);
extern __device__ int getCP_xNums(int cnnLayer);
extern __device__ int getCP_yNums(int cnnLayer);

extern __device__ int getCW_xNums();
extern __device__ int getCW_yNums();
extern __device__ int getCPooling_xNums();
extern __device__ int getCPooling_yNums();

//input系アクセッサ
extern __device__ int getCInputChannelNums();
extern __device__ float getCInputData(int x, int y, int inputIdx, int miniBatchIdx);

//bアクセッサ
extern __device__ float getCB(int inputIdx);

//w系アクセッサ
extern __device__ float getDW(int x, int y, int inputIdx, int outputIdx, int cnnLayer);

extern __device__ int getCCnnInputIdxNums(int cnnLayer);
extern __device__ float getCMlpB(int outputIdx);
#endif
