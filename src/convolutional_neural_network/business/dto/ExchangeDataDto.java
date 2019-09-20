package convolutional_neural_network.business.dto;

public class ExchangeDataDto{

	//member
	private String date;

	private String time;

	private int opnRate;

	private int hghtPrc;

	private int lwPrc;

	private int clsRate;

	private int diffOpn;

	private int diffHght;

	private int diffLw;

	private int diffCls;

	private int emaShrt;

	private int diffEma;

	private int emaSgnl;

	private int sigmaMid;

	private int sigmaUp;

	private int sigmaDown;

	private int rsi;

	private int profitAct;

	private int trgtFlg;

	private long seqNo;

	//accessor
	//setters

	public void setDate(String date){
		this.date = date;
	}

	public void setTime(String time){
		this.time = time;
	}

	public void setOpnRate(int opnRate){
		this.opnRate = opnRate;
	}

	public void setHghtPrc(int hghtPrc){
		this.hghtPrc = hghtPrc;
	}

	public void setLwPrc(int lwPrc){
		this.lwPrc = lwPrc;
	}

	public void setClsRate(int clsRate){
		this.clsRate = clsRate;
	}

	public void setDiffOpn(int diffOpn){
		this.diffOpn = diffOpn;
	}

	public void setDiffHght(int diffHght){
		this.diffHght = diffHght;
	}

	public void setDiffLw(int diffLw){
		this.diffLw = diffLw;
	}

	public void setDiffCls(int diffCls){
		this.diffCls = diffCls;
	}

	public void setEmaShrt(int emaShrt){
		this.emaShrt = emaShrt;
	}

	public void setDiffEma(int diffEma){
		this.diffEma = diffEma;
	}

	public void setEmaSgnl(int emaSgnl){
		this.emaSgnl = emaSgnl;
	}

	public void setSigmaMid(int sigmaMid){
		this.sigmaMid = sigmaMid;
	}

	public void setSigmaUp(int sigmaUp){
		this.sigmaUp = sigmaUp;
	}

	public void setSigmaDown(int sigmaDown){
		this.sigmaDown = sigmaDown;
	}

	public void setRsi(int rsi){
		this.rsi = rsi;
	}

	public void setProfitAct(int profitAct){
		this.profitAct = profitAct;
	}

	public void setTrgtFlg(int trgtFlg){
			this.trgtFlg = trgtFlg;
	}

	public void setSeqNo(long seqNo){
			this.seqNo = seqNo;
	}

	//getters

	public String getDate(){
		return(date);
	}

	public String getTime(){
		return(time);
	}

	public int getOpnRate(){
		return(opnRate);
	}

	public int getHghtPrc(){
		return(hghtPrc);
	}

	public int getLwPrc(){
		return(lwPrc);
	}

	public int getClsRate(){
		return(clsRate);
	}

	public int getDiffOpn(){
		return(diffOpn);
	}

	public int getDiffHght(){
		return(diffHght);
	}

	public int getDiffLw(){
		return(diffLw);
	}

	public int getDiffCls(){
		return(diffCls);
	}

	public int getEmaShrt(){
		return(emaShrt);
	}

	public int getDiffEma(){
		return(diffEma);
	}

	public int getEmaSgnl(){
		return(emaSgnl);
	}

	public int getSigmaMid(){
		return(sigmaMid);
	}

	public int getSigmaUp(){
		return(sigmaUp);
	}

	public int getSigmaDown(){
		return(sigmaDown);
	}

	public int getRsi(){
		return(rsi);
	}

	public int getProfitAct(){
		return(profitAct);
	}

	public int getTrgtFlg(){
			return(trgtFlg);
	}

	public long getSeqNo(){
			return(seqNo);
	}

}
