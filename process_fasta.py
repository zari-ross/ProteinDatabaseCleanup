from Bio import SeqIO
import sys

def get_gene_name(header):
    gn_index = header.find('GN=')
    if gn_index != -1:
        gn_index += 3
        gene_name = ""
        while header[gn_index] != ' ' and gn_index < len(header):
            gene_name += header[gn_index]
            gn_index += 1
        return gene_name
    else:
        return None

def process_fasta(input_fasta, output_fasta):
    seq_dict = {}
    for seq_record in SeqIO.parse(input_fasta, "fasta"):
        gene_name = get_gene_name(seq_record.description)
        if gene_name is not None:
            if gene_name not in seq_dict:
                seq_dict[gene_name] = (seq_record, seq_record.id)
                #print(f"Added {gene_name} with id {seq_record.id}")
            else:
                existing_seq, existing_id = seq_dict[gene_name]
                new_seq = seq_record

                # If the new sequence is SwissProt and the existing is not, or the new sequence is longer
                if ((new_seq.id.startswith('sp|') and not existing_id.startswith('sp|')) or
                        (new_seq.id[:2] == existing_id[:2] and len(new_seq.seq) > len(existing_seq.seq))):
                    #print(f"Replacing {gene_name} with id {existing_id} by {new_seq.id}")
                    seq_dict[gene_name] = (new_seq, new_seq.id)

    with open(output_fasta, "w") as output_handle:
        for seq in seq_dict.values():
            SeqIO.write(seq[0], output_handle, "fasta")

# Use the function
process_fasta(sys.argv[1], sys.argv[2])

