# recon_automation
![view](https://user-images.githubusercontent.com/82051128/114009556-ae259f80-987c-11eb-998c-6eb7765ffa8a.PNG)
# About:
A simple recon automation script that definitely will help you in bug bounty hunting and penetration testing.
# Requirements:
    1)Make Sure go language is installed and set to $PATH.
    2)or Download the go language from its official website.
    3)Open terminal and move to directory where you downloaded go.
    4)Now run tar -c /usr/local -xzf {go .gz folder}.
    5)then open sudo nano $HOME/.zshrc or sudo nano $HOME/.bashrc add the following commands.
    6)export PATH=$PATH:/usr/local/go/bin 
    export GOPATH=$HOME/go   
    export PATH=$PATH:$HOME/go/bin 
    export PATH=$PATH:$HOME/go/  

# Installation:
    1)  Simply Clone the repository
    2)  chmod +x install.sh
    3)  ./install.sh
    4)  chmod +x script.sh
    5)  Now run the script as ./script.sh


# Usage:
    ./script.sh example.com

# Current Features:
    1) This script will collect all the subdomains using amass, assetfinder, subfinder and crt.sh
    2) For subdomain bruteforcing, shuffledns is used in the script.
    3) This script will gather all the subdomains and put them in a single .txt file.
    4) This script will resolves all the subdomains using shuffledns.
    5) And Finally will check http/https services on the given domains using httpx tool.
    6) It will check for the Following Vulnerablities:
    a) Subdomain takeover
    b) CORS misconfiguration
    c) nuclei scan
    d) Open Redirect Scanner
    e) LFI Scanner
    f) Advance XSS Scanner and method used.
    g) Sqli Scan
    7) This script will collect all the urls using waybackurls and will filter them and store them in single file.
    8) ffuf is used in this script to find valid urls.
    9) This script will generate target based paths/parameters using unfurl for further attack.

# Future Features:
    1. SSRF Automation
    2. Host Header Injection Automation
    3. Hidden and Sensitive Directories bruteforce
    4. CRLF Injection
    5. HTTP Request Smuggling Automation


# Special Thanks To:
1) @tomnomnom
2) @projectdiscovery
3) and other infosec community.

# TOOLS Used:
    Subfinder
    Amass
    Assetfinder
    waybackurls
    unfurl
    subjack
    subzy
    ffuf
    shuffledns
    httpx
    nuclei
    crt.sh
    massdns
    

# Author
    I am a CS student and bug bounty hunter, Ethical Hacker from Pakistan.
