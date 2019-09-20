//extern __constant__ int cW[CNNLAYER];
__shared__ int cW[CNNLAYER];
extern __constant__ int cCnnoutputNumsNums;
//出力(wba, p)：
extern __constant__ int cWba_xNums[CNNLAYER]; //配列だから、固定でMAX値を割り当てておく
extern __constant__ int cWba_yNums[CNNLAYER]; //配列だから、固定でMAX値を割り当てておく
extern __constant__ int cP_xNums[CNNLAYER]; //配列だから、固定でMAX値を割り当てておく
extern __constant__ int cP_yNums[CNNLAYER]; //配列だから、固定でMAX値を割り当てておく
//w_xy
extern __constant__ int cW_xNums;
extern __constant__ int cW_yNums;
//pooling_xy
extern __constant__ int cPooling_xNums;
extern __constant__ int cPooling_yNums;
//w：device定義とする。convolution層では、使用するところだけをシェアードに移す。
extern __device__ float dW[];
//b：device定義とする。convolution層では、使用するところだけをコンスタントメモリに移す。
extern __device__ float dB[];
extern __device__ float dWb[];
extern __device__ float dA[];
extern __device__ float dp[];

//~~~~~ここまで~~~~

//1各層分だけ確保し、各層で入れ替えて共有する。
extern __constant__ int cInputChannelNums;
extern __constant__ int cInputData_xNums;
extern __constant__ int cInputData_yNums;
extern __constant__ float cInputData[INPUTDATASIZE];//出力(wba_xy,p_xy)
extern __constant__ float cB[maxInputSize];
extern __constant__ float dWb[];
extern __constant__ int dWb_xNums;
extern __constant__ int dWb_yNums;

extern __device__ int getCWba_xNums(int cnnLayer);

extern __device__ int getCWba_yNums(int cnnLayer);

extern __device__ int getCP_xNums(int cnnLayer);

extern __device__ int getCP_yNums(int cnnLayer);
extern __device__ int getCW_xNums(int cnnLayer);
extern __device__ int getCW_yNums(int cnnLayer);

extern __device__ int getCPooling_xNums(int cnnLayer);

extern __device__ int getCPooling_yNums(int cnnLayer);


//input系アクセッサ
extern __device__ int getCInputChannelNums();

extern __device__ int getCInputData_xNums();

extern __device__ int getCInputData_yNums();

extern __device__ float getCInputData(int x, int y, int inputIdx);


//bアクセッサ
extern __device__ float getCB(int inputIdx);

//w系アクセッサ
extern __device__ int getCW_xNums();

extern __device__ int getCW_yNums();

extern __device__ float getDW(int x, int y, int inputIdx, int outputIdx, int cnnLayer);


//wba系アクセッサ
extern __device__ void setDA(int x, int y, int outputIdx, int cnnLayer, float setValue);


int getCCnnInputIdxNums(int cnnLayer);
