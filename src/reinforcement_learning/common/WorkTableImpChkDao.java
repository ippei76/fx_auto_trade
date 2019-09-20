package reinforcement_learning.common;

import java.sql.*;
import java.util.*;
import static reinforcement_learning.values.Constants.*;
import reinforcement_learning.business.DaoAbstruct;

public class WorkTableImpChkDao extends DaoAbstruct{

	public WorkTableImpChkDao() {
		super();
	}

	public void updateTargetFlgClear(){
		//本テーブルのフラグを0に戻す
		try{
			String sql;
			sql = "UPDATE " + mt4TableList.get(0) + " ";
			sql += "SET TRGT_FLG = 0 ;";

			stmt.executeUpdate(sql);
			con.commit();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);

		}
			
	}

	public void updateTargetFlgInitialSet(String startDateTime, String endDateTime){
		//対象レコードにフラグをセット
		// STEPをstartDateTimeを起点に連番をセット

		for(String mt4Table : mt4TableList){
			try{

				long baseTime = getBaseTimeMt4Table(mt4Table);
				long pastStep = Long.parseLong(startDateTime) - (baseTime * getHisStep());

				ResultSet rs;

				String sql;

				sql  = "UPDATE FX." + mt4Table + " ";
				sql += "SET TRGT_FLG = 1 ";
				sql += "WHERE " + pastStep + " <= concat(DATE, TIME) ";
				sql += "AND concat(DATE, TIME) <= " + endDateTime + ";";

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

		for(String table : workTableList){
			try{
				ResultSet rs;

				String sql;

				sql = "TRUNCATE TABLE FX." + table + " ";

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
		//本テーブルからワークテーブルに移す

		for(int i = 0; i < workTableList.size(); i++){
			try{
				ResultSet rs;

				String sql1;
				String sql2;
				String sql3;
				String sql4;
				
				sql1 = "SET @a := " + (-1) * (getHisStep() + 1) + ";";

				sql2 = "INSERT INTO " + workTableList.get(i) + " ";
				sql2 += "(SELECT @a := @a + 1, tbl.DATE, tbl.TIME, ";
				sql2 += "tbl.WDAY, tbl.OPN_RATE, tbl.HGHT_PRC, ";
				sql2 += "tbl.LW_PRC, tbl.CLS_RATE, tbl.DIFF_OPN, ";
				sql2 += "tbl.DIFF_HGHT, tbl.DIFF_LW, tbl.DIFF_CLS, ";
				sql2 += "tbl.EMAshrt, tbl.EMAlng, tbl.DIFF_EMA, ";
				sql2 += "tbl.EMAsgnl, tbl.SIGMA_MID, tbl.SIGMA_UP, ";
				sql2 += "tbl.SIGMA_DOWN, tbl.RSI, 0 ";
				sql2 += "FROM " + mt4TableList.get(i) + " tbl ";
				sql2 += "WHERE tbl.TRGT_FLG = 1 ";
				sql2 += "ORDER BY tbl.DATE, tbl.TIME );";

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
		for(String table : workTableList){
			try{
				ResultSet rs;

				String sql;

				sql = "DELETE FROM " + table + " ";
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
		for(String table : workTableList){
			try{
				ResultSet rs;

				String sql;

				sql = "SELECT DATE, TIME FROM " + table + " ";
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
