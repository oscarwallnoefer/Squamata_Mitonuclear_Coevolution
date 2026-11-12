## Giorgia
## Estract mt genes and first neighbors from Comm[...].graphml file; save the list in a .txt file
## usage: python script.py file.graphml -o output.txt

import networkx as nx
import argparse

parser = argparse.ArgumentParser(description="Identify mt genes and first neighbors")
parser.add_argument("graphml_file", help="File .graphml in input")
parser.add_argument("-o", "--output", default="mito_gene_list.txt")
args = parser.parse_args()

G = nx.read_graphml(args.graphml_file)

with open(args.output, "w", encoding="utf-8") as f:
    for node in G.nodes():
        if G.nodes[node].get('Functional_category', '').lower() == 'mitochondria':
            comp_id = G.nodes[node].get('Comprehensive_ID', 'NA').replace('Nnaj__', '')
            hog_id = G.nodes[node].get('name', node)
            mito_gene = f"{hog_id} | {comp_id}"

            neighbors = list(G.neighbors(node))
            neighbor_names = [G.nodes[n].get('name', n) for n in neighbors]
            f.write(f"{mito_gene}:\n")
            for n in neighbor_names:
                f.write(f"  - {n}\n")
            f.write("\n")

print(f"Saved in: {args.output}")
