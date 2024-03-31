
#!/bin/bash

rm -rf project-x.csv

#Fetching raw PR data 60 days old filtering with our manager name#

/volume/buildtools/bin/query-pr --format '"%s$ %s$ %s$ %s$ %s$ %s$ %s$" number Synopsis Customer Product Originally-Reported-In Responsible' -o project-x.csv  -e 'Arrival-Date > "700 day ago" & ((Responsible[manager]=="vvikas" | Responsible[manager]=="gowt
ham" | Originator[manager]=="vvikas" | Originator[manager]=="gowtham" ))'


sleep 5
cat project-x.csv | grep -v "srx\|nfx" > project-x1.csv
sort -r project-x1.csv  > project-x-sorted.csv #Sort new PR on top#


#Segregating different customer PR to different file#
cat project-x-sorted.csv | grep -i microsoft  > Microsoft-pr-x11.csv

cat  Microsoft-pr-x11.csv  | grep -v  " $ "   >  Microsoft-pr-x1.csv



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
done < Final-PR-Report-x
}

rm -rf Final-PR-Report-x


echo  "\n <h5><p style="color:black">MICROSOFT PRs</p></h5> \n"  > Final-PR-Report-html-tag-x.html
awk -F'$' '{d[$2]++;if(d[$2]==1) print $1 "$",$6"$",$4"$",$5"$",$2}' Microsoft-pr-x1.csv  >> Final-PR-Report-x;

myfunction > Final-PR-Report-html-tag-x.html  #Function called here for formating and saving output to final file#


sleep 2

mail -a 'Content-Type: text/html' -s "Automated PR Report for Enterprise Customers" krikumar@juniper.net < Final-PR-Report-html-tag-x.html
