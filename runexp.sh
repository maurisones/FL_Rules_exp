#!/bin/bash

# java 8
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export PATH=/usr/lib/jvm/java-1.8.0-openjdk-amd64/bin:$PATH

WEKAJAR="/home/mauri/Downloads/wekaAndJDK/weka-3-8-6/weka.jar"
FLRULEJAR="/home/mauri/Dropbox/temp/eclipse_rulesWekaFL/RuleBasedFederateLearing/jarExport/RulesBasedFederatedLearning.jar"
OUTDIR="outdir"

datasets=("australian" "breast" "breastcancer" "diabetes" "heart" "hepatitis" "ionosphere" "labor" "liver-disorders" "mushroom" "sick" "sonar" "tic-tac-toe" "vote")

#datasets=("breast" "sonar")

nos=("30" "50" "70")

for ds in ${datasets[*]}; do

    echo "Processing dataset $ds ... "

    # faz o split usando cv em 10 fols
    ./split.sh $WEKAJAR "${ds}.arff" $OUTDIR  
    
    # para cada fold gerado
    for fold in {1..10}; do
    
    	# discretiza os datasets de train e test
    	java -classpath $WEKAJAR weka.filters.unsupervised.attribute.Discretize -b -i "${OUTDIR}/${ds}-train-${fold}-of-10.arff" -o "${OUTDIR}/${ds}-train-${fold}-of-10-d.arff" -r "${OUTDIR}/${ds}-test-${fold}-of-10.arff" -s "${OUTDIR}/${ds}-test-${fold}-of-10-d.arff"
    	
    	# elimina alguns caracteres inseridos na discretização que geram problemas na extração das regras
    	# são eles: =, (, )
    	sed -i 's/=/x/g' "${OUTDIR}/${ds}-train-${fold}-of-10-d.arff"
    	sed -i 's/=/x/g' "${OUTDIR}/${ds}-test-${fold}-of-10-d.arff"
    	
    	sed -i 's/(//g' "${OUTDIR}/${ds}-train-${fold}-of-10-d.arff"
    	sed -i 's/(//g' "${OUTDIR}/${ds}-test-${fold}-of-10-d.arff"
    	
    	sed -i 's/)//g' "${OUTDIR}/${ds}-train-${fold}-of-10-d.arff"
    	sed -i 's/)//g' "${OUTDIR}/${ds}-test-${fold}-of-10-d.arff"
    	
    	sed -i s/"'"/""/g "${OUTDIR}/${ds}-train-${fold}-of-10-d.arff"
    	sed -i s/"'"/""/g "${OUTDIR}/${ds}-test-${fold}-of-10-d.arff"
    	
    	sed -i 's/\\//g' "${OUTDIR}/${ds}-train-${fold}-of-10-d.arff"
    	sed -i 's/\\//g' "${OUTDIR}/${ds}-test-${fold}-of-10-d.arff"

    	sed -i 's/\]//g' "${OUTDIR}/${ds}-train-${fold}-of-10-d.arff"
    	sed -i 's/\]//g' "${OUTDIR}/${ds}-test-${fold}-of-10-d.arff"

    	sed -i 's/\[//g' "${OUTDIR}/${ds}-train-${fold}-of-10-d.arff"
    	sed -i 's/\[//g' "${OUTDIR}/${ds}-test-${fold}-of-10-d.arff"
    	
        # gera subconjuntos dos dados para os nós - de acordo com a lista nos
        NODEFILELIST=""
        for no in ${nos[*]}; do
            java -classpath $WEKAJAR weka.filters.unsupervised.instance.Resample -S 1 -Z $no -i "${OUTDIR}/${ds}-train-${fold}-of-10-d.arff" -o "${OUTDIR}/${ds}-train-${fold}-of-10-d-no${no}.arff"
        
            # faz a execução do nó
            java -classpath "$WEKAJAR:$FLRULEJAR" run.RunNode "${OUTDIR}/${ds}-train-${fold}-of-10-d-no${no}.arff" "$OUTDIR/${ds}-train-${fold}-of-10-d-no${no}"
            
            NODEFILELIST="$NODEFILELIST $OUTDIR/${ds}-train-${fold}-of-10-d-no${no}"            
        
        done       
        
        # faz a execução do coordenador RuleMatchCount + J48
        # aqui o nome do experimento depois do ultimo - determina o file prefix dos nós
        java -classpath "$WEKAJAR:$FLRULEJAR" run.RunCoordinator RuleMatchCount "${OUTDIR}/${ds}-test-${fold}-of-10-d.arff" "${ds}-${fold}" "3node-RuleMatchCount-J48" $NODEFILELIST 
        
	# faz a execução do coordenador RuleMatchWeighted + J48
        java -classpath "$WEKAJAR:$FLRULEJAR" run.RunCoordinator RuleMatchWeighted "${OUTDIR}/${ds}-test-${fold}-of-10-d.arff" "${ds}-${fold}" "3node-RuleMatchWeighted-J48" $NODEFILELIST 


 	# faz a execução do coordenador RuleMatchCount + DT
        java -classpath "$WEKAJAR:$FLRULEJAR" run.RunCoordinator RuleMatchCount "${OUTDIR}/${ds}-test-${fold}-of-10-d.arff" "${ds}-${fold}" "3node-RuleMatchCount-DT" $NODEFILELIST 
        
	# faz a execução do coordenador RuleMatchCount + PART
        java -classpath "$WEKAJAR:$FLRULEJAR" run.RunCoordinator RuleMatchCount "${OUTDIR}/${ds}-test-${fold}-of-10-d.arff" "${ds}-${fold}" "3node-RuleMatchCount-PART" $NODEFILELIST 
        
	# faz a execução do coordenador RuleMatchWeighted + PART
        java -classpath "$WEKAJAR:$FLRULEJAR" run.RunCoordinator RuleMatchWeighted "${OUTDIR}/${ds}-test-${fold}-of-10-d.arff" "${ds}-${fold}" "3node-RuleMatchWeighted-PART" $NODEFILELIST 

        
        # faz a execução do PureWeka
        java -classpath "$WEKAJAR:$FLRULEJAR" run.RunWekaJ48 "${ds}-${fold}" "${OUTDIR}/${ds}-train-${fold}-of-10-d.arff" 1 "${OUTDIR}/${ds}-test-${fold}-of-10-d.arff"
        
    done
	
	
done

