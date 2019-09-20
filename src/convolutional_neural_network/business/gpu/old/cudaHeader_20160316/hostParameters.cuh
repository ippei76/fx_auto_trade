extern void setSv_xNums(int sv_xNums_arg);
extern int getSv_xNums();
extern void setSv_yNums(int sv_yNums_arg);
extern int getSv_yNums();
extern void setSvDataMiniNums(int svDataMiniNums_arg);
extern int getSvDataMiniNums();
extern void setSvChannelNums(int svChannelNums_arg);
extern int getSvChannelMiniNums();
extern void setSv(float *sv_arg);
extern int *sv;

extern void setCnnOutputNumsNums(int cnnOutputNumsNums_arg);
extern int getCnnOutputNumsNums();
extern void setCnnOutputNums(int *cnnOutputNums_arg);
extern int *cnnOutputNums;

extern void setCnnFilter_xNums(int cnnFilter_xNums_arg);
extern int getCnnFilter_xNums();
extern void setCnnFilter_yNums(int cnnFilter_yNums_arg);
extern int getCnnFilter_yNums();
extern void setCnnFilter(float *cnnFilter_arg);
extern float *cnnFilter;

extern void setPooling_xNums(int pooling_xNums_arg);
extern int getPooling_xNums();
extern void setPooling_yNums(int pooling_yNums_arg);
extern int getPooling_yNums();

extern void setWb_xNums(int wb_xNums_arg);
extern int getWb_xNums();
extern void setWb_yNums(int wb_yNums_arg);
extern int getWb_yNums();
extern void setWb(float *wb_arg);
extern float *wb;

extern void setA_xNums(int a_xNums_arg);
extern int getA_xNums();
extern void setA_yNums(int a_yNums_arg);
extern int getA_yNums();
extern void setA(float *a_arg);
extern float *a;

extern void setP_xNums(int p_xNums_arg);
extern int getP_xNums();
extern void setP_yNums(int p_yNums_arg);
extern int getP_yNums();
extern void setP(float *p_arg);
extern float *p;

extern int getDim2Idx(int x, int X, int y, int Y);
extern int getDim3Idx(int x, int X, int y, int Y, int z, int Z);
