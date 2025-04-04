import csv

def combine_names(input_file, output_file):
    with open(input_file, 'r', newline='') as infile, \
         open(output_file, 'w', newline='') as outfile:

        reader = csv.reader(infile)
        writer = csv.writer(outfile)

        for row in reader:
            # Extract first and last names
            first_name = row[0] if len(row) > 0 else ''
            last_name = row[1] if len(row) > 1 else ''
            
            # Combine names with a space
            full_name = f"{first_name} {last_name}".strip()

            # Ensure row has at least 26 columns
            if len(row) < 26:
                row += [''] * (26 - len(row))
            
            # Update column Z (index 25)
            row[25] = full_name

            writer.writerow(row)

if __name__ == '__main__':
    combine_names('input.csv', 'output.csv')