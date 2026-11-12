# GO enrichment scripts and plots

Biological Process plots in Fig. 2 are R scripts written starting from REVIGO output.

If you want to replicate this kind of plot: 

  1. download the scatterplot REVIGO R script from http://revigo.irb.hr/
  2. fill the "revigo.data" object into the `to_replicate_HDBSCAN.R` script, where indicated (copy and paste from REVIGO's output).
  3. modify the minPts variable where indicated, it sets the minimum number of dots considered to define a cluster.
  4. modify color, where indicated.
  5. change parameter to be used for labels, where indicated.
