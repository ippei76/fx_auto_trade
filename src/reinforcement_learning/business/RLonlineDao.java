package reinforcement_learning.business;

import java.sql.*;
import java.util.*;
import java.util.Calendar;
import java.util.Date;
import java.math.BigDecimal;
import static reinforcement_learning.values.Constants.*;
import static reinforcement_learning.values.Variables.*;


public class RLonlineDao extends RLdao {

	public RLonlineDao(){
		super();
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
			}
			rs.close();
		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
		return(xcList);
	}

	public ArrayList<String> selectRecentDateTimeList(String mt4Table, int hisStep){
		//最新の時刻レコードとテーブル名を返す
		ArrayList<String> retDateTimeList = new ArrayList<String>();
		try{
			ResultSet rs;

			String sql;

			con.commit(); // DBを最新状態にする。

			sql = "SELECT SQL_NO_CACHE concat(DATE, TIME) FROM " + mt4Table;
			sql += " ORDER BY RGST_TIME DESC limit " + hisStep + ";";
			//sql += " WHERE RGST_TIME = (select max(RGST_TIME) from " + mt4Table + ");";

			rs = stmt.executeQuery(sql);

			while(rs.next()){
				retDateTimeList.add(rs.getString("concat(DATE, TIME)"));
			}
			rs.close();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
		return(retDateTimeList);
	}

	private long selectMaxSeqNo(String table){
		long maxSeqNo = -1;
		try{
			ResultSet rs;

			String sql;

			con.commit(); // DBを最新状態にする。

			sql = "SELECT SQL_NO_CACHE SEQ_NO FROM " + table ;
			sql += " ORDER BY RGST_TIME DESC limit 1;";

			rs = stmt.executeQuery(sql);
			while(rs.next()){
				maxSeqNo = rs.getInt("SEQ_NO");
			}
			rs.close();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
		return(maxSeqNo);
	}

	public ArrayList<Long> selectMaxSeqNoList(){
		//対象テーブルから最新のシーケンスNoリストを取得する。
		ArrayList<Long> seqNoList = new ArrayList<Long>();

		for(String mt4Table : mt4TableList){
			//最新のシーケンスNo取得
			long recentSeqNo = selectMaxSeqNo(mt4Table);

			seqNoList.add(recentSeqNo);
		}
		//closeConnection();
		return(seqNoList);
	}

	public ArrayList<BigDecimal> selectCurrentState(int hisStep){
		//対象テーブルから状態を抜く 
		
		ArrayList<BigDecimal> stateList = new ArrayList<BigDecimal>();

		ArrayList<String> stateCombinationList = new ArrayList<String>(Arrays.asList(stateCombination));

		// テーブル照会実行
		for(String mt4Table : mt4TableList){
			try{
				//最新のシーケンスNo取得
				long recentSeqNo = selectMaxSeqNo(mt4Table);
				ResultSet rs;

				String sql;

				con.commit(); // DBを最新状態にする。

				sql = "SELECT SQL_NO_CACHE " + getStateCombinationString();
				sql += " FROM " + mt4Table + " ";
				sql += " WHERE ";
				sql += (recentSeqNo - hisStep) + "< SEQ_NO AND SEQ_NO <= " + recentSeqNo;
				sql += " ORDER BY DATE, TIME;";

				rs = stmt.executeQuery(sql);

				while(rs.next()){
					for(String column : stateCombinationList){
						stateList.add(rs.getBigDecimal(column));
					}
				}
				rs.close();

			} catch(SQLException e){
				System.err.println("SQL failed.");
				e.printStackTrace();
				System.exit(2);

			}
		}
		return(stateList);
	}

}
