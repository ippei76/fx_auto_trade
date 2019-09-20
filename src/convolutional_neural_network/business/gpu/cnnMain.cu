#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <constraint.cuh>
#include <hostParameters.cuh>
#include <deviceParameters.cuh>
#include <check.cuh> 
#include <cudaCheck.cuh>
#include <commonFunc.cuh>
#include <sys/time.h>

//extern void dynamicAllocateDeviceMemory(float *cnnW, const int cnnWDataNums, float *mlpW, const int mlpWDataNums);
extern void cnnConvolution(const int cnnLayer);
extern void cnnBatchNormalization(const int cnnLayer);
extern void cnnActivate(const int cnnLayer);
extern void cnnPooling(const int cnnLayer);
extern void mlpMultiply(const int mlpLayer);
extern void mlpBatchNormalization(const int mlpLayer);
extern void mlpActivate(const int mlpLayer);
extern void lossFunc(const int mlpOutputNumsLastIdx);
extern void backMlpActivate(const int mlpLayer);
extern void backMlpBatchNormalization(const int mlpLayer);
extern void backMlpMultiply(const int mlpLayer);
extern void backCnnPMlpW(const int cnnLayer);
extern void backCnnPooling(const int cnnLayer);
extern void backCnnActivate(const int cnnLayer);
extern void backCnnBatchNormalization(const int cnnLayer);
extern void backCnnConvolution(const int cnnLayer);
extern void backCnnSv(const int cnnLayer);
extern void inferenceBnMeanVar2(const int episode, float *infCnnBnMean, float *infCnnBnVar2, float *infMlpBnMean, float *infMlpBnVar2);
extern void cnnBatchNormalization_culcurationAveVar2(const int cnnLayer);

void cnnForwardPropagation(){

//	struct timeval t1, t2, t3, t4, t5, t6, t7;
//	gettimeofday(&t1, NULL);
//	printTime(t1,t2,t3);

	int cnnLayer;
	for(cnnLayer = 0; cnnLayer < getCnnOutputNumsNums(); cnnLayer ++){
//		printf("\n\ncnnLayer:%d\n\n",cnnLayer);
		//inputDataに関するチェック
		//checkInputDataSize(inputDataSize);
		//checkInput_xyNums(input_xNums, input_yNums);
		//checkInputChannelNums(inputChannelNums);

		cnnConvolution(cnnLayer);
		cnnBatchNormalization(cnnLayer);
		cnnActivate(cnnLayer);
		cnnPooling(cnnLayer);
	}
}

void mlpForwardPropagation(){

	int mlpLayer;
	for(mlpLayer = 0; mlpLayer < getMlpOutputNumsNums(); mlpLayer++){
//		printf("\n\nmlpLayer:%d\n\n",mlpLayer);

		mlpMultiply(mlpLayer);
		mlpBatchNormalization(mlpLayer);
		mlpActivate(mlpLayer);
	}
}

void mlpBackPropagation(){

	//mlp最終層取得
	int mlpOutputNumsLastIdx = getMlpOutputNumsNums() - 1;
	int mlpLayer;

	for(mlpLayer = mlpOutputNumsLastIdx; mlpLayer >= 0; mlpLayer--){
//		printf("\n\nmlpLayerBack:%d\n\n",mlpLayer);
		if(mlpLayer == mlpOutputNumsLastIdx){
			//mlp最終層のmlpBnを求める。
			lossFunc(mlpOutputNumsLastIdx);
		}
		else{
			backMlpActivate(mlpLayer);
			backMlpBatchNormalization(mlpLayer);
		}
		backMlpMultiply(mlpLayer);
	}

}

void cnnBackPropagation(){

	//cnn最終層取得
	int cnnOutputNumsLastIdx = getCnnOutputNumsNums() - 1;
	int cnnLayer;

	for(cnnLayer = cnnOutputNumsLastIdx; cnnLayer >= -1; cnnLayer--){
//		printf("\n\ncnnLayerBack:%d\n\n",cnnLayer);
		if(cnnLayer == cnnOutputNumsLastIdx){
			//cnn最終層のcnnPとmlp0層のmlpWを更新する。
			backCnnPMlpW(cnnLayer); //cnnLayerを渡していることに注意
		}
		else{
			if(cnnLayer != -1){
				backCnnPooling(cnnLayer);
			}
			else{
				//最後に0層のwを更新する。
				backCnnSv(cnnLayer);
				break;
			}
		}
		backCnnActivate(cnnLayer);
		backCnnBatchNormalization(cnnLayer);
		backCnnConvolution(cnnLayer);

	}
}

void getDeviceResult(){

	//GPUメモリより、最終アウトプットをメモリにコピー
	int resultDataSize = getMlpOutputNums(getMlpOutputNumsNums() - 1) * getMiniBatchNums() * sizeof(float);
	gpuErrchk(cudaMemcpyFromSymbol(result, dResult, resultDataSize));
	/*
	int i;
	for(i = 0; i< resultDataSize / sizeof(float);i++){
		printf("result[%d]=%f\n",i,result[i]);
	}
	*/

}

void getScore(){
	int outputIdx, miniBatchIdx;
	E = 0.0;
	for(miniBatchIdx = 0; miniBatchIdx < getMiniBatchNums(); miniBatchIdx++){
		for(outputIdx = 0; outputIdx < getMlpOutputNums(getMlpOutputNumsNums() - 1); outputIdx++){
			//softmaxでは、分母に無限大が発生する可能性がある。それをここで検知する。
		//	printf("koko%f ",getResult(outputIdx, miniBatchIdx));
			checkInfNan(getResult(outputIdx, miniBatchIdx), "resultValues");
			if(getResult(outputIdx, miniBatchIdx) > 0){
				E += (-1) * getTeachOut(outputIdx, miniBatchIdx) * logf(getResult(outputIdx, miniBatchIdx));
			}
			else{
				E += (-1) * getTeachOut(outputIdx, miniBatchIdx) * logf(getResult(outputIdx, miniBatchIdx) + getBnEps());
			}
			checkInfNan(E, "EValues");
		//	printf("LOG:result[%d,%d]=%f, teachOut[%d,%d]=%f\n",outputIdx,miniBatchIdx,getResult(outputIdx, miniBatchIdx), outputIdx,miniBatchIdx,getTeachOut(outputIdx, miniBatchIdx));
		}
	}
	E = E / getMiniBatchNums();
	printf("LOG:E=%f\n",E);
}

bool breakCheck(){
	if(E < 0.003){
		printf("LOG: E is very small. break.\n");
		return(true);
	}
	return(false);
}

void attenuationLearningRate(const int episode){
	if((episode + 1) % 500 == 0){
		float newLearningRate = getLearningRate() * 0.99;
		setLearningRate(newLearningRate);
		gpuErrchk(cudaMemcpyToSymbol(cLearningRate, &learningRate, sizeof(float)));
	}
}

void jnaExecuteOnline(){

	cnnForwardPropagation();
	mlpForwardPropagation();
	getDeviceResult();

}
void jnaExecuteTraining(){

//	struct timeval t1, t2, t3, t4, t5, t6, t7;
//	gettimeofday(&t1, NULL);
	cnnForwardPropagation();
//	gettimeofday(&t2, NULL);
	mlpForwardPropagation();
//	gettimeofday(&t3, NULL);
	getDeviceResult();
//	gettimeofday(&t4, NULL);
	getScore();
//	gettimeofday(&t5, NULL);
	mlpBackPropagation();
//	gettimeofday(&t6, NULL);
	cnnBackPropagation();
//	gettimeofday(&t7, NULL);

//	printTime(t1,t2,t3);
//	printTime(t3,t4,t5);
//	printTime(t5,t6,t7);
//	exit(2);
}

int getAllDataIdx(const int allDataNums, const int oneTeachOutDataNumsNoMiniBatch, const float *teachOutAll){
	int targetIdx = -1;
	targetIdx = getRandomInt(0, allDataNums);
	while(true){
		/*
		printf("targetIdx:%d{",targetIdx);
		int i;
		for(i = 0; i < oneTeachOutDataNumsNoMiniBatch; i++){
			printf("%f ",teachOutAll[targetIdx * oneTeachOutDataNumsNoMiniBatch + i]);
		}
		*/
		//wait(=0,0,1)がteachOutの場合は除外する。
		if(teachOutAll[targetIdx * oneTeachOutDataNumsNoMiniBatch + 2] == 1){
		//if(teachOutAll[targetIdx * oneTeachOutDataNumsNoMiniBatch + 0] == 1){
			//break;
			targetIdx = getRandomInt(0, allDataNums);

		}
		else{
			//printf("skip(%d)\n",targetIdx);
			break;
		}
	}
	return(targetIdx);
}

void jnaExecuteBeforeTraining(const float *svAll, const float *teachOutAll, const int oneSvDataNums, const int oneTeachOutDataNums, const int allDataNums){
	//教師データの中から、miniBatchNums数選び、dSv,teachOutにセットする。
	//oneSV,oneTeachOutはminiBatchを含んでいる。
	int svIdx = 0;
	int teachOutIdx = 0;
	int miniBatchIdx, allDataIdx, i, j;
	int oneSvDataSize = oneSvDataNums * sizeof(float);
	int oneTeachOutDataSize = oneTeachOutDataNums * sizeof(float);
	int oneSvDataNumsNoMiniBatch = oneSvDataNums / getMiniBatchNums();
	int oneTeachOutDataNumsNoMiniBatch = oneTeachOutDataNums / getMiniBatchNums();
	float *sv; //teachOutはグローバル変数を使う。
	//sv,teachOutの動的確保
	sv = (float *)malloc(oneSvDataSize);
	teachOut = (float *)malloc(oneTeachOutDataSize);
	for(miniBatchIdx = 0; miniBatchIdx < getMiniBatchNums(); miniBatchIdx++){
		//ランダム選択
		allDataIdx = getAllDataIdx(allDataNums, oneTeachOutDataNumsNoMiniBatch, teachOutAll);
		//printf("%d ",allDataIdx);
		//printf("LOG:allDataIdx=%d\n",allDataIdx);
		for(i = 0; i < oneSvDataNumsNoMiniBatch; i++){	//miniBatchを含まない1データ
			sv[svIdx] = svAll[allDataIdx * oneSvDataNumsNoMiniBatch + i];
			//sv[svIdx] = svIdx;
			//sv[svIdx] = 1;
//			printf("sv[%d]=%f\n",svIdx,sv[svIdx]);
			svIdx++;
		}
		for(j = 0; j < oneTeachOutDataNumsNoMiniBatch; j++){	//miniBatchを含まない1データ
			teachOut[teachOutIdx] = teachOutAll[allDataIdx * oneTeachOutDataNumsNoMiniBatch + j];
			/*
			if(j%oneTeachOutDataNumsNoMiniBatch==0){
				teachOut[teachOutIdx] = 1;
			}
			else{
				teachOut[teachOutIdx] = 0;
			}
			*/
	//		printf("teachOutAll[%d]=%f\n",allDataIdx * oneTeachOutDataNumsNoMiniBatch + j,teachOut[teachOutIdx]);
			teachOutIdx++;
		}
	}
	/*
	for(i=0; i < oneTeachOutDataNumsNoMiniBatch * getMiniBatchNums(); i++){
		printf("%d = %f , ",i,teachOut[i]);
	}
	*/
	//GPUチェック。
	checkSvTeachOutDataNums(oneSvDataNums, oneTeachOutDataNums);
	//GPUへコピー
	gpuErrchk(cudaMemcpyToSymbol(dSv, sv, oneSvDataSize));
	gpuErrchk(cudaMemcpyToSymbol(dTeachOut, teachOut, oneTeachOutDataSize));
}

void jnaExecuteBeforeOnline(const float *sv_arg, const int oneSvDataNums, const float *cnnBnAveMean_arg, const float *cnnBnAveVar2_arg, const float *mlpBnAveMean_arg, const float *mlpBnAveVar2_arg){

	int oneSvDataSize = oneSvDataNums * sizeof(float);
	//svをGPUへコピー
	gpuErrchk(cudaMemcpyToSymbol(dSv, sv_arg, oneSvDataSize));
	//トレーニングにて算出した平均分散をコンスタントメモリにコピーする。
	int cnnBnMeanVar2DataSize = sizeof(float) * getCnnOutputNumsSum();
	int mlpBnMeanVar2DataSize = sizeof(float) * getMlpOutputNumsSum();
	gpuErrchk(cudaMemcpyToSymbol(cCnnBnAveMean, cnnBnAveMean_arg, cnnBnMeanVar2DataSize));
	gpuErrchk(cudaMemcpyToSymbol(cCnnBnAveVar2, cnnBnAveVar2_arg, cnnBnMeanVar2DataSize));
	gpuErrchk(cudaMemcpyToSymbol(cMlpBnAveMean, mlpBnAveMean_arg, mlpBnMeanVar2DataSize));
	gpuErrchk(cudaMemcpyToSymbol(cMlpBnAveVar2, mlpBnAveVar2_arg, mlpBnMeanVar2DataSize));

}

void jnaExecuteAfterTraining(float *cnnW, float *mlpW, float *cnnBnGamma, float *cnnBnBeta, float *mlpBnGamma, float *mlpBnBeta){

	int cnnWDataSize = getCnnWDataNums() * sizeof(float);
	int mlpWDataSize = getMlpWDataNums() * sizeof(float);
	int cnnBnGammaBetaSize = getCnnOutputNumsSum() * sizeof(float);
	int mlpBnGammaBetaSize = getMlpOutputNumsSum() * sizeof(float);

	//学習済みのcnnW,mlpW,cnnBnGamma,cnnBnBeta,mlpBnGamma,mlpBnBetaをGPUから移送する。
	gpuErrchk(cudaMemcpyFromSymbol(cnnW, dCnnW, cnnWDataSize));
	gpuErrchk(cudaMemcpyFromSymbol(mlpW, dMlpW, mlpWDataSize));
	gpuErrchk(cudaMemcpyFromSymbol(cnnBnGamma, dCnnBnGamma, cnnBnGammaBetaSize));
	gpuErrchk(cudaMemcpyFromSymbol(cnnBnBeta, dCnnBnBeta, cnnBnGammaBetaSize));
	gpuErrchk(cudaMemcpyFromSymbol(mlpBnGamma, dMlpBnGamma, mlpBnGammaBetaSize));
	gpuErrchk(cudaMemcpyFromSymbol(mlpBnBeta, dMlpBnBeta, mlpBnGammaBetaSize));

	/*終了処理*/
	cudaDeviceReset();

}
void jnaExecuteAfterOnline(){

	/*終了処理*/
	cudaDeviceReset();

}

void cnnMain(
		int sv_xNums_arg, int sv_yNums_arg, int miniBatchNums_arg, int svChannelNums_arg, float *sv_arg, float *svAll, float *teachOut_arg, float *teachOutAll,

		int *cnnOutputNums_arg, int cnnOutputNumsNums_arg, 

		float *cnnBnBeta_arg, float *cnnBnGamma_arg, float bnEps_arg,

		int cnnW_xNums_arg, int cnnW_yNums_arg, float *cnnW_arg, 

		int cnnPooling_xNums_arg, int cnnPooling_yNums_arg, 

		int *cnnWba_xNums_arg, int *cnnWba_yNums_arg, 

		int *cnnP_xNums_arg, int *cnnP_yNums_arg,

		int *mlpOutputNums_arg, int mlpOutputNumsNums_arg,

		float *mlpBnBeta_arg, float *mlpBnGamma_arg,

		float *mlpW_arg,

		int stepNums, int episodeNums,

		int oneSvDataNums, int oneTeachOutDataNums, int allDataNums,

		int cnnWbaDataNums, int cnnPDataNums, int mlpWbaDataNums,

		int cnnWDataNums_arg, int cnnBnBetaGammaDataNums,

		int mlpWDataNums_arg, int mlpBnBetaGammaDataNums,

		float *infCnnBnMean, float *infCnnBnVar2, float *infMlpBnMean, float *infMlpBnVar2,

		//トレーニング時には、使用しない。
		float *cnnBnAveMean, float *cnnBnAveVar2, float *mlpBnAveMean, float *mlpBnAveVar2,

		//「トレーニング:0」「Online:1」
		int execFlg_arg, float *result_arg, float learningRate_arg

		){
			puts("cnnMain start.");

			//CPU側のデータ確保
			//output
			setCnnOutputNums(cnnOutputNums_arg);
			setCnnOutputNumsNums(cnnOutputNumsNums_arg);
			//sv,teachOut
			setSv_xNums(sv_xNums_arg);
			setSv_yNums(sv_yNums_arg);
			setSvChannelNums(svChannelNums_arg);
			//setSv(sv_arg);
			setTeachOut(teachOut_arg);

			//cnn
			setCnnBnBeta(cnnBnBeta_arg);
			setCnnBnGamma(cnnBnGamma_arg);
			setBnEps(bnEps_arg);

			setCnnW_xNums(cnnW_xNums_arg);
			setCnnW_yNums(cnnW_yNums_arg);
			setCnnWDataNums(cnnWDataNums_arg);
			setCnnW(cnnW_arg); //kokoiru???

			setCnnPooling_xNums(cnnPooling_xNums_arg);
			setCnnPooling_yNums(cnnPooling_yNums_arg);

			setCnnWba_xNums(cnnWba_xNums_arg);
			setCnnWba_yNums(cnnWba_yNums_arg);

			setCnnP_xNums(cnnP_xNums_arg);
			setCnnP_yNums(cnnP_yNums_arg);

			//mlp
			setMlpOutputNums(mlpOutputNums_arg);
			setMlpOutputNumsNums(mlpOutputNumsNums_arg);

			setMlpWDataNums(mlpWDataNums_arg);

			setMlpBnBeta(mlpBnBeta_arg);
			setMlpBnGamma(mlpBnGamma_arg);

			setMiniBatchNums(miniBatchNums_arg);

			setExecFlg(execFlg_arg);

			//result
			setResult(result_arg);

			//other
			setLearningRate(learningRate_arg);

			//GPUメモリのチェック(ノード変数)
			//sv,teachOutはBeforeで実施
			//cnn,mlp,result
			checkNodeValues(cnnWbaDataNums, cnnPDataNums, mlpWbaDataNums, getMlpOutputNums(getMlpOutputNumsNums() - 1));

			//GPUメモリのチェック(学習変数)
			//cnn,mlp
			checkLearnValues(cnnWDataNums, cnnBnBetaGammaDataNums, mlpWDataNums, mlpBnBetaGammaDataNums);
			gpuErrchk(cudaMemcpyToSymbol(dCnnW, cnnW_arg, cnnWDataNums * sizeof(float)));
			gpuErrchk(cudaMemcpyToSymbol(dCnnBnBeta, cnnBnBeta_arg, cnnBnBetaGammaDataNums * sizeof(float)));
			gpuErrchk(cudaMemcpyToSymbol(dCnnBnGamma, cnnBnGamma_arg, cnnBnBetaGammaDataNums * sizeof(float)));
			gpuErrchk(cudaMemcpyToSymbol(dMlpW, mlpW_arg, mlpWDataNums * sizeof(float)));
			gpuErrchk(cudaMemcpyToSymbol(dMlpBnBeta, mlpBnBeta_arg, mlpBnBetaGammaDataNums * sizeof(float)));
			gpuErrchk(cudaMemcpyToSymbol(dMlpBnGamma, mlpBnGamma_arg, mlpBnBetaGammaDataNums * sizeof(float)));

			//各種値の代入
			//sv
			gpuErrchk(cudaMemcpyToSymbol(cSvChannelNums, &svChannelNums_arg, sizeof(int)));
			gpuErrchk(cudaMemcpyToSymbol(cSv_xNums, &sv_xNums_arg, sizeof(int)));
			gpuErrchk(cudaMemcpyToSymbol(cSv_yNums, &sv_yNums_arg, sizeof(int)));
			//ノード数
			gpuErrchk(cudaMemcpyToSymbol(cCnnOutputNums, cnnOutputNums_arg, sizeof(int) * getCnnOutputNumsNums()));
			gpuErrchk(cudaMemcpyToSymbol(cMlpOutputNums, mlpOutputNums_arg, sizeof(int) * getCnnOutputNumsNums()));
			gpuErrchk(cudaMemcpyToSymbol(cCnnOutputNumsNums, &cnnOutputNumsNums_arg, sizeof(int)));
			gpuErrchk(cudaMemcpyToSymbol(cMlpOutputNumsNums, &mlpOutputNumsNums_arg, sizeof(int)));
			//出力(wba,p)
			gpuErrchk(cudaMemcpyToSymbol(cCnnWba_xNums, cnnWba_xNums, sizeof(int) * getCnnOutputNumsNums()));
			gpuErrchk(cudaMemcpyToSymbol(cCnnWba_yNums, cnnWba_yNums, sizeof(int) * getCnnOutputNumsNums()));
			gpuErrchk(cudaMemcpyToSymbol(cCnnP_xNums, cnnP_xNums, sizeof(int) * getCnnOutputNumsNums()));
			gpuErrchk(cudaMemcpyToSymbol(cCnnP_yNums, cnnP_yNums, sizeof(int) * getCnnOutputNumsNums()));
			//cnnW
			gpuErrchk(cudaMemcpyToSymbol(cCnnW_xNums, &cnnW_xNums, sizeof(int)));
			gpuErrchk(cudaMemcpyToSymbol(cCnnW_yNums, &cnnW_yNums, sizeof(int)));
			//cnnPooling
			gpuErrchk(cudaMemcpyToSymbol(cCnnPooling_xNums, &cnnPooling_xNums, sizeof(int)));
			gpuErrchk(cudaMemcpyToSymbol(cCnnPooling_yNums, &cnnPooling_yNums, sizeof(int)));
			//その他
			gpuErrchk(cudaMemcpyToSymbol(cMiniBatchNums, &miniBatchNums_arg, sizeof(int)));
			gpuErrchk(cudaMemcpyToSymbol(cLearningRate, &learningRate, sizeof(float)));

			//Constant Memory チェック
			checkConstantMemory();

			//各種制限値チェック
			checkMiniBatchNums(getMiniBatchNums());
			checkOutputNums(cnnOutputNums, getCnnOutputNumsNums(), mlpOutputNums, getMlpOutputNumsNums());
			checkW_xyNums(getCnnW_xNums(), getCnnW_yNums());

			//Online
			if(getExecFlg() == getExecFlgOnline()){
				puts("Online start.");
				jnaExecuteBeforeOnline(sv_arg, oneSvDataNums, cnnBnAveMean, cnnBnAveVar2, mlpBnAveMean, mlpBnAveVar2);
				jnaExecuteOnline();
				jnaExecuteAfterOnline();
			}
			//Trainig
			else if(getExecFlg() == getExecFlgTraining()){
				puts("Training start.");
				int episode, step;
				for(episode = 0; episode < episodeNums; episode++){
					//struct timeval t1, t2, t3, t4;
					//gettimeofday(&t1, NULL);
					jnaExecuteBeforeTraining(svAll, teachOutAll, oneSvDataNums, oneTeachOutDataNums, allDataNums);
					//gettimeofday(&t2, NULL);
					for(step = 0; step < stepNums; step++){
						printf("LOG:episode=%d, step=%d, learningRate=%f\n",episode,step,getLearningRate());
						jnaExecuteTraining();
						/*
						if(step == 5){
							exit(2);
						}
						*/
						if(breakCheck() == true){
							break;
						}
						/*
						if(step == 4){
							printCnnMlpW();
							printCnnMlpBnBeta();
							printCnnMlpBnGamma();
							exit(2);
						}
						*/
					}
					//gettimeofday(&t3, NULL);
					//batch normalizationの結果をinfBnMean,Var2にコピーする。
					inferenceBnMeanVar2(episode, infCnnBnMean, infCnnBnVar2, infMlpBnMean, infMlpBnVar2);
					attenuationLearningRate(episode);
					//printf("timeRec\n");
					//printTime(t1,t2,t3);
					//exit(2);
				}
				jnaExecuteAfterTraining(cnnW_arg, mlpW_arg, cnnBnGamma_arg, cnnBnBeta_arg, mlpBnGamma_arg, mlpBnBeta_arg);
			}
			else{
				printf("execFlg error. (execFlg=%d)\n", getExecFlg());
			}
		}
