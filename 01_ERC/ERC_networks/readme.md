### ERC networks

In this folder: 
+ `01_ERC/run_louvain.py` to identify communities using the Louvain algorithm. It will create a `Comm_Cytoscape_network[...].graphml` file.
+ `01_ERC/02_run_communities_update.py` to create scalable figures of networks (`[...]communities.svg`; could be **very** heavy), where different communities are labeled with different colors. Note: if you select the --cmap viridis option you will highlight communities with max 6 colors (but the number of communities could be much higher). For each network, the script produces also a folder (`[...]_communities_lists/`) filled with one file per community (list of nodes; i.e. `Community_1.txt`). 
+ `01_ERC/04_run_mitochondrial_highlighted.py` to create scalable figure of networks where mitochondrial genes and their first-neighbors are highlighted. It erates also 


You can have an idea about the community gene content using the `01_ERC/InterProScan_output.tsv` file.
