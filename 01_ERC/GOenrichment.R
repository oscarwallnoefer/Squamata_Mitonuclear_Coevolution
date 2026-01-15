#go2genes = go term annotation for all genese
#list_expanded_genes.txt = list of genes of interest
#install.packages("topGO")
library(tidyverse)
library(topGO)

# the following commented passages are part of the original script from where I developed the function `GOenrichment`
gene_universe <- readMappings(file = "GOterms_all.tsv")
geneUniverse <- names(gene_universe)

genesOfInterest <- read.table("list_0.001_0.8.txt",header=FALSE)
list_interest1 <- list( "name_interest" = genesOfInterest)

################################# GO function
GOenrichment <- function(trait, trait_name) {
  if (!dir.exists("01_enrichment")) {
    dir.create("01_enrichment")
  }
  
  genesOfInterest <- as.character(trait[[1]]) #as vector not character 
  geneList <- factor(as.integer(geneUniverse %in% genesOfInterest))
  names(geneList) <- geneUniverse
  
  print(trait_name)
  
  ontology_values = c("BP", "MF", "CC")
  
  GOdata_list <- lapply(ontology_values, function(ontology_value) {
    GOdata_name <- paste("GOdata_", ontology_value, sep = "")
    # annot = annFUN.gene2GO this imparts the program which annotation it should use. In this case, it is specified that it will be in gene2GO format and provided by the user.
    # gene2GO = gene_universe is the argument used to tell where is the annotation
    assign(GOdata_name, new("topGOdata", ontology=ontology_value, allGenes=geneList, annot = annFUN.gene2GO, gene2GO = gene_universe))
  })
  
  elim_list <- lapply(seq_along(ontology_values), function(i) {
    elim_name <- paste("elim_", ontology_values[i], sep="")
    assign(elim_name, runTest(GOdata_list[[i]], algorithm="elim", statistic="fisher"))
  })
  
  results_elim <- function(GO_data, elim_data) {
    num_nodes <- min(1000, length(elim_data@score))
    resulte <- GenTable(GO_data, Classic_Fisher = elim_data,
                        orderBy = "Classic_Fisher", topNodes=num_nodes, numChar=1000)
    resulte$Classic_Fisher <- as.numeric(resulte$Classic_Fisher)
    resulte <- subset(resulte, Classic_Fisher < 0.05)
    return(resulte)
  }
  
  results_elim_list <- lapply(seq_along(ontology_values), function(i) {
    resulte_name <- paste("resulte_", ontology_values[i], sep="")
    assign(resulte_name, envir = .GlobalEnv, results_elim(GOdata_list[[i]], elim_list[[i]]))
  })
  
  write_elim_results <- function(result, ontology_value, trait_name) {
    table_name <- paste("01_enrichment/topGOe_", trait_name, "_", ontology_value, ".txt", sep="")
    write.table(result, file=table_name, quote=F, sep = "\t", row.names = F)
  }
  
  lapply(seq_along(ontology_values), function(i) {
    write_elim_results(results_elim_list[[i]], ontology_values[i], trait_name)
  })
}


#this particular syntax has been necessary since it was impossible to give the function the trait name it was computing.
GO_enrichment <- function(list) {
  lapply(seq_along(list), function(i) {
    GOenrichment(list[[i]], names(list)[i])
  })
}

#Final function to run
GO_enrichment(list_interest1)