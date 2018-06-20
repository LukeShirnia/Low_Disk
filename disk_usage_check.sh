#!/bin/bash

BREAK="============================================================"

NotRun=()

ServerTime() {
    date "+%F %H:%M %Z"
}
PrintHeader() {
    echo -ne "\n$BREAK \n \t == $1 == \n$BREAK \n\n";
}
usage() {
    echo "Usage : $0"
    echo "Usage : $0 -f filesystem"
    exit 1
}
lsof_check_number() {
    PrintHeader "Number of Open Deleted Files on: $filesystem"
    if [ $(lsof 2> /dev/null | grep $filesystem | grep deleted | wc -l ) ]; then
        printf "Number of deleted files: "
        lsof 2> /dev/null | grep $filesystem | grep deleted | wc -l;
        echo
    else
        return
    fi
    
    if [ $(lsof 2> /dev/null | awk '/$filesystem/ && /deleted/' | awk '{ if($9 > 1048576) print $9/1048576, "MB ",$9,$1 }' | sort -n -u | tail ) ]; then
        PrintHeader "Open Deleted Files Over 1GB"
        echo -ne "\n $BREAK \n \t Open Deleted Files on :$filesystem bigger than 1GB \n $BREAK \n\n";
        lsof 2> /dev/null | awk '/$filesystem/ && /deleted/' | awk '{ if($9 > 1048576) print $9/1048576, "MB ",$9,$1 }' | sort -n -u | tail;
    else
        NotRun+=("lsof_large")
    fi
}
home_rack() {
    if [ $( du /home/rack | awk '{print $1}' ) -gt 1073741824 ]; then 
        echo "/home/rack LARGE! Please check"
    else
        NotRun+=("home_rack")
    fi
}
NotRun() {
    echo $BREAK
    echo

    for i in "${NotRun[@]}"; do

        case $i in

        "vgs" )
            echo "[OK]    No Volume groups (vgs) found"
        ;; 
        "lsof" )
            echo "[CHECK] lsof not found, cannot check 'Open Deleted Files'"
        ;;
        "lsof_large" )
            echo "[OK]    No deleted files over 1GB"
        ;;
        "home_rack" )
            echo "[OK]    /home/rack smaller than 1GB"
        ;;
        esac
        echo
    done
}



case $1 in

"" )
    filesystem="/"   
;;
"-f")
    case $# in
    "1")
        echo "Please enter 2 arguments"
        echo
        usage
    ;;
    "2")
        if [ -d $2 ]; then
            filesystem=$2
        else
            echo "Filesystem argument doesn't exist"
            echo
            usage
        fi
    ;;
    * ) 
        usage    
    ;;
    esac
;;
"--help" | "-h" | *)
    usage
;;
esac


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


if [ $( vgs $(df -h $filesystem | grep dev | awk '{print $1}'| cut -d\- -f1| cut -d\/ -f4) ) ]; then
    PrintHeader "Volume Group Usage"
    vgs $(df -h $filesystem | grep dev | awk '{print $1}'| cut -d\- -f1| cut -d\/ -f4)
else
    NotRun+=("vgs")
fi


if [ $( which lsof 2>/dev/null ) ]; then 
    lsof_check_number
else
    NotRun+=("lsof_large")
fi

home_rack

NotRun

echo 
echo $BREAK
echo 

exit 0
