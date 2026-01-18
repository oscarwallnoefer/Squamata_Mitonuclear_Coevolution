# ERC

We followed the [ERCnet](https://github.com/EvanForsythe/ERCnet) pipeline. 

- [x] Phylogenomic analyses

                ./Phylogenomics.py -j OUT_p1r20 -r 20 -p 1 -l 100 -m 32 -P 0.9 -b 85 -T -o <path/to/orthofinder/results/>

- [x] Gene-tree/Species-tree reconciliation 

                ./GTST_reconciliation.py -j OUT_p1r20

- [x] ERC analysis

                ./ERC_analyses.py -j OUT_p1r20 -m 32 -b R2T -s Nnaj

- [x] Network analysis

                ./Network_analyses.py -j OUT_p1r20 -p [0.05/0.01/0.001] -r [0.4/0.5/0.6/0.7/0.8] -c spearman -m R2T -S -y fg -s Nnaj -F -L

### Output

The main output `ERC_results_R2T.tsv` contains all the combinations between each protein pair (n = 2,9). 
All the pairs involving at least one mitochondrial OXPHOS proteins are shown in `all_coevolving_mito_ERC.tsv`.

Metrics relative to sequences were compared between mtOXPHOS-first-neighbours and total nuclear proteins using: `run_compare_stats.R`.

---

# Networks

We wrote some python scripts:
+ communities identification: `run_louvain.py`
+ metrics (transitivity, edge density, mean distance, diameter): `run_metrics.py`
+ plot and gene lists: `run_communities.py` 

---

# InterProScan and GO enrichment

We used [bioKIT](https://jlsteenwyk.com/BioKIT/) to sort 2,424 orthogroups by sequence length, and we retained the longest per orthogroup. 

      biokit reorder_by_sequence_length
      for a in *ed.fa; do seqkit head -n 1 ${a} > longest_${a}; done
      cat longest_* > input_interproscan.fa

Then, we ran InterProScan as following:

      /home/PERSONALE/oscar.wallnoefer2/my_interproscan/interproscan-5.71-102.0/interproscan.sh -i input_interproscan.fasta --goterms --pathways --cpu 16 -appl PANTHER -d interproscan_output

GO background was prepared using this command: 

      cut -f 14 input_interproscan.fasta.tsv | grep GO | sed 's/(PANTHER)//g' | sed 's/(InterPro)//g' | sed 's/[|]/,/g' > GObackground.txt
      awk -F',' '{delete s; o=""; for(i=1;i<=NF;i++) if(!s[$i]++) o=(o?o","$i:$i); print o}' GObackground.txt

The file `GObackground.txt` associate 1924 proteins to GO terms. 
GO enrichment was performed in R (`GOenrichment.R`, writted by @MirkMart). 

We applied gene enrichment to multiple lists of interest extracted from ERC networks (i.e., communities, direct neighbours).

