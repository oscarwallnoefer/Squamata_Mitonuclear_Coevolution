#!/usr/bin/env python3
# calculate network metrics and create a .csv fle for R analysis. Mitochondrial genes are labeled as "true" in the csv file (column "Mito").

import sys
import networkx as nx
import pandas as pd

# help
if len(sys.argv) < 2:
    print("Usage: python network_centrality_analysis.py network.graphml")
    sys.exit(1)

graph_file = sys.argv[1]

# define mt genes
mito_genes = ["COX1","COX2","COX3","ATP6","NADH1","NADH2","NADH4","NADH5","NADH6","CYTB"]

# load graph
G = nx.read_graphml(graph_file)

# calculate centrality
centralities = {
    'degree': nx.degree_centrality(G),
    'betweenness': nx.betweenness_centrality(G),
    'closeness': nx.closeness_centrality(G),
    'eigenvector': nx.eigenvector_centrality(G),
    'core': nx.core_number(G)
}

# df creation
nodes = []
for n in G.nodes():
    node_label = G.nodes[n].get('Node_labels')
    if node_label is None or node_label == 'NA':
        node_label = G.nodes[n].get('name')
    nodes.append({
        'Node': n,
        'Label': node_label,
        'Community': G.nodes[n].get('community', None)
    })

df = pd.DataFrame(nodes)
# add centralities
for key, val in centralities.items():
    df[key] = df['Node'].map(val)

# labels for mt genes
df['Mito'] = df['Label'].isin(mito_genes)

# save csv for R
output_file = graph_file.replace('.graphml', '_centralities.csv')
df.to_csv(output_file, index=False)

