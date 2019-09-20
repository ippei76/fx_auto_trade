package convolutional_neural_network.business.dao;

import java.sql.*;
import java.util.*;
import java.util.Calendar;
import java.util.Date;
import java.math.BigDecimal;
import static convolutional_neural_network.values.Constants.*;
import reinforcement_learning.business.DaoAbstruct;
import convolutional_neural_network.business.dto.CnnMlpParasDto;
import convolutional_neural_network.business.dto.CnnMlpOutputNumsDto;
import convolutional_neural_network.business.dto.CnnMlpWDto;
import convolutional_neural_network.business.dto.CnnMlpBnParasDto;


public class CnnMlpParasDao extends DaoAbstruct{

	public CnnMlpParasDao(){
		super();
	}

	//基本パラメータを保存
	//学習結果をDBに登録する。
	public void insertCnnMlpParas(int plsCount, int eqlCount, int mnsCount, String settingCurrency, String rgstDateTime){
		try{
			ResultSet rs;

			String sql;

			sql = "INSERT INTO CNN_MLP_PARAS ";
			sql += "(CURRENCY, PLUS_COUNT, WAIT_COUNT, MINUS_COUNT, EPISODE_NUMS, STEP_NUMS, S_DATE, E_DATE, MINIBATCH_NUMS, SV_DATA_NUMS, SV_CHANNEL_NUMS, SV_X_NUMS, SV_Y_NUMS, W_X_NUMS, W_Y_NUMS, POOLING_X_NUMS, POOLING_Y_NUMS, CNN_OUTPUT_NUMS_NUMS, MLP_OUTPUT_NUMS_NUMS, RGST_DATE_TIME)";
			sql += "VALUES ('" + settingCurrency + "', " + plsCount + ", " + eqlCount + ", " + mnsCount;
			sql += ", " + getEpisodeNums() + ", " + getStepNums() + ", '" + getLearnStartDateTime() + "', '" + getLearnEndDateTime() + "', " + getMiniBatchNums();
			sql += ", " + getSvDataNums() + ", " + getSvChannelNums() + ", " + getSv_xNums() + ", " + getSv_yNums();
			sql += ", " + getCnnW_xNums() + ", " + getCnnW_yNums() + ", " + getCnnPooling_xNums() + ", " + getCnnPooling_yNums();
			sql += ", " + cnnOutputNums.length + ", " + mlpOutputNums.length;
			sql += ", '" + rgstDateTime + "');";

			stmt.executeUpdate(sql);
			con.commit();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
	}

	//オンライン結果を保存
	public void updateOnlineResult(int plsCount, int mnsCount, int eqlCount, int seqNo){
		try{
			ResultSet rs;

			String sql;

			sql = "UPDATE CNN_MLP_PARAS ";
			sql += "SET PLUS_COUNT = " + plsCount + ", WAIT_COUNT = " + eqlCount + ", MINUS_COUNT = " + mnsCount + " ";
			sql += "WHERE SEQ_NO = " + seqNo + ";";

			stmt.executeUpdate(sql);
			con.commit();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
	}

	//引数のシーケンスNoをCnng_PARASから取得する。
	public int selectCnnMlpParasSeqNo(String rgstDateTime){
		int retSeqNo = -1;
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT SEQ_NO ";
			sql += "FROM CNN_MLP_PARAS ";
			sql += "WHERE RGST_DATE_TIME = " + rgstDateTime + ";";

			rs = stmt.executeQuery(sql);
			while(rs.next()){
				retSeqNo = rs.getInt("SEQ_NO");
			}
			rs.close();

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
		return(retSeqNo);
	}

	//OutputNumsパラメータを保存
	private String makeSqlInsertCnnMlpOutputNums(int seqNo, int type, int layer, int outputNums){

		String sql = null;

		sql = "INSERT INTO CNN_MLP_OUTPUT_NUMS ";
		sql += "(SEQ_NO, TYPE, LAYER, NUMS)";
		sql += "VALUES (" + seqNo + ", " + type + ", " + layer + ", " + outputNums + ");";
		return(sql);
	}
	public void insertCnnMlpOutputNums(String rgstDateTime){
		//Cnn,MlpOutputNumsをDBに追加する
		try{
			ResultSet rs;

			int seqNo = selectCnnMlpParasSeqNo(rgstDateTime);
			//cnnOutputNumsの追加
			for(int layer = 0; layer < cnnOutputNums.length; layer++){
				String sql = null;
				//SQL作成
				sql = makeSqlInsertCnnMlpOutputNums(seqNo, getTypeIsCnn(), layer, cnnOutputNums[layer]);

				stmt.executeUpdate(sql);
				con.commit();
			}

			//mlpOutputNumsの追加
			for(int layer = 0; layer < mlpOutputNums.length; layer++){
				String sql = null;
				//SQL作成
				sql = makeSqlInsertCnnMlpOutputNums(seqNo, getTypeIsMlp(), layer, mlpOutputNums[layer]);

				stmt.executeUpdate(sql);
				con.commit();
			}

		}catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
	}

	//Load Data のSQL文を作成
	private String makeLoadDataSql(String fileName, String tableName){
		String sql = null;

		sql = "LOAD DATA LOCAL INFILE '" + fileName + "' INTO TABLE " + tableName + " ";
		sql += "FIELDS TERMINATED BY ',' LINES TERMINATED BY '\\n';";
		return(sql);
	}
	//Cnn,MlpWをDBに保存
	public void loadDataCnnMlpW(){
		try{
			ResultSet rs;

			String sql = null;
			
			//SQL作成
			String tableName = "CNN_MLP_W";
			sql = makeLoadDataSql(getLoadDataFile(), tableName);

			stmt.executeUpdate(sql);
			con.commit();

		}catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
	}
	//Bn系パラメータをDBに保存
	public void loadDataCnnMlpBnParas(){
		try{
			ResultSet rs;

			String sql = null;
			
			//SQL作成
			String tableName = "CNN_MLP_BN_PARAS";
			sql = makeLoadDataSql(getLoadDataFile(), tableName);

			stmt.executeUpdate(sql);
			con.commit();

		}catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
	}

	//以下保存したパラメータを取得するDAO
	//基本パラメータを取得する
	public ArrayList<CnnMlpParasDto> selectCnnMlpParas(int seqNo){
		ArrayList<CnnMlpParasDto> cnnMlpParaList = new ArrayList<CnnMlpParasDto>();
		cnnMlpParaList.clear();
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT CURRENCY, EPISODE_NUMS, STEP_NUMS, MINIBATCH_NUMS, ";
			sql += "SV_DATA_NUMS, SV_X_NUMS, SV_Y_NUMS, W_X_NUMS, W_Y_NUMS, ";
			sql += "POOLING_X_NUMS, POOLING_Y_NUMS, CNN_OUTPUT_NUMS_NUMS, MLP_OUTPUT_NUMS_NUMS ";
		       	sql += "FROM CNN_MLP_PARAS ";
			sql += "WHERE SEQ_NO = " + seqNo + ";";

			rs = stmt.executeQuery(sql);

			CnnMlpParasDto cnnMlpPara = new CnnMlpParasDto();
			while(rs.next()){
				cnnMlpPara.setCurrency(rs.getString("CURRENCY"));
				cnnMlpPara.setEpisodeNums(rs.getInt("EPISODE_NUMS"));
				cnnMlpPara.setStepNums(rs.getInt("STEP_NUMS"));
				cnnMlpPara.setMiniBatchNums(rs.getInt("MINIBATCH_NUMS"));
				cnnMlpPara.setSvDataNums(rs.getInt("SV_DATA_NUMS"));
				cnnMlpPara.setSv_xNums(rs.getInt("SV_X_NUMS"));
				cnnMlpPara.setSv_yNums(rs.getInt("SV_Y_NUMS"));
				cnnMlpPara.setCnnW_xNums(rs.getInt("W_X_NUMS"));
				cnnMlpPara.setCnnW_yNums(rs.getInt("W_Y_NUMS"));
				cnnMlpPara.setCnnPooling_xNums(rs.getInt("POOLING_X_NUMS"));
				cnnMlpPara.setCnnPooling_yNums(rs.getInt("POOLING_Y_NUMS"));
				cnnMlpPara.setCnnOutputNumsNums(rs.getInt("CNN_OUTPUT_NUMS_NUMS"));
				cnnMlpPara.setMlpOutputNumsNums(rs.getInt("MLP_OUTPUT_NUMS_NUMS"));
				if(rs.wasNull()){
					System.out.println("cnnMlpPara is null.");
					System.exit(2);
				}
				cnnMlpParaList.add(cnnMlpPara);
			}
			rs.close();
		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
		return(cnnMlpParaList);
	}

	//OutputNumsパラメータを取得する
	public ArrayList<CnnMlpOutputNumsDto> selectCnnMlpOutputNums(int seqNo){
		ArrayList<CnnMlpOutputNumsDto> cnnMlpOutputNumsList = new ArrayList<CnnMlpOutputNumsDto>();
		cnnMlpOutputNumsList.clear();
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT TYPE, LAYER, NUMS ";
		       	sql += "FROM CNN_MLP_OUTPUT_NUMS ";
			sql += "WHERE SEQ_NO = " + seqNo + ";";

			rs = stmt.executeQuery(sql);

			while(rs.next()){
				CnnMlpOutputNumsDto cnnMlpOutputNums = new CnnMlpOutputNumsDto();
				cnnMlpOutputNums.setType(rs.getInt("TYPE"));
				cnnMlpOutputNums.setLayer(rs.getInt("LAYER"));
				cnnMlpOutputNums.setNums(rs.getInt("NUMS"));
				if(rs.wasNull()){
					System.out.println("cnnMlpOutputNums is null.");
					System.exit(2);
				}
				cnnMlpOutputNumsList.add(cnnMlpOutputNums);
			}
			rs.close();
		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
		//System.exit(2);
		return(cnnMlpOutputNumsList);
	}

	//CNN_MLP_Wパラメータを取得する
	public ArrayList<CnnMlpWDto> selectCnnMlpW(int seqNo){
		ArrayList<CnnMlpWDto> cnnMlpWList = new ArrayList<CnnMlpWDto>();
		cnnMlpWList.clear();
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT TYPE, IDX, VALUE ";
		       	sql += "FROM CNN_MLP_W ";
			sql += "WHERE SEQ_NO = " + seqNo + ";";

			rs = stmt.executeQuery(sql);

			while(rs.next()){
				CnnMlpWDto cnnMlpW = new CnnMlpWDto();
				cnnMlpW.setType(rs.getInt("TYPE"));
				cnnMlpW.setIdx(rs.getInt("IDX"));
				cnnMlpW.setValue(rs.getFloat("VALUE"));
				//System.out.println(cnnMlpW.getType() + " " + cnnMlpW.getIdx() + " " + cnnMlpW.getValue());
				if(rs.wasNull()){
					System.out.println("cnnMlpW is null.");
					System.exit(2);
				}
				cnnMlpWList.add(cnnMlpW);
			}
			rs.close();
		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
		return(cnnMlpWList);
	}

	//CNN_MLP_BNパラメータを取得する
	public ArrayList<CnnMlpBnParasDto> selectCnnMlpBnParas(int seqNo){
		ArrayList<CnnMlpBnParasDto> cnnMlpBnParasList = new ArrayList<CnnMlpBnParasDto>();
		cnnMlpBnParasList.clear();
		try{
			ResultSet rs;

			String sql;

			sql = "SELECT TYPE, BN_TYPE, IDX, VALUE ";
		       	sql += "FROM CNN_MLP_BN_PARAS ";
			sql += "WHERE SEQ_NO = " + seqNo + ";";

			rs = stmt.executeQuery(sql);

			while(rs.next()){
				CnnMlpBnParasDto cnnMlpBnParas = new CnnMlpBnParasDto();
				cnnMlpBnParas.setType(rs.getInt("TYPE"));
				cnnMlpBnParas.setBnType(rs.getInt("BN_TYPE"));
				cnnMlpBnParas.setIdx(rs.getInt("IDX"));
				cnnMlpBnParas.setValue(rs.getFloat("VALUE"));
				//System.out.println(cnnMlpBnParas.getType() + " " + cnnMlpBnParas.getBnType() + " " + cnnMlpBnParas.getIdx() + " " + cnnMlpBnParas.getValue());
				if(rs.wasNull()){
					System.out.println("cnnMlpBnParas is null.");
					System.exit(2);
				}
				cnnMlpBnParasList.add(cnnMlpBnParas);
			}
			rs.close();
		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);
		}
		return(cnnMlpBnParasList);
	}

}
