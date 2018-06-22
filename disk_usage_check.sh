#!/bin/bash

BREAK="============================================================"

NotRun=()              # Array to store all commands not run during script

PrintHeader() {        # Common header used throughout script
    echo -ne "\n$BREAK \n \t == $1 == \n$BREAK \n\n";
}
usage() {              # Print script usage function
    echo "Usage : $0"
    echo "Usage : $0 -f filesystem"
    exit 1
}
lsof_check_number() {  # Check deleted files function
    if [ $(lsof 2> /dev/null | awk '/$filesystem/ && /deleted/' | awk '{ if($9 > 1048576) print $9/1048576, "MB ",$9,$1 }' | sort -n -u | tail ) ]; then
        PrintHeader "Open Deleted Files Over 1GB"
        echo -ne "\n $BREAK \n \t Open Deleted Files on :$filesystem bigger than 1GB \n $BREAK \n\n";
        lsof 2> /dev/null | awk '/$filesystem/ && /deleted/' | awk '{ if($9 > 1048576) print $9/1048576, "MB ",$9,$1 }' | sort -n -u | tail;
    else
        NotRun+=("lsof_large")
    fi
}
home_rack() {         # Check disk usage in /home/rack
    if [ -d "/home/rack" ]; then
        rack=$( du /home/rack | awk '{print $1}' )
        if [ $rack -gt 1048576 ]; then 
            PrintHeader "/home/rack/ LARGE! Please check"
            echo "$( du -h /home/rack --max-depth=1  | head -5 )"
            echo
        else
            NotRun+=("home_rack")
        fi
    else
        NotRun+=("home_rack_exists_false")
    fi
}
NotRun() {           # Print a list of commands not run at the end of the script
    echo $BREAK
    echo

    for i in "${NotRun[@]}"; do

        case $i in

        "vgs" )
            echo "[OK]      No Volume groups (vgs) found"
        ;; 
        "lsof" )
            echo "[CHECK]   lsof not found, cannot check 'Open Deleted Files'"
        ;;
        "lsof_large" )
            echo "[OK]      No deleted files over 1GB"
        ;;
        "home_rack" )
            printf "[OK]      /home/rack smaller than 1GB: $(($rack / 1024)) MB\n"
        ;;
        "home_rack_exists_false" )
            echo "[WARNING] /home/rack does not appear to exist"
        ;;
        esac
        echo
    done
}


# Checking the script arguments and assigning the appropriate $filesystem
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

echo 

PrintHeader "Filesystem Information"

df -PTh $filesystem;

echo

df -PTi $filesystem;

PrintHeader "Largest Directories"
du -hcx --max-depth=2 $filesystem 2>/dev/null | grep -P '^([0-9]\.*)*G(?!.*(\btotal\b|\./$))' | sort -rnk1,1 | head -10 | column -t;

PrintHeader "Largest Files"
find $filesystem -mount -ignore_readdir_race -type f -exec du {} + 2>&1 | sort -rnk1,1 | head -20 | awk 'BEGIN{ CONVFMT="%.2f";}{ $1=( $1 / 1024 )"M"; print;}' | column -t

# Check to see if logical volumes are being used
if [ $( vgs $(df -h $filesystem | grep dev | awk '{print $1}'| cut -d\- -f1| cut -d\/ -f4) ) ]; then
    PrintHeader "Volume Group Usage"
    vgs $(df -h $filesystem | grep dev | awk '{print $1}'| cut -d\- -f1| cut -d\/ -f4)
else
    NotRun+=("vgs")
fi

# Check if lsof is installed
if [ $( which lsof 2>/dev/null ) ]; then 
    lsof_check_number
else
    NotRun+=("lsof_large")
fi

# Run home_rack function to check disk usage
home_rack

# Print commands/sections not run
NotRun

echo 
echo $BREAK
echo 

exit 0
