#include <stdio.h>
#include <constraint.cuh>

extern void printResult();
extern void printVar2();
extern void printCnnMlpW();
extern void printCnnMlpBnBeta();
extern void printCnnMlpBnGamma();

void checkInput_xyNums(const int input_xNums, const int input_yNums){
	if(input_xNums > maxInput_xNums || input_yNums > maxInput_yNums){
		puts("LOG:input_xyNums error.");
		printf("LOG:input_xNums(%d) > maxInput_xNums(%d)\nor\n", input_xNums, maxInput_xNums);
		printf("LOG:input_yNums(%d) > maxInput_yNums(%d)", input_yNums, maxInput_yNums);
		exit(2);
	}
}

void checkInputChannelNums(const int inputChannelNums){
	if(inputChannelNums > maxInputChannelNums){
		puts("LOG:inputChannelNums error.");
		printf("LOG:inputChannelNums(%d) > maxInputChannelNums(%d)\nor\n", inputChannelNums, maxInputChannelNums);
		exit(2);
	}
}

void checkMiniBatchNums(const int miniBatchNums_arg){
	if(miniBatchNums_arg > maxMiniBatchNums){
		puts("LOG:miniBatchNums error.");
		printf("LOG:miniBatchNums(%d) > maxMiniBatchNums(%d)\nor\n", miniBatchNums_arg, maxMiniBatchNums);
		exit(2);
	}
}

void checkOutputNums(const int *cnnOutputNums_arg, const int cnnOutputNumsNums, const int *mlpOutputNums_arg, const int mlpOutputNumsNums){
	if(cnnOutputNumsNums > maxCnnOutputNumsNums || mlpOutputNumsNums > maxMlpOutputNumsNums){
		puts("LOG:outputNums error.");
		printf("LOG:cnnOutputNumsNums(%d) > maxCnnOutputNumsNums(%d)\nor\n", cnnOutputNumsNums, maxCnnOutputNumsNums);
		printf("LOG:mlpOutputNumsNums(%d) > maxMlpOutputNumsNums(%d)\nor\n", mlpOutputNumsNums, maxMlpOutputNumsNums);
		exit(2);
	}

	int layer;
	for(layer = 0; layer < cnnOutputNumsNums; layer++){
		if(cnnOutputNums_arg[layer] > maxCnnOutputNums){
			puts("LOG:outputNums error.");
			printf("LOG:cnnOutputNums[%d](%d) > maxCnnOutputNums(%d)\n", layer, cnnOutputNums_arg[layer], maxCnnOutputNums);
			exit(2);
		}
	}
	for(layer = 0; layer < mlpOutputNumsNums; layer++){
		if(mlpOutputNums_arg[layer] > maxMlpOutputNums){
			puts("LOG:outputNums error.");
			printf("LOG:mlpOutputNums[%d](%d) > maxMlpOutputNums(%d)\n", layer, mlpOutputNums_arg[layer], maxMlpOutputNums);
			exit(2);
		}
	}
}

void checkW_xyNums(const int w_xNums_arg, const int w_yNums_arg){
	if(w_xNums_arg > maxW_xNums || w_yNums_arg > maxW_yNums){
		puts("LOG:w_xyNums error.");
		printf("LOG:w_xNums(%d) > maxW_xNums(%d)\nor\n", w_xNums_arg, maxW_xNums);
		printf("LOG:w_yNums(%d) > maxW_yNums(%d)", w_yNums_arg, maxW_yNums);
		exit(2);
	}
}

void checkInputDataSize(const int inputDataSize){
	if(inputDataSize > maxInputDataNums * sizeof(float)){
		puts("LOG:inputDataSize error.");
		printf("LOG:inputDataSize : %d\n", inputDataSize);
		printf("LOG:maxInputDataNums : %d\n", maxInputDataNums);
		exit(2);
	}
}

void checkGridSize(dim3 dim3GridSize){
	int gridSize = dim3GridSize.x * dim3GridSize.y * dim3GridSize.z;
	if(gridSize > maxGridSize){ 
		puts("LOG:GridSize error.");
		printf("LOG:gridSize : %d\n", gridSize);
		printf("LOG:maxGridSize : %d\n", maxGridSize);
		exit(2);
	}
}

void checkThreadSize(dim3 dim3ThreadSize){
	int threadSize = dim3ThreadSize.x * dim3ThreadSize.y * dim3ThreadSize.z;
	if(threadSize > maxThreadSize){ 
		puts("LOG:ThreadSize error.");
		printf("LOG:threadSize : %d\n", threadSize);
		printf("LOG:maxThreadSize : %d\n", maxThreadSize);
		exit(2);
	}
	if(dim3ThreadSize.x > maxThreadSize){
		puts("LOG:dim3ThreadSize.x error.");
		printf("LOG:dim3ThreadSize.x : %d\n", dim3ThreadSize.x);
		printf("LOG:maxThreadSize_x : %d\n", maxThreadSize_x);
		exit(2);
	}
	if(dim3ThreadSize.y > maxThreadSize){
		puts("LOG:dim3ThreadSize.y error.");
		printf("LOG:dim3ThreadSize.y : %d\n", dim3ThreadSize.y);
		printf("LOG:maxThreadSize_y : %d\n", maxThreadSize_y);
		exit(2);
	}
	if(dim3ThreadSize.z > maxThreadSize){
		puts("LOG:dim3ThreadSize.z error.");
		printf("LOG:dim3ThreadSize.z : %d\n", dim3ThreadSize.z);
		printf("LOG:maxThreadSize_z : %d\n", maxThreadSize_z);
		exit(2);
	}
}

void checkSharedMemorySize(const int sharedMemorySize){
	if(sharedMemorySize > maxSharedMemorySize){ 
		puts("LOG:SharedMemorySize error.");
		printf("LOG:sharedMemorySize : %d\n", sharedMemorySize);
		printf("LOG:maxSharedMemorySize : %d\n", maxSharedMemorySize);
		exit(2);
	}
}

void checkInputW(const int input_xNums, const int input_yNums, const int w_xNums, const int w_yNums){
	if(input_xNums < w_xNums || input_yNums < w_yNums){
		puts("LOG:InputWSize error.");
		printf("LOG:input_xNums : %d\n", input_xNums);
		printf("LOG:w_xNums : %d\n", w_xNums);
		printf("LOG:input_yNums : %d\n", input_yNums);
		printf("LOG:w_yNums : %d\n", w_yNums);
		exit(2);
	}
	//畳み込み後のサイズがフィルタのサイズより小さくなってはいけない。
	//wをシェアードメモリにコピーするときに、コピー漏れが発生する。
	if(input_xNums - w_xNums + 1 < w_xNums || input_yNums - w_yNums + 1 < w_yNums){
		puts("LOG:Input and wSize error.");
		printf("LOG:input_xNums : %d\n", input_xNums);
		printf("LOG:w_xNums : %d\n", w_xNums);
		printf("LOG:input_yNums : %d\n", input_yNums);
		printf("LOG:w_yNums : %d\n", w_yNums);
		exit(2);
	}
}

void checkConstantMemory(){
	int constMemSum = 0;

	//cCnnOutputNums
	//cWba_xNums
	//cWba_yNums
	//cP_xNums
	//cP_yNums
	constMemSum += sizeof(int) * maxCnnOutputNumsNums * 5;

	//cMlpOutputNums
	constMemSum += sizeof(int) * maxMlpOutputNumsNums * 1;

	//cW_xNums
	//cW_yNums
	//cPooling_xNums
	//cPooling_yNums
	constMemSum += sizeof(int) * 4;

	//cCnnBnAveMean
	//cCnnBnAveVar2
	constMemSum += sizeof(int) * maxCnnLayerNumsSum * 2;

	//cMlpBnAveMean
	//cMlpBnAveVar2
	constMemSum += sizeof(int) * maxMlpLayerNumsSum * 2;

	if(constMemSum > maxConstantMemorySize){
		puts("LOG:constant memory size error.");
		printf("LOG:constMemSum(%d) > maxConstantMemorySize(%d)", constMemSum, maxConstantMemorySize);
		exit(2);
	}

}

void checkInfNan(const float inf_nan_arg, const char *message){
	if(isinf(inf_nan_arg)){
		printf("LOG:inf error.(%s)\n", message);
		printResult();
		printVar2();
		printCnnMlpW();
		printCnnMlpBnBeta();
		printCnnMlpBnGamma();
		exit(2);
	}
	if(isnan(inf_nan_arg)){
		printf("LOG:nan error.(%s)\n", message);
		printResult();
		printVar2();
		printCnnMlpW();
		printCnnMlpBnBeta();
		printCnnMlpBnGamma();
		exit(2);
	}
}

void checkNodeValues(const int cnnWbaDataNums, const int cnnPDataNums, const int mlpWbaDataNums, const int mlpLastOutputNums){
	if(cnnWbaDataNums > maxCnnWbaDataNums){
		puts("LOG:cnnWbaDataNums error.");
		printf("LOG:cnnWbaDataNums(%d) > max(%d)", cnnWbaDataNums, maxCnnWbaDataNums);
		exit(2);
	}
	if(cnnPDataNums > maxCnnPDataNums){
		puts("LOG:cnnPDataNums error.");
		printf("LOG:cnnPDataNums(%d) > max(%d)", cnnPDataNums, maxCnnPDataNums);
		exit(2);
	}
	if(mlpWbaDataNums > maxMlpWbaDataNums){
		puts("LOG:mlpWbaDataNums error.");
		printf("LOG:mlpWbaDataNums(%d) > max(%d)", mlpWbaDataNums, maxMlpWbaDataNums);
		exit(2);
	}
	if(mlpLastOutputNums > maxTeachOutNums){
		puts("LOG:mlpLastOutputNums error.");
		printf("LOG:mlpLastOutputNums(%d) > max(%d)", mlpLastOutputNums, maxTeachOutNums);
		exit(2);
	}
}

void checkLearnValues(const int cnnWDataNums, const int cnnBnBetaGammaDataNums, const int mlpWDataNums, const int mlpBnBetaGammaDataNums){
	if(cnnWDataNums > maxCnnWDataNums){
		puts("LOG:cnnWDataNums error.");
		printf("LOG:cnnWDataNums(%d) > max(%d)", cnnWDataNums, maxCnnWDataNums);
		exit(2);
	}
	if(cnnBnBetaGammaDataNums > maxCnnLayerNumsSum){
		puts("LOG:cnnBnBetaGammaDataNums error.");
		printf("LOG:cnnBnBetaGammaDataNums(%d) > max(%d)", cnnBnBetaGammaDataNums, maxCnnLayerNumsSum);
		exit(2);
	}
	if(mlpWDataNums > maxMlpWDataNums){
		puts("LOG:mlpWDataNums error.");
		printf("LOG:mlpWDataNums(%d) > max(%d)", mlpWDataNums, maxMlpWDataNums);
		exit(2);
	}
	if(mlpBnBetaGammaDataNums > maxMlpLayerNumsSum){
		puts("LOG:mlpBnBetaGammaDataNums error.");
		printf("LOG:mlpBnBetaGammaDataNums(%d) > max(%d)", mlpBnBetaGammaDataNums, maxMlpLayerNumsSum);
		exit(2);
	}

}

void checkSvTeachOutDataNums(const int oneSvDataNums, const int oneTeachOutDataNums){
	if(oneSvDataNums > maxInputDataNums){
		puts("LOG:oneSvDataNums error.");
		printf("LOG:oneSvDataNums(%d) > max(%d)", oneSvDataNums, maxInputDataNums);
		exit(2);
	}
	if(oneTeachOutDataNums > maxOutputDataNums){
		puts("LOG:oneTeachOutDataNums error.");
		printf("LOG:oneTeachOutDataNums(%d) > max(%d)", oneTeachOutDataNums, maxOutputDataNums);
		exit(2);
	}
}
