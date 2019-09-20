#!/bin/bash
cd ~/projects/fx/src/convolutional_neural_network/common &&
javac PropertiesReader.java &&
echo "PropertiesReader.java OK!" &&
javac CalendarMethod.java &&
echo "CalendarMethod.java OK!" &&
cd ~/projects/fx/src/convolutional_neural_network/values &&
javac Mt4Define.java &&
echo "Mt4Define.java OK!" &&
javac CulcuConstants.java &&
echo "CulcuConstants.java OK!" &&
javac Constants.java &&
echo "Constants.java OK!" &&
cd ~/projects/fx/src/convolutional_neural_network/business/dto &&
javac CnnMlpBnParasDto.java  &&
echo "CnnMlpBnParasDto.java OK!" &&
javac CnnMlpOutputNumsDto.java &&
echo "CnnMlpOutputNumsDto.java OK!" &&
javac CnnMlpParasDto.java &&
echo "CnnMlpParasDto.java OK!" &&
javac CnnMlpWDto.java &&
echo "CnnMlpWDto.java OK!" &&
javac ExchangeDataDto.java &&
echo "ExchangeDataDto.java OK!" &&
cd ~/projects/fx/src/convolutional_neural_network/business/dao &&
javac CnnMlpParasDao.java &&
echo "CnnMlpParasDao.java OK!" &&
javac WorkTableImpChkDao.java &&
echo "WorkTableImpChkDao.java OK!" &&
cd ~/projects/fx/src/convolutional_neural_network/common &&
javac MnistService.java &&
echo "MnistService.java OK!" &&
cd ~/projects/fx/src/convolutional_neural_network/business &&
javac JnaIF.java &&
echo "JnaIF.java OK!" &&
javac WorkTableImpChkService.java &&
echo "WorkTableImpChkService.java OK!" &&
javac CnnMlpParasService.java &&
echo "CnnMlpParasService.java OK!" &&
javac ExchangeDataService.java &&
echo "ExchangeDataService.java OK!" &&
javac CnnTrainingService.java &&
echo "CnnTrainingService.java OK!" &&
javac CnnOnlineService.java &&
echo "CnnOnlineService.java OK!" &&
javac Main.java &&
echo "Main.java OK!" &&
cd ~/projects/fx/src/convolutional_neural_network/business/gpu &&
nvcc -shared -Xcompiler -fPIC -arch=sm_30 -rdc=true -o libJnaInterface.so JnaInterface.cu -I cudaHeader/ -O2 &&
echo "libJnaInterface.cu compile success!" &&
echo "All compile success! KOBAYASI OK!"
