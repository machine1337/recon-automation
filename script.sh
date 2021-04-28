#!/bin/bash
echo -e "\n\e[00;33m#########################################################\e[00m"
echo -e "\e[00;32m#                                                       #\e[00m" 
echo -e "\e[00;31m#\e[00m" "\e[01;32m             Bug Bounty Recon automation script \e[00m" "\e[00;31m#\e[00m"
echo -e "\e[00;34m#                                                       #\e[00m" 
echo -e "\e[00;35m#########################################################\e[00m"
echo -e ""
echo -e "\e[00;36m##### https://www.facebook.com/unknownclay/ #####\e[00m"
echo -e "\e[00;37m#####       Coded By: Machine404            #####\e[00m"

echo -e "\n\e[00;35m#########################################################\e[00m"
sleep 2
d=$(date +"%b-%d-%y %H:%M")

echo -e "\n\e[00;34m################## Recon Automation  Started On:  $d #####################\e[00m"
sleep 2
domain=$1

mkdir -p $domain $domain/domain_enum $domain/final_domains $domain/takeovers $domain/vulnerabilities $domain/vulnerabilities/ref_xss $domain/vulnerabilities/xss_scan $domain/vulnerabilities/sqli $domain/vulnerabilities/cors  $domain/nuclei_scan $domain/waybackurls $domain/target_wordlist $domain/gf  $domain/vulnerabilities/LFI $domain/vulnerabilities/openredirect

echo -e "\n\e[00;33m#################### Domain Enumeration Started ###########################\e[00m"
sleep 2
domain_recon(){
echo -e "\n\e[00;31m#################### crt.sh Enumeration Started ###########################\e[00m"
curl -s https://crt.sh/\?q\=%25.$domain\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee $domain/domain_enum/crt.txt
sleep 2
echo -e "\n\e[00;32m#################### subfinder Enumeration Started ###########################\e[00m"
subfinder -d $domain -o $domain/domain_enum/subfinder.txt
sleep 2
echo -e "\n\e[00;33m#################### assetfinder Enumeration Started ###########################\e[00m"
assetfinder -subs-only $domain | tee $domain/domain_enum/assetfinder.txt
sleep 2
echo -e "\n\e[00;34m#################### Amass Enumeration Started ###########################\e[00m"
amass enum -passive -d $domain -o $domain/domain_enum/amass.txt
sleep 2
echo -e "\n\e[00;35m#################### shuffledns  Started ###########################\e[00m"

shuffledns -d $domain -w /usr/share/seclists/Discovery/DNS/deepmagic.com-prefixes-top50000.txt -r ~/tools/resolvers/resolver.txt -o $domain/domain_enum/shuffledns.txt
 

sleep 2
echo -e "\n\e[00;36m##################Collecting all subdomains into one file ###########################\e[00m"
cat $domain/domain_enum/*.txt > $domain/domain_enum/all.txt
}
domain_recon
sleep 2
echo -e "\n\e[00;37m##################Resolving All Subdomains ###########################\e[00m"

resolving_domains(){
shuffledns -d $domain -list $domain/domain_enum/all.txt -o $domain/final_domains/domains.txt -r ~/tools/resolvers/resolver.txt
}
resolving_domains
sleep 2
echo -e "\n\e[00;30m##################Checking Services on subdomains ###########################\e[00m"
http_prob(){
cat $domain/final_domains/domains.txt | httpx -threads 30 -o $domain/final_domains/httpx.txt
}
http_prob
sleep 2
echo -e "\n\e[00;31m############Searching For Subdomain takeover Vulnerability#####################\e[00m"
subdomain_takeover(){
subzy -hide_fails -targets $domain/domain_enum/all.txt | tee $domain/takeovers/subzy.txt
subjack -w $domain/domain_enum/all.txt -t 100 -timeout 30 -o $domain/takeovers/take.txt -ssl
}
subdomain_takeover
sleep 2
echo -e "\n\e[00;32m#############Checking For Cors misconfiguration#####################\e[00m"
cors_misconfiguration(){
python3 ~/tools/Corsy/corsy.py -i $domain/final_domains/httpx.txt -t 15 | tee $domain/vulnerabilities/cors/cors_misconfig.txt
}
cors_misconfiguration
sleep 2
echo -e "\n\e[00;34m#############...Collecting URLS ...#####################\e[00m"
wayback_data(){

cat $domain/final_domains/domains.txt | gau | tee $domain/waybackurls/tmp.txt
cat $domain/waybackurls/tmp.txt | egrep -v "\.woff|\.ttf|\.svg|\.eot|\.png|\.jpep|\.jpeg|\.css|\.ico|\jpg" | sed 's/:80//g;s/:443//g' | sort -u >> $domain/waybackurls/wayback.txt

rm $domain/waybackurls/tmp.txt
}
wayback_data
sleep 2
echo -e "\n\e[00;35m#############...Fuzz Faster You Fool Started  ...#####################\e[00m"
valid_urls(){

ffuf -c -u "FUZZ" -w $domain/waybackurls/wayback.txt -of csv -o $domain/waybackurls/valid-tmp.txt

cat $domain/waybackurls/valid-tmp.txt | grep http | awk -F "," '{print $1}'  >>  $domain/waybackurls/valid.txt

rm $domain/waybackurls/valid-tmp.txt
}
valid_urls
sleep 2
echo -e "\n\e[00;36m##################Generating target based wordlist ###########################\e[00m"
custom_wordlist(){
cat $domain/waybackurls/wayback.txt | unfurl -unique paths > $domain/target_wordlist/paths.txt
cat $domain/waybackurls/wayback.txt | unfurl -unique keys > $domain/target_wordlist/param.txt
echo "..............Target Based Wordlist successfully Generated................."
}
custom_wordlist
sleep 2
echo -e "\n\e[00;37m##################Gf Pattern Started ###########################\e[00m"
gf_patterns(){

gf xss $domain/waybackurls/valid.txt | tee $domain/gf/xss.txt
cat $domain/gf/xss.txt | sed 's/=.*/=/' | sed 's/URL: //' | tee $domain/gf/purexss.txt
gf ssrf $domain/waybackurls/valid.txt | tee $domain/gf/ssrf.txt
gf sqli $domain/waybackurls/valid.txt | tee $domain/gf/sql.txt
gf lfi $domain/waybackurls/valid.txt | tee $domain/gf/lfi.txt
gf ssti $domain/waybackurls/valid.txt | tee $domain/gf/ssti.txt
gf aws-keys $domain/waybackurls/valid.txt | tee $domain/gf/awskeys.txt
gf redirect $domain/waybackurls/valid.txt | tee $domain/gf/redirect.txt
cat $domain/gf/redirect.txt | sed 's/\=.*/=/' | tee $domain/gf/purered.txt
gf idor $domain/waybackurls/valid.txt | tee $domain/gf/idor.txt
}
gf_patterns
sleep 2
echo -e "\n\e[00;32m###############Searching For Open Redirect  ###########################\e[00m"
open_redirect(){
cat $domain/gf/redirect.txt | qsreplace FUZZ | tee $domain/vulnerabilities/openredirect/fuzzredirect.txt
python3 ~/tools/OpenRedireX/openredirex.py -l $domain/vulnerabilities/openredirect/fuzzredirect.txt -p ~/tools/OpenRedireX/payloads.txt --keyword FUZZ | tee $domain/vulnerabilities/openredirect/confrimopenred.txt

}
open_redirect
sleep 1
echo -e "\n\e[00;34m##################XSS Scanner Started ###########################\e[00m"
xss_scanner(){

cat $domain/gf/xss.txt | kxss | tee $domain/vulnerabilities/xss_scan/kxss.txt
cat $domain/gf/xss.txt grep '=' | qsreplace "'><sCriPt class=khan>prompt(1)</script>" | while read host do ; do curl --silent --path-as-is --insecure "$host" | grep -qs "'><sCriPt class=khan>prompt(1)" && echo "$host \033[0;31mVulnerable\n";done | tee $domain/vulnerabilities/xss_scan/vulnxss.txt
}
xss_scanner
sleep 2
echo -e "\n\e[00;33m###############Searching For Reflected Params And XSS ###########################\e[00m"
param_reflected(){
python3 ~/tools/ParamSpider/paramspider.py --domain $domain/final_domains/httpx.txt --exclude png,svg,jpg -o $domain/vulnerabilities/ref_xss/paramspider.txt
cat $domain/waybackurls/valid.txt | Gxss -p khan | dalfox pipe --mining-dict ~/tools/Arjun/arjun/db/params.txt --skip-bav -o $domain/vulnerabilities/ref_xss/xss.txt
 
}
param_reflected
sleep 2
echo -e "\n\e[00;33m#############...Nuclei Scanner Started...#####################\e[00m"
nuclei_scan(){
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/cves/ -c 50 -o $domain/nuclei_scan/cves.txt
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/vulnerabilities/ -c 50 -o $domain/nuclei_scan/vulnerabilities.txt
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/misconfiguration/ -c 50 -o $domain/nuclei_scan/misconfiguration.txt

}
nuclei_scan
sleep 1
echo -e "\n\e[00;35m#############...Searching For Sql Injection...#####################\e[00m"
vuln_scan(){
sqlmap -m $domain/gf/sql.txt --batch --random-agent --level 1 | tee $domain/vulnerabilities/sqli/sqlmap.txt
sleep 1
echo -e "\n\e[00;37m#############...Searching For LFI vulnerabilities...#####################\e[00m"
cat $domain/gf/lfi.txt | qsreplace FUZZ | while read url ; do ffuf -u $url -mr "root:x" -w ~/tools/lfipayloads.txt ; done | tee $domain/vulnerabilities/LFI/lfi.txt
}
vuln_scan
