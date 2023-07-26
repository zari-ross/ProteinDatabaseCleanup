# Protein Database Cleanup

This project contains a set of scripts used to process and clean up protein databases for proteomics experiments. The main objective is to select the longest or most prevalent isoforms from protein databases, minimize overlap in proteins, and avoid multiple mappings for peptides, hence improving the accuracy and effectiveness of proteomic analysis.

The main script, ProteinDatabaseCleanup.sh, works by linearizing the sequences, removing sequences without GN ids, uncharacterized and fragmented sequences. 
1) The resulting sequences are unique by gene names (identified by the pattern following GN=).
2) If there are multiple sequences with the same gene name, the following priority order should be used to select one:
        1) The sequence from the SwissProt database is preferred.
        2) If multiple sequences from SwissProt exist, the longest should be chosen.
        3) If no sequence from SwissProt exists, but there are sequences from TrEMBL, the longest should be chosen.

Modifications of the script can include maintaining a certain level of sequence diversity in the dataset and keeping sequences that are less than 90% similar:
    t_coffee -other_pg seq_reformat -in inter_out_deleted_empty_lines -action +trim _seq_%%90_ >> deduped.fasta

However, our goal is to minimize redundancy and keep only unique representative sequences per gene, so we are selecting the longest sequence per gene as per the database priority.

How to Use:

    Download the latest Uniprot entries for the selected organism. Download all in fasta (gz-archive), do not include multiple isoforms - it will significantly complicate the deduplication.
    Clone this repository to your local machine.
    Ensure that you have Bash installed and that the scripts have execute permissions (Ensure that your scripts have execute permissions. You can do this with the chmod command. For example, chmod +x ProteinDatabaseCleanup.sh gives the script execute permissions.).
    Run the ProteinDatabaseCleanup.sh script with your protein database as an argument.

Requirements:

    Bash 4.0 or later
    AWK
    t_coffee tool for sequence alignment

This project is open-source, and contributions are welcomed. Please feel free to open an issue or submit a pull request if you have suggestions for improvements or have found any issues.
