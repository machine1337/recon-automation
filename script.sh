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
domain=$1

mkdir -p $domain $domain/domain_enum $domain/final_domains $domain/takeovers $domain/cors $domain/nuclei_scan $domain/waybackurls $domain/target_wordlist

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

shuffledns -d $domain -w /usr/share/wordlists/seclists/Discovery/DNS/deepmagic.com-prefixes-top50000.txt -r ~/tools/resolvers/resolver.txt -o $domain/domain_enum/shuffledns.txt
 

sleep 2
echo -e "\n\e[00;36m##################Collecting all subdomains into one file ###########################\e[00m"
cat $domain/domain_enum/*.txt > $domain/domain_enum/all.txt
}
domain_recon
sleep 2
echo -e "\n\e[00;37m##################Resolving All Subdomains ###########################\e[00m"

resolving_domains(){
shuffledns -d $domain -list $domain/domain_enum/all.txt -o $domain/domains.txt -r ~/tools/resolvers/resolver.txt
}
resolving_domains
sleep 2
echo -e "\n\e[00;30m##################Checking Services on subdomains ###########################\e[00m"
http_prob(){
cat $domain/domains.txt | httpx -threads 30 -o $domain/final_domains/httpx.txt
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
python3 ~/tools/Corsy/corsy.py -i $domain/final_domains/httpx.txt -t 15 | tee $domain/cors/cors_misconfig.txt
}
cors_misconfiguration
sleep 2
echo -e "\n\e[00;33m#############...Nuclei Scanner Started...#####################\e[00m"
nuclei_scan(){
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/cves/ -c 50 -o $domain/nuclei_scan/cves.txt
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/vulnerabilities/ -c 50 -o $domain/nuclei_scan/vulnerabilities.txt
cat $domain/final_domains/httpx.txt | nuclei -t ~/tools/nuclei-templates/misconfiguration/ -c 50 -o $domain/nuclei_scan/misconfiguration.txt

}
nuclei_scan
sleep 2
echo -e "\n\e[00;34m#############...Collecting URLS ...#####################\e[00m"
wayback_data(){

cat $domain/domains.txt | waybackurls | tee $domain/waybackurls/tmp.txt
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
echo -e "\n\e[00;31m##############More Features will be Added in Future ###########################\e[00m"
