#!/bin/bash

# perform AU test wrapped in IQTREE
# use as input set of alignments, and two alternative topologies.

ALN_DIR="01_pruned_2334_HOG/"
NUC_TREE="rooted_nuclear_topology.nwk"
MITO_TREE="rooted_mito_topology.nwk"

mkdir -p pruned_trees topologies 02_AU_output taxa_lists

for aln in ${ALN_DIR}/*.fa; do
    base=$(basename "$aln" .fa)
    # estract taxa from genes
    grep "^>" "$aln" | sed 's/>//' > taxa_lists/${base}.txt
    # prune trees
    phykit prune_tree "$NUC_TREE"  taxa_lists/${base}.txt -k -o pruned_trees/${base}_nuclear.nwk
    phykit prune_tree "$MITO_TREE" taxa_lists/${base}.txt -k -o pruned_trees/${base}_mito.nwk
    # create nwk topologies
    cat pruned_trees/${base}_nuclear.nwk pruned_trees/${base}_mito.nwk > topologies/${base}.nwk

    # AU test
    iqtree3 -s "$aln" -m LG+G -z topologies/${base}.nwk -n 0 -zb 10000 -au -T 20 -pre 02_AU_output/${base}
done
