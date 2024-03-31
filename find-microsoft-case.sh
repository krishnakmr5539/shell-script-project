
#!/bin/bash

msft_time=$(date '+_%Y-%m%d')

today_date=$(date '+%Y-%m%d')

#msft_time = $(TZ=GMT date '+_%Y-%m%d') #UTC time zone#

year=$(date '+%Y')

date=$(date | awk '{ print $2 " " $3 }')
 
rm -rf  /volume/CSdata/krikumar/Microsoft-automation/microsoft-case-list.txt 
 
 
ls -l /volume/case_$year | grep "$date" | grep -v "xfr\|meta"  > /volume/CSdata/krikumar/Microsoft-automation/today-modified-case-report.txt #finding all case modified today#
 
 #Find the case numebr in case format#
cat /volume/CSdata/krikumar/Microsoft-automation/today-modified-case-report.txt | awk '{print $9}' >  /volume/CSdata/krikumar/Microsoft-automation/case-list-formated.txt 

 
while read line;  #Find the Microsoft cases which conatain a pattern#
do
find /volume/case_$year/$line -name "*$line_logs_generic.logs" 2>/dev/null  | awk -F'/' '{print $4}'  >>  /volume/CSdata/krikumar/Microsoft-automation/microsoft-case-list.txt
done < /volume/CSdata/krikumar/Microsoft-automation/case-list-formated.txt


rm -rf /volume/CSdata/krikumar/Microsoft-automation/case-list.txt
rm -rf /volume/CSdata/krikumar/Microsoft-automation/final-case-list.txt

while read line;  #removing the false positive case which logs were not uploaded today , however were modified by adding different logs#
do
   ls -l  /volume/case_$year/$line | grep "$date" | grep  _logs_generic.logs  > /volume/CSdata/krikumar/Microsoft-automation/case-list.txt
   cat /volume/CSdata/krikumar/Microsoft-automation/case-list.txt | awk -F '_' '{print $3}' >> /volume/CSdata/krikumar/Microsoft-automation/final-case-list.txt
done < /volume/CSdata/krikumar/Microsoft-automation/microsoft-case-list.txt


#Fina Microsoft case in the file final-case-list #

