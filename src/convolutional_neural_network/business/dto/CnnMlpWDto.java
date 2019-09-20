package convolutional_neural_network.business.dto;

public class CnnMlpWDto{

	//member
	private int seqNo;

	private int type;

	private int idx;

	private float value;

	
	//accessor
	//setter
	public void setSeqNo(int seqNo){
		this.seqNo = seqNo;
	}

	public void setType(int type){
		this.type = type;
	}

	public void setIdx(int idx){
		this.idx = idx;
	}

	public void setValue(float value){
		this.value = value;
	}

	//getter
	public int getSeqNo(){
		return(this.seqNo);
	}

	public int getType(){
		return(this.type);
	}

	public int getIdx(){
		return(this.idx);
	}

	public float getValue(){
		return(this.value);
	}
}
