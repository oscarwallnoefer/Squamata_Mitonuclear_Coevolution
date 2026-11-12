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

See 01_ERC/ for scritps.
  
---

# InterProScan and GO enrichment background

We used [bioKIT](https://jlsteenwyk.com/BioKIT/) to sort 2,424 orthogroups by sequence length, and we retained the longest per orthogroup. 

      for a in *; do biokit reorder_by_sequence_length ${a}; done 
      for a in HOG*reordered.fa; do seqkit head -n 1 ${a} > longest_${a}; done
      cat longest_* > input_interproscan.fa

Then, we ran InterProScan 5.7 as following:

      /path/to/interproscan-5.71-102.0/interproscan.sh -i input_interproscan.fasta --goterms --pathways --cpu 16 -appl PANTHER -d interproscan_output

GO background was prepared using this command: 

      cut -f 1,14 input_interproscan.fasta.tsv | grep GO | sed 's/(PANTHER)//g' | sed 's/(InterPro)//g' | sed 's/[|]/,/g' > GObackground.txt
      awk -F'\t' '{split($2,g,","); delete s; o=""; for(i in g) if(!s[g[i]]++) o=(o?o","g[i]:g[i]); print $1 "\t" o}' GObackground.txt
      awk -F "__" '{print$3}' GObackground.txt

 See enrichment/ to replicate HDBSCAN.R.
