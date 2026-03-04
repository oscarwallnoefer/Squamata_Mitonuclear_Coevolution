# ERC

We followed the [ERCnet](https://github.com/EvanForsythe/ERCnet) pipeline (Forsythe et al. 2025). 

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
+ plot and gene lists: `02_run_communities_update.py`
+ stats per network: `Network_stats.csv`
+ plot with mitochondrial first-neighbors highlighted: `04_run_mitochondrial_highlighted.py`
+ table network/mito_nodes/mito_neighbors/: `05_count_mito_neighbors.py`
+ n° of mitochondrial genes and mt first-neighbors per network: `mito_neighbor_summary.tsv`
+ table network statistics (degree, betweenness, closeness, centrality): `Comm_Cytoscape_network_Filtered_ERC_results_R2T_spearman_0.05_0.4_FDR_fg_trimcutoff_0_centralities.csv`, obtained using `06_network_stats.py`
+ Calculate mitochondrial metrics into networks (first version based on Wilcoxon test): `network_mitochondrial_metrics_1.R` (results are inside the script)
+ Calculate mitochondrial metrics into networks (second version based on permutation test): `network_mitochondrial_metrics_2.R` (results in `network_permutation.tsv`)
+ `07_run_list_mt_neighbors.py` to create a list of mitochondrial first-neighbors for each network (see head for usage)
  
---

# InterProScan and GO enrichment

We used [bioKIT](https://jlsteenwyk.com/BioKIT/) to sort 2,424 orthogroups by sequence length, and we retained the longest per orthogroup. 

      for a in *; do biokit reorder_by_sequence_length ${a}; done 
      for a in HOG*reordered.fa; do seqkit head -n 1 ${a} > longest_${a}; done
      cat longest_* > input_interproscan.fa

Then, we ran InterProScan as following:

      /home/PERSONALE/oscar.wallnoefer2/my_interproscan/interproscan-5.71-102.0/interproscan.sh -i input_interproscan.fasta --goterms --pathways --cpu 16 -appl PANTHER -d interproscan_output

GO background was prepared using this command: 

      cut -f 1,14 input_interproscan.fasta.tsv | grep GO | sed 's/(PANTHER)//g' | sed 's/(InterPro)//g' | sed 's/[|]/,/g' > GObackground.txt
      awk -F'\t' '{split($2,g,","); delete s; o=""; for(i in g) if(!s[g[i]]++) o=(o?o","g[i]:g[i]); print $1 "\t" o}' GObackground.txt
      awk -F "__" '{print$3}' GObackground.txt

**Summary**

+ 2,424 rows in ERC_results.tsv # number of proteins for ERC
+ 2,403 rows in input_interproscan_HOG.tsv # number of HOGs successfully annotated by InterProScan
+ 1,924 rows in GObackground.txt # number of HOGs with GO terms association

The file `GObackground.txt` associate 1,924 proteins to GO terms. We created a background specific for each network, subsampling Gobackground.txt. 
GO enrichment was performed in R (`GOenrichment.R`, writted by @MirkMart). 

We applied gene enrichment to multiple lists of interest extracted from ERC networks (i.e., communities, direct neighbours). Results were visualized in Revigo.

---

# Alignment statistics
  pwd:/home/PERSONALE/oscar.wallnoefer2/MPMR_Squamata/03_Evolutionary_Rates_Covariation_Squamata/ERCnet/OUT_p1_r20/01_InterProScan/00_alignment_statistics

We used AMAS to calculate assembly statistics on the 2,424 trimmed alingments.

    AMAS.py summary -i GB_* -f fasta -d aa 

and visualized on R (`run_compare_stats.R`).
