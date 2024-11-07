import requests
from bs4 import BeautifulSoup
import re
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import time

ultimo_edital = 3928

def send_email(link, recipient_email, sender_email, sender_password):
    # Setup the MIME
    message = MIMEMultipart()
    message['From'] = sender_email
    message['To'] = recipient_email
    message['Subject'] = "Olha a convocação aí gente"

    # Email body content
    body = f"Acessa o Link aí mozão:\n\n{link}"
    message.attach(MIMEText(body, 'plain'))

    # Send the email using Hotmail SMTP server
    try:
        server = smtplib.SMTP('smtp-mail.outlook.com', 587)
        server.starttls()  # Upgrade the connection to secure
        server.login(sender_email, sender_password)
        text = message.as_string()
        server.sendmail(sender_email, recipient_email, text)
        server.quit()
        print(f"[+] Email sent successfully to {recipient_email}")
    except Exception as e:
        print(f"Failed to send email: {e}")

def get_links_from_url(url, recipient_email, sender_email, sender_password):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36'
    }

    try:
        # Send a GET request with a User-Agent header
        response = requests.get(url, headers=headers)
        response.raise_for_status()  # Raise an exception for bad status codes

        # Parse the HTML content using BeautifulSoup
        soup = BeautifulSoup(response.text, 'html.parser')

        # Find all the anchor tags <a> and extract the href attribute (the link)
        links = [a.get('href') for a in soup.find_all('a', href=True)]

        # Filter and process links containing 'edital'
        for link in links:
            if 'edital' in link.lower():
                # Use a regular expression to find the number between 'edital-no-' and '-'
                match = re.search(r'/edital-no-(\d+)-', link)
                if match:
                    edital_number = int(match.group(1))
                    # print(f"{link}\n{edital_number}")

                    # If the number is greater than 3136, send an email
                    if edital_number > ultimo_edital:
                        print(link)
                        #send_email(link, recipient_email, sender_email, sender_password)

    except requests.exceptions.RequestException as e:
        print(f"[-] An error occurred with URL {url}: {e}")

# Example usage: A list of URLs
urls = [
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/hu-ufsc",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/hu-ufsc?b_start:int=140",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/he-ufpel",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/he-ufpel?b_start:int=30",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/hu-furg",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/hu-furg?b_start:int=40",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/husm-ufsm",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/husm-ufsm?b_start:int=30",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/hub-unb",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/hub-unb?b_start:int=90"
    # Add more URLs as needed
]

recipient_email = "cristilunkes@gmail.com"  # Replace with the recipient's email
sender_email = "rfe89@hotmail.com"  # Replace with your Hotmail email
sender_password = "s377LYSu8*6$2%^52G3Kt7@e!q!8oft"  # Replace with your Hotmail password

# Continuous loop to run the program every 10 minutes
while True:
    print("[+] Checking URLs...\n")
    # Loop through each URL in the list
    for url in urls:
        get_links_from_url(url, recipient_email, sender_email, sender_password)

    # Wait for 10 minutes before running again
    print("[+] Waiting for 20 minutes...\n")
    time.sleep(1200)
