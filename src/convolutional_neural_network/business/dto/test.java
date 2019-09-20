setDate(rs.getString("date"));
setTime(rs.getString("time"));
setOpnRate(rs.getIng("opnRate"));
setHghtPrc(rs.getIng("hghtPrc"));
setLwPrc(rs.getIng("lwPrc"));
setClsRate(rs.getIng("clsRate"));
setDiffOpn(rs.getIng("diffOpn"));
setDiffHght(rs.getIng("diffHght"));
setDiffLw(rs.getIng("diffLw"));
setDiffCls(rs.getIng("diffCls"));
setEmaShrt(rs.getIng("emaShrt"));
etDiffEma(rs.getIng("diffEma"));
setEmaSgnl(rs.getIng("emaSgnl"));
setSigmaMid(rs.getIng("sigmaMid"));
setSigmaUp(rs.getIng("sigmaUp"));
setSigmaDown(rs.getIng("sigmaDown"));
setRsi(rs.getIng("rsi"));
setProfitAct(rs.getIng("profitAct"));
setTrgtFlg(rs.getIng("trgtFlg"));
setSeqNo(rs.getLong("seqNo"));

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
