package reinforcement_learning.business;

import reinforcement_learning.business.RLservice;
import static reinforcement_learning.values.Constants.*;
import static reinforcement_learning.values.Variables.*;
import static reinforcement_learning.common.RBFNProcess.*;
import java.lang.reflect.Method;

class Main{
	public static void main(String[] args){

		if(args.length != 2){
			System.out.println("java business.Main (args[0] = 0:traning 1:online), (args[1] = 0:normal 1:perDeal) args.length = " + args.length);
			System.exit(2);
		}
		final String learnStartDateTime = "201601250800";
		final String learnEndDateTime   = "201601252000";
		final long learnEpisodes = 30;
		final long tgtSeqNo = 6;

		if(Byte.parseByte(args[0]) == 0){
			//学習プログラム
			learning(learnStartDateTime, learnEndDateTime, learnEpisodes, args);
		}
		else if(Byte.parseByte(args[0]) == 1){
			//学習結果検証プログム
			onlineLearning(args, tgtSeqNo);
		}
	}

	public static RLonlineService makeOnlineInstance(String[] args, RLonlineService instance, long tgtSeqNo){

		if(Byte.parseByte(args[1]) == 0){
			instance = new RLonlineService(tgtSeqNo);
		}
		else{
			System.out.println("onlineServiceERROR : args[1] = " + args[1]);
			System.exit(2);
		}
		return(instance);
	}

	public static RLservice makeInstance(String[] args, RLservice instance, String startDateTime, String endDateTime){

		if(Byte.parseByte(args[1]) == 0){
			instance = new RLservice(startDateTime, endDateTime);
		}
		else if(Byte.parseByte(args[1]) == 1){
			instance = new PerDeal(startDateTime, endDateTime);
		}
		else{
			System.out.println("ERROR : args[1] = " + args[1]);
			System.exit(2);
		}
		return(instance);
	}

	public static void learning(String startDateTime, String endDateTime, long episodes, String[] args){

		RLservice instance = null;
		instance = makeInstance(args, instance, startDateTime, endDateTime);

		instance.executeBefore();
		for(long ep = 0; ep < episodes; ep++){
			if(ep >= episodes * 0.95){
				setEpsilonZero();
			}
			if(ep%10 == 0){
				System.out.println("Episode\tSumRwd\tplsC\tmnsC\teqlC\tAT(0)\tAT(1)\tAT(2)\tUnits(0~2)\tmu\tsigma\tw");
			}
			instance.execute(ep);
		}
		instance.executeAfter(episodes, startDateTime, endDateTime);
		System.out.println("End");
	}

	public static void onlineLearning(String[] args, long tgtSeqNo){
		RLonlineService instance = null;
		instance = makeOnlineInstance(args, instance, tgtSeqNo);

		instance.executeOnlineBefore();
//		setEpsilonZero();
		instance.executeOnline(0);
		instance.executeOnlineAfter();
		System.out.println("Online End");
	}
}
