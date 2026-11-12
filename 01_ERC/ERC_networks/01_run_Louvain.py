## Load file .graphml, find communities through Louvain and label as 'community' each node within a community. Save as .graphml.
## usage: python script_louvain.py file.graphml output.graphml

import networkx as nx
import matplotlib.pyplot as plt
import community as community_louvain
import sys

def rileva_comunita(file_input, file_output=None, visualizza=False):
# load graph and detect communities
    G = nx.read_graphml(file_input)
    partition = community_louvain.best_partition(G)
    # add labels
    nx.set_node_attributes(G, partition, "community")
    # save as
    if file_output:
        nx.write_graphml(G, file_output)
    if visualizza:
        pos = nx.spring_layout(G, seed=42, k=0.2)
        colors = [partition[n] for n in G.nodes()]
        nx.draw(G, pos, node_color=colors, with_labels=False, node_size=50, cmap=plt.cm.tab20)
        plt.show()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("usage: python detect_communities.py input.graphml [output.graphml] [--show]")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 and not sys.argv[2].startswith('--') else None
    show_flag = '--show' in sys.argv
    rileva_comunita(input_file, output_file, show_flag)
