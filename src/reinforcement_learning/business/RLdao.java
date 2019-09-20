package reinforcement_learning.business;

import java.sql.*;
import java.util.*;
import java.util.Calendar;
import java.util.Date;
import java.math.BigDecimal;
import static reinforcement_learning.values.Constants.*;
import static reinforcement_learning.values.Variables.*;


public class RLdao extends DaoAbstruct{

	public RLdao() {
		super();
	}

	private long getNowTime(int step, String table){
		//stepから最小足テーブルの日時を取得する。
		long nowTime = 0;
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT concat(DATE, TIME) ";
			sql += "FROM " + table + " ";
			sql += "WHERE STEP = " + step + ";";

			rs = stmt.executeQuery(sql);
			while(rs.next()){
				nowTime = rs.getLong("concat(DATE, TIME)");
			}
			rs.close();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);

		}
		return(nowTime);
	}

	private int getTableNowStep(long nowTime, String table){
		//取得した現時刻から、対応するSTEPを取得する。
		
		int nowStep = 0;
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT MAX(STEP) FROM " + table + " WHERE concat(DATE, TIME) <= " + nowTime + " ";

			rs = stmt.executeQuery(sql);
			while(rs.next()){
				nowStep = rs.getInt("MAX(STEP)");
			}
			rs.close();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);

		}
		return(nowStep);
	}

	public void updateAct(int step, byte act){

		// テーブル照会実行
		try{
			String sql;

			sql = "UPDATE " + workTableList.get(0) + " ";
			sql += "SET ACT =  " + act + " ";
			sql += "WHERE STEP = " + step + ";";

			stmt.executeUpdate(sql);
			con.commit();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);

		}
	}

	public ArrayList<BigDecimal> selectStateStep(int step, int hisStep){
		//時刻をキーに対象テーブルから状態を抜く 
		
		ArrayList<BigDecimal> stateList = new ArrayList<BigDecimal>();

		ArrayList<String> stateCombinationList = new ArrayList<String>(Arrays.asList(stateCombination));

		long nowTime = getNowTime(step, workTableList.get(0));
		//System.out.println("nowTime : " + nowTime +"  getstep : " + getStep() + "  step :" + step);
		// テーブル照会実行
		for(String table : workTableList){
			int tableNowStep = getTableNowStep(nowTime, table);
			try{
				ResultSet rs;

				String sql;

				sql = "SELECT " + getStateCombinationString() + " ";
				sql += "FROM " + table + " ";
				sql += "WHERE ";
				sql += (tableNowStep - hisStep) + "< STEP AND STEP <= " + tableNowStep + ";";

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

	public BigDecimal selectNowStockValue(int step){

		BigDecimal output = new BigDecimal("0");
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT OPN_RATE ";
			sql += "FROM " + workTableList.get(0) + " ";
			sql += "WHERE STEP = " + step + ";";

			rs = stmt.executeQuery(sql);
			while(rs.next()){
				output = rs.getBigDecimal("OPN_RATE");
			}
			rs.close();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);

		}
		return(output);
	}

	public BigDecimal selectMaxStockValue(){
		BigDecimal output = new BigDecimal("0");
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT MAX(HGHT_PRC) ";
			sql += "FROM " + workTableList.get(0) + " ";

			rs = stmt.executeQuery(sql);
			while(rs.next()){
				output = rs.getBigDecimal("MAX(HGHT_PRC)");
			}
			rs.close();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);

		}
		return(output);
	}

	public BigDecimal selectMinStockValue(){
		BigDecimal output = new BigDecimal("0");
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT MIN(LW_PRC) ";
			sql += "FROM " + workTableList.get(0) + " ";

			rs = stmt.executeQuery(sql);
			while(rs.next()){
				output = rs.getBigDecimal("MIN(LW_PRC)");
			}
			rs.close();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);

		}
		return(output);
	}

	public int selectEndStep(){
		//endStep獲得のために、ワークテーブルの最大STEPを取得する。
		
		int maxStep = -1;
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT MAX(STEP) ";
			sql += "FROM " + workTableList.get(0) + ";";

			rs = stmt.executeQuery(sql);

			while(rs.next()){
				maxStep = rs.getInt("MAX(STEP)");
				if(rs.wasNull()){
					System.err.println("MAX(STEP) error.");
					System.exit(2);
				}
			}
			rs.close();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);

		}
		return(maxStep - getOcoLimitStep());
	}

	public int selectTopOcoCheck(int step, BigDecimal upPrc){
		//OCOを用いて指値が先に出現した場合は正の報酬を、指値が先に出現した場合は負の報酬を与える。
		int ocoTopStep = -1;
		BigDecimal nowPrc = selectNowStockValue(step);
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT MIN(STEP) ";
			sql += "FROM " + workTableList.get(0) + " ";
			sql += "WHERE " + step + "< STEP AND STEP <= " + (step + getOcoLimitStep()) + " ";
			sql += "AND HGHT_PRC >= " + nowPrc.add(upPrc) + ";";

			rs = stmt.executeQuery(sql);

			while(rs.next()){
				ocoTopStep = rs.getInt("MIN(STEP)");
//				System.out.println("ocoTop :  " + ocoTopStep);
				if(rs.wasNull()){
		//			System.out.println(sql);
					ocoTopStep = step + getOcoLimitStep() + 1;
				}
			}
			rs.close();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);

		}
		if(ocoTopStep < 0){
			System.out.println("ocoTopStep value error");
		}
//		System.out.println("topselect:"+step+workTableList.get(0)+"\t"+ocoTopStep+"\t"+nowPrc+"\t"+nowPrc.add(upPrc));
		return(ocoTopStep);
	}

	public int selectBottomOcoCheck(int step, BigDecimal downPrc){
		//OCOを用いて指値が先に出現した場合は正の報酬を、指値が先に出現した場合は負の報酬を与える。
		int ocoBottomStep = -1;
		BigDecimal nowPrc = selectNowStockValue(step);
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT MIN(STEP) ";
			sql += "FROM " + workTableList.get(0) + " ";
			sql += "WHERE " + step + "< STEP AND STEP <= " + (step + getOcoLimitStep()) + " ";
			sql += "AND LW_PRC <= " + nowPrc.subtract(downPrc) + ";";

			rs = stmt.executeQuery(sql);

			while(rs.next()){
				ocoBottomStep = rs.getInt("MIN(STEP)");
//				System.out.println("ocoBottom :  " + ocoBottomStep);
				if(rs.wasNull()){
					ocoBottomStep = step + getOcoLimitStep() + 1;
//					System.out.println(sql);
				}
			}
			rs.close();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
		if(ocoBottomStep < 0){
			System.out.println("ocoBottomStep value error");
		}
//		System.out.println("bottomselect:"+step+workTableList.get(0)+"\t"+ocoBottomStep+"\t"+nowPrc+"\t"+nowPrc.subtract(downPrc));
		return(ocoBottomStep);
	}

	private long selectRLparasSeqNo(String rgstDateTime){
		//引数のシーケンスNoをRL_PARASから取得する。
		long retSeqNo = -1;
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT RL_SEQ_NO ";
			sql += "FROM RL_PARAS ";
			sql += "WHERE RGST_DATE_TIME = " + rgstDateTime + ";";

			rs = stmt.executeQuery(sql);
			while(rs.next()){
				retSeqNo = rs.getLong("RL_SEQ_NO");
			}
			rs.close();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
		return(retSeqNo);
	}

	public void insertRLparas(String currency, int plsCount, int eqlCount, int mnsCount, long episodes, String startDate, String endDate, String rgstDateTime, int hisStep){
		//学習結果をDBに登録する。
		try{
			ResultSet rs;

			String sql;

			sql = "INSERT INTO RL_PARAS ";
			sql += "(CURRENCY, PLS_COUNT, WAIT_COUNT, MINUS_COUNT, EPISODES, SDATE, EDATE, STATES, BAR_TABLE, HIS_STEP, RGST_DATE_TIME)";
			sql += "VALUES ('" + currency + "', " + plsCount + ", " + eqlCount + ", " + mnsCount;
			sql += ", " + episodes + ", " + startDate + ", " + endDate + ", '" + getStateCombinationString() + "', ";
			sql += "'" + getMt4TableListString() + "', '" + hisStep + "', '" + rgstDateTime + "');";

			stmt.executeUpdate(sql);
			con.commit();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
	}

	public void insertUnits(String rgstDateTime){
		//学習が完了したUnitsをDBに追加する
		try{
			ResultSet rs;

			String sql = null;
			long seqNo = selectRLparasSeqNo(rgstDateTime);
			for(byte act = 0; act < actType.length ; act++){
				sql = "INSERT INTO RL_UNITS ";
				sql += "(RL_SEQ_NO, ACT, UNITS)";
				sql += "VALUES (" + seqNo + ", " + act + ", " + getUnits(act) + ");";

				stmt.executeUpdate(sql);
			}
			con.commit();

		}catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
	}

	public void insertMu(String rgstDateTime){
		//学習が完了したMUをDBに追加する
		try{
			ResultSet rs;

			String sql = null;
			long seqNo = selectRLparasSeqNo(rgstDateTime);
			for(byte act = 0; act < actType.length ; act++){
				for(int k = 0; k < getUnits(act); k++){
					for(int i = 0; i < getStates(); i++){
						sql = "INSERT INTO RL_MU ";
						sql += "(RL_SEQ_NO, ACT, UNIT, STATE, MU_VALUE)";
						sql += "VALUES (" + seqNo + ", " + act + ", " + k + ", " + i + ", " + mu[act][k][i] + ");";

						stmt.executeUpdate(sql);
					}
				}
			}
			con.commit();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
	}

	public void insertSigma(String rgstDateTime){
		//学習が完了したSIGMAをDBに追加する
		try{
			ResultSet rs;

			String sql = null;
			long seqNo = selectRLparasSeqNo(rgstDateTime);
			for(byte act = 0; act < actType.length ; act++){
				for(int k = 0; k < getUnits(act); k++){
					sql = "INSERT INTO RL_SIGMA ";
					sql += "(RL_SEQ_NO, ACT, UNIT,  SIGMA_VALUE)";
					sql += "VALUES (" + seqNo + ", " + act + ", " + k + ", " +  sigma[act][k] + ");";
					
					stmt.executeUpdate(sql);
				}
			}
			con.commit();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
	}

	public void insertW(String rgstDateTime){
		//学習が完了したWをDBに追加する
		try{
			ResultSet rs;

			String sql = null;
			long seqNo = selectRLparasSeqNo(rgstDateTime);
			for(byte act = 0; act < actType.length ; act++){
				for(int k = 0; k < getUnits(act); k++){
					sql = "INSERT INTO RL_W ";
					sql += "(RL_SEQ_NO, ACT, UNIT,  W_VALUE)";
					sql += "VALUES (" + seqNo + ", " + act + ", " + k + ", " +  w[act][k] + ");";

					stmt.executeUpdate(sql);
				}
			}
			con.commit();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
	}

	public void insertXCth(String rgstDateTime){
		//学習が完了したXCthをDBに追加する
		try{
			ResultSet rs;

			String sql = null;
			long seqNo = selectRLparasSeqNo(rgstDateTime);
			for(byte act = 0; act < actType.length ; act++){
				sql = "INSERT INTO RL_XC ";
				sql += "(RL_SEQ_NO, ACT, XC_VALUE)";
				sql += "VALUES (" + seqNo + ", " + act + ", " +  XCth[act] + ");";

				stmt.executeUpdate(sql);
			}
			con.commit();

		}catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
	}
}
