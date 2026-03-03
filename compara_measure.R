options(max.print=999999)
options(digits = 6)
options(scipen=500)
library("scmamp")


output_dir <- "/home/mauri/Downloads/federatedlearning/FL_Rules_exp/"

measures = c("measures-Accuracy-all", "measures-FMeasureWeightedAvg-all", "measures-PrecisionWeightedAvg-all", "measures-RecallWeightedAvg-all")

algs <- c("RuleMatchCount.PART", "RuleMatchWeighted.PART", "RuleMatchCount.J48",   "RuleMatchWeighted.J48", "RuleMatchCount.DT",     
           "RuleMatchCount.Rand",    "RuleMatchWeighted.Rand")

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
    plotCD(dfc, alpha=0.05, cex=0.5)
    dev.off()
    
  }
}

