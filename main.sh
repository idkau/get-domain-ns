#!/bin/bash
#
#For usage on server CLI example: ./get-domain-ns.sh v1.pau.vps server
#Put domains in a list of one column and name the file "domainlist" if using locally
#Send output to CSV file
#Get the domainlist off the server with cat /etc/userdomains | cut -d :  -f 1
#Example:    bash get-domains-ns.sh >> EXC-output.csv
#Example with stdout: bash get-domain-ns.sh | tee -a EXC-output.csv
#No output after domain means the domain is not registered.
#
#by Jason Pearl
#
#
#---------------------------------------------------------------------

#Add TLD constants here.

AU='q.au'
COM='g.gtld-servers.net'
NZ='ns6.dns.net.nz'
CO='ns4.cctld.co'
ORG='a0.org.afilias-nst.info'
NET='g.gtld-servers.net'
HOSTING='ns3.uniregistry.net'
IO='b0.nic.io'
INFO='a0.info.afilias-nst.info'
BIZ='c.gtld.biz'
CC='ac3.nstld.com'
SYSTEMS='v0n0.nic.systems'
ASIA='d0.asia.afilias-nst.asia'
COMNR='ns0.cenpac.net.nr'
LIMITED='v0n0.nic.limited'

vpsId=$1
count=0

if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "\nYou forgot something..." 
    echo -e "\nUsage: $0 VPS-ID 'local or server'\n"
    echo -e "$0 VPS-ID server\n"
    exit
fi

#Get the correct server to query authoritative names by tld

getTLD() {     

    case $domain in

    *"com.au"*)
                tld=$AU
                ;;
    *"net.au"*)
                tld=$AU
                ;;
   *".org.au"*)
                tld=$AU
                ;;
   *".edu.au"*)
                tld=$AU
                ;;
    *".id.au"*)
                tld=$AU
                ;;
     *"co.nz"*)
                tld=$NZ
                ;;
    *"net.nz"*)
                tld=$NZ
                ;;
       *".nz"*)
                tld=$NZ
                ;;
      *".com"*)
                tld=$COM
                ;;
       *".co"*)
                tld=$CO
                ;;
      *".org"*)
                tld=$ORG
                ;;
      *".net"*)
                tld=$NET
                ;;
  *".hosting"*)
                tld=$HOSTING
                ;;
       *".io"*)
                tld=$IO
                ;;
     *".info"*)
                tld=$INFO
                ;;
      *".biz"*)
                tld=$BIZ 
                ;;
       *".cc"*)
                tld=$CC 
                ;;
  *".systems"*)
                tld=$SYSTEMS
                ;;
     *".asia"*)
                tld=$ASIA
                ;;
   *".com.nr"*)
                tld=$COMNR
                ;;
  *".limited"*)
                tld=$LIMITED
                ;;

             *)
                echo "No TLD match. Lookup manually or modify script."
                ;;
    esac

}

# Added to keep the admin entertained while the script runs for extended periods

stillWorking() {
    
    if [ $count == 10 ]; then
        echo "Still working... Please wait..."
        ((count = 0))
    else
        ((count++))
    fi
    
}
if [ $2 == "local" ]; then
    echo -e "\nRunning script for localhost"
    
elif [ $2 == "server" ]; then

    cut -d : -f 1 /etc/userdomains | sed 1d > domainlist
fi

# Pull domains from domain list.

for domain in $(cat domainlist);
do 
    
    getTLD $domain   

    echo $domain >> $vpsId.csv #Needed for centos digs
    dig A $domain | grep "A" | sed 1,5d >> $vpsId.csv
    dig MX $domain | grep "MX" | sed 1,2d >> $vpsId.csv
    dig NS $domain @$tld | grep -e "NS" | sed 1,3d >> $vpsId.csv 
    echo "," >> $vpsId.csv
    sleep 1
    stillWorking 
done 

#Send the csv file to AWS for processing and storage. workmail addy > SES > S3 > lambda > S3

echo "$vpsId" | mail -s "$vpsId" -a $vpsId.csv yourownemail@aws-automation.awsapps.com

echo -e "Mail sent...\n"

echo -e "Finished Successfully!\n"

if [ $2 == "server" ]; then
    echo "Do you want to delete the domainlist file? (y or n) "
    read doDelete
    if [[ $doDelete == "y" ]]; then
        rm -f domainlist
        echo -e "File deleted..."
    else
        echo -e "File not deleted...\n"
    fi
fi