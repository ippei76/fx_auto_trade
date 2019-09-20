package convolutional_neural_network.business;

import java.util.*;
import java.io.IOException;
import java.math.MathContext;
import java.util.Random;
import static convolutional_neural_network.values.Constants.*;
import static convolutional_neural_network.values.Mt4Define.*;
import convolutional_neural_network.business.dao.CnnMlpParasDao;
import convolutional_neural_network.business.dto.CnnMlpParasDto;
import convolutional_neural_network.business.dto.CnnMlpOutputNumsDto;
import convolutional_neural_network.business.dto.CnnMlpWDto;
import convolutional_neural_network.business.dto.CnnMlpBnParasDto;
import convolutional_neural_network.business.dao.FileOperateDao;


public class CnnMlpParasService{

	private Random random = new Random();

	private CnnMlpParasDao cnnMlpParasDao = new CnnMlpParasDao();
	private FileOperateDao fileOperateDao= new FileOperateDao();

	public CnnMlpParasService(){
	}

	public void initLearningParaRandom(){
		//cnnBnBeta,cnnBnGammaの初期値を設定
		for(int i = 0; i < cnnBnBeta.length; i++){
			//cnnBnBeta[i] = (float)(i+1);
			//cnnBnGamma[i] = (float)(i+1) % 7;
			cnnBnBeta[i] = random.nextFloat();
			cnnBnGamma[i] = random.nextFloat();
			//System.out.println("cnnBnBeta[" + i + "]=" + cnnBnBeta[i]);
			//System.out.println("cnnBnGamma[" + i + "]=" + cnnBnGamma[i]);
		}


		//wの初期値を設定
		for(int i = 0; i < cnnW.length; i++){
			//cnnW[i] = (float)(i+1) % 23;
			//cnnW[i] = (float)(1);
			//cnnW[i] = random.nextFloat() * 0.0001f;
			cnnW[i] = random.nextFloat();
			//System.out.println("cnnW[" + i + "]=" + cnnW[i]);
		}

		//mlpWの初期値を設定
		for(int i = 0; i < mlpW.length; i++){
			//mlpW[i] = (float)(i+5) / 10;
			//mlpW[i] = random.nextFloat() * 0.0001f;
			mlpW[i] = random.nextFloat();
			//System.out.println("mlpW[" + i + "]=" + mlpW[i]);
		}
		//mlpBnBeta,mlpBnGammaの初期値を設定
		for(int i = 0; i < mlpBnBeta.length; i++){
			//mlpBnBeta[i] = (float)(i+1) * (i+1);
			//mlpBnGamma[i] = (float)(i+1) * (i+1);
			mlpBnBeta[i] = random.nextFloat();
			mlpBnGamma[i] = random.nextFloat();
			//System.out.println("mlpBnBeta[" + i + "]=" + mlpBnBeta[i]);
			//System.out.println("mlpBnGamma[" + i + "]=" + mlpBnGamma[i]);
		}
	}

	public void initConstParaCheck(){
		//基本パラメータのチェック
		ArrayList<CnnMlpParasDto> cnnMlpParasList = new ArrayList<CnnMlpParasDto>();
		cnnMlpParasList.clear();
		cnnMlpParasList = cnnMlpParasDao.selectCnnMlpParas(getSeqNo());

		if(cnnMlpParasList.isEmpty()){
			System.out.println("cnnMlpParasList is empty.");
			System.exit(2);
		}
		for(CnnMlpParasDto cnnMlpParasDto : cnnMlpParasList){
			if(getApplication() == getApplicationIsExchangeData() && !cnnMlpParasDto.getCurrency().equals(getCurrency())){
				System.out.println("currency unmatch.");
				System.out.println(cnnMlpParasDto.getCurrency() + " != " + getCurrency());
				System.exit(2);
			}

			//onlineでは,minibatchNumsは必ず1でなければならない。
			if(getExecFlg() == getExecFlgIsOnline() && getMiniBatchNums() != 1){
				System.out.println("miniNums must be one.");
				System.out.println(getMiniBatchNums() + "!= 1");
				System.exit(2);
			}

			//不要?
			/*
			if(cnnMlpParasDto.getSvDataNums() != getSvDataNums()){
				System.out.println("svDataNums unmatch.");
				System.out.println(cnnMlpParasDto.getSvDataNums() + " != " + getSvDataNums());
				System.exit(2);
			}
			*/

			if(cnnMlpParasDto.getSv_xNums() != getSv_xNums()){
				System.out.println("sv_xNums unmatch.");
				System.out.println(cnnMlpParasDto.getSv_xNums() + " != " + getSv_xNums());
				System.exit(2);
			}

			if(cnnMlpParasDto.getSv_yNums() != getSv_yNums()){
				System.out.println("sv_yNums unmatch.");
				System.out.println(cnnMlpParasDto.getSv_yNums() + " != " + getSv_yNums());
				System.exit(2);
			}

			if(cnnMlpParasDto.getCnnW_xNums() != getCnnW_xNums()){
				System.out.println("cnnW_xNums unmatch.");
				System.out.println(cnnMlpParasDto.getCnnW_xNums() + " != " + getCnnW_xNums());
				System.exit(2);
			}

			if(cnnMlpParasDto.getCnnW_yNums() != getCnnW_yNums()){
				System.out.println("cnnW_yNums unmatch.");
				System.out.println(cnnMlpParasDto.getCnnW_yNums() + " != " + getCnnW_yNums());
				System.exit(2);
			}

			if(cnnMlpParasDto.getCnnPooling_xNums() != getCnnPooling_xNums()){
				System.out.println("pooling_xNums unmatch.");
				System.out.println(cnnMlpParasDto.getCnnPooling_xNums() + " != " + getCnnPooling_xNums());
				System.exit(2);
			}

			if(cnnMlpParasDto.getCnnPooling_yNums() != getCnnPooling_yNums()){
				System.out.println("pooling_yNums unmatch.");
				System.out.println(cnnMlpParasDto.getCnnPooling_yNums() + " != " + getCnnPooling_yNums());
				System.exit(2);
			}

			if(cnnMlpParasDto.getCnnOutputNumsNums() != cnnOutputNums.length){
				System.out.println("cnnOutputNums unmatch.");
				System.out.println(cnnMlpParasDto.getCnnOutputNumsNums() + " != " + cnnOutputNums.length);
				System.exit(2);
			}

			if(cnnMlpParasDto.getMlpOutputNumsNums() != mlpOutputNums.length){
				System.out.println("mlpOutputNums unmatch.");
				System.out.println(cnnMlpParasDto.getMlpOutputNumsNums() + " != " + mlpOutputNums.length);
				System.exit(2);
			}
		}


		//outputNumsのチェック
		ArrayList<CnnMlpOutputNumsDto> cnnMlpOutputNumsList = new ArrayList<CnnMlpOutputNumsDto>();
		cnnMlpOutputNumsList.clear();
		cnnMlpOutputNumsList = cnnMlpParasDao.selectCnnMlpOutputNums(getSeqNo());

		if(cnnMlpOutputNumsList.isEmpty()){
			System.out.println("cnnMlpOutputNumsList is empty.");
			System.exit(2);
		}

		for(CnnMlpOutputNumsDto cnnMlpOutputNums : cnnMlpOutputNumsList){
			if(cnnMlpOutputNums.getType() == getTypeIsCnn()){
				if(cnnOutputNums[cnnMlpOutputNums.getLayer()] != cnnMlpOutputNums.getNums()){
					System.out.println("cnnOutputNums(layer=" + cnnMlpOutputNums.getLayer() + ") unmatch.");
					System.out.println(cnnOutputNums[cnnMlpOutputNums.getLayer()] + " != " + cnnMlpOutputNums.getNums());
					System.exit(2);
				}
			}
			else if(cnnMlpOutputNums.getType() == getTypeIsMlp()){
				if(mlpOutputNums[cnnMlpOutputNums.getLayer()] != cnnMlpOutputNums.getNums()){
					System.out.println("mlpOutputNums(layer=" + cnnMlpOutputNums.getLayer() + ") unmatch.");
					System.out.println(mlpOutputNums[cnnMlpOutputNums.getLayer()] + " != " + cnnMlpOutputNums.getNums());
					System.exit(2);
				}
			}
			else{
				System.out.println("cnnMlpOutputNums.getType(= " + cnnMlpOutputNums.getType() + ") is error.");
				System.exit(2);
			}
		}
	}

	public void initLearnedPara(){

		//cnn,mlpW値をセット
		ArrayList<CnnMlpWDto> cnnMlpWList = new ArrayList<CnnMlpWDto>();
		cnnMlpWList.clear();
		cnnMlpWList = cnnMlpParasDao.selectCnnMlpW(getSeqNo());

		if(cnnMlpWList.isEmpty()){
			System.out.println("cnnMlpWList is empty.");
			System.exit(2);
		}

		for(CnnMlpWDto cnnMlpW : cnnMlpWList){
			//System.out.println(cnnMlpW.getType() + " " + cnnMlpW.getIdx() + " " + cnnMlpW.getValue());
			if(cnnMlpW.getType() == getTypeIsCnn()){
				cnnW[cnnMlpW.getIdx()] = cnnMlpW.getValue();
			}
			else if(cnnMlpW.getType() == getTypeIsMlp()){
				mlpW[cnnMlpW.getIdx()] = cnnMlpW.getValue();
			}
			else{
				System.out.println("cnnMlpW.getType(= " + cnnMlpW.getType() + ") is error.");
				System.exit(2);
			}
		}

		//cnn,mlpBnPara値をセット
		ArrayList<CnnMlpBnParasDto> cnnMlpBnParasList = new ArrayList<CnnMlpBnParasDto>();
		cnnMlpBnParasList.clear();
		cnnMlpBnParasList = cnnMlpParasDao.selectCnnMlpBnParas(getSeqNo());

		if(cnnMlpBnParasList.isEmpty()){
			System.out.println("cnnMlpBnParasList is empty.");
			System.exit(2);
		}

		for(CnnMlpBnParasDto cnnMlpBnParas : cnnMlpBnParasList){
			//System.out.println(cnnMlpBnParas.getType() + " " + cnnMlpBnParas.getIdx() + " " + cnnMlpBnParas.getValue());
			if(cnnMlpBnParas.getType() == getTypeIsCnn()){
				if(cnnMlpBnParas.getBnType() == getBnTypeIsGamma()){
					cnnBnGamma[cnnMlpBnParas.getIdx()] = cnnMlpBnParas.getValue();
				}
				else if(cnnMlpBnParas.getBnType() == getBnTypeIsBeta()){
					cnnBnBeta[cnnMlpBnParas.getIdx()] = cnnMlpBnParas.getValue();
				}
				else if(cnnMlpBnParas.getBnType() == getBnTypeIsAveMean()){
					cnnBnAveMean[cnnMlpBnParas.getIdx()] = cnnMlpBnParas.getValue();
				}
				else if(cnnMlpBnParas.getBnType() == getBnTypeIsAveVar2()){
					cnnBnAveVar2[cnnMlpBnParas.getIdx()] = cnnMlpBnParas.getValue();
				}
				else{
					System.out.println("cnnMlpBnParas.getBnType(= " + cnnMlpBnParas.getBnType() + ") is error.");
					System.exit(2);
				}
			}
			else if(cnnMlpBnParas.getType() == getTypeIsMlp()){
				if(cnnMlpBnParas.getBnType() == getBnTypeIsGamma()){
					mlpBnGamma[cnnMlpBnParas.getIdx()] = cnnMlpBnParas.getValue();
				}
				else if(cnnMlpBnParas.getBnType() == getBnTypeIsBeta()){
					mlpBnBeta[cnnMlpBnParas.getIdx()] = cnnMlpBnParas.getValue();
				}
				else if(cnnMlpBnParas.getBnType() == getBnTypeIsAveMean()){
					mlpBnAveMean[cnnMlpBnParas.getIdx()] = cnnMlpBnParas.getValue();
				}
				else if(cnnMlpBnParas.getBnType() == getBnTypeIsAveVar2()){
					mlpBnAveVar2[cnnMlpBnParas.getIdx()] = cnnMlpBnParas.getValue();
				}
				else{
					System.out.println("cnnMlpBnParas.getBnType(= " + cnnMlpBnParas.getBnType() + ") is error.");
					System.exit(2);
				}
			}
			else{
				System.out.println("cnnMlpBnParas.getType(= " + cnnMlpBnParas.getType() + ") is error.");
				System.exit(2);
			}
		}
	}

	public void updateOnlineResult(int plsCount, int mnsCount, int eqlCount, int seqNo){
		cnnMlpParasDao.updateOnlineResult(plsCount, mnsCount, eqlCount, seqNo);
	}

	public void preserveLearnedParas(int plsCount, int eqlCount, int mnsCount, String settingCurrency, String currentDateTimeStr){

		//基本情報の保存
		cnnMlpParasDao.insertCnnMlpParas(plsCount, eqlCount, mnsCount, settingCurrency, currentDateTimeStr);

		//OutputNumsの保存
		cnnMlpParasDao.insertCnnMlpOutputNums(currentDateTimeStr);

		//保存のSeqNoを取得
		int targetSeqNo = cnnMlpParasDao.selectCnnMlpParasSeqNo(currentDateTimeStr);

		//cnnMlpWの保存
		//一つずつinsertでは時間がかかるため、一度ファイルに出して一気に保存する。
		fileOperateDao.makeLoadDataFileCnnMlpW(targetSeqNo);
		cnnMlpParasDao.loadDataCnnMlpW();
		//Bnパラメータの保存
		//一つずつinsertでは時間がかかるため、一度ファイルに出して一気に保存する。
		fileOperateDao.makeLoadDataFileCnnMlpBnParas(targetSeqNo);
		cnnMlpParasDao.loadDataCnnMlpBnParas();

		System.out.println("LOG:parameters preserved(seqNo = " + targetSeqNo + ").");
	}
}
