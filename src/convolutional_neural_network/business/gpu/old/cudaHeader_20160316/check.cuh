extern const int CNNLAYER;
extern const int maxInputSize;
extern const int maxInput_xNums;
extern const int maxInput_yNums;
extern const int maxInputChannel;
extern const int maxOutputSize;
extern const int maxW_xNums;
extern const int maxW_yNums;
extern const int INPUTDATASIZE; //16000 >= sv_xNums*sv_yNums*svChannelNumsが制約:120(分)*10(指標)*5(rate)=6000を想定
extern const int maxGridSize;
extern const int maxThreadSize;
extern const int maxSharedMemorySize;

extern const int WSIZE; //16000 >= w_xNums*w_yNums*getInputNums(layer)*getOutputNums(layer)が制約：5*5*20*20=2500を想定


extern void checkInputDataSize(int inputDataSize);

//extern void checkGridSize(dim3 dim3GridSize);

//extern void checkThreadSize(dim3 dim3ThreadSize);

//extern void checkSharedMemorySize(int sharedMemorySize);
