#!/bin/bash
if [ $# -ne 2 ]; then
	echo "jcnn miniBatchNums seqNo"
	echo "there is no miniBatchNums or seqNo(if randomSeqNo : set -1)"
	exit 1
fi
sed -i "/^miniBatchNums_property/c\miniBatchNums_property = $1" /root/projects/fx/src/convolutional_neural_network/values/PropertyValues.properties 
sed -i "/^seqNo_property/c\seqNo_property = $2" /root/projects/fx/src/convolutional_neural_network/values/PropertyValues.properties 
sed -i "/^execFlg_property/c\execFlg_property = 0" /root/projects/fx/src/convolutional_neural_network/values/PropertyValues.properties 
java convolutional_neural_network.business.Main
