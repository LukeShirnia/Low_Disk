#!/bin/bash

lsof_check() {

    echo -ne "\n $BREAK \n \t Number of Open Deleted Files on:$filesystem \n $BREAK \n\n";
    lsof 2> /dev/null | grep $filesystem | grep deleted | wc -l;
 
    echo -ne "\n $BREAK \n \t Open Deleted Files on :$filesystem bigger than 1GB \n $BREAK \n\n";
    lsof 2> /dev/null | grep $filesystem | grep deleted| awk '{ if($9 > 1048576) print $9/1048576, "MB ",$9,$1 }' | sort -n -u | tail;

}

ServerTime() {
    date "+%F %H:%M %Z"
}
PrintHeader() {
    echo -ne "\n $BREAK \n \t == $1 == \n $BREAK \n\n";
}
Intro() {
    echo
    echo "If you would like to run this against another filesystem please specify it with the -f flag"
    echo "Example: monkey -d -- -f /data/"
    echo ""
}

BREAK="============================================================"



Intro

# check if alternative filesystem has been specified
if [ $# == 0 ]; then
    filesystem="/"
elif [ $# == 2 ] && [ $1 == '-f' ]; then
    filesystem=$2
fi

# Check filesystem exists
if [ ! -d $filesystem ]; then
    echo "Filesystem does NOT exist"
    exit
fi

PrintHeader "Server Date/Time"

ServerTime

echo 
# Echo the filesystem the script is being run against
echo "Running against $filesystem Filesystem"

PrintHeader "Filesystem Information"
df -PTh $filesystem;

PrintHeader "Inode Information"
df -PTi $filesystem;

PrintHeader "Largest Directories"
du -hcx --max-depth=2 $filesystem 2>/dev/null | grep -P '^([0-9]\.*)*G(?!.*(\btotal\b|\./$))' | sort -rnk1,1 | head -10 | column -t;

PrintHeader "Largest Files"
find $filesystem -mount -ignore_readdir_race -type f -exec du {} + 2>&1 | sort -rnk1,1 | head -20 | awk 'BEGIN{ CONVFMT="%.2f";}{ $1=( $1 / 1024 )"M"; print;}' | column -t

PrintHeader "Largest Files Older Than 30 Days"
find $filesystem -mount -ignore_readdir_race -type f -mtime +30 -exec du {} + 2>&1 | sort -rnk1,1 | head -20 | awk 'BEGIN{ CONVFMT="%.2f";}{ $1=( $1 / 1024 )"M"; print; }' | column -t

PrintHeader "Volume Group Usage"

vgs $(df -h $filesystem | grep dev | awk '{print $1}'| cut -d\- -f1| cut -d\/ -f4)


if [ $( which losf 2>/dev/null ) ]; then 
    lsof_check
fi

echo 
echo $BREAK
echo 
