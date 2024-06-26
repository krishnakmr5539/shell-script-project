#!/bin/bash

rm -rf /volume/CSdata/krikumar/Microsoft-automation/pr_report.csv

#Fetching raw PR data 60 days old filtering with our manager name#
/volume/buildtools/bin/query-pr --format '"%s$ %s$ %s$ %s$ %s$ %s$ %s$" number Synopsis Customer Product Originally-Reported-In Responsible' -o /volume/CSdata/krikumar/Microsoft-automation/pr_report.csv  -e 'Arrival-Date > "700 day ago" & ((Responsible[manager]=="vvikas" | Responsible[manager]=="gowtham" | Originator[manager]=="vvikas" | Originator[manager]=="gowtham" ))'


sleep 5
cat /volume/CSdata/krikumar/Microsoft-automation/pr_report.csv | grep -v "srx\|nfx" > /volume/CSdata/krikumar/Microsoft-automation/pr_report1.csv
sort -r /volume/CSdata/krikumar/Microsoft-automation/pr_report1.csv  > /volume/CSdata/krikumar/Microsoft-automation/pr_report1-sorted.csv #Sort new PR on top#


#Segregating different customer PR to different file#
cat /volume/CSdata/krikumar/Microsoft-automation/pr_report1-sorted.csv | grep -i microsoft  > /volume/CSdata/krikumar/Microsoft-automation/Microsoft-pr-x11.csv

cat  /volume/CSdata/krikumar/Microsoft-automation/Microsoft-pr-x11.csv  | grep -v  " $ "   >  /volume/CSdata/krikumar/Microsoft-automation/Microsoft-pr-x1.csv

#Function for fromating output in html fromat#

myfunction()
{
        n=1
        while read line; do
                pr1="$(echo "$line" | cut -c 1-7)"
                user1="$(echo "$line" | awk -F'$' '{print $2 | "cut -c 1-10"}')"
                platform1="$(echo "$line" | awk -F'$' '{ print $3 | "cut -c 1-10"}')"
                version1="$(echo "$line" | awk -F'$' '{ print $4| "cut -c 1-13"}')"
                synopsis1="$(echo "$line" | awk -F'$' '{ print $5}')"

        echo "<p><a href=https://gnats.juniper.net/web/default/$pr1#description_tab>$pr1</a>-<span style="color:purple">$user1</span>-<span style="color:red">$platform1</span>-<span style="color:purple">$version1</span>-$synopsis1</p>"
                n=$((n+1))
done < /volume/CSdata/krikumar/Microsoft-automation/Final-PR-Report-x
}

rm -rf /volume/CSdata/krikumar/Microsoft-automation/Final-PR-Report-x


echo  "\n <h5><p style="color:black">MICROSOFT PRs</p></h5> \n"  > /volume/CSdata/krikumar/Microsoft-automation/Final-PR-Report-html-tag-x.html
awk -F'$' '{d[$2]++;if(d[$2]==1) print $1 "$",$6"$",$4"$",$5"$",$2}' Microsoft-pr-x1.csv  >> /volume/CSdata/krikumar/Microsoft-automation/Final-PR-Report-x;

myfunction > /volume/CSdata/krikumar/Microsoft-automation/Final-PR-Report-html-tag-x.html  #Function called here for formating and saving output to final file#


sleep 2

mail -a 'Content-Type: text/html' -s "Automated PR Report for Enterprise Customers" krikumar@juniper.net < /volume/CSdata/krikumar/Microsoft-automation/Final-PR-Report-html-tag-x.html
