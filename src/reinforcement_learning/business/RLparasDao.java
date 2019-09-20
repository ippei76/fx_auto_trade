package reinforcement_learning.business;

import java.sql.*;
import java.util.*;
import java.util.Calendar;
import java.util.Date;
import java.math.BigDecimal;
import static reinforcement_learning.values.Constants.*;
import static reinforcement_learning.values.Variables.*;


public class RLparasDao extends RLdao {

	public RLparasDao(){
		super();
	}

	public int selectRLunits(long seqNo, byte act){
		//指定されたRLSEQNOのユニット数を取得する。
		int retUnits = -1;
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT UNITS FROM RL_UNITS";
			sql += " WHERE RL_SEQ_NO = " + seqNo;
			sql += " AND ACT = " + act + ";";

			rs = stmt.executeQuery(sql);

			while(rs.next()){
				retUnits = rs.getInt("UNITS");
				if(rs.wasNull()){
					System.out.println("units is null.");
					System.exit(2);
				}
			}
			rs.close();
		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
		return(retUnits);
	}

	public ArrayList<BigDecimal> selectRLmuParas(long seqNo){
		//指定されたRLSEQNOのMUパラメータ値を取得する
		ArrayList<BigDecimal> muList = new ArrayList<BigDecimal>();
		muList.clear();
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT MU_VALUE FROM RL_MU";
			sql += " WHERE RL_SEQ_NO = " + seqNo;
			sql += " ORDER BY ACT, UNIT, STATE ;";

			rs = stmt.executeQuery(sql);

			while(rs.next()){
				muList.add(rs.getBigDecimal("MU_VALUE"));
				if(rs.wasNull()){
					System.out.println("mu is null.");
					System.exit(2);
				}
			}
			rs.close();
		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);

		}
		return(muList);
	}

	public ArrayList<BigDecimal> selectRLsigmaParas(long seqNo){
		//指定されたRLSEQNOのSIGMAパラメータ値を取得する
		ArrayList<BigDecimal> sigmaList = new ArrayList<BigDecimal>();
		sigmaList.clear();
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT SIGMA_VALUE FROM RL_SIGMA";
			sql += " WHERE RL_SEQ_NO = " + seqNo;
			sql += " ORDER BY ACT, UNIT;";

			rs = stmt.executeQuery(sql);

			while(rs.next()){
				sigmaList.add(rs.getBigDecimal("SIGMA_VALUE"));
				if(rs.wasNull()){
					System.out.println("sigma is null.");
					System.exit(2);
				}
			}
			rs.close();
		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
		return(sigmaList);
	}

	public ArrayList<BigDecimal> selectRLwParas(long seqNo){
		//指定されたRLSEQNOのWパラメータ値を取得する
		ArrayList<BigDecimal> wList = new ArrayList<BigDecimal>();
		wList.clear();
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT W_VALUE FROM RL_W";
			sql += " WHERE RL_SEQ_NO = " + seqNo;
			sql += " ORDER BY ACT, UNIT;";

			rs = stmt.executeQuery(sql);

			while(rs.next()){
				wList.add(rs.getBigDecimal("W_VALUE"));
				if(rs.wasNull()){
					System.out.println("w is null.");
					System.exit(2);
				}
			}
			rs.close();
		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
		return(wList);
	}

	public ArrayList<BigDecimal> selectRLxcParas(long seqNo){
		//指定されたRLSEQNOのxcパラメータ値を取得する
		ArrayList<BigDecimal> xcList = new ArrayList<BigDecimal>();
		xcList.clear();
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT XC_VALUE FROM RL_XC";
			sql += " WHERE RL_SEQ_NO = " + seqNo;
			sql += " ORDER BY ACT;";

			rs = stmt.executeQuery(sql);

			while(rs.next()){
				xcList.add(rs.getBigDecimal("XC_VALUE"));
				if(rs.wasNull()){
					System.out.println("xc is null.");
					System.exit(2);
				}
			}
			rs.close();
		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
		return(xcList);
	}

}
