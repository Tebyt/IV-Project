this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)
quote <- read.csv("/quote.csv")
getwd()
