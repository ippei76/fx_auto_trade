//host処理系のグローバル変数定義
#ifndef INCLUDED_HOSTVALUESACCESSER
#define INCLUDED_HOSTVALUESACCESSER
#include <stdio.h>

extern int cnnOutputNumsNums;
extern int *cnnOutputNums;

extern int sv_xNums;
extern int sv_yNums;
extern int svChannelNums;
extern int miniBatchNums;
extern float *sv;

extern int w_xNums;
extern int w_yNums;
extern float *w;

extern float *b;

extern int *wba_xNums;
extern int *wba_yNums;
extern float *wb;
extern float *a;

extern int *p_xNums;
extern int *p_yNums;
extern float *p;

extern int pooling_xNums;
extern int pooling_yNums;

extern int mlpOutputNumsNums;
extern int *mlpOutputNums;

extern float *mlpW;
extern float *mlpB;

extern float *mlpWb;
extern float *mlpA;

extern void setSv_xNums(int sv_xNums_arg);
extern int getSv_xNums();
extern void setSv_yNums(int sv_yNums_arg);
extern int getSv_yNums();
extern void setMiniBatchNums(int miniBatchNums_arg);
extern int getMiniBatchNums();
extern void setSvChannelNums(int svChannelNums_arg);
extern int getSvChannelNums();
extern void setSv(float *sv_arg);
extern float getSv(int x, int y, int svIdx, int svBatchIdx);
extern void setCnnOutputNumsNums(int cnnOutputNumsNums_arg);
extern int getCnnOutputNumsNums();
extern void setCnnOutputNums(int *cnnOutputNums_arg);
extern int getCnnOutputNums(int cnnLayer);
extern void setW_xNums(int w_xNums_arg);
extern int getW_xNums();
extern void setW_yNums(int w_yNums_arg);
extern int getW_yNums();
extern void setW(float *w_arg);
extern float getW(int x, int y, int inputIdx, int outputIdx, int cnnLayer);
extern int getWIdx(int x, int y, int inputIdx, int outputIdx, int cnnLayer);
extern void setB(float *b_arg);
extern float getB(int inputIdx, int cnnLayer);
extern int getBIdx(int inputIdx, int cnnLayer);
extern void setWba_xNums(int *wba_xNums_arg);
extern int getWba_xNums(int cnnLayer);
extern void setWba_yNums(int *wba_yNums_arg);
extern int getWba_yNums(int cnnLayer);
extern void setWb(float *wb_arg);
extern float getWb(int x, int y, int outputIdx, int miniBatchIdx, int cnnLayer);
extern int getWbaIdx(int x, int y, int outputIdx, int miniBatchIdx, int cnnLayer);
extern void setA(float *a_arg);
extern float getA(int x, int y, int outputIdx, int miniBatchIdx, int cnnLayer);
extern void setP_xNums(int p_xNums_arg);
extern int getP_xNums(int cnnLayer);
extern void setP_yNums(int p_yNums_arg);
extern int getP_yNums(int cnnLayer);
extern void setP(float *p_arg);
extern float getP(int x, int y, int outputIdx, int miniBatchIdx, int cnnLayer);
extern void setPooling_xNums(int pooling_xNums_arg);
extern int getPooling_xNums();
extern void setPooling_yNums(int pooling_yNums_arg);
extern int getPooling_yNums();
extern void setMlpOutputNumsNums(int mlpOutputNumsNums_arg);
extern int getMlpOutputNumsNums();
extern void setMlpOutputNums(int *mlpOutputNums_arg);
extern int getMlpOutputNums(int mlpLayer);
extern void setMlpW(float *mlpW_arg);
extern float getMlpW(int inputIdx, int outputIdx, int mlpLayer);
extern void setMlpB(float *mlpB_arg);
extern float getMlpB(int mlpLayer);
extern void setMlpWb(float *mlpWb_arg);
extern float getMlpWb(int outputIdx, int miniBatchIdx, int mlpLayer);
extern void setMlpA(float *mlpA_arg);
extern float getMlpA(int outputIdx, int miniBatchIdx, int mlpLayer);

extern int __device__ __host__ getDim2Idx(int x, int y, int X);
extern int __device__ __host__ getDim3Idx(int x, int y, int z, int X, int Y);
extern int __device__ __host__ getDim4Idx(int x, int y, int z, int a, int X, int Y, int Z);
extern int __device__ __host__ getDim5Idx(int x, int y, int z, int a, int b, int X, int Y, int Z, int A);
extern int getCnnInputIdxNums(int cnnLayer);
extern int getMlpInputIdxNums(int mlpLayer);
#endif
