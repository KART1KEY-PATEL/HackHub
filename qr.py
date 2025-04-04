import pandas as pd
import qrcode
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from io import BytesIO
import sys

def generate_pdf(csv_file, output_pdf):
    # Read CSV (assumes header names 'Team Number', 'Team Name', 'Team Domain')
    df = pd.read_csv(csv_file)
    
    # Create a PDF canvas
    c = canvas.Canvas(output_pdf, pagesize=letter)
    page_width, page_height = letter
    
    for index, row in df.iterrows():
        # Extract values from CSV assuming columns: 'Team Number', 'Team Name', 'Team Domain'
        team_no = row['Team Number']
        team_name = row['Team Name']
        team_domain = row['Team Domain']
        
        # Generate QR code for the team name
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_H,
            box_size=10,
            border=4,
        )
        qr.add_data(team_name)
        qr.make(fit=True)
        img = qr.make_image(fill_color="black", back_color="white")
        
        # Save QR code image to a BytesIO stream (in PNG format)
        buffer = BytesIO()
        img.save(buffer, format="PNG")
        buffer.seek(0)
        
        # Set font and draw the texts centered on the page
        c.setFont("Helvetica", 18)
        c.drawCentredString(page_width / 2, page_height - 100, f"Seat Number: {team_no}")
        c.drawCentredString(page_width / 2, page_height - 140, f"Team Name: {team_name}")
        c.drawCentredString(page_width / 2, page_height - 180, f"Team Domain: {team_domain}")
        
        # Define QR code size and position (centered)
        qr_size = 200  # adjust the size as needed
        image_x = (page_width - qr_size) / 2
        image_y = (page_height - qr_size) / 2 - 50  # adjust vertical offset as needed
        c.drawImage(buffer, image_x, image_y, width=qr_size, height=qr_size)
        
        # Finish the page
        c.showPage()
    
    # Save the final PDF
    c.save()

if __name__ == "__main__":
    # Check for command-line arguments: csv input file and output pdf file
    if len(sys.argv) < 3:
        print("Usage: python generate_qr_pdf.py <csv_file> <output_pdf>")
    else:
        csv_file = sys.argv[1]
        output_pdf = sys.argv[2]
        generate_pdf(csv_file, output_pdf)
