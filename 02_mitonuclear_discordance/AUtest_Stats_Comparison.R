summary <- read.table("summary_AUtest_2334_HOG.txt",
                      header = TRUE,
                      stringsAsFactors = FALSE,
                      check.names = FALSE)

mito_genes <- readLines("genes_supporting_mitochondrial.txt")
nuc_genes  <- readLines("genes_supporting_nuclear.txt")

summary$Group <- NA
summary$Group[summary$Alignment_name %in% mito_genes] <- "Mito"
summary$Group[summary$Alignment_name %in% nuc_genes]  <- "Nuclear"

dataset <- subset(summary, !is.na(Group))

dataset$Group <- factor(dataset$Group,
                        levels = c("Nuclear","Mito"))

vars <- c("Alignment_length",
          "Missing_percent",
          "Proportion_parsimony_informative")

for (v in vars) {

  cat("\n====================\n")
  cat("Variable:", v, "\n\n")

  cat("Median Nuclear:",
      median(dataset[dataset$Group=="Nuclear", v]), "\n")
  cat("Median Mito:",
      median(dataset[dataset$Group=="Mito", v]), "\n\n")

  print(wilcox.test(dataset[[v]] ~ dataset$Group))
}

######################### STATS

====================
Variable: Alignment_length 

Median Nuclear: 481 
Median Mito: 285 


	Wilcoxon rank sum test with continuity correction

data:  dataset[[v]] by dataset$Group
W = 65186, p-value = 1.101e-14
alternative hypothesis: true location shift is not equal to 0


====================
Variable: Missing_percent 

Median Nuclear: 2.527 
Median Mito: 2.112 


	Wilcoxon rank sum test with continuity correction

data:  dataset[[v]] by dataset$Group
W = 50788, p-value = 0.02492
alternative hypothesis: true location shift is not equal to 0


====================
Variable: Proportion_parsimony_informative 

Median Nuclear: 0.309 
Median Mito: 0.093 


	Wilcoxon rank sum test with continuity correction

data:  dataset[[v]] by dataset$Group
W = 74214, p-value < 2.2e-16
alternative hypothesis: true location shift is not equal to 0
