package convolutional_neural_network.business.dao;

import static convolutional_neural_network.values.Constants.*;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;

public class FileOperateDao{

	public FileOperateDao(){
	}

	public void makeLoadDataFileCnnMlpW(int seqNo){
		//ファイルオブジェクトの生成
		File outputFile = new File(getLoadDataFile());

		try{
			//出力ストリームの生成
			FileOutputStream fileOutputStream = new FileOutputStream(outputFile);
			OutputStreamWriter outputStreamWriter = new OutputStreamWriter(fileOutputStream);
			PrintWriter printWriter = new PrintWriter(outputStreamWriter);

			//ファイルへ書き込み
			//cnnにおける出力
			for(int idx = 0; idx < cnnW.length; idx++){
				printWriter.println(seqNo + "," + getTypeIsCnn() + "," + idx + "," + cnnW[idx]);
			}
			//mlpにおける出力
			for(int idx = 0; idx < mlpW.length; idx++){
				printWriter.println(seqNo + "," + getTypeIsMlp() + "," + idx + "," + mlpW[idx]);
			}

			//クローズ
			printWriter.close();

		}catch(Exception e){
			e.printStackTrace();
			System.exit(2);
		}
	}

	private void makeBnFile(int seqNo, int type, int bnType, float[] valueArray, PrintWriter printWriter){
		for(int idx = 0; idx < valueArray.length; idx++){
			printWriter.println(seqNo + "," + type + "," + bnType + "," + idx + "," + valueArray[idx]);
		}
	}
	public void makeLoadDataFileCnnMlpBnParas(int seqNo){
		//ファイルオブジェクトの生成
		File outputFile = new File(getLoadDataFile());

		try{
			//出力ストリームの生成
			FileOutputStream fileOutputStream = new FileOutputStream(outputFile);
			OutputStreamWriter outputStreamWriter = new OutputStreamWriter(fileOutputStream);
			PrintWriter printWriter = new PrintWriter(outputStreamWriter);

			//ファイルへ書き込み
			//cnnBnGammaにおける出力
			makeBnFile(seqNo, getTypeIsCnn(), getBnTypeIsGamma(), cnnBnGamma, printWriter);
			//cnnBnBetaにおける出力
			makeBnFile(seqNo, getTypeIsCnn(), getBnTypeIsBeta(), cnnBnBeta, printWriter);
			//cnnBnAveMeanの追加
			makeBnFile(seqNo, getTypeIsCnn(), getBnTypeIsAveMean(), cnnBnAveMean, printWriter);
			//cnnBnAveVar2の追加
			makeBnFile(seqNo, getTypeIsCnn(), getBnTypeIsAveVar2(), cnnBnAveVar2, printWriter);
			
			//mlpBnGammaにおける出力
			makeBnFile(seqNo, getTypeIsMlp(), getBnTypeIsGamma(), mlpBnGamma, printWriter);
			//mlpBnBetaにおける出力
			makeBnFile(seqNo, getTypeIsMlp(), getBnTypeIsBeta(), mlpBnBeta, printWriter);
			//mlpBnAveMeanの追加
			makeBnFile(seqNo, getTypeIsMlp(), getBnTypeIsAveMean(), mlpBnAveMean, printWriter);
			//mlpBnAveVar2の追加
			makeBnFile(seqNo, getTypeIsMlp(), getBnTypeIsAveVar2(), mlpBnAveVar2, printWriter);

			//クローズ
			printWriter.close();

		}catch(Exception e){
			e.printStackTrace();
			System.exit(2);
		}
	}

}
