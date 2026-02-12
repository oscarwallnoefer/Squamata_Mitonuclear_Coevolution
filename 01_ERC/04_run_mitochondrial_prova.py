## Highlight mitochondrial nodes and their first neighbors
## usage: python script.py file.graphml

import argparse
import networkx as nx
import matplotlib.pyplot as plt
import os
import sys
import numpy as np
from collections import Counter

def main():
    parser = argparse.ArgumentParser(description="Highlight mitochondrial nodes and direct neighbors in .graphml")
    parser.add_argument("input_file", help="Path .graphml")
    args = parser.parse_args()

    input_file = args.input_file
    if not os.path.isfile(input_file):
        print(f"'{input_file}' missing", file=sys.stderr)
        sys.exit(1)

    basename = os.path.splitext(os.path.basename(input_file))[0]

    print(f"loading: {input_file}")
    try:
        G = nx.read_graphml(input_file)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    n_nodes = G.number_of_nodes()
    pos = nx.spring_layout(G, seed=1233, k=1/np.sqrt(n_nodes), iterations=100)
    community_attr = "community"
    communities = {n: d.get(community_attr, "0") for n, d in G.nodes(data=True)}
    comm_counts = Counter(communities.values())
    unique_comms = sorted(comm_counts.keys())
    color_comms = [c for c in unique_comms if comm_counts[c] >= 10]
    np.random.seed(1233)

    for comm in color_comms:
        nodes_comm = [n for n in G.nodes() if communities[n] == comm]
        if len(nodes_comm) <= 1:
            continue

        center = np.mean([pos[n] for n in nodes_comm], axis=0)
        for n in nodes_comm:
            pos[n] = center + np.random.normal(scale=0.1, size=2)
# Identify mt nodes through functional category
    mito_nodes = []
    for n, d in G.nodes(data=True):
        cat = d.get('v_Functional_category') or d.get('Functional_category') or ''
        if isinstance(cat, str) and cat.lower() == 'mitochondria':
            mito_nodes.append(n)

    print(f"found {len(mito_nodes)} mt nodes")

    # identify direct mitochondrial neighbors
    neighbor_nodes = set()
    for n in mito_nodes:
        neighbor_nodes.update(G.neighbors(n))
    neighbor_nodes = neighbor_nodes - set(mito_nodes)

    print(f"found {len(neighbor_nodes)} mt neighbors")

    node_colors = []
    for node in G.nodes():
        if node in mito_nodes:
            node_colors.append('red')
        elif node in neighbor_nodes:
            node_colors.append('orange')
        else:
            node_colors.append('steelblue')

    plt.figure(figsize=(20, 20))

    nx.draw_networkx_nodes(
        G, pos,
        nodelist=list(G.nodes()),
        node_color=node_colors,
        node_size=200,
        alpha=1.0
    )

    nx.draw_networkx_edges(G, pos, alpha=0.12)

    # mitochondrial labels
    mito_labels = {}
    for n in mito_nodes:
        d = G.nodes[n]
        label = d.get('Node_labels')
        if label is None or label == 'NA':
            label = d.get('Comprehensive_ID', n)
        mito_labels[n] = label

    nx.draw_networkx_labels(G, pos, labels=mito_labels,
                            font_size=20, font_color='black')

    plt.title("Mitochondrial Nodes and Direct Neighbors Highlighted")
    plt.axis('off')
    plt.tight_layout()

    output_image = f"{basename}_mitochondrial_highlighted.svg"
    plt.savefig(output_image)


if __name__ == "__main__":
    main()
