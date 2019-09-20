#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <constraint.cuh>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh> 
#include <cudaCheck.cuh>

extern __global__ void kernelBackCnnConvolutionProp(const int cnnLayer, const float bnEps);
extern __global__ void kernelBackCnnConvolutionUpdate(const int cnnLayer, const int wba_xNums, const int wba_yNums, const int miniBatchIdxNums, const float bnEps);
extern void backCnnConvolution_culcurationDelTmp(const int cnnLayer, const int targetFlg);

void backCnnConvolution(const int cnnLayer){

//	struct timeval t1, t2, t3;

	//ブロック・スレッド定義
	dim3 gridProp(getCnnOutputNums(cnnLayer), getMiniBatchNums());
	dim3 blockProp(getCnnWba_xNums(cnnLayer), getCnnWba_yNums(cnnLayer), 1);
	dim3 gridUpdate(getCnnOutputNums(cnnLayer), 1);
	dim3 blockUpdate(1, 1, 1);

	//次元チェック
	checkGridSize(gridProp);
	checkThreadSize(blockProp);
	checkGridSize(gridUpdate);
	checkThreadSize(blockUpdate);

	//delTmpの事前計算
	backCnnConvolution_culcurationDelTmp(cnnLayer, 0);
	//カーネル起動
	cudaDeviceSynchronize();
	kernelBackCnnConvolutionProp<<<gridProp, blockProp>>>(cnnLayer, getBnEps());

	//deltaBetaGammaの事前計算
//	backCnnConvolution_culcurationDelTmp(cnnLayer, 1);
	cudaDeviceSynchronize();
	kernelBackCnnConvolutionUpdate<<<gridUpdate, blockUpdate>>>(cnnLayer, getCnnWba_xNums(cnnLayer), getCnnWba_yNums(cnnLayer), getMiniBatchNums(), getBnEps());

//	gettimeofday(&t1, NULL);
//	gettimeofday(&t2, NULL);
//	gettimeofday(&t3, NULL);
//	printTime(t1,t2,t3);
//	exit(2);

}

__global__ void
kernelBackCnnConvolutionProp(const int cnnLayer, const float bnEps){
	int cnnWba_x = threadIdx.x;
	int cnnWba_y = threadIdx.y;
	int cnnWba_xNums = blockDim.x;
	int cnnWba_yNums = blockDim.y;
	int outputIdx = blockIdx.x;
	int miniBatchIdx = blockIdx.y;
	int miniBatchIdxNums = gridDim.y;
	float mean, var2;
	float del2Tmp = 0;
	float del3Tmp = 0;

	//平均値を取得
	mean = getDCnnBnMean(outputIdx, cnnLayer);
	//分散を取得
	var2 = getDCnnBnVar2(outputIdx, cnnLayer);
	/*
	if(miniBatchIdx == 0 && cnnWba_x == 0 && cnnWba_y == 0){
		printf("mean[%d,%d,%d]:%f\n", cnnWba_x,cnnWba_y,outputIdx , mean);
		printf("var2[%d,%d,%d]:%f\n", cnnWba_x,cnnWba_y,outputIdx , var2);
	}
	*/

	/*
	//cnnWb更新要素の計算
	int x, y, z;
	for(z = 0; z < miniBatchIdxNums; z++){
		for(y = 0; y < cnnWba_yNums; y++){
			for(x = 0; x < cnnWba_xNums; x++){
				del2Tmp += getDCnnBnBack(x, y, outputIdx, z, cnnLayer)\
					   * (getDCnnWb(x, y, outputIdx, z, cnnLayer) - mean) * powf((var2 + bnEps), -0.5f);
				//if(outputIdx == 1 && cnnWba_x == 1 &&cnnWba_y == 1 && miniBatchIdx == 0){
	//			if(x==17 && y==5 && z == 15 &&cnnWba_x == 17 &&cnnWba_y == 1 && miniBatchIdx == 1 && outputIdx == 1){
					//printf("cnnBnBack(%d,%d,%d,%d):%f\n", x, y, outputIdx, z, getDCnnBnBack(x,y,outputIdx, z, cnnLayer));
					//printf("cnnWb(%d,%d,%d,%d):%f\n", x,y,outputIdx, z, getDCnnWb(x,y,outputIdx, z, cnnLayer));
//					printf("sCnnTmp(%d,%d,%d,%d,%d):%f ", x,y,outputIdx, z, cnnLayer,getDCnnBnBack(x, y, outputIdx, z, cnnLayer) * (getDCnnWb(x, y, outputIdx, z, cnnLayer) - mean) * powf((var2 + bnEps), -0.5f));
	//			}
				del3Tmp += getDCnnBnBack(x, y, outputIdx, z, cnnLayer);
			}
		}
	}
	*/
	del2Tmp = dCnnBackDel2Tmp[outputIdx];
	del3Tmp = dCnnBackDel3Tmp[outputIdx];
	//mlpのminiBatchIdxNums → miniBatchIdxNums * cnnWba_x * cnnWba_y
	float del1 = (miniBatchIdxNums * cnnWba_xNums * cnnWba_yNums) * getDCnnBnBack(cnnWba_x, cnnWba_y, outputIdx, miniBatchIdx, cnnLayer);
	float del2 = del2Tmp * (getDCnnWb(cnnWba_x, cnnWba_y, outputIdx, miniBatchIdx, cnnLayer) - mean) * powf((var2 + bnEps), -0.5f);
	float del3 = del3Tmp;
	//float subtractDel = floatSubtraction(floatSubtraction(del1, del2), del3);
	float subtractDel = del1 - del2 - del3;

	/*
	if(cnnWba_x == 17 &&cnnWba_y == 5 && miniBatchIdx == 15 && outputIdx == 17){
		printf("del1(%d,%d,%d,%d,%d):%f\n", cnnWba_x,cnnWba_y,outputIdx, miniBatchIdx, cnnLayer,del1);
		printf("del2(%d,%d,%d,%d,%d)%f\n", cnnWba_x,cnnWba_y,outputIdx, miniBatchIdx, cnnLayer,del2);
		printf("del2Tmp(%d,%d,%d,%d,%d):%f(culcu:%f)\n", cnnWba_x,cnnWba_y,outputIdx, miniBatchIdx, cnnLayer,del2Tmp, dCnnBackDel2Tmp[outputIdx]);
		printf("del3(%d,%d,%d,%d,%d):%f(culcu:%f)\n", cnnWba_x,cnnWba_y,outputIdx, miniBatchIdx, cnnLayer,del3, dCnnBackDel3Tmp[outputIdx]);
	}
	*/

	dCnnWbBack[getDCnnWbaIdx(cnnWba_x, cnnWba_y, outputIdx, miniBatchIdx, cnnLayer)] =\
		subtractDel * getDCnnBnGamma(outputIdx, cnnLayer) * powf((var2 + bnEps), -0.5f) / (miniBatchIdxNums * cnnWba_xNums * cnnWba_yNums);

//		printf("subtractDel(%d,%d,%d,%d):%f\n", cnnWba_x,cnnWba_y,outputIdx, miniBatchIdx, subtractDel);
//		printf("cnnWbBack(%d,%d,%d,%d):%f\n", cnnWba_x,cnnWba_y,outputIdx, miniBatchIdx, dCnnWbBack[getDCnnWbaIdx(cnnWba_x,cnnWba_y,outputIdx, miniBatchIdx, cnnLayer)]);
//		printf("del2Tmp(%d,%d,%d,%d,%d):%f(culcu:%f):%f\n", cnnWba_x,cnnWba_y,outputIdx, miniBatchIdx, cnnLayer,del2Tmp, dCnnBackDel2Tmp[outputIdx],dCnnWbBack[getDCnnWbaIdx(cnnWba_x, cnnWba_y, outputIdx, miniBatchIdx, cnnLayer)]);
//		printf("del3(%d,%d,%d,%d,%d):%f(culcu:%f):%f\n", cnnWba_x,cnnWba_y,outputIdx, miniBatchIdx, cnnLayer,del3, dCnnBackDel3Tmp[outputIdx],dCnnWbBack[getDCnnWbaIdx(cnnWba_x, cnnWba_y, outputIdx, miniBatchIdx, cnnLayer)]);
}

__global__ void
kernelBackCnnConvolutionUpdate(const int cnnLayer, const int wba_xNums, const int wba_yNums, const int miniBatchIdxNums, const float bnEps){

	int outputIdx = blockIdx.x;
	float mean, var2, bnTmp;
	float sumGamma = 0, sumBeta = 0;

	//平均値を取得
	mean = getDCnnBnMean(outputIdx, cnnLayer);
	//分散を取得
	var2 = getDCnnBnVar2(outputIdx, cnnLayer);

	//更新値を計算
	int x, y, z;
	for(z = 0; z < miniBatchIdxNums; z++){
		for(y = 0; y < wba_yNums; y++){
			for(x = 0; x < wba_xNums; x++){
				bnTmp = (getDCnnWb(x, y, outputIdx, z, cnnLayer) - mean) / powf((var2 + bnEps), 0.5f);
				sumGamma += getDCnnBnBack(x, y, outputIdx, z, cnnLayer) * bnTmp;
				sumBeta += getDCnnBnBack(x, y, outputIdx, z, cnnLayer);
				//if(outputIdx == 1){
//					printf("bnTmp(%d,%d,%d,%d):%f  ", x,y,outputIdx, z, bnTmp);
//					printf("sumGamma(%d,%d,%d,%d):%f  ", x,y,outputIdx, z, sumGamma);
//					printf("sumBeta(%d,%d,%d,%d):%f  ", x,y,outputIdx, z, sumBeta);
				//}

			}
		}
	}
	//sumGamma = dCnnBackDelGamma[outputIdx];
	//sumBeta = dCnnBackDelBeta[outputIdx];
	//更新
	dCnnBnGamma[getDCnnBnMeanVar2Idx(outputIdx, cnnLayer)] -= sumGamma * getCLearningRate();
	dCnnBnBeta[getDCnnBnMeanVar2Idx(outputIdx, cnnLayer)] -= sumBeta * getCLearningRate();
//	if(outputIdx == 1){
//		printf("cnnGamma(%d):%f  ", outputIdx, dCnnBnGamma[getDCnnBnMeanVar2Idx(outputIdx, cnnLayer)]);
//		printf("cnnBeta(%d):%f  ", outputIdx, dCnnBnBeta[getDCnnBnMeanVar2Idx(outputIdx, cnnLayer)]);
//	}
	/*
	printf("delGamma(%d,%d):%f(culcu:%f)\n", outputIdx, cnnLayer,sumGamma, dCnnBackDelGamma[outputIdx]);
	printf("delBeta(%d,%d):%f(culcu:%f):\n", outputIdx, cnnLayer, sumBeta, dCnnBackDelBeta[outputIdx]);
	*/
}
