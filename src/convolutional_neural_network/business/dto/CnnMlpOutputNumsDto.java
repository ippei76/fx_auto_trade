package convolutional_neural_network.business.dto;

public class CnnMlpOutputNumsDto{

	//member
	private int seqNo;

	private int type;

	private int layer;

	private int nums;

	//accessor
	//setter
	public void setSeqNo(int seqNo){
		this.seqNo = seqNo;
	}

	public void setType(int type){
		this.type = type;
	}

	public void setLayer(int layer){
		this.layer = layer;
	}

	public void setNums(int nums){
		this.nums = nums;
	}

	//getter
	public int getSeqNo(){
		return(this.seqNo);
	}

	public int getType(){
		return(this.type);
	}

	public int getLayer(){
		return(this.layer);
	}

	public int getNums(){
		return(this.nums);
	}
}
