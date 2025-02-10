#!/bin/bash

# Input and output files
INPUT_CSV="domains.csv"    # Input CSV file containing domains
OUTPUT_CSV="scan_results.csv"  # Output CSV file for nmap results

# Ensure the output CSV file has a header
echo "Domain,Port,State,Service" > "$OUTPUT_CSV"

# Open the input CSV file and skip the header
exec 3< "$INPUT_CSV"
read -r header <&3  # Read and discard the header

# Read domains from CSV file and run nmap for each
while IFS= read -r domain <&3; do
    if [[ -n "$domain" ]]; then
        echo "Scanning $domain..."
        nmap -Pn --open --script=http-title -oG - "$domain" | awk '
        /Ports:/ {
            split($0, a, "Ports: ");
            split(a[2], ports, ", ");
            for (i in ports) {
                split(ports[i], port_data, "/");
                print "'"$domain"'" "," port_data[1] "," port_data[2] "," port_data[5];
            }
        }' >> "$OUTPUT_CSV"
    fi
done

# Close file descriptor
exec 3<&-

