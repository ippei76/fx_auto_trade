#!/bin/bash
for FILE in `ls -v1 *.csv`
do
	tail -n +2 $FILE >>EURUSD.dat
done
