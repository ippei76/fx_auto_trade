package reinforcement_learning.common;

import reinforcement_learning.common.WorkTableImpChkDao;
import java.util.Date;
import java.util.ArrayList;
import java.util.Calendar;
import java.lang.Long;
import java.text.SimpleDateFormat;
import java.text.ParseException;
import static reinforcement_learning.values.Constants.*;

public class WorkTableImpChkService{
	
	WorkTableImpChkDao workTableImpChkDao = new WorkTableImpChkDao();

	//日付フォーマット
	//yyyymmddhhmi
	SimpleDateFormat sdf_yyyyMMddhhmm = new SimpleDateFormat("yyyyMMddHHmm");

	private void updateTargetFlgClear(){

		workTableImpChkDao.updateTargetFlgClear();

	}

	private void updateTargetFlgSet(String startDateTime, String endDateTime){

		workTableImpChkDao.updateTargetFlgInitialSet(startDateTime, endDateTime);

	}

	private void truncateWorkTable(){

		workTableImpChkDao.truncateWorkTable();

	}

	private void insertMainToWorkTable(){

		workTableImpChkDao.insertMainToWorkTable();

	}

	private void importProcess(String startDateTime, String endDateTime){
		//為替テーブルの対象フラグを0にリセット
		updateTargetFlgClear();
		//為替テーブルの対象レコードの対象フラグを1にセット
		updateTargetFlgSet(startDateTime, endDateTime);
		//ワークテーブルをトランケート
		truncateWorkTable();
		//為替テーブルから対象レコードをワークテーブルへ取り込む
		insertMainToWorkTable();
	}

	private void deleteZeroValueRecord(){

		workTableImpChkDao.deleteZeroValueRecord();

	}

	private void checkIsNotExistOverlapDateTime(){

		//重複した時刻を格納するリスト
		ArrayList<String> overlapDateTimeList = new ArrayList<String>();
		overlapDateTimeList.clear();
		overlapDateTimeList = workTableImpChkDao.selectOverlapDateTimeList();
		if(overlapDateTimeList.size() != 0){
			System.out.println("overlap error.");
			for(int i = 0; i < overlapDateTimeList.size(); i++){
				System.out.println(overlapDateTimeList.get(i));
			}
			System.exit(2);
		}
		System.out.println("overlap check is OK.");
	}

	private long diffTimeMinute(String t1, String t2){
		//二つの時刻の差（t1 - t2)を「分」で返す
		//tのフォーマット : yyyyMMddhhmm

		Date date1 = null;
		Date date2 = null;

		//日付作成
		try{
			date1 = sdf_yyyyMMddhhmm.parse(t1);
			date2 = sdf_yyyyMMddhhmm.parse(t2);
		}catch(ParseException e){
			System.out.println("Date Parse error.");
			e.printStackTrace();
			System.exit(2);
		}

		//日付をlong値に変換
		long dateLong1 = date1.getTime();
		long dateLong2 = date2.getTime();

		//差分の日時を算出
		long dateDiffLong = (dateLong1 - dateLong2) / (1000 * 60);

		return(dateDiffLong);
	}
		
	private void isExistAllData(String startDateTime, String endDateTime){

		ArrayList<String> dateTimeList = new ArrayList<String>();

		for(String workTable : workTableList){
			dateTimeList.clear();
			dateTimeList = workTableImpChkDao.selectAllDateTimeList(workTable);
			if(dateTimeList.size() == 0){
				System.out.println("target DateTime is null.");
				System.exit(2);
			}
			long baseTime = getBaseTimeMt4WorkTable(workTable);
			//最初の時刻が足りてることをチェック。
			if(diffTimeMinute(dateTimeList.get(0), startDateTime) > baseTime){
				//(最初の時刻-startDateTime > baseTime)であれば
				System.out.println("first list time error.");
				System.out.println("startDateTime : " + startDateTime);
				System.out.println("dateTimeList.get(0) : " + dateTimeList.get(0));
				System.out.println("baseTime : " + baseTime);
				System.out.println("getHisStep() : " + getHisStep());
				System.exit(2);
			}
			//baseTime毎に取得されていることをチェック
			for(int i = 0; i < dateTimeList.size() - 1; i++){
				//チェックし、正しくなければエラーを出力
				if(diffTimeMinute(dateTimeList.get(i + 1), dateTimeList.get(i)) > baseTime){
					//(最初の時刻-startDateTime > baseTime)であれば
					System.out.println("count up time error.");
					System.out.println("dateTime(i + 1) : " + dateTimeList.get(i + 1));
					System.out.println("dateTime(i) : " + dateTimeList.get(i));
					System.out.println("baseTime : " + baseTime);
					System.exit(2);
				}
			}
			//最後の時刻が足りていることをチェック
			if(diffTimeMinute(endDateTime, dateTimeList.get(dateTimeList.size() - 1)) > baseTime){
				//(最初の時刻-startDateTime > baseTime)であれば
				System.out.println("last list time error.");
				System.out.println("endDateTime : " + endDateTime);
				System.out.println("dateTimeList.get(last) : " + dateTimeList.get(dateTimeList.size() - 1));
				System.out.println("baseTime : " + baseTime);
				System.out.println("getHisStep() : " + getHisStep());
				System.exit(2);
			}
		}
	}

	private void checkProcess(String startDateTime, String endDateTime){
		//価格を取得できていないレコードを削除
		deleteZeroValueRecord();
		//重複レコードが存在しないことを確認
		checkIsNotExistOverlapDateTime();
		//対象期間の全データが存在していることを確認
		isExistAllData(startDateTime, endDateTime);
	}

	public void importCheckProcess(String startDateTime, String endDateTime){

		//import処理
		importProcess(startDateTime, endDateTime);

		//check処理
		checkProcess(startDateTime, endDateTime);

	}
}
