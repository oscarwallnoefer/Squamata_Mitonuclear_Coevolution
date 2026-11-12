### ERC networks - scripts

+ `01_run_louvain.py` - identify Louvain communities. It creates `Comm_*.graphml` files.
+ `02_run_communities_update.py` - create .svg network figures, where different communities are labeled with different colors. Note: if you select the --cmap 
viridis option you will highlight communities with max 6 colors (but the number of communities could be much higher). For each network, the script produces also a 
folder (`*_communities_lists/`) where nodes are listed per community.
+ `03_run_mitochondrial_highlighted.py` - create .svg network figures where mitochondrial genes and their first-neighbors are highlighted.
+ `04_count_mito_neighbors.py` - create a .tsv file with n° of mitochondrial nodes and their neighbors per network.
+ `05_network_stats.py` - create a table of network statistics (degree, betweenness, closeness, centrality), use Comm_*.graphml as input.
+ `06_run_list_mt_neighbors.py` - create a list of mitochondrial first-neighbors for each network
+ `07_network_metrics_permutations.R` - calculate mitochondrial vs nuclear network metrics (degree, betweenness, closeness, centrality) based on 10,000 
permutations of equal sample size. It takes the output of 06_network_stats.py as input.

