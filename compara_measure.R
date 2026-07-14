options(max.print=999999)
options(digits = 6)
options(scipen=500)
library("scmamp")

library(ggplot2)
library(dplyr)
library(tidyr)


output_dir <- "/home/mauri/Downloads/federatedlearning/FL_Rules_exp/"

measures = c("measures-Accuracy-all", "measures-FMeasureWeightedAvg-all", "measures-PrecisionWeightedAvg-all", "measures-RecallWeightedAvg-all")

algs <- c("RuleMatchCount.J48",   "RuleMatchWeighted.J48", "RuleMatchCount.PART", "RuleMatchWeighted.PART",  "RuleMatchCount.DT",     
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




friedmanps <- c();

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
      pure <- gsub("Pure", "Cent", pure)
      colnames(dfc) <- c("3", "5", "10", "20", "30", pure)
    } else{
      dfc <- cbind(dfc,  acc3[,"PureJ48"], acc3[,"PureDT"], acc3[,"PurePART"])
      colnames(dfc) <- c("3", "5", "10", "20", "30", "CentJ48", "CentDT", "CentPART")
    }
    rownames(dfc) <- rownames(acc3)
      
    # remove o avg e o ranksum
    dfc <- dfc [-nrow(dfc),]
    dfc <- dfc [-nrow(dfc),]
    
    postscript(paste(output_dir, m, "-", c,"-evolution.eps", sep=""))
    plotCD(dfc, alpha=0.05, cex=2)
    dev.off()
    
    friedman <- friedmanTest(dfc, )
    friedmanps <- c(friedmanps, paste(m, c, friedman$p.value, sep=":"))

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
  
  # df to win tie loss
  dfwtl <- cbind(acc3[1:14,c(1:6, 10:11)], acc5[1:14,c(1:6, 10:11)], acc10[1:14,c(1:6, 10:11)], acc20[1:14,c(1:6, 10:11)], acc30[1:14,c(1:6, 10:11)], acc3[1:14, c("PureJ48", "PureDT", "PurePART")])
  colnames(dfwtl) <- c("FRMC-PART-3", "FRMW-PART-3", "FRMC-J48-3", "FRMW-J48-3", "FRMC-DT-3", "FRMW-DT-3", "FRMC-R-3", "FRMW-R-3", 
                       "FRMC-PART-5", "FRMW-PART-5", "FRMC-J48-5", "FRMW-J48-5", "FRMC-DT-5", "FRMW-DT-5", "FRMC-R-5", "FRMW-R-5", 
                       "FRMC-PART-10", "FRMW-PART-10", "FRMC-J48-10", "FRMW-J48-10", "FRMC-DT-10", "FRMW-DT-10", "FRMC-R-10", "FRMW-R-10", 
                       "FRMC-PART-20", "FRMW-PART-20", "FRMC-J48-20", "FRMW-J48-20", "FRMC-DT-20", "FRMW-DT-20", "FRMC-R-20", "FRMW-R-20", 
                       "FRMC-PART-30", "FRMW-PART-30", "FRMC-J48-30", "FRMW-J48-30", "FRMC-DT-30", "FRMW-DT-30", "FRMC-R-30", "FRMW-R-30", 
                       "CentJ48", "CentDT", "CentPART"
  )
  exps <- c()
  expsw <- c()
  expst <- c()
  expsl <- c()
  for (exp in 1:ncol(dfwtl)){
    w <- 0
    t <- 0
    l <- 0
    for (exp2 in 1:ncol(dfwtl)){
      if (exp != exp2){
        wil <- wilcox.test(dfwtl[,exp], dfwtl[,exp2], paired = T, exact = F)   
        if (wil$p.value < 0.05){
          
          npos <- length(which(dfwtl[exp] - dfwtl[exp2] > 0))
          nneg <- length(which(dfwtl[exp] - dfwtl[exp2] < 0))
          if (npos > nneg){
            w <- w + 1
          } else {
            l <- l + 1
          }
        } else{
          t <- t + 1
        }
      }
    }
    exps <- c(exps, colnames(dfwtl)[exp])
    expsw <- c(expsw, w);
    expst <- c(expst, t);
    expsl <- c(expsl, l);
  }
  

  # 1. Create sample data
  data <- data.frame(
    Algorithm = exps,
    Wins = expsw,
    Ties = expst,
    Losses = expsl
  )
  
  # 2. Reshape the data to long format
  data_long <- data %>%
    pivot_longer(
      cols = c(Wins, Ties, Losses),
      names_to = "Outcome",
      values_to = "Count"
    )
  
  
  # 3. Order factors for proper legend and bar display
  data_long$Outcome <- factor(data_long$Outcome, levels = c("Losses", "Ties", "Wins"))
  
  # 4. Generate the Win-Tie-Loss plot
  plt <- ggplot(data_long, aes(x = Algorithm, y = Count, fill = Outcome)) +
    geom_bar(stat = "identity", position = "fill") + # use "stack" instead of "fill" for absolute counts
    scale_y_continuous(labels = scales::percent) +
    scale_fill_manual(values = c("Wins" = "#4E8397", "Ties" = "#C7C8C9", "Losses" = "#C55B5B")) +
    labs(
      title = "Win-Tie-Loss Comparison",
      x = "Method",
      y = "Proportion",
      fill = "Outcome"
    ) +
    theme_minimal() +
    coord_flip() # Optional: flips bars horizontally
  
  ggsave(paste(output_dir, m, "-wtl.eps", sep=""), plot = plt, device = "eps")
  
  postscript(paste(output_dir, m, "-", c,"-all.eps", sep=""))
  plotCD(dfwtl, alpha=0.05, cex=2)
  dev.off()

  
}

friedmanps

write.csv(friedmanps, "p-values-friedman.csv")

