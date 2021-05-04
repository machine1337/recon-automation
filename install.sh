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

echo -e "\n\e[00;34m################## Installation  Started On:  $d #####################\e[00m"
sleep 1

echo -e "\n\e[00;31m#################### Installing assetfinder tool ###########################\e[00m"
sleep 1
assetfinder_checking(){
command -v "assetfinder" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
        echo "Installing assetfinder: "
        go get -u github.com/tomnomnom/assetfinder
        echo ".............assetfinder successfully installed.............."
        else
        echo "...........assetfinder already installed................"
    fi
sleep 1
echo -e "\n\e[00;34m#################### Installing Gau tool ###########################\e[00m"
command -v "gau" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
            echo "..........Installing gau............"
            go get -u -v github.com/lc/gau
            echo ".........gau successfully installed................"
            else
            echo "...........gau already exists....................."
       fi
sleep 1
echo -e "\n\e[00;32m#################### Installing qsreplace tool ###########################\e[00m"
command -v "qsreplace" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
            echo "..........Installing qsreplace............"
            go get -u github.com/tomnomnom/qsreplace
            echo ".........qsreplace successfully installed................"
            else
            echo "...........qsreplace already exists....................."
       fi
}
assetfinder_checking
sleep 1
echo -e "\n\e[00;36m#################### Installing gf tool and patterns ##########################\e[00m"
checking_gf(){
command -v "gf" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
         echo "............Installing gf tool............."
         go get -u github.com/tomnomnom/gf
         echo 'source $GOPATH/pkg/mod/github.com/tomnomnom/gf*/gf-completion.zsh' >> ~/.zshrc
         cp -r $GOPATH/pkg/mod/github.com/tomnomnom/gf*/examples ~/.gf
         source ~/.zshrc
         echo "..............Gf tool Successfully installed.............."
         else
         echo "................Gf tool already exsist................."
    fi
sleep 1
echo -e "\n\e[00;32m#################### Installing Gf Patterns  ###########################\e[00m"
if [[ ! -d ~/Gf-Patterns  ]]; then
        echo "..............Installing Gf Patterns................."
        cd ~
        git clone https://github.com/1ndianl33t/Gf-Patterns.git
        sudo mv ~/Gf-Patterns/*.json ~/.gf
        echo "...........Gf Patterns Successfully Installed............"
        else
        echo "...........Gf Patterns Already exsist................."
    fi    

}
checking_gf
sleep 1
echo -e "\n\e[00;37m#################### Installing amass tool ###########################\e[00m"
amass_checking(){

command -v "amass" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
         echo "Installing amass:"
         sudo apt-get install update
         sudo apt-get install amass
         echo "................Amass successfully installed.............."
         else
         echo "...............Amass is already installed................."
   fi
}
amass_checking
sleep 1
echo -e "\n\e[00;33m#################### Installing jq tool ###########################\e[00m"
jq_checking(){

command -v "jq" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
         echo "Installing jq:"
         sudo apt-get install update
         sudo apt-get install jq
         echo ".................jq successfully installed.............."
         else
         echo ".............jq is already installed..............."
   fi

}
jq_checking

sleep 1
echo -e "\n\e[00;34m#################### Installing subfinder tool ###########################\e[00m"
subfinder_checking(){
command -v "subfinder" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
         echo "Installing subfinder:"
         GO111MODULE=on go get -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder
         echo "................subfinder successfully installed.............."
         else
         echo "............subfinder is already installed..............."
   fi

}
subfinder_checking
sleep 1
echo -e "\n\e[00;35m#################### Installing Massdns tool ###########################\e[00m"
massdns_checking(){
mkdir -p ~/tools
command -v "massdns" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
         echo "Installing massdns.....\n\n:"
         cd ~/tools
         git clone https://github.com/blechschmidt/massdns.git
         cd massdns
          make
          cd bin
          sudo mv massdns /usr/local/bin
          echo "............massdns installed successfully............"
         else
         echo "..............massdns is already installed................"
    fi

}
massdns_checking
sleep 1
echo -e "\n\e[00;32m#################### Installing nuclei tool ###########################\e[00m"
command -v "nuclei" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
          echo "Installing nuclei tool..........\n\n"
         GO111MODULE=on go get -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei
      
          else
          echo "...........Nuclei tool already exists..................."
       fi
sleep 1
echo -e "\n\e[00;37m#################### Installing nuclei templates ###########################\e[00m"
if [[ ! -d ~/tools/nuclei-templates ]]; then
         echo ".............Installing nuclei templates..........."
         mkdir -p ~/tools
         cd ~/tools
         git clone https://github.com/projectdiscovery/nuclei-templates.git
         echo "...............Nuclei templates installation done................."
         else
         echo "................nuclei templates already exists................"
  fi
sleep 1
echo -e "\n\e[00;35m#################### Installing dnsvalidator tool ###########################\e[00m"
dnsvalidator_installing(){
mkdir -p ~/tools
mkdir -p ~/tools/resolvers


command -v "dnsvalidator" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
        cd ~/tools
       git clone  https://github.com/vortexau/dnsvalidator.git
       cd dnsvalidator
       sudo apt-get install python3-pip
       sudo python3 setup.py install
       dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 25 -o resolvers.txt
       cat resolvers.txt | tail -n 60 > ~/tools/resolvers/resolver.txt
       else
        echo ".......dnsvalidator already exist...!\n\n"
fi

}
dnsvalidator_installing
sleep 1

other_tools(){
echo -e "\n\e[00;36m#################### Installing httpx tool ###########################\e[00m"
command -v "httpx" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
         echo "Installing httpx.....\n\n:"
        go get -v github.com/projectdiscovery/httpx/cmd/httpx
        echo ".................httpx successfully installed.............."
         else
         echo "................httpx is already installed..............."
   fi

sleep 1
echo -e "\n\e[00;37m#################### Installing httprobe tool ###########################\e[00m"
command -v "httprobe" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
         echo "Installing httprobe.....\n\n:"
         go get -u github.com/tomnomnom/httprobe
         echo ".............httprobe successfully installed.............."
         else
         echo "............httprobe is already installed................."
   fi
   
sleep 1
echo -e "\n\e[00;31m#################### Installing shuffledns tool ###########################\e[00m"
command -v "shuffledns" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
        echo "Installing shuffledns.....\n\n:"
        mkdir -p ~/tools
        cd ~/tools
        wget https://github.com/projectdiscovery/shuffledns/releases/download/v1.0.4/shuffledns_1.0.4_linux_amd64.tar.gz
        tar -xvzf shuffledns*.gz
       
        sudo mv shuffledns /usr/local/bin
         rm -R shuffledns*.gz
        echo "................shuffledns successfully installed.............."
         
         else
        echo "..............shuffledns is already installed.................."
   fi
sleep 1
echo -e "\n\e[00;32m#################### Installing seclists wordlist ###########################\e[00m"

command -v "seclists" >/dev/null 2>&1
if [[ ! -d /usr/share/seclists ]]; then
        sudo apt update
        sudo apt install seclists
        echo "....................Seclists Successfully Installed................."
        
        else
        echo ".................Seclists Already Exists................."
fi
sleep 1      
echo -e "\n\e[00;31m#################### Downloading  LFI Payloads ###########################\e[00m"    
if [[ ! -f ~/tools/dotdotpwn.txt ]]; then
         cd ~/tools
        wget https://raw.githubusercontent.com/swisskyrepo/PayloadsAllTheThings/master/Directory%20Traversal/Intruder/dotdotpwn.txt
        cat dotdotpwn.txt | head -n 120 > ~/tools/lfipayloads.txt
        echo "....................LFI Payloads Successfully Downloaded................."
        else
        echo ".................LFI Payloads Already Exists................."
fi  
    
sleep 1
echo -e "\n\e[00;37m#################### Installing Cors misconfiguration tool ###########################\e[00m"
command -v "Corsy" >/dev/null 2>&1
if [[ ! -d ~/tools/Corsy ]]; then
        echo ".............Installing cors misconfiguration tools..............";
        cd ~/tools
        git clone  https://github.com/s0md3v/Corsy.git
        cd Corsy
        sudo apt install python3-pip
        pip install -r requirements.txt
        echo "....................Cors installation done...................";
        else
        echo ".............Corsy already installed............."
    fi



sleep 1
echo -e "\n\e[00;36m#################### Installing waybackurls ###########################\e[00m"
command -v "waybackurls" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
        go get github.com/tomnomnom/waybackurls
        echo "......waybackurls installed successfully......"
        else
        echo "........waybackurls already exists..........."
    fi
sleep 1
echo -e "\n\e[00;32m#################### Installing unfurl ###########################\e[00m"
command -v "unfurl" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
         go get -u github.com/tomnomnom/unfurl
        echo "......Unfurl installed successfully......"
        else
        echo "........Unfurl already exists..........."   
    fi
sleep 1
echo -e "\n\e[00;32m#################### Installing ffuf ###########################\e[00m"
command -v "ffuf" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "........installing fuff..........."
    go get -u github.com/ffuf/ffuf
    else
    echo ".......ffuf already exists........."
    fi
sleep 1
echo -e "\n\e[00;36m#################### Installing OpenRedireX tool ###########################\e[00m"
if [ -d ~/tools/OpenRedireX ]; then
     echo "..................OpenRedireX already exists..............."
     else
     
    cd ~/tools
    git clone https://github.com/devanshbatham/OpenRedireX
    echo ".................OpenRedireX Installed successfully................."
fi
sleep 1
echo -e "\n\e[00;37m#################### Installing kxss tool ###########################\e[00m"
command -v "kxss" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "........installing kxss............"
    go get github.com/Emoe/kxss
    else
    echo ".......kxss already exists........."
    fi
sleep 1
echo -e "\n\e[00;35m#################### Installing dalfox tool ###########################\e[00m"
command -v "dalfox" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "........installing dalfox tool............"
    GO111MODULE=on go get -v github.com/hahwul/dalfox/v2
    else
    echo ".......dalfox already exists........."
    fi

}
other_tools

sleep 2
echo -e "\n\e[00;33m#################### Installing subdomain takeover tool ###########################\e[00m"
sleep 1
subdomain_takeover(){
echo -e "\n\e[00;34m#################### Installing subzy takeover tool ###########################\e[00m"
command -v "subzy" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
         echo "..........Installing subzy takover tool.....\n\n:"
         go get -u -v github.com/lukasikic/subzy
         echo "..........Subzy takeover tool Installation done........\n\n:"
         else
         echo "subzy is already installed"
    fi
echo -e "\n\e[00;36m#################### Installing subjack takeover tool ###########################\e[00m"
sleep 1
command -v "subjack" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
          echo "..........Installing subjack tool........\n\n:"
          go get github.com/haccer/subjack
          cd ~/go/pkg/mod/github.com/haccer/
          sudo mv subjack@* subjack
          cd ~/go/
          mkdir src
          mkdir -p src/github.com
          sudo mv ~/go/pkg/mod/github.com/haccer ~/go/src/github.com/
         echo ".........Subjack takeover tool installation done.........\n\n"
          else
          echo "subjack is already installed"
    fi
}
subdomain_takeover
sleep 1
echo -e "\n\e[00;31m#################### Installing xss tools ###########################\e[00m"
xss_tools(){
command -v "Gxss" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
        echo "...................Installing Gxss tool...................."
        go get -u github.com/KathanP19/Gxss
        echo "...............Gxss successfully installed.................."
        else
        echo "..................Gxss already installed.................."
     fi
sleep 1
echo -e "\n\e[00;32m############ Installing ParamSpider tool #####################\e[00m"
if [[ ! -d ~/tools/ParamSpider ]]; then
       cd ~/tools
        git clone https://github.com/devanshbatham/ParamSpider
       cd ParamSpider
       pip3 install -r requirements.txt
       echo "............ParamSpider Successfully Installed................"
       else
       echo "............ParamSpider already installed....................."
    fi
sleep 1
echo -e "\n\e[00;36m############ Installing Arjun tool #####################\e[00m"
if [[ ! -d ~/tools/Arjun ]]; then
       cd ~/tools
      git clone https://github.com/s0md3v/Arjun.git
       cd Arjun
       sudo python3 setup.py install
       echo "............Arjun Successfully Installed................"
       else
       echo "............Arjun already installed....................."
    fi
}
xss_tools
echo -e "\n\e[00;35m############ All Done Now Enjoy Your Hunting Automation #####################\e[00m"
