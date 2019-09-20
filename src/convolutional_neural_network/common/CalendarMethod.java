package convolutional_neural_network.common;

import java.util.Calendar;
import java.util.GregorianCalendar;
import java.text.ParseException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;

public class CalendarMethod{

	//日付フォーマット
	//yyyymmddhhmi
	private static SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmm");

	private static Calendar parseStrToCal(String str){
		//Calendar cal = new GregorianCalendar();
		Calendar cal = Calendar.getInstance();
		if(str == null){
			System.out.println("parseStrToCal error. str is null.");
			System.exit(2);
		}
		else{
			try {
				//cal.setTime(DateFormat.getDateInstance().parse(str));
				//System.out.println(str);
				//cal.setTime(sdf.parse(str));
				cal.set(Calendar.YEAR, Integer.parseInt(str.substring(0, 4)));
				cal.set(Calendar.MONTH, Integer.parseInt(str.substring(4, 6)) - 1); //MONTHは0が1月なので -1
				cal.set(Calendar.DAY_OF_MONTH, Integer.parseInt(str.substring(6, 8)));
				cal.set(Calendar.HOUR_OF_DAY, Integer.parseInt(str.substring(8, 10)));
				cal.set(Calendar.MINUTE, Integer.parseInt(str.substring(10, 12)));
			} catch (Exception e) {
				e.printStackTrace();
				System.out.println("parseException .");
				System.exit(2);
			}
		}
		return(cal);
	}

	private static String parseCalToStr(Calendar cal){
		String  str = null;
		if(cal == null){
			System.out.println("cal is null .");
			System.exit(2);
		}
		else{
			str = sdf.format(cal.getTime());
		}
		return(str);
	}

	public static String subtractionMinute(String yyyyMMddhhmmString, int subtractMinute){

		//Calendar型に文字列日付を変換
		Calendar yyyyMMddhhmm = parseStrToCal(yyyyMMddhhmmString);

		//subtractMinute引く
		yyyyMMddhhmm.add(Calendar.MINUTE, (-1) * subtractMinute);

		//文字列に戻して返す
		return(parseCalToStr(yyyyMMddhhmm));

	}

}
