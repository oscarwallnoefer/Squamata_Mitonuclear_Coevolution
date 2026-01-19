# mitonuclear_discordance

---

### AU test

We used the same set of orthologs as in ERCnet. Firstly, we added the outgroup *S. punctatus*: this species is lacking is ERCnet because outgroups are excluded from the branch lenght covariations. To add it, we identified the correct paralogs using [phylopypruner](https://github.com/fethalen/phylopypruner) with default parameters.

        phylopypruner --threads 12 --output output_phylopypruner --no-plot --no-supermatrix --dir 01_input_phylopypruner/ --min-taxa 20

Once retrieved the correct paralog for *S. punctatus* for each ortholog, we filtered out all the orthologs without *S. punctatus*, that served as outgroup. The number of orthologs decreased from 2,516 to 2,175.

Each of 2,175 proteins were used as input for AU test, where we compared the topological preference towards the nuclear-based tree or the mitochondrial-based tree.

All orthologs (both mitochondrial and nuclear proteins) were aligned using MAFFT (--maxiterate 1000 --localpair), and trimmed using TrimAl (-automated1). 
For each of the 1,175 alignments, we calculated gene trees as follow:

        iqtree -s trim_aln_[ortholog] -m MFP -B 1000 -T 16

Gene models are stored in `gene_models.tsv`.

The two alternative topologies were created as follows:
+ the **mitochondrial-based tree** (`mitochondrial_markers.treefile`) was a maximum likelihood tree using the 13 mtOXPHOS from 31 species (partition models).

        iqtree -s concatenated.out -p partitions.txt -m MFP+MERGE -b 100 -T 16 -pre ML_mitochondrial_squamata
        pwd: /home/PERSONALE/oscar.wallnoefer2/MPMR_Squamata/00_database/mtOXPHOS/all/01_ML

+ the **nuclear-based tree** (`nuclear_markers.treefile`) derived from a subset of orthologs composed of those genes with the same 31 species as in the mitochondrial dataset. It resulted in 681 orthologs (we excluded the mtXPHOS from this gene dataset). 
      
        iqtree -s concatenated_681HOG.out -p partitions_681HOG.txt -m MFP+MERGE -B 1000 -T 16 -pre ML_speciestree_squamata
        pwd: /home/PERSONALE/oscar.wallnoefer2/MPMR_Squamata/03_Evolutionary_Rates_Covariation_Squamata/AUtest/01_AUtest/02_output_phylopypruner/phylopypruner_output/new_species_tree/outgroup

Orthologs, their gene models and the two alternative topologies (nuclear and mitochondrial) were used as follow to perform the AU test:

        iqtree -s [ortholog].fa -m [model] -z topologies.nwk -n 0 -zb 10000 -au -T 32 -pre TEST_[ortholog].fa

Results were summarized here: `AU_test_summary.tsv`.

---

### Concordance Factors

The R script to plot concordance factors ratio is `CF.R`.



---

### GO terms

We applied the script `GOenrichment.R`(@MirkMart), as done in 01_ERC/.


