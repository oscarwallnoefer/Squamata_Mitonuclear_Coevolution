import networkx as nx
import os
from collections import Counter

output_file = "mito_neighbor_summary.tsv"

with open(output_file, "w") as out:
    out.write("File\tMito_nodes\tMito_neighbors\n")

    for file in os.listdir("."):
        if file.endswith(".graphml"):

            try:
                G = nx.read_graphml(file)
            except Exception as e:
                print(f"Error loading {file}: {e}")
                continue

            # Identify mitochondrial nodes
            mito_nodes = []
            for n, d in G.nodes(data=True):
                cat = d.get('v_Functional_category') or d.get('Functional_category') or ''
                if isinstance(cat, str) and cat.lower() == 'mitochondria':
                    mito_nodes.append(n)

            # Direct neighbors
            neighbor_nodes = set()
            for n in mito_nodes:
                neighbor_nodes.update(G.neighbors(n))

            neighbor_nodes -= set(mito_nodes)

            out.write(f"{file}\t{len(mito_nodes)}\t{len(neighbor_nodes)}\n")

            print(f"{file}: {len(mito_nodes)} mt nodes, {len(neighbor_nodes)} neighbors")

print(f"\nSummary written to {output_file}")

