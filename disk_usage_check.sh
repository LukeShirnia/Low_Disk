#!/bin/bash

BREAK="============================================================"

echo
echo "If you would like to run this against another filesystem please specify it with the -f flag"
echo "Example: monkey -d -- -f /data/"
echo ""

ServerTime() {
    date "+%F %H:%M %Z"
}

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

# Print data and time
echo "== Server Date/Time: ==";
ServerTime
echo 
# Echo the filesystem the script is being run against
echo "Running against $filesystem Filesystem"


echo -ne "\n $BREAK \n \t == Filesystem Information == \n $BREAK \n\n";
df -PTh $filesystem;

echo -ne "\n $BREAK \n \t == Inode Information == \n $BREAK \n\n";
df -PTi $filesystem;

echo -ne "\n $BREAK \n \t == Largest Directories ==  \n $BREAK \n\n";
du -hcx --max-depth=2 $filesystem 2>/dev/null | grep -P '^([0-9]\.*)*G(?!.*(\btotal\b|\./$))' | sort -rnk1,1 | head -10 | column -t;

echo -ne "\n $BREAK \n \t == Largest Files ==  \n $BREAK \n\n";
find $filesystem -mount -ignore_readdir_race -type f -exec du {} + 2>&1 | sort -rnk1,1 | head -20 | awk 'BEGIN{ CONVFMT="%.2f";}{ $1=( $1 / 1024 )"M"; print;}' | column -t

echo -ne "\n $BREAK \n \t == Largest Files Older Than 30 Days ==  \n $BREAK \n\n";
find $filesystem -mount -ignore_readdir_race -type f -mtime +30 -exec du {} + 2>&1 | sort -rnk1,1 | head -20 | awk 'BEGIN{ CONVFMT="%.2f";}{ $1=( $1 / 1024 )"M"; print; }' | column -t

echo -ne "\n $BREAK \n \t == Volume Group Usage == \n $BREAK \n\n";
vgs $(df -h $filesystem | grep dev | awk '{print $1}'| cut -d\- -f1| cut -d\/ -f4);

echo -ne "\n $BREAK \n \t Number of Open Deleted Files on:$filesystem \n $BREAK \n\n";
lsof 2> /dev/null | grep $filesystem | grep deleted | wc -l;

echo -ne "\n $BREAK \n \t Open Deleted Files on :$filesystem bigger than 1GB \n $BREAK \n\n";
lsof 2> /dev/null | grep $filesystem | grep deleted| awk '{ if($7 > 1048576) print $7/1048576, "MB ",$9,$1 }' | sort -n -u | tail;

echo $BREAK
