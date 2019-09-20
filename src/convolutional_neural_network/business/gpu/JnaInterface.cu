#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "check.cu"
#include "hostAccesser.cu"
#include "deviceAccesser.cu"
#include "cnnMain.cu"
#include "cnnConvolution.cu"
#include "cnnBatchNormalization.cu"
#include "cnnActivate.cu"
#include "cnnPooling.cu"
#include "mlpMultiply.cu"
#include "mlpBatchNormalization.cu"
#include "mlpActivate.cu"
#include "lossFunc.cu"
#include "backMlpActivate.cu"
#include "backMlpBatchNormalization.cu"
#include "backMlpMultiply.cu"
#include "backCnnPMlpW.cu"
#include "backCnnPooling.cu"
#include "backCnnActivate.cu"
#include "backCnnBatchNormalization.cu"
#include "backCnnConvolution.cu"
#include "backCnnSv.cu"
#include "inferenceBnMeanVar2.cu"
#include "cnnBatchNormalization_culcurationAveVar2.cu"
#include "backCnnConvolution_culcurationDelTmp.cu"
#ifdef __cplusplus
extern "C" {//pay attention to this!
#endif 

	void jnaInterface(
			int sv_xNums_arg, int sv_yNums_arg, int miniBatchNums_arg, int svChannelNums_arg, float *sv_arg, float *svAll_arg, float *teachOut_arg, float *teachOutAll_arg,

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

			int cnnWDataNums, int cnnBnBetaGammaDataNums,

			int mlpWDataNums, int mlpBnBetaGammaDataNums,

			float *infCnnBnMean, float *infCnnBnVar2, float *infMlpBnMean, float *infMlpBnVar2,

			//トレーニング時には、使用しない。
			float *cnnBnAveMean, float *cnnBnAveVar2, float *mlpBnAveMean, float *mlpBnAveVar2,

			//「トレーニング:0」「Online:1」
			int execFlg_arg, float *result_arg, float learningRate_arg

				){

					cnnMain(\
							sv_xNums_arg, sv_yNums_arg, miniBatchNums_arg, svChannelNums_arg, sv_arg, svAll_arg, teachOut_arg, teachOutAll_arg,\
							\
							cnnOutputNums_arg, cnnOutputNumsNums_arg,\
							\
							cnnBnBeta_arg, cnnBnGamma_arg, bnEps_arg,\
							\
							cnnW_xNums_arg, cnnW_yNums_arg, cnnW_arg,\
							\
							cnnPooling_xNums_arg, cnnPooling_yNums_arg,\
							\
							cnnWba_xNums_arg, cnnWba_yNums_arg,\
							\
							cnnP_xNums_arg, cnnP_yNums_arg,\
							\
							mlpOutputNums_arg, mlpOutputNumsNums_arg,\
							\
							mlpBnBeta_arg, mlpBnGamma_arg,\
							\
							mlpW_arg,\
							\
							stepNums, episodeNums,\
							\
							oneSvDataNums, oneTeachOutDataNums, allDataNums,\
							\
							cnnWbaDataNums, cnnPDataNums, mlpWbaDataNums,\
							\
							cnnWDataNums, cnnBnBetaGammaDataNums,\
							\
							mlpWDataNums, mlpBnBetaGammaDataNums,\
							\
							infCnnBnMean, infCnnBnVar2, infMlpBnMean, infMlpBnVar2,\
							\
							cnnBnAveMean, cnnBnAveVar2, mlpBnAveMean, mlpBnAveVar2,\
							\
							execFlg_arg, result_arg, learningRate_arg
							);
					puts("deep learning training end");
				}
#ifdef __cplusplus
} //pay attention to this
#endif 
