#!/usr/bin/env python3

## Starting from .graphml, highlight communities with >= 10 nodes, grey the remainings.
## Adds legend and saves lists of genes (key d0) for each community.
## Improved layout for large networks with slight random offset per community.
## Allows colormap selection via --cmap (default: nipy_spectral)
## Usage: python script.py file.graphml [--cmap viridis]

import argparse
import networkx as nx
import matplotlib.pyplot as plt
from matplotlib.patches import Patch
from collections import Counter
import os
import numpy as np

parser = argparse.ArgumentParser(description="Highlight communities in .graphml")
parser.add_argument("input_file")
parser.add_argument("--cmap", default="nipy_spectral", help="select colormap matplotlib (default = nipy_spectral)")
args = parser.parse_args()

input_file = args.input_file
basename = os.path.splitext(os.path.basename(input_file))[0]

# load graph
print(f"Loading: {input_file}")
G = nx.read_graphml(input_file)

sample_node = list(G.nodes(data=True))[0]
print("Example features node:", sample_node[1])

# attributes
community_attr = "community"
key_d0 = "name"

communities = {n: d.get(community_attr, "0") for n, d in G.nodes(data=True)}

# analysis community
comm_counts = Counter(communities.values())
unique_comms = sorted(comm_counts.keys())

print("single community:", unique_comms)
print("total n° community:", len(unique_comms))

# select number of nodes to define community (≥10 nodi)
color_comms = [c for c in unique_comms if comm_counts[c] >= 10]
print("Community with >= 10 nodes:", len(color_comms))

# extract gene lists per community
output_dir = f"{basename}_communities_lists"
os.makedirs(output_dir, exist_ok=True)

print(f"writing genes in: {output_dir}/")

for comm in unique_comms:
    outfile = os.path.join(output_dir, f"community_{comm}.txt")
    genes = []

    for n, data in G.nodes(data=True):
        if communities[n] == comm:
            genes.append(data.get(key_d0, "NA"))

    genes = sorted(genes)

    with open(outfile, "w") as f:
        for g in genes:
            f.write(str(g) + "\n")

print("gene list written.")

# colors
color_map = {comm: i for i, comm in enumerate(color_comms)}
cmap = plt.cm.get_cmap(args.cmap, len(color_comms))

# plot layout
n_nodes = G.number_of_nodes()
pos = nx.spring_layout(G, seed=1233, k=1/np.sqrt(n_nodes), iterations=100)

# for each comm., add noise around the center
for comm in color_comms:
    nodes_comm = [n for n in G.nodes() if communities[n] == comm]
    if len(nodes_comm) <= 1:
        continue
    # define centers
    center = np.mean([pos[n] for n in nodes_comm], axis=0)
    for n in nodes_comm:
        pos[n] = center + np.random.normal(scale=0.1, size=2)

# general plot borders
plt.figure(figsize=(20, 20))

# highlight nodes and feat.
colored_nodes = [n for n in G.nodes() if communities[n] in color_map]
nx.draw_networkx_nodes(
    G, pos,
    nodelist=colored_nodes,
    node_color=[color_map[communities[n]] for n in colored_nodes],
    cmap=cmap,
    node_size=200,
    alpha=0.7,
    vmin=0,
    vmax=len(color_comms)-1
)

# small communities (grey)
gray_nodes = [n for n in G.nodes() if communities[n] not in color_map]
nx.draw_networkx_nodes(
    G, pos,
    nodelist=gray_nodes,
    node_color="darkgrey",
    node_size=200,
    alpha=1
)

# Edges
nx.draw_networkx_edges(G, pos, alpha=0.05)

plt.title(f"Network: {basename}")
plt.axis('off')

# legend
legend_elements = []
for comm in color_comms:
    idx = color_map[comm]
    color = cmap(idx)
    legend_elements.append(
        Patch(facecolor=color, edgecolor='black',
              label=f"Community {comm} (n={comm_counts[comm]})")
    )

plt.legend(handles=legend_elements,
           title="Comunity (>=10 nodes)",
           loc="upper right",
           fontsize=8, title_fontsize=9)

# save
output_image = f"{basename}_communities.svg"
plt.savefig(output_image)
print(f"Plot saved: {output_image}")

