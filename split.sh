#!/bin/bash
 #
 # expects the weka.jar as first parameter and the datasets to work on as 
 # second parameter.
 #
 # FracPete, 2007-04-10
 
 if [ ! $# -eq 3 ]
 then
   echo
   echo "usage: folds.sh <weka.jar> <dataset>"
   echo
   exit 1
 fi
 
 JAR=$1
 DATASET=$2
 OUTDIR=$3
 OUTFILENAME=`echo $DATASET | sed s/"\.arff"//g`
 OUTFILE="$OUTDIR/$OUTFILENAME"
 FOLDS=10
 FILTER=weka.filters.unsupervised.instance.RemoveFolds
 SEED=1
 
 
 # apaga os sets já gerados
 echo "apagando folds anteriores que terminam em *$FOLDS.arff"
 rm -rfv *"$FOLDS".arff
 
 for ((i = 1; i <= $FOLDS; i++))
 do
   echo "Generating pair $i/$FOLDS..."
 
   # train set
   java -cp $JAR $FILTER -V -N $FOLDS -F $i -S $SEED -i $DATASET -o "$OUTFILE-train-$i-of-$FOLDS.arff"
   # test set
   java -cp $JAR $FILTER    -N $FOLDS -F $i -S $SEED -i $DATASET -o "$OUTFILE-test-$i-of-$FOLDS.arff"
 done
