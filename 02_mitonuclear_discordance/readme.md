# mitonuclear discordance

### Mitochondrial and nuclear tree inference

+ the **mitochondrial-based tree** was a maximum likelihood tree using the 13 mtOXPHOS from 31 species (partition models).

        for a in HOG*; do mafft --maxiterate 1000 --localpair ${a} > aln_${a}; done  
        for a in aln_HOG00*; do trimal -automated1 -in $a -out trim_${a}; done 
        iqtree -s concatenated.out -p partitions.txt -m MFP+MERGE -b 100 -T 16 -pre ML_mitochondrial_squamata

+ the **nuclear-based tree** was a maximum likelihood tree using a subset of single-copy orthologs present in all 31 species (681 orthogroups).

        for a in HOG*; do mafft --maxiterate 1000 --localpair ${a} > aln_${a}; done  
        for a in aln_HOG00*; do trimal -gappyout -in $a -out trim_${a}; done       
        iqtree -s concatenated_681HOG.out -p partitions_681HOG.txt -m MFP+MERGE -B 1000 -T 16 -pre ML_speciestree_squamata

---

### Concordance Factors

We performed gene trees for all the 2,334 nuclear orthologs and for 13 mtOXPHOS using the following command:

        for a in *.fa; do iqtree3 -s ${a} -m MFP -mset LG -B 1000 -T 16; done 

**sCF and gCF**

        iqtree3 -te ML_speciestree_squamata.treefile -s concatenated_681HOG.out --scfl 1000        
        iqtree3 -te speciestree_ML.treefile --gcf ../06_astral/input_astral.treefile --prefix gCF

The R script to plot concordance factors ratio is `CF.R`.

---

### AU test

We used the same set of orthologs that passed Orthofinder and that was used in the first step of ERCnet. 
Firstly, we added the outgroup *S. punctatus*: this species was lacking in ERCnet because outgroups are excluded from the branch lenght covariations. To add it, we identified the correct paralogs using [phylopypruner](https://github.com/fethalen/phylopypruner) with these parameters (see `phylopypruner_details.txt`):

        phylopypruner --threads 12 --output 02_output_phylopypruner --mask longest --exclude Ahom Iles Tsci Eeur --min-support 100 --outgroup Spun --prune LS --subclades subclades_2.txt --no-plot --no-supermatrix --min-len 100 --dir 01_input_phylopypruner/

Then, we retained only those orthogroups with at least one reprentative for each one of the key four groups for mitonuclear discordance in Squamata: Acrodonta, Pleurodonta, Serpentes and Others (Gekkota,Anguimorpha,Laterata,Scincomorpha and S. punctatus).

        for f in trim*.fa; do grep -q -E '^(>)(Pvit|Pfor|Lsac|Pprz)\b' "$f" &&   grep -q -E '^(>)(Acar|Asag|Sund|Ppla)\b' "$f" &&   grep -q -E '^(>)(Tele|Apra|Pcat|Pgut|Nnaj|Nscu|Ptex|Ohan|Pmuc|Cada|Casp|Ereg|Pbiv)\b' "$f" &&   grep -q -E '^(>)(Emac|Stow|Hbin|Gjap|Praf|Zviv|Lagi|Vkom|Ledw|Spun)\b' "$f" &&   echo "$f";  done > list_to_be_kept.txt

Then, we realigned sequences: 

        for a in HOG*; do mafft --maxiterate 1000 --localpair ${a} > aln_${a}; done  

and softly trimmed: 

        for a in aln_HOG00*; do trimal -seqoverlap 50 -resoverlap 0.5 -in $a -out trim_${a}; done 
        
We re-check the species-per-clade and the number of orthologs decreased to 2,334 genes.

Each of 2,334 proteins were used as input for AU test, where we compared the topological preference towards the nuclear-based tree or the mitochondrial-based tree. The unique difference among the two topologies concerns the sister relationship Acrodonta+Serpentes, that typically chareacterized the mitonuclear phylogenetic discordance in Squamata. 

The two topologies must be pruned to contain the same OTUs. For each ortholog, its gene model and the two alternative topologies were used as follow to perform the AU test:

        iqtree -s [ortholog].fa -m [model] -z topologies.nwk -n 0 -zb 10000 -au -T 32 -pre TEST_[ortholog].fa

The script to integrate these commands is here `run_AU.sh`, which require alignment files and the two alternative topologies. Extract results with `run_AU_result_extraction.sh`. 
To replicate AU plot: `run_AU_lolliplot.R`.