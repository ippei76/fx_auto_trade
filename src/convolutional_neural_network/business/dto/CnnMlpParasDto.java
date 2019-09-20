package convolutional_neural_network.business.dto;

public class CnnMlpParasDto{

	//member
	private int seqNo;

	private String currency;

	private int plusCount;

	private int waitCount;

	private int minusCount;

	private int episodeNums;

	private int stepNums;

	private String sDate;

	private String eDate;

	private int miniBatchNums;

	private int svDataNums;

	private int sv_xNums;

	private int sv_yNums;

	private int cnnW_xNums;

	private int cnnW_yNums;

	private int cnnPooling_xNums;

	private int cnnPooling_yNums;

	private int cnnOutputNumsNums;

	private int mlpOutputNumsNums;

	private String rgstDateTime;

	//accessor
	//setter
	public void setSeqNo(int seqNo){
		this.seqNo = seqNo;
	}

	public void setCurrency(String currency){
		this.currency = currency;
	}

	public void setPlusCount(int plusCount){
		this.plusCount = plusCount;
	}

	public void setWaitCount(int waitCount){
		this.waitCount = waitCount;
	}

	public void setMinusCount(int minusCount){
		this.minusCount = minusCount;
	}

	public void setEpisodeNums(int episodeNums){
		this.episodeNums = episodeNums;
	}

	public void setStepNums(int stepNums){
		this.stepNums = stepNums;
	}

	public void setSDate(String sDate){
		this.sDate = sDate;
	}

	public void setEDate(String eDate){
		this.eDate = eDate;
	}

	public void setMiniBatchNums(int miniBatchNums){
		this.miniBatchNums = miniBatchNums;
	}

	public void setSvDataNums(int svDataNums){
		this.svDataNums = svDataNums;
	}

	public void setSv_xNums(int sv_xNums){
		this.sv_xNums = sv_xNums;
	}

	public void setSv_yNums(int sv_yNums){
		this.sv_yNums = sv_yNums;
	}

	public void setCnnW_xNums(int cnnW_xNums){
		this.cnnW_xNums = cnnW_xNums;
	}

	public void setCnnW_yNums(int cnnW_yNums){
		this.cnnW_yNums = cnnW_yNums;
	}

	public void setCnnPooling_xNums(int cnnPooling_xNums){
		this.cnnPooling_xNums = cnnPooling_xNums;
	}

	public void setCnnPooling_yNums(int cnnPooling_yNums){
		this.cnnPooling_yNums = cnnPooling_yNums;
	}

	public void setCnnOutputNumsNums(int cnnOutputNumsNums){
		this.cnnOutputNumsNums = cnnOutputNumsNums;
	}

	public void setMlpOutputNumsNums(int mlpOutputNumsNums){
		this.mlpOutputNumsNums = mlpOutputNumsNums;
	}

	public void setRgstDateTime(String rgstDateTime){
		this.rgstDateTime = rgstDateTime;
	}

	//getter
	public int getSeqNo(){
		return(this.seqNo);
	}

	public String getCurrency(){
		return(this.currency);
	}

	public int getPlusCount(){
		return(this.plusCount);
	}

	public int getWaitCount(){
		return(this.waitCount);
	}

	public int getMinusCount(){
		return(this.minusCount);
	}

	public int getEpisodeNums(){
		return(this.episodeNums);
	}

	public int getStepNums(){
		return(this.stepNums);
	}

	public String getSDate(){
		return(this.sDate);
	}

	public String getEDate(){
		return(this.eDate);
	}

	public int getMiniBatchNums(){
		return(this.miniBatchNums);
	}

	public int getSvDataNums(){
		return(this.svDataNums);
	}

	public int getSv_xNums(){
		return(this.sv_xNums);
	}

	public int getSv_yNums(){
		return(this.sv_yNums);
	}

	public int getCnnW_xNums(){
		return(this.cnnW_xNums);
	}

	public int getCnnW_yNums(){
		return(this.cnnW_yNums);
	}

	public int getCnnPooling_xNums(){
		return(this.cnnPooling_xNums);
	}

	public int getCnnPooling_yNums(){
		return(this.cnnPooling_yNums);
	}

	public int getCnnOutputNumsNums(){
		return(this.cnnOutputNumsNums);
	}

	public int getMlpOutputNumsNums(){
		return(this.mlpOutputNumsNums);
	}

	public String getRgstDateTime(){
		return(this.rgstDateTime);
	}

}
