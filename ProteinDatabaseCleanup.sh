#!/bin/bash

# cd /mnt/c/Users/NITru/OneDrive/Documents/PhD_work/Projects/NT_projects/ProteinDatabaseCleanup/MouseProteomeCleanup

# Variables
INPUT="cleaned_before_dedup.fasta"
OUTPUT_DEDUP="deduped.fasta"
OUTPUT="cured_mouse_database.fasta"
LOG_FILE="sequence_counts.log"
REMOVED="removed_sequences.fasta"

# Get the start time
START_TIME=$(date +%s)
echo "Script started at $(date)" >> "$LOG_FILE"

# Functions

# This function counts ids in the input file and logs the count
log_counts() {
  local count=$(grep -c "^>" "$1")
  echo "$2: $count" >> "$LOG_FILE"
}

# This function linearizes the fasta input and prints to stdout
linearize_fasta() {
  awk '/^>/ {printf("%s%s\n",(N>0?"\n":""),$0);N++;next;}
     {printf("%s",$0);}
  END  {printf("\n");}' < "$1"
}

# This function prepares sequences, removes sequences 
# without GN ids OR uncharacterized OR fragmented sequences
# OR sequences from pseudogenes.
# It also logs sequences that were removed.
prepare_sequences() {
  local lin_fasta_file=$(mktemp)
  linearize_fasta "$1" > "$lin_fasta_file"
  awk 'BEGIN {RS = ">" ; FS = "\n" ; ORS = ""} 
       $2 !~ /GN=|[uU]ncharacterized|(Fragment)|pseudogene/ && length($2) > 50 {print ">"$0 > "'"$2"'";}
       $2 ~ /GN=|[uU]ncharacterized|(Fragment)|pseudogene/ || length($2) <= 50 {print ">"$0 > "'"$3"'";}' "$lin_fasta_file"
  rm "$lin_fasta_file"
}

sort_sequences_by_length() {
  local input_fasta=$1
  local output_fasta=$2

  # This transforms the FASTA file so that each sequence is on a single line, prefixed by the header
  # Then, it adds sequence length at the beginning of each line
  # Finally, it sorts the sequences by length in reverse order (longest first) and removes the lengths
  awk '/^>/ {printf("%s%s\t",(N>0?"\n":""),$0);N++;next;} {printf("%s",$0);}' "$input_fasta" |\
  awk -F '\t' '{printf("%d\t%s\n",length($2),$0);}' |\
  sort -k1,1nr | cut -f 2- | tr "\t" "\n" > "$output_fasta"
}

deduplicate_sequences() {
  local fasta_file=$1
  local dedup_file=$2
  
  # Sort sequences by length, SwissProt, and then gene name
  local sorted_file=$(mktemp)
  sort_fasta_by_gene "$fasta_file" "$sorted_file"
  
  # Initialize previous gene name
  local prev_gene=""
  
  # Get total number of lines (for progress bar)
  local total_lines=$(wc -l < "$sorted_file")
  local line_counter=0
  
  # Process sorted sequences
  while IFS= read -r line; do
    # Extract gene name from the current sequence
    local current_gene=$(echo "$line" | awk -F '|' '{print $5}')
    
    # If the current gene is different from the previous gene, this is a new group
    if [[ "$current_gene" != "$prev_gene" ]]; then
      # Select the sequence and append it to the output file
      echo "$line" >> "$dedup_file"
      
      # Update the previous gene name
      prev_gene="$current_gene"
    fi
    
    # # Update progress bar
    # line_counter=$((line_counter+1))
    # if ((line_counter % 1000 == 0)); then
    #   echo -ne "Progress: $((100*line_counter/total_lines))%\r"
    # fi
  done < "$sorted_file"
  echo  # Move to the new line after the progress bar
  
  rm "$sorted_file"
}

# Call the functions
log_counts "$INPUT" "Original count"
prepare_sequences "$INPUT" "$OUTPUT" "$REMOVED"
log_counts "$OUTPUT" "Count after cleaning"
log_counts "$REMOVED" "Count of removed sequences"
deduplicate_sequences "$OUTPUT" "$OUTPUT_DEDUP" "$REMOVED_DEDUP"
log_counts "$OUTPUT_DEDUP" "Count after deduplication"
log_counts "$REMOVED_DEDUP" "Count of removed sequences in deduplication"

# Copy the deduplicated sequences to the final output
cp "$OUTPUT_DEDUP" "$OUTPUT"
log_counts "$OUTPUT" "Final count"

# Get the end time and calculate the duration
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
echo "Script ended at $(date)" >> "$LOG_FILE"
echo "Execution time: $DURATION seconds" >> "$LOG_FILE"