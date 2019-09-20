#ifndef INCLUDED_CONSTRAINT
#define INCLUDED_CONSTRAINT

const int maxCnnOutputNums = 50;
const int maxMlpOutputNums = 500;
const int maxCnnOutputNumsNums = 5;
const int maxMlpOutputNumsNums = 10;
const int maxMiniBatchNums = 32;
const int maxTeachOutNums = 10;
const int maxInput_xNums = 90;
const int maxInput_yNums = 90;
const int maxInputChannelNums = 100;
const int maxW_xNums = 5;
const int maxW_yNums = 5;
const int maxInputDataNums = maxInput_xNums * maxInput_yNums * maxInputChannelNums * maxMiniBatchNums; //45000 >= sv_xNums*sv_yNums*svChannelNumsが制約:90(分)*5(指標)*10(channels)*10(miniBatch)=0を想定
const int maxOutputDataNums =  maxTeachOutNums * maxMiniBatchNums;
const int maxGridSize = 65535;
const int maxThreadSize = 1024;
const int maxThreadSize_x = 1024;
const int maxThreadSize_y = 1024;
const int maxThreadSize_z = 64;
const int maxSharedMemorySize = 16000;
const int maxConstantMemorySize = 64000;
const int warpNums = 32;

//ノード変数・学習変数のグローバルメモリの配列サイズ定義
const int maxCnnWDataNums = maxW_xNums * maxW_yNums * maxInputChannelNums * maxCnnOutputNums * maxCnnOutputNumsNums; //16000 >= w_xNums*w_yNums*getInputNums(layer)*getOutputNums(layer)が制約：5*5*20*20=2500を想定
const int maxMlpWDataNums = 10000000; //シェアードに使用していないので無制限
//const int maxMlpWDataNums = maxInputChannelNums * maxOutputNums * maxOutputNumsNums; //シェアードに使用していないので無制限
//const int maxCnnWbaDataNums = maxInput_xNums * maxInput_yNums * maxOutputNums * maxMiniBatchNums * maxOutputNumsNums;
const int maxCnnWbaDataNums = maxInput_xNums * maxInput_yNums * maxCnnOutputNums * maxMiniBatchNums * maxCnnOutputNumsNums / 2;
const int maxCnnPDataNums = maxCnnWbaDataNums / 2;
const int maxMlpWbaDataNums = maxMlpOutputNums * maxMiniBatchNums * maxMlpOutputNumsNums;
const int maxCnnLayerNumsSum = maxCnnOutputNumsNums * maxCnnOutputNums;
const int maxMlpLayerNumsSum = maxMlpOutputNumsNums * maxMlpOutputNums;
#endif
