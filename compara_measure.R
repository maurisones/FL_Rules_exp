options(max.print=999999)
options(digits = 6)
options(scipen=500)
library("scmamp")


output_dir <- "/home/mauri/Downloads/federatedlearning/FL_Rules_exp/"

measures = c("measures-Accuracy-all", "measures-FMeasureWeightedAvg-all", "measures-PrecisionWeightedAvg-all", "measures-RecallWeightedAvg-all")

algs <- c("RuleMatchCount.PART", "RuleMatchWeighted.PART", "RuleMatchCount.J48",   "RuleMatchWeighted.J48", "RuleMatchCount.DT",     
          "RuleMatchWeighted.DT", "RuleMatchCount.Rand",    "RuleMatchWeighted.Rand")


generate_ranking <- function(data){
  
  retorno = list()
  coluna = ncol(data)
  linha = nrow(data)
  
  rank_first_0 = data.frame()
  rank_last_0 = data.frame()
  rank_average_0 = data.frame()
  rank_random_0 = data.frame()
  rank_min_0 = data.frame()
  rank_max_0 = data.frame()
  
  i = 1
  for(i in 1:linha){
    rf = rank(data[i,], ties.method = "first")     # first occurrence wins
    rl = rank(data[i,], ties.method = "last")      # last occurrence wins
    rav = rank(data[i,], ties.method = "average")   # média
    ran = rank(data[i,], ties.method = "random")    # ordem aleatória
    rma = rank(data[i,], ties.method = "max")       # máximo
    rmi = rank(data[i,], ties.method = "min")       # mínimo
    
    rank_first_0 = rbind(rank_first_0, rf)
    rank_last_0 = rbind(rank_last_0, rl)
    rank_average_0 = rbind(rank_average_0, rav)
    rank_random_0 = rbind(rank_random_0, ran)
    rank_max_0 = rbind(rank_max_0, rma)
    rank_min_0 = rbind(rank_min_0, rmi)
    
  }
  
  colnames(rank_first_0) = colnames(data)
  colnames(rank_last_0) = colnames(data)
  colnames(rank_average_0) = colnames(data)
  colnames(rank_random_0) = colnames(data)
  colnames(rank_max_0) = colnames(data)
  colnames(rank_min_0) = colnames(data)
  
  
  rank_first_1 = data.frame()
  rank_last_1 = data.frame()
  rank_average_1 = data.frame()
  rank_random_1 = data.frame()
  rank_min_1 = data.frame()
  rank_max_1 = data.frame()
  
  i = 1
  for(i in 1:linha){
    rf = (coluna -  rank_first_0[i,]) +1
    rl = (coluna - rank_last_0[i,]) +  1
    rav = (coluna - rank_average_0[i,]) + 1
    ran = (coluna - rank_random_0[i,]) + 1
    rma = (coluna - rank_max_0[i,]) + 1
    rmi = (coluna - rank_min_0[i,]) + 1
    
    rank_first_1 = rbind(rank_first_1, rf)
    rank_last_1 = rbind(rank_last_1, rl)
    rank_average_1 = rbind(rank_average_1, rav)
    rank_random_1 = rbind(rank_random_1, ran)
    rank_max_1 = rbind(rank_max_1, rma)
    rank_min_1 = rbind(rank_min_1, rmi)
  }
  
  colnames(rank_first_1) = colnames(data)
  colnames(rank_last_1) = colnames(data)
  colnames(rank_average_1) = colnames(data)
  colnames(rank_random_1) = colnames(data)
  colnames(rank_max_1) = colnames(data)
  colnames(rank_min_1) = colnames(data)
  
  rank_average_0 = trunc(rank_average_0,0)
  rank_average_1 = trunc(rank_average_1,0)
  
  retorno$rank_first_0 = rank_first_0
  retorno$rank_last_0 = rank_last_0
  retorno$rank_average_0 = rank_average_0
  retorno$rank_random_0 = rank_random_0
  retorno$rank_max_0 = rank_max_0
  retorno$rank_min_0 = rank_min_0
  
  retorno$rank_first_1 = rank_first_1
  retorno$rank_last_1 = rank_last_1
  retorno$rank_average_1 = rank_average_1
  retorno$rank_random_1 = rank_random_1
  retorno$rank_max_1 = rank_max_1
  retorno$rank_min_1 = rank_min_1
  
  return(retorno)
}






for (m in measures){
  acc3 <- read.csv(paste(output_dir, "results-3/", m,".csv", sep = ""), row.names = 1)
  acc5 <- read.csv(paste(output_dir, "results-5/", m,".csv", sep = ""), row.names = 1)
  acc10 <- read.csv(paste(output_dir, "results-10/", m,".csv", sep = ""), row.names = 1)
  acc20 <- read.csv(paste(output_dir, "results-20/", m,".csv", sep = ""), row.names = 1)
  acc30 <- read.csv(paste(output_dir, "results-30/", m,".csv", sep = ""), row.names = 1)
  
  for (c in algs){

    dfc <- cbind(acc3[,c], acc5[,c], acc10[,c], acc20[,c], acc30[,c])
  
    pure <- paste("Pure", strsplit(c, "\\.")[[1]][2], sep="")    
    if (pure != "PureRand"){
      dfc <- cbind(dfc,  acc3[,pure])
      colnames(dfc) <- c("3", "5", "10", "20", "30", pure)
    } else{
      dfc <- cbind(dfc,  acc3[,"PureJ48"], acc3[,"PureDT"], acc3[,"PurePART"])
      colnames(dfc) <- c("3", "5", "10", "20", "30", "PureJ48", "PureDT", "PurePART")
    }
    rownames(dfc) <- rownames(acc3)
      
    # remove o avg e o ranksum
    dfc <- dfc [-nrow(dfc),]
    dfc <- dfc [-nrow(dfc),]
    
    postscript(paste(output_dir, m, "-", c,"-evolution.eps", sep=""))
    plotCD(dfc, alpha=0.05, cex=1.3)
    dev.off()
    
    
    
    # add average
    dfc <- rbind(dfc, colMeans(dfc))
    rownames(dfc)[nrow(dfc)] <- "Average"
    
    # add rank and media aos resultados
    ranking <- generate_ranking(head(dfc,-1)) # head para retirar a linha da média
    ranking <- ranking$rank_average_1
    dfc <- rbind(dfc, colSums(ranking))
    rownames(dfc)[nrow(dfc)] <- "RankSum"
    
    write.csv(dfc, paste(output_dir, m, "-", c,"-evolution.csv", sep=""))
    
  }
}

