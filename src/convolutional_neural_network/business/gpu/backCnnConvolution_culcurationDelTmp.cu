#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <constraint.cuh>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh> 
#include <cudaCheck.cuh>

extern __global__ void kernelBackCnnCulcu1(const int cnnLayer, const float bnEps, const int targetFlg);
extern __global__ void kernelBackCnnCulcu2(const int cnnLayer, const int targetFlg);

void backCnnConvolution_culcurationDelTmp(const int cnnLayer, const int targetFlg){
	//targetFlg  0:delTmp 1:delGamma 2:delBeta

	//del2Tmp,del3Tmp
	//Culcu1###############################################################################################
	//ブロック・スレッド定義
	dim3 gridCulcu1(getCnnOutputNums(cnnLayer), getMiniBatchNums());
	dim3 blockCulcu1(getCnnWba_xNums(cnnLayer), getCnnWba_yNums(cnnLayer), 1);

	//次元チェック
	checkGridSize(gridCulcu1);
	checkThreadSize(blockCulcu1);

	//シェアードメモリ確保
	int sharedSizeCnnWba_xyNums;
	sharedSizeCnnWba_xyNums = sizeof(float) * getCnnWba_xNums(cnnLayer) * getCnnWba_yNums(cnnLayer); 

	//シェアードメモリチェック
	checkSharedMemorySize(sharedSizeCnnWba_xyNums);

	cudaDeviceSynchronize();
	//delTmpの計算
	kernelBackCnnCulcu1<<<gridCulcu1, blockCulcu1, sharedSizeCnnWba_xyNums>>>(cnnLayer, getBnEps(), targetFlg);
	//#####################################################################################################

	//Culcu2###############################################################################################
	//ブロック・スレッド定義
	dim3 gridCulcu2(getCnnOutputNums(cnnLayer), 1);
	dim3 blockCulcu2(getMiniBatchNums(), 1, 1);

	//次元チェック
	checkGridSize(gridCulcu2);
	checkThreadSize(blockCulcu2);

	//シェアードメモリ確保
	int sharedSizeMiniBatchNums;
	sharedSizeMiniBatchNums = sizeof(float) * getMiniBatchNums(); 

	//シェアードメモリチェック
	checkSharedMemorySize(sharedSizeMiniBatchNums);

	cudaDeviceSynchronize();
	kernelBackCnnCulcu2<<<gridCulcu2, blockCulcu2, sharedSizeMiniBatchNums>>>(cnnLayer, targetFlg);
	//#####################################################################################################

}

//本来kernelでの分岐はふさわしくないが、ワープ内の全てのレーンで同じ処理を実施するため、速度低下は発生しないはず。
//http://news.mynavi.jp/series/kepler_gpu/002/

__global__ void kernelBackCnnCulcu1(const int cnnLayer, const float bnEps, const int targetFlg){
	int wba_x = threadIdx.x;
	int wba_y = threadIdx.y;
	int miniBatchIdx = blockIdx.y;
	int outputIdx = blockIdx.x;
	int outputNums = gridDim.x;

	int threadIdxNo = getDim3Idx(threadIdx.x, threadIdx.y, threadIdx.z, blockDim.x, blockDim.y);
	int culcu1BlockIdxNo = getDim2Idx(outputIdx, miniBatchIdx, outputNums);

	float mean, var2;

	//平均値を取得
	mean = getDCnnBnMean(outputIdx, cnnLayer);
	//分散を取得
	var2 = getDCnnBnVar2(outputIdx, cnnLayer);

	//cnnWbをshared memoryにコピー
	extern __shared__ float sCnnBnBackWb[];

	//first
	if(targetFlg == 0){
		//del2Tmp
		sCnnBnBackWb[threadIdxNo] = getDCnnBnBack(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer)\
				    * (getDCnnWb(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer) - mean) * powf((var2 + bnEps), -0.5f);
	}
	else if(targetFlg == 1){
		//delGamma
		float bnTmp = (getDCnnWb(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer) - mean) / powf((var2 + bnEps), 0.5f);
		sCnnBnBackWb[threadIdxNo] = getDCnnBnBack(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer) * bnTmp;
	}
	__threadfence_block();
	dCnnBackDelTmp1_culcu[culcu1BlockIdxNo] = culcurateSum(sCnnBnBackWb, threadIdxNo);

	__threadfence_block();
	//second
	if(targetFlg == 0){
		//del3Tmp
		sCnnBnBackWb[threadIdxNo] = getDCnnBnBack(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer);
	}
	else if(targetFlg == 1){
		//delBeta
		sCnnBnBackWb[threadIdxNo] = getDCnnBnBack(wba_x, wba_y, outputIdx, miniBatchIdx, cnnLayer);
	}
	__threadfence_block();
	dCnnBackDelTmp2_culcu[culcu1BlockIdxNo] = culcurateSum(sCnnBnBackWb, threadIdxNo);
}

__global__ void kernelBackCnnCulcu2(const int cnnLayer, const int targetFlg){
	int miniBatchIdx = threadIdx.x;
	int outputIdx = blockIdx.x;
	int outputNums = gridDim.x;

	int threadIdxNo = getDim3Idx(threadIdx.x, threadIdx.y, threadIdx.z, blockDim.x, blockDim.y);
	int culcu1BlockIdxNo = getDim2Idx(outputIdx, miniBatchIdx, outputNums);

	extern __shared__ float sCnnDelTmp_culcu[];
	
	//delTmp1_culcuの結果を取得
	//common
	sCnnDelTmp_culcu[miniBatchIdx] = dCnnBackDelTmp1_culcu[culcu1BlockIdxNo];
	__threadfence_block();
	if(targetFlg == 0){
		//del2Tmp
		dCnnBackDel2Tmp[outputIdx] = culcurateSum(sCnnDelTmp_culcu, threadIdxNo);
	}
	else if(targetFlg == 1){
		//delGamma
		dCnnBackDelGamma[outputIdx] = culcurateSum(sCnnDelTmp_culcu, threadIdxNo);
	}
	__threadfence_block();

	//delTmp2_culcuの結果を取得
	//common
	sCnnDelTmp_culcu[miniBatchIdx] = dCnnBackDelTmp2_culcu[culcu1BlockIdxNo];
	__threadfence_block();
	if(targetFlg == 0){
		//del3Tmp
		dCnnBackDel3Tmp[outputIdx] = culcurateSum(sCnnDelTmp_culcu, threadIdxNo);
	}
	else if(targetFlg == 1){
		//delBeta
		dCnnBackDelBeta[outputIdx] = culcurateSum(sCnnDelTmp_culcu, threadIdxNo);
	}
}
