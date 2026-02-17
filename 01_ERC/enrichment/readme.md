# GO enrichment scripts and plots

Biological process plots in Fig. 1,2 and 3 are R scripts written starting from Revigo's output.

If you want to replicate this kind of plot: 

  1. download the scatterplot Revigo R script
  2. copy and paste the "revigo.data" object into the `to_replicate_HDBSCAN.R` script, where indicated.
  3. modify the minPts variable where indicated, it sets the minimum number of dots considered to define a cluster.
  4. modify color, where indicated.
  5. change parameter to be used for labels, where indicated.
