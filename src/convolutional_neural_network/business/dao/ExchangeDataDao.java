package convolutional_neural_network.business.dao;

import java.sql.*;
import java.util.*;
import java.util.Calendar;
import java.util.Date;
import java.math.BigDecimal;
import static convolutional_neural_network.values.Constants.*;
import static convolutional_neural_network.values.Mt4Define.*;
import reinforcement_learning.business.DaoAbstruct;


public class ExchangeDataDao extends DaoAbstruct{

	public ExchangeDataDao(){
		super();
	}

	public long selectCount(String workTableName){
		//workTableの件数を取得する。

		long seqNo = 0;
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT COUNT(*) FROM " + workTableName  + ";";

			rs = stmt.executeQuery(sql);
			while(rs.next()){
				seqNo = rs.getLong("COUNT(*)");
			}
			rs.close();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);

		}
		return(seqNo);
	}

	//為替データを取得する
	public ArrayList<ArrayList<Integer>> selectExchangeData(String workTableName){

		//Dtoはselect,set,getがifで複雑になるので使用しない。
		ArrayList<ArrayList<Integer>> exchangeDataListList = new ArrayList<ArrayList<Integer>>();
		exchangeDataListList.clear();
		try{
			ResultSet rs;

			String sql;
			String selectTarget = String.join(",", itemNameList);

			sql = "SELECT " + selectTarget + ", PROFIT_ACT ";

			sql += "FROM " + workTableName + " ";

			sql += "ORDER BY STEP ;";

			//System.out.println(sql);
			rs = stmt.executeQuery(sql);

			while(rs.next()){
				ArrayList<Integer> exchangeDataList = new ArrayList<Integer>();
				for(String itemName : itemNameList){
					exchangeDataList.add(rs.getInt(itemName));
				}
				exchangeDataList.add(rs.getInt("PROFIT_ACT"));
				if(rs.wasNull()){
					System.out.println("exchangeData is null.");
					System.exit(2);
				}
				exchangeDataListList.add(exchangeDataList);
			}
			rs.close();
		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
		return(exchangeDataListList);
	}
}
