package convolutional_neural_network.business.dao;

import java.sql.*;
import java.util.*;
import static convolutional_neural_network.values.Constants.*;
import static convolutional_neural_network.values.Mt4Define.*;
import static convolutional_neural_network.common.CalendarMethod.*;
import convolutional_neural_network.business.dao.WorkTableImpChkDao;
import reinforcement_learning.business.DaoAbstruct;

public class WorkTableImpChkDao extends DaoAbstruct{

	public WorkTableImpChkDao() {
		super();
	}

	public void updateTargetFlgClear(){
		//本テーブルのフラグを0に戻す
		for(String mt4TableName : mt4InputTableNameList){
			try{
				String sql;
				sql = "UPDATE " + mt4TableName + " ";
				sql += "SET TRGT_FLG = 0 ;";

				stmt.executeUpdate(sql);
				con.commit();

			} catch(SQLException e){
				System.err.println("SQL failed.");
				e.printStackTrace();
				System.exit(2);

			}
		}

	}

	private long getSeqNoFromTableTime(String dateTime, String table){
		//取得した現時刻から、対応するSeqNoを取得する。

		long seqNo = 0;
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT MAX(SEQ_NO) FROM " + table + " WHERE concat(DATE, TIME) <= " + dateTime + " ";
			sql += "AND OPN_RATE <> 0;";

			rs = stmt.executeQuery(sql);
			while(rs.next()){
				seqNo = rs.getLong("MAX(SEQ_NO)");
			}
			rs.close();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);

		}
		return(seqNo);
	}

	public void updateTargetFlgInitialSet(String startDateTime, String endDateTime){
		//対象レコードに取り込みフラグをセット
		// STEPをstartDateTimeを起点に連番をセット

		for(String mt4TableName : mt4InputTableNameList){
			try{

				//TRGT_FLG対象として、svColumn分過去にさかのぼってデータを抽出する必要が有る。
				String idealStartDateTime = subtractionMinute(startDateTime, getSvColumnNums() * getInputBaseTime());

				long startSeqNo = getSeqNoFromTableTime(idealStartDateTime, mt4TableName);
				long endSeqNo = getSeqNoFromTableTime(endDateTime, mt4TableName);

				ResultSet rs;

				String sql;

				sql  = "UPDATE FX." + mt4TableName + " ";
				sql += "SET TRGT_FLG = 1 ";
				sql += "WHERE " + startSeqNo + " < SEQ_NO AND SEQ_NO <= " + endSeqNo + ";";

				stmt.executeUpdate(sql);

				con.commit();

			} catch(SQLException e){
				System.err.println("SQL failed.");
				e.printStackTrace();
				System.exit(2);
			}
		}
	}

	public void truncateWorkTable(){

		for(String mt4TableName : mt4InputTableNameList){
			String workTableName = getWorkTableName(mt4TableName);
			try{
				ResultSet rs;

				String sql;

				sql = "TRUNCATE TABLE FX." + workTableName + " ";

				stmt.executeUpdate(sql);

				con.commit();

			} catch(SQLException e){
				System.err.println("SQL failed.");
				e.printStackTrace();
				System.exit(2);

			}
		}	
	}

	public void insertMainToWorkTable(){
		//kokomada
		//本テーブルからワークテーブルに移す

		for(String mt4TableName : mt4InputTableNameList){
			String workTableName = getWorkTableName(mt4TableName);
			try{
				ResultSet rs;

				String sql1;
				String sql2;
				String sql3;
				String sql4;

				sql1 = "SET @a := " + (-1) * getSvColumnNums() + ";";

				sql2 = "INSERT INTO " + workTableName + " ";
				sql2 += "(SELECT @a := @a + 1, ";
				sql2 += "DATE, TIME, WDAY, OPN_RATE, HGHT_PRC, ";
				sql2 += "LW_PRC, CLS_RATE, DIFF_OPN, DIFF_HGHT, DIFF_LW, ";
				sql2 += "DIFF_CLS, EMAshrt, EMAlng, DIFF_EMA, EMAsgnl, ";
				sql2 += "SIGMA_MID, SIGMA_UP, SIGMA_DOWN, RSI, STOCHASTIC, PROFIT_ACT ";
				sql2 += "FROM " + mt4TableName + " tbl ";
				sql2 += "WHERE tbl.TRGT_FLG = 1 ";
				sql2 += "ORDER BY SEQ_NO );";

				stmt.executeUpdate(sql1);
				stmt.executeUpdate(sql2);

				con.commit();

			} catch(SQLException e){
				System.err.println("SQL failed.");
				e.printStackTrace();
				System.exit(2);

			}
		}
	}

	public void deleteZeroValueRecord(){
		//価格が0になっているデータを削除する。
		for(String mt4TableName : mt4InputTableNameList){
			String workTableName = getWorkTableName(mt4TableName);
			try{
				ResultSet rs;

				String sql;

				sql = "DELETE FROM " + workTableName + " ";
				sql += "WHERE OPN_RATE = 0;";

				stmt.executeUpdate(sql);

				con.commit();

			} catch(SQLException e){
				System.err.println("SQL failed.");
				e.printStackTrace();
				System.exit(2);

			}
		}	
	}

	public ArrayList<String> selectOverlapDateTimeList(){
		//時刻における重複レコードを取得する。
		ArrayList<String> overlapDateTimeList = new ArrayList<String>();
		for(String mt4TableName : mt4InputTableNameList){
			String workTableName = getWorkTableName(mt4TableName);
			try{
				ResultSet rs;

				String sql;

				sql = "SELECT DATE, TIME FROM " + workTableName + " ";
				sql += "GROUP BY DATE, TIME ";
				sql += "HAVING COUNT(*) >= 2 ";

				rs = stmt.executeQuery(sql);
				while(rs.next()){
					overlapDateTimeList.add(rs.getString("DATE") + rs.getString("TIME"));
				}
				rs.close();

				con.commit();

			} catch(SQLException e){
				System.err.println("SQL failed.");
				e.printStackTrace();
				System.exit(2);

			}
		}
		return(overlapDateTimeList);
	}

	public int selectProfitActIsMinusOne(){
		//ProfitActが-1のレコードを取得する。

		int countSum = 0;
		for(String mt4TableName : mt4InputTableNameList){
			String workTableName = getWorkTableName(mt4TableName);
			try{
				ResultSet rs;

				String sql;

				sql = "SELECT COUNT(*) FROM " + workTableName + " ";
				sql += "WHERE PROFIT_ACT = " + String.valueOf(getProfitActUnset()) + ";";

				rs = stmt.executeQuery(sql);
				while(rs.next()){
					countSum += rs.getInt("COUNT(*)");

				}
				rs.close();

				con.commit();

			} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);

			}

		}
		return(countSum);
	}

	public ArrayList<String> selectAllDateTimeList(String workTable){
		//全時刻をリストで取得
		ArrayList<String> dateTimeList = new ArrayList<String>();
		dateTimeList.clear();
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT concat(DATE, TIME) FROM " + workTable + " ";
			sql += "ORDER BY DATE, TIME ;";

			rs = stmt.executeQuery(sql);
			while(rs.next()){
				dateTimeList.add(rs.getString("concat(DATE, TIME)"));
			}
			rs.close();

			con.commit();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);

		}
		return(dateTimeList);
	}
}
