#!/bin/bash

# Variables
INPUT="uniprot_proteome_moouse.fasta"
OUTPUT="cleaned_before_dedup.fasta"
GENES_NOT_UNIQUE="genes_not_unique"
GENES_UNIQUE="genes_unique"

# Functions

# This function counts ids in the input file
count_ids() {
  grep -c "^>" "$INPUT"
}

# This function linearizes the fasta input
linearize_fasta() {
  awk '/^>/ {printf("%s%s\n",(N>0?"\n":""),$0);N++;next;}
     {printf("%s",$0);}
  END  {printf("\n");}' < "$INPUT" > lin_"$INPUT"
}

# This function prepares sequences, removes sequences without GN ids, uncharacterized and fragmented sequences.
prepare_sequences() {
  # Your implementation goes here
}

# Call the functions

count_ids
linearize_fasta
prepare_sequences
# etc...

