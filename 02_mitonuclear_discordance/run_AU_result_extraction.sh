#!/bin/bash

# Output file
out="AU_test_summary.tsv"

# Loop *iqtree
for file in *.iqtree; do
    # gene name btwn "TEST_" and ".iqtree"
    gene=$(basename "$file" .iqtree | sed 's/^TEST_//')

    # last rows after "deltaL"
    grep -A3 " deltaL " "$file" | tail -n2 | while read -r line; do
        echo -e "$gene\t$line" >> "$out"
    done
done
