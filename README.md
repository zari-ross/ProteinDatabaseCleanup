# Protein Database Cleanup

This project contains a set of scripts used to process and clean up protein databases for proteomics experiments. The main objective is to select the longest or most prevalent isoforms from protein databases, minimize overlap in proteins, and avoid multiple mappings for peptides, hence improving the accuracy and effectiveness of proteomic analysis.

The main script, ProteinDatabaseCleanup.sh, works by linearizing the sequences, removing sequences without GN ids, uncharacterized and fragmented sequences. It then processes the sequences to prioritize SwissProt ones for keeping while removing duplicates with 90% similarity.

How to Use:

    Download the latest Uniprot entries for the selected organism. Download all in fasta (gz-archive), do not include multiple isoforms - it will significantly complicate the deduplication.
    Clone this repository to your local machine.
    Ensure that you have Bash installed and that the scripts have execute permissions.
    Run the ProteinDatabaseCleanup.sh script with your protein database as an argument.

Requirements:

    Bash 4.0 or later
    AWK
    t_coffee tool for sequence alignment

This project is open-source, and contributions are welcomed. Please feel free to open an issue or submit a pull request if you have suggestions for improvements or have found any issues.
