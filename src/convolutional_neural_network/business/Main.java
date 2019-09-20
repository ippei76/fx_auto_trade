package convolutional_neural_network.business;

import convolutional_neural_network.business.CnnTrainingService;
import convolutional_neural_network.business.CnnOnlineService;
import static convolutional_neural_network.values.Constants.*;
//import static convolutional_neural_network.values.Variables.*;

class Main{
	public static void main(String[] args){

		if(args.length != 0){
			System.out.println("java business.Main (args[0] = null) " + args.length);
			System.exit(2);
		}
		
		//トレーニングモード
		if(getExecFlg() == getExecFlgIsTraining()){
			//学習プログラム
			training(args);
		}
		//オンラインモード
		else if(getExecFlg() == getExecFlgIsOnline()){
			//学習結果検証プログム
			System.out.println("Onlne Start.");
			online(args);
		}
	}

	public static void training(String[] args){

		CnnTrainingService instance = new CnnTrainingService();

		instance.executeBefore();
		instance.execute();
		instance.executeAfter();
		System.out.println("End");
	}

	public static void online(String[] args){

		CnnOnlineService instance = new CnnOnlineService();

		instance.executeBefore();
		for(int svDataIdx = 0; svDataIdx < getSvDataNums(); svDataIdx++){
			System.out.println("LOG:svDataIdx=" + svDataIdx);
			instance.execute();
		}
		instance.executeAfter();
		System.out.println("Online End");
	}
}
