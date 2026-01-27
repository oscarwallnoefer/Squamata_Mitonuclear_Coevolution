# mitonuclear discordance

---

### AU test

We used the same set of orthologs that passed Orthofinder and that was used in the first step of ERCnet (2,509 orthogroups). 
Firstly, we added the outgroup *S. punctatus*: this species was lacking in ERCnet because outgroups are excluded from the branch lenght covariations. To add it, we identified the correct paralogs using [phylopypruner](https://github.com/fethalen/phylopypruner) with these parameters (see `phylopypruner_details.txt`):

        phylopypruner --threads 12 --output 02_output_phylopypruner --mask longest --exclude Ahom Iles Tsci Eeur --min-support 100 --outgroup Spun --prune LS --subclades subclades_2.txt --no-plot --no-supermatrix --min-len 100 --dir 01_input_phylopypruner/

Then, we retained only those orthogroups with at least one reprentative for each one of the key four groups for mitonuclear discordance in Squamata: Acrodonta, Pleurodonta, Serpentes and Others (Gekkota,Anguimorpha,Laterata,Scincomorpha and S. punctatus).

        for f in trim*.fa; do grep -q -E '^(>)(Pvit|Pfor|Lsac|Pprz)\b' "$f" &&   grep -q -E '^(>)(Acar|Asag|Sund|Ppla)\b' "$f" &&   grep -q -E '^(>)(Tele|Apra|Pcat|Pgut|Nnaj|Nscu|Ptex|Ohan|Pmuc|Cada|Casp|Ereg|Pbiv)\b' "$f" &&   grep -q -E '^(>)(Emac|Stow|Hbin|Gjap|Praf|Zviv|Lagi|Vkom|Ledw|Spun)\b' "$f" &&   echo "$f";  done > list_to_be_kept.txt

The number of orthologs decreased from 2,509 to 2,353. 

Then, we exluded mtOXPHOS from the gene dataset for the AU test. 

The number of orthologs decreased from 2,353 to 2,342. 

Here, we realigned sequences: 

        for a in HOG*; do mafft --maxiterate 1000 --localpair ${a} > aln_${a}; done  

and softly trimmed: 

        for a in aln_HOG00*; do trimal -seqoverlap 50 -resoverlap 0.5 -in $a -out trim_${a}; done 
        
We re-check the species-per-clade and the number of orthologs decreased from 2,342 to 2,334. The lowest number of species per orthogrups is 15/31.  

Thus, after the last trimming, the gene dataset rested to 2,334, entirely composed of a ERCnet orthogroups subset.

Each of 2,334 proteins were used as input for AU test, where we compared the topological preference towards the nuclear-based tree (`nuclear_markers.treefile`) or the mitochondrial-based tree (`mitochondrial_markers.treefile`). The unique difference among the two topologies concerns the sister relationship Acrodonta+Serpentes, that typically chareacterized the mitonuclear phylogenetic discordance in Squamata.

Orthologs, their gene models and the two alternative topologies were used as follow to perform the AU test:

        iqtree -s [ortholog].fa -m [model] -z topologies.nwk -n 0 -zb 10000 -au -T 32 -pre TEST_[ortholog].fa

The script to integrate this command is here: `run_AU.sh`

Results were summarized here: `AU_test_summary.tsv`.

Plot and stats were calculated on R: `ÀUtest_squamata.R`.

---

### Mitochondrial and nuclear tree inference

+ the **mitochondrial-based tree** was a maximum likelihood tree using the 13 mtOXPHOS from 31 species (partition models).

        for a in HOG*; do mafft --maxiterate 1000 --localpair ${a} > aln_${a}; done  
        for a in aln_HOG00*; do trimal -automated1 -in $a -out trim_${a}; done 
        iqtree -s concatenated.out -p partitions.txt -m MFP+MERGE -b 100 -T 16 -pre ML_mitochondrial_squamata
        pwd: /home/PERSONALE/oscar.wallnoefer2/MPMR_Squamata/00_database/mtOXPHOS/all/01_ML

+ the **nuclear-based tree** derived from a subset of orthologs composed of those genes with the same 31 species as in the mitochondrial dataset. It resulted in 681 orthologs (we excluded the mtXPHOS from this gene dataset). 

        for a in HOG*; do mafft --maxiterate 1000 --localpair ${a} > aln_${a}; done  
        for a in aln_HOG00*; do trimal -gappyout -in $a -out trim_${a}; done       
        iqtree -s concatenated_681HOG.out -p partitions_681HOG.txt -m MFP+MERGE -B 1000 -T 16 -pre ML_speciestree_squamata
        pwd: /home/PERSONALE/oscar.wallnoefer2/MPMR_Squamata/03_Evolutionary_Rates_Covariation_Squamata/AUtest/01_AUtest/02_output_phylopypruner/phylopypruner_output/new_species_tree/outgroup

---

### Concordance Factors

We performed gene trees for all the 2,334 nuclear orthologs and for 13 mtOXPHOS using the following command:

        for a in *.fa; do iqtree3 -s ${a} -m MFP -mset LG -B 1000 -T 16; done 

The R script to plot concordance factors ratio is `CF.R`.



---

### GO terms

We applied the script `GOenrichment.R`(@MirkMart), as done in 01_ERC/.


