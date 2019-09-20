package reinforcement_learning.business;

import java.sql.*;
import java.util.*;
import java.util.Calendar;
import java.util.Date;
import java.math.BigDecimal;
import static reinforcement_learning.values.Constants.*;
import static reinforcement_learning.values.Variables.*;


public class SyncTradeInfoDao extends DaoAbstruct{

	public SyncTradeInfoDao(){
		super();
	}

	public void insertTradeInfo(String currency, String tradeDateTime, byte act){
		//MT4へトレード指令情報をinsertする。
		try{
			ResultSet rs;

			String sql;

			sql = "INSERT INTO " + syncTradeTable;
			sql += " (CURRENCY, DATE, TIME, TRADE_FLG, POSITION_FLG, PROFIT_FLG, LINK_FLG)";
			sql += " VALUES ('" + currency + "', '" + tradeDateTime.substring(0, 8) + "', '" + tradeDateTime.substring(8, 12) + "', " + act + ", 0, 0, 0);";

			stmt.executeUpdate(sql);

			con.commit();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);

		}
	}

	public byte selectPositionFlg(String currency, String tradeDateTime){
		//MT4がポジションを獲得したか確認する。
		//フラグの値をそのまま返す。

		byte ret = -1;
		try{
			ResultSet rs;

			String sql;

			con.commit(); // DBを最新状態にする。

			sql = "SELECT SQL_NO_CACHE POSITION_FLG, SEQ_NO";
			sql += " FROM " + syncTradeTable;
			sql += " WHERE CURRENCY = '" + currency + "' AND concat(DATE, TIME) = '" + tradeDateTime + "';";

			rs = stmt.executeQuery(sql);

			while(rs.next()){
				ret = rs.getByte("POSITION_FLG");
				System.out.println("POSITION_FLG : " + ret + ", SEQ_NO : " + rs.getLong("SEQ_NO"));
			}
		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
		return(ret);
	}

	public byte selectProfitFlg(String currency, String tradeDateTime){
		//MT4がPROFIT_FLGを更新したか確認する。
		byte ret = -1;
		try{
			ResultSet rs;

			String sql;

			con.commit(); // DBを最新状態にする。

			sql = "SELECT SQL_NO_CACHE PROFIT_FLG";
			sql += " FROM " + syncTradeTable;
			sql += " WHERE CURRENCY = '" + currency + "' AND concat(DATE, TIME) = '" + tradeDateTime + "';";

			rs = stmt.executeQuery(sql);

			while(rs.next()){
				ret = rs.getByte("PROFIT_FLG");
			}
		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
		return(ret);
	}
}
