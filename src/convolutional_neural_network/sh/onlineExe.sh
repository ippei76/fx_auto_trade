#!/bin/bash
if [ $# -ne 2 ]; then
	echo "jcnno seqNo exchangeDataMode"
	echo "there is no seqNo or exchangeDataMode(0:test 1:realTrade)"
	exit 1
fi
sed -i '/^miniBatchNums_property/c\miniBatchNums_property = 1' /root/projects/fx/src/convolutional_neural_network/values/PropertyValues.properties 
sed -i "/^seqNo_property/c\seqNo_property = $1" /root/projects/fx/src/convolutional_neural_network/values/PropertyValues.properties 
sed -i "/^exchangeDataMode_property/c\exchangeDataMode_property = $2" /root/projects/fx/src/convolutional_neural_network/values/PropertyValues.properties 
sed -i "/^execFlg_property/c\execFlg_property = 1" /root/projects/fx/src/convolutional_neural_network/values/PropertyValues.properties 
java convolutional_neural_network.business.Main
