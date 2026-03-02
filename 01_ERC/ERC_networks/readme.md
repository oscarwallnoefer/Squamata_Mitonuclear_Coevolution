### ERC networks

+ `Cytoscape_network...` are the original .graphml file produced by ERCnet
+ `Comm_Cytoscape_network...` contain community annotations.
+ `...communities.svg` are the scalable (could be **very** heavy) figures of networks, where different communities are labeled with different colors.
  Note: I ran the script 02_run_communities_update.py using the --cmap viridis: this option highlight communities with only 6 colors, but the number of communities could be much more higher. For each *.svg file, the script produces also a folder () filled with one file per community (list of nodes). You can have an idea of the community-content using the InterProScan_output.tsv file. 

