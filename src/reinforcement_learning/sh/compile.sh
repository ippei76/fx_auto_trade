#!/bin/bash
cd ~/projects/fx/src/reinforcement_learning/values &&
javac Constants.java &&
echo "Constants.java OK!" &&
javac Variables.java &&
echo "Variables.java OK!" &&
cd ~/projects/fx/src/reinforcement_learning/business &&
javac DaoAbstruct.java &&
echo "DaoAbstruct.java OK!" &&
cd ~/projects/fx/src/reinforcement_learning/common &&
javac RBFNProcess.java && 
echo "RBFNProcess.java OK!" &&
javac WorkTableImpChkDao.java &&
echo "WorkTableImpChkDao.java OK!" &&
javac WorkTableImpChkService.java &&
echo "WorkTableImpChkService.java OK!" &&
cd ~/projects/fx/src/reinforcement_learning/business &&
javac MultiThreadRenwlMu.java &&
echo "MultiThreadRenwlMu.java OK!" &&
javac RLdao.java && 
echo "RLdao.java OK!" &&
javac SyncTradeInfoDao.java &&
echo "SyncTradeInfoDao.java OK!" &&
javac RLparasDao.java &&
echo "RLparasDao.java" &&
javac RLservice.java &&
echo "RLservice.java OK!" &&
javac RLonlineDao.java && 
echo "RLonlineDao.java OK!" &&
javac RLonlineService.java &&
echo "RLonlineService.java OK!" &&
javac Main.java &&
echo "Main.java OK!" &&
echo "All compile success!"
