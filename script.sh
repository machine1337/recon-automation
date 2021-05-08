#!/bin/bash
function bounty_recon(){
echo -e "\n\e[00;33m#########################################################\e[00m"
echo -e "\e[00;32m#                                                       #\e[00m" 
echo -e "\e[00;31m#\e[00m" "\e[01;32m        Bug Bounty Recon Automation Script \e[00m" "\e[00;31m#\e[00m"
echo -e "\e[00;34m#                                                       #\e[00m" 
echo -e "\e[00;35m#########################################################\e[00m"
echo -e ""
echo -e "\e[00;36m##### https://www.facebook.com/unknownclay/ #####\e[00m"
echo -e "\e[00;37m#####       Coded By: Machine404            #####\e[00m"

echo -e "\n\e[00;35m#########################################################\e[00m"
}
d=$(date +"%b-%d-%y %H:%M")

function single_recon(){
clear
bounty_recon
echo -n "[+] Enter Single domain (e.g evil.com) : " 
           read domain
mkdir -p $domain $domain/vulnerabilities $domain/vulnerabilities/cors $domain/waybackurls $domain/target_wordlist $domain/gf $domain/vulnerabilities/openredirect/ $domain/vulnerabilities/xss_scan $domain/nuclei_scan $domain/vulnerabilities/LFI $domain/vulnerabilities/sqli
echo -e "\n\e[00;34m################ Single Target Recon Started On: $d  ##################\e[00m"
sleep 1
echo -e "\n\e[00;31m#################### checking services on domain ###########################\e[00m"
echo "$domain" | httpx -threads 30 -o $domain/httpx.txt
sleep 1
echo -e "\n\e[00;32m#############Checking For Cors misconfiguration#####################\e[00m"
python3 ~/tools/Corsy/corsy.py -i $domain/httpx.txt -t 15 | tee $domain/vulnerabilities/cors/cors_misconfig.txt
sleep 1
echo -e "\n\e[00;34m#############...Collecting URLS ...##########################\e[00m"
cat $domain/httpx.txt | gau | tee $domain/waybackurls/tmp.txt
cat $domain/waybackurls/tmp.txt | egrep -v "\.woff|\.ttf|\.svg|\.eot|\.png|\.jpep|\.jpeg|\.css|\.ico|\jpg" | sed 's/:80//g;s/:443//g' | sort -u >> $domain/waybackurls/wayback.txt

rm $domain/waybackurls/tmp.txt
sleep 1
echo -e "\n\e[00;35m#############...Fuzz Faster You Fool Started  ...#####################\e[00m"
ffuf -c -u "FUZZ" -w $domain/waybackurls/wayback.txt -of csv -o $domain/waybackurls/valid-tmp.txt

cat $domain/waybackurls/valid-tmp.txt | grep http | awk -F "," '{print $1}'  >>  $domain/waybackurls/valid.txt

rm $domain/waybackurls/valid-tmp.txt
echo -e "\n\e[00;36m##################Generating target based wordlist ###########################\e[00m"
cat $domain/waybackurls/wayback.txt | unfurl -unique paths > $domain/target_wordlist/paths.txt
cat $domain/waybackurls/wayback.txt | unfurl -unique keys > $domain/target_wordlist/param.txt
echo -e "\n\e[00;37m##################Gf Pattern Started ###########################\e[00m"
gf xss $domain/waybackurls/valid.txt | tee $domain/gf/xss.txt
gf ssrf $domain/waybackurls/valid.txt | tee $domain/gf/ssrf.txt
gf sqli $domain/waybackurls/valid.txt | tee $domain/gf/sql.txt
gf lfi $domain/waybackurls/valid.txt | tee $domain/gf/lfi.txt
gf ssti $domain/waybackurls/valid.txt | tee $domain/gf/ssti.txt
gf aws-keys $domain/waybackurls/valid.txt | tee $domain/gf/awskeys.txt
gf redirect $domain/waybackurls/valid.txt | tee $domain/gf/redirect.txt
cat $domain/gf/redirect.txt | sed 's/\=.*/=/' | tee $domain/gf/purered.txt
gf idor $domain/waybackurls/valid.txt | tee $domain/gf/idor.txt
echo -e "\n\e[00;33m#############...Nuclei Scanner Started...#####################\e[00m"
cat $domain/httpx.txt | nuclei -t ~/tools/nuclei-templates/cves/ -c 50 -o $domain/nuclei_scan/cves.txt
cat $domain/httpx.txt | nuclei -t ~/tools/nuclei-templates/vulnerabilities/ -c 50 -o $domain/nuclei_scan/vulnerabilities.txt
cat $domain/httpx.txt | nuclei -t ~/tools/nuclei-templates/misconfiguration/ -c 50 -o $domain/nuclei_scan/misconfiguration.txt
cat $domain/httpx.txt | nuclei -t ~/tools/nuclei-templates/technologies/ -c 50 -o $domain/nuclei_scan/tech.txt
echo -e "\n\e[00;32m###############Searching For Open Redirect  ###########################\e[00m"
cat $domain/gf/redirect.txt | qsreplace FUZZ | tee $domain/vulnerabilities/openredirect/fuzzredirect.txt
python3 ~/tools/OpenRedireX/openredirex.py -l $domain/vulnerabilities/openredirect/fuzzredirect.txt -p ~/tools/OpenRedireX/payloads.txt --keyword FUZZ | tee $domain/vulnerabilities/openredirect/confrimopenred.txt
echo -e "\n\e[00;34m##################XSS Scanner Started ###########################\e[00m"
cat $domain/gf/xss.txt | kxss  | tee $domain/vulnerabilities/xss_scan/kxss.txt
cat $domain/vulnerabilities/xss_scan/kxss.txt | awk '{print $9}' | sed 's/=.*/=/' | tee $domain/vulnerabilities/xss_scan/kxss1.txt
cat $domain/vulnerabilities/xss_scan/kxss1.txt | dalfox pipe | tee $domain/vulnerabilities/xss_scan/dalfoxss.txt
cat $domain/gf/xss.txt | grep "=" | qsreplace "'><sCriPt class=khan>prompt(1)</script>" | while read host do ; do curl --silent --path-as-is --insecure "$host" | grep -qs "'><sCriPt class=khan>prompt(1)" && echo "$host \033[0;31mVulnerable\n";done | tee $domain/vulnerabilities/xss_scan/vulnxss.txt
echo -e "\n\e[00;35m#############...Searching For Sql Injection...#####################\e[00m"
sqlmap -m $domain/gf/sql.txt --batch --random-agent --level 1 | tee $domain/vulnerabilities/sqli/sqlmap.txt
sleep 1
echo -e "\n\e[00;37m#############...Searching For LFI vulnerabilities...#####################\e[00m"
cat $domain/gf/lfi.txt | qsreplace FUZZ | while read url ; do ffuf -u $url -mr "root:x" -w ~/tools/lfipayloads.txt -of csv -o $domain/vulnerabilities/LFI/lfi.txt -t 50 -c  ; done
}

function massive_recon(){
clear
bounty_recon
echo -n "[+] Full Recon with subdomains (e.g *.example.com): "
read domain
mkdir -p $domain $domain/domain_enum $domain/final_domains $domain/takeovers $domain/vulnerabilities $domain/vulnerabilities/xss_scan $domain/vulnerabilities/sqli $domain/vulnerabilities/cors  $domain/nuclei_scan $domain/waybackurls $domain/target_wordlist $domain/gf  $domain/vulnerabilities/LFI $domain/vulnerabilities/openredirect
echo -e "\n\e[00;34m################ Full Recon Started On: $d  ##################\e[00m"
sleep 1
echo -e "\n\e[00;31m#################### crt.sh Enumeration Started ###########################\e[00m"
curl -s https://crt.sh/\?q\=%25.$domain\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee $domain/domain_enum/crt.txt
echo -e "\n\e[00;32m#################### subfinder Enumeration Started ###########################\e[00m"
subfinder -d $domain -o $domain/domain_enum/subfinder.txt
echo -e "\n\e[00;33m#################### assetfinder Enumeration Started ###########################\e[00m"
assetfinder -subs-only $domain | tee $domain/domain_enum/assetfinder.txt
echo -e "\n\e[00;34m#################### Amass Enumeration Started ###########################\e[00m"
amass enum -passive -d $domain -o $domain/domain_enum/amass.txt
echo -e "\n\e[00;35m#################### shuffledns  Started ###########################\e[00m"
shuffledns -d $domain -w /usr/share/seclists/Discovery/DNS/deepmagic.com-prefixes-top50000.txt -r ~/tools/resolvers/resolver.txt -o $domain/domain_enum/shuffledns.txt
echo -e "\n\e[00;36m##################Collecting all subdomains into one file ###########################\e[00m"
cat $domain/domain_enum/*.txt > $domain/domain_enum/all.txt
echo -e "\n\e[00;37m##################Resolving All Subdomains ###########################\e[00m"
shuffledns -d $domain -list $domain/domain_enum/all.txt -o $domain/final_domains/domains.txt -r ~/tools/resolvers/resolver.txt
echo -e "\n\e[00;30m##################Checking Services on subdomains ###########################\e[00m"
cat $domain/final_domains/domains.txt | httpx -threads 30 -o $domain/final_domains/httpx.txt
echo -e "\n\e[00;31m############Searching For Subdomain takeover Vulnerability#####################\e[00m"
subzy -hide_fails -targets $domain/domain_enum/all.txt | tee $domain/takeovers/subzy.txt
subjack -w $domain/domain_enum/all.txt -t 100 -timeout 30 -o $domain/takeovers/take.txt -ssl
echo -e "\n\e[00;32m#############Checking For Cors misconfiguration#####################\e[00m"
python3 ~/tools/Corsy/corsy.py -i $domain/final_domains/httpx.txt -t 15 | tee $domain/vulnerabilities/cors/cors_misconfig.txt
echo -e "\n\e[00;33m#############...Nuclei Scanner Started...#####################\e[00m"
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/cves/ -c 50 -o $domain/nuclei_scan/cves.txt
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/vulnerabilities/ -c 50 -o $domain/nuclei_scan/vulnerabilities.txt
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/misconfiguration/ -c 50 -o $domain/nuclei_scan/misconfiguration.txt
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/technologies/ -c 50 -o $domain/nuclei_scan/tech.txt
echo -e "\n\e[00;34m#############...Collecting URLS ...#####################\e[00m"
cat $domain/final_domains/domains.txt | gau | tee $domain/waybackurls/tmp.txt
cat $domain/waybackurls/tmp.txt | egrep -v "\.woff|\.ttf|\.svg|\.eot|\.png|\.jpep|\.jpeg|\.css|\.ico|\jpg" | sed 's/:80//g;s/:443//g' | sort -u >> $domain/waybackurls/wayback.txt

rm $domain/waybackurls/tmp.txt
echo -e "\n\e[00;35m#############...Fuzz Faster You Fool Started  ...#####################\e[00m"
ffuf -c -u "FUZZ" -w $domain/waybackurls/wayback.txt -of csv -o $domain/waybackurls/valid-tmp.txt

cat $domain/waybackurls/valid-tmp.txt | grep http | awk -F "," '{print $1}'  >>  $domain/waybackurls/valid.txt

rm $domain/waybackurls/valid-tmp.txt
echo -e "\n\e[00;36m##################Generating target based wordlist ###########################\e[00m"
cat $domain/waybackurls/wayback.txt | unfurl -unique paths > $domain/target_wordlist/paths.txt
cat $domain/waybackurls/wayback.txt | unfurl -unique keys > $domain/target_wordlist/param.txt
echo -e "\n\e[00;37m##################Gf Pattern Started ###########################\e[00m"
gf xss $domain/waybackurls/valid.txt | tee $domain/gf/xss.txt
gf ssrf $domain/waybackurls/valid.txt | tee $domain/gf/ssrf.txt
gf sqli $domain/waybackurls/valid.txt | tee $domain/gf/sql.txt
gf lfi $domain/waybackurls/valid.txt | tee $domain/gf/lfi.txt
gf ssti $domain/waybackurls/valid.txt | tee $domain/gf/ssti.txt
gf aws-keys $domain/waybackurls/valid.txt | tee $domain/gf/awskeys.txt
gf redirect $domain/waybackurls/valid.txt | tee $domain/gf/redirect.txt
cat $domain/gf/redirect.txt | sed 's/\=.*/=/' | tee $domain/gf/purered.txt
gf idor $domain/waybackurls/valid.txt | tee $domain/gf/idor.txt
echo -e "\n\e[00;32m###############Searching For Open Redirect  ###########################\e[00m"
cat $domain/gf/redirect.txt | qsreplace FUZZ | tee $domain/vulnerabilities/openredirect/fuzzredirect.txt
python3 ~/tools/OpenRedireX/openredirex.py -l $domain/vulnerabilities/openredirect/fuzzredirect.txt -p ~/tools/OpenRedireX/payloads.txt --keyword FUZZ | tee $domain/vulnerabilities/openredirect/confrimopenred.txt
echo -e "\n\e[00;34m##################XSS Scanner Started ###########################\e[00m"
cat $domain/gf/xss.txt | kxss  | tee $domain/vulnerabilities/xss_scan/kxss.txt
cat $domain/vulnerabilities/xss_scan/kxss.txt | awk '{print $9}' | sed 's/=.*/=/' | tee $domain/vulnerabilities/xss_scan/kxss1.txt
cat $domain/vulnerabilities/xss_scan/kxss1.txt | dalfox pipe | tee $domain/vulnerabilities/xss_scan/dalfoxss.txt
cat $domain/gf/xss.txt | grep "=" | qsreplace "'><sCriPt class=khan>prompt(1)</script>" | while read host do ; do curl --silent --path-as-is --insecure "$host" | grep -qs "'><sCriPt class=khan>prompt(1)" && echo "$host \033[0;31mVulnerable\n";done | tee $domain/vulnerabilities/xss_scan/vulnxss.txt

echo -e "\n\e[00;33m#############...Nuclei Scanner Started...#####################\e[00m"
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/cves/ -c 50 -o $domain/nuclei_scan/cves.txt
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/vulnerabilities/ -c 50 -o $domain/nuclei_scan/vulnerabilities.txt
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/misconfiguration/ -c 50 -o $domain/nuclei_scan/misconfiguration.txt
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/technologies/ -c 50 -o $domain/nuclei_scan/tech.txt
echo -e "\n\e[00;35m#############...Searching For Sql Injection...#####################\e[00m"
sqlmap -m $domain/gf/sql.txt --batch --random-agent --level 1 | tee $domain/vulnerabilities/sqli/sqlmap.txt
echo -e "\n\e[00;37m#############...Searching For LFI vulnerabilities...#####################\e[00m"
cat $domain/gf/lfi.txt | qsreplace FUZZ | while read url ; do ffuf -u $url -mr "root:x" -w ~/tools/lfipayloads.txt -of csv -o $domain/vulnerabilities/LFI/lfi.txt -t 50 -c  ; done
}
menu(){
clear
bounty_recon
echo -e "\n[*] Which Type of recon u want to Perform\n "
echo -e "[1] Single domain Recon\n[2] Full Target Recon with Subdomains\n"
echo -n "[+] Select: "
        read bounty_play
                if [ $bounty_play -eq 1 ]; then
                        single_recon
                elif [ $bounty_play -eq 2 ]; then
                        massive_recon
                fi

}
menu
