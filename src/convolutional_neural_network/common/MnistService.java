package convolutional_neural_network.common;

import java.util.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.math.MathContext;
import static convolutional_neural_network.values.Constants.*;


public class MnistService{

	public static void getAllSvTeachMnist(String mnistInputFileName, String mnistOutputFileName){
		//svAllの初期値を設定
		try {
			BufferedReader br = new BufferedReader(new FileReader(mnistInputFileName));
			String lineString;
			int count = 0;
			// ファイルを行単位で読む
			while((lineString = br.readLine()) != null) {
				//System.out.println(lineString);
				// カンマで分割したString配列を得る
				String[] svTmp= lineString.split(" ");
				//データ数をチェックしたあと代入、プリントする
				if(svTmp.length != 28 * 28){
					System.out.println("mnist size error. ");
					System.out.println("svTmp.length:" + svTmp.length);
				}
				//sv配列にコピー
				//コピーの際に、Stringからfloatに変換する。
				for(int i = 0; i < svTmp.length; i++){
					svAll[i + count * svTmp.length] = Float.parseFloat(svTmp[i]);
				}
				count++;
			}
			br.close();
		} catch(IOException e){
			System.out.println("入出力エラーがありました");
		} catch(NumberFormatException e){
			System.out.println("フォーマットエラーがありました");
		}
		/*
		   for(int i = 0; i < 28 * 28; i++){
		   System.out.println("svAll[60][" + (i) + "]=" + svAll[60][i]);
		   }
		   */

		//teachOutAllの初期値を設定
		try {
			BufferedReader br = new BufferedReader(new FileReader(mnistOutputFileName));
			String lineString;
			int teachOutOneDataNums = mlpOutputNums[mlpOutputNums.length - 1];
			int count = 0;
			// ファイルを行単位で読む
			while((lineString = br.readLine()) != null) {
				//System.out.println(lineString);
				// カンマで分割したString配列を得る
				String[] teachOutTmp= lineString.split(" ");
				//データ数をチェックしたあと代入、プリントする
				if(teachOutTmp.length != 1){
					System.out.println("mnist size error. ");
					System.out.println("teachOutTmp.length:" + teachOutTmp.length);
				}
				//teach配列にコピー
				//コピーの際に、Stringからfloatに変換する。さらに、0,1データに変換する。
				int teachOutNum = Integer.parseInt(teachOutTmp[0]);
				for(int i = 0; i < teachOutOneDataNums; i++){
					if(i == teachOutNum){
						teachOutAll[i + count * teachOutOneDataNums] = 1.0f;
					}
					else{
						teachOutAll[i + count * teachOutOneDataNums] = 0.0f;
					}
				}
				count++;
			}
			br.close();
		} catch(IOException e){
			System.out.println("入出力エラーがありました");
		} catch(NumberFormatException e){
			System.out.println("フォーマットエラーがありました");
		}
	}
}
