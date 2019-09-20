package convolutional_neural_network.business;

import java.util.*;
import java.io.IOException;
import java.math.MathContext;
import static convolutional_neural_network.values.Constants.*;
import static convolutional_neural_network.values.Mt4Define.*;
import convolutional_neural_network.business.dao.ExchangeDataDao;
import convolutional_neural_network.business.WorkTableImpChkService;


public class ExchangeDataService{

	private ExchangeDataDao exchangeDataDao = new ExchangeDataDao();
	private WorkTableImpChkService workTableImpChkService = new WorkTableImpChkService();

	public ExchangeDataService(){
	}

	private int getInputColumnAllIdx(int svColumnIdx, int svDataIdx){
		int idx = svColumnIdx + svDataIdx;
		return(idx);
	}

	private void setSvAll(int svDataIdx, String workTableName, ArrayList<ArrayList<Integer>> exchangeDataListList){
		//sv_yIdxはMT4テーブルリストから対象のテーブル名が何番目かと同値である。
		String mt4InputTableName = getInputTableName(workTableName);
		int svRowIdx = mt4InputTableNameList.indexOf(mt4InputTableName);
		//全体値算出
		int svChannelNums = getSvChannelNums();
		int svColumnNums = getSv_xNums();
		int svRowNums = getSv_yNums();

		//1つのsvの横を精査
		for(int svColumnIdx = 0; svColumnIdx < svColumnNums; svColumnIdx++){
			//exchangeDataList全体で見たときの横のインデックス
			int exchangeDataListColumnAllIdx = getInputColumnAllIdx(svColumnIdx, svDataIdx);
			//System.out.println("allIdx = " + exchangeDataListColumnAllIdx);
			//System.out.println("listSize = " + exchangeDataListList.size());
			ArrayList<Integer> exchangeDataList = exchangeDataListList.get(exchangeDataListColumnAllIdx);
			//1つのsvのチャネルを精査
			for(int svChannelIdx = 0; svChannelIdx < svChannelNums; svChannelIdx++){
				int svAllIdx = svColumnIdx + svRowIdx * svColumnNums + svChannelIdx * svColumnNums * svRowNums + svDataIdx * svColumnNums * svRowNums * svChannelNums;
				svAll[svAllIdx] = exchangeDataList.get(svChannelIdx);
				//System.out.print(" " + svAll[svAllIdx]);
			}
		}
	}

	private void setTeachOutAll(int svDataIdx, ArrayList<ArrayList<Integer>> exchangeDataListList){
		//予測したい為替のPROFIT_ACTを取得するにあたり、最後の列(現在の列）を取得する。
		int latestColumnIdx = getInputColumnAllIdx(getSvColumnNums() - 1, svDataIdx);
		//exchangeDataListの中でPROFIT_ACTのindexを取得する。
		int profitActIdx = itemNameList.size();

		int teachOutNum = exchangeDataListList.get(latestColumnIdx).get(profitActIdx);
		int teachOutOneDataNums = mlpOutputNums[mlpOutputNums.length - 1];
		for(int i = 0; i < teachOutOneDataNums; i++){
			if(i == teachOutNum){
				teachOutAll[i + svDataIdx * teachOutOneDataNums] = 1.0f;
			}
			else{
				teachOutAll[i + svDataIdx * teachOutOneDataNums] = 0.0f;
			}
		}
	}

	private void setAllSvTeachOutExchangeData(String workTableName){

		ArrayList<ArrayList<Integer>> exchangeDataListList = new ArrayList<ArrayList<Integer>>();
		exchangeDataListList.clear();
		//svAll,teachOutAllをDBから取得
		//対象の為替ペアにおける為替データを取得
		exchangeDataListList = exchangeDataDao.selectExchangeData(workTableName);

		if(exchangeDataListList.isEmpty()){
			System.out.println("exchangeDataListList is empty.");
			System.exit(2);
		}
		if(exchangeDataListList.size() != getSvDataNums() + getSvColumnNums() - 1){
			System.out.println("exchangeDataListList size is unmatch.");
			System.out.println("dataList size(" + exchangeDataListList.size() + ") != svDataNums(" + getSvDataNums() + ") + svColumnNums(" + getSvColumnNums() + ") + 1");
		}

		for(int svDataIdx = 0; svDataIdx < getSvDataNums(); svDataIdx++){

			//svAllの設定
			setSvAll(svDataIdx, workTableName, exchangeDataListList);

			//teachOutの対象テーブルであるかを判定する。
			if(workTableName.indexOf(getCurrency()) != -1){
				//teachOutAllの設定
				setTeachOutAll(svDataIdx, exchangeDataListList);
			}
			else{
				//System.out.println(workTableName + " is not " + getCurrency());
			}
		}
	}

	private void makeTrainingTable(String startDateTime, String endDateTime){
		workTableImpChkService.importCheckProcess(startDateTime, endDateTime);
	}

	private void getAllSvTeachOutExchangeDataCommon(String startDateTime, String endDateTime){
		//取引対象通貨が対象テーブルに含まれているか確認
		if(String.join(",", mt4InputTableNameList).indexOf(getCurrency()) == -1){
			System.out.println("There is no " + getCurrency() + " in " + String.join(",", mt4InputTableNameList));
			System.exit(2);
		}
		//TrainingTable make
		makeTrainingTable(startDateTime, endDateTime);
		//各為替ペア毎にsvAll,teachOutAllを取得する
		for(String mt4InputTableName : mt4InputTableNameList){
			String workTableName = getWorkTableName(mt4InputTableName);

			//select対象のセット数とsvDataNumsが一致していなければいけない
			long count = exchangeDataDao.selectCount(workTableName);
			if(count != getSvDataNums() + (getSvColumnNums() - 1)){
				System.out.println("dataNums is unmatch.");
				System.out.println("count(" + count + ") != svDataNums(" + getSvDataNums() + ") - 1");
				System.exit(2);
			}

			//トレーニング用にsvAll,teachOutAllをセットする。
			setAllSvTeachOutExchangeData(workTableName);
		}
	}

	public void getAllSvTeachOutExchangeDataTraining(){
		getAllSvTeachOutExchangeDataCommon(getLearnStartDateTime(), getLearnEndDateTime());
	}
	public void getAllSvTeachOutExchangeDataTestMode(){
		getAllSvTeachOutExchangeDataCommon(getTestModeStartDateTime(), getTestModeEndDateTime());
	}

}
