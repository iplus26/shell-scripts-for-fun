#!/bin/bash

# A useful(maybe) script to find whether apps you've installed
#   are installed and not installed via brew-cask
# @author ivanjiang
# 
# Output should be like:
# 
#     !!! Installed applications: 146               # Num of application you've installed in /Applications/*
#     !!! Installed casks: 18                       # Num of casks you've installed via brew-cask
#     Found adapter (not installed by brew-cask)    # Iterate applications you've installed and also provided
#     Found aliedit (not installed by brew-cask)    #   by brew-casks...
#     Found aliwangwang (installed by brew-cask)
#     Found charles (installed by brew-cask)
#     ...
#     !!! All casks: 3994                           # Num of casks provided by brew-cask

INSTALLED_APP=()
ALL_CASKS=()
INSTALLED_CASK=()

for application in /Applications/*
do 
    filename="$(basename "$application")"
    filename="${filename%.*}"
    filename="$(echo $filename | tr '[:upper:]' '[:lower:]')"
    INSTALLED_APP+=("$filename")
done

INSTALLED_APP_LEN=${#INSTALLED_APP[@]}
echo "!!! Installed applications: $INSTALLED_APP_LEN"


while read line
do 
    installed_cask=$line
    INSTALLED_CASK+=("$installed_cask") 
done < <(brew cask list -1) # Run `process substitution` within bash: https://stackoverflow.com/a/30207833/4158282

INSTALLED_CASK_LEN=${#INSTALLED_CASK[@]}
echo "!!! Installed casks: $INSTALLED_CASK_LEN"

for cask in "$(brew --repository)"/Library/Taps/homebrew/homebrew-cask/Casks/*
do 
    caskname="$(basename "$cask")"
    caskname="${caskname%.*}"
    caskname="$(echo $caskname | tr '[:upper:]' '[:lower:]')"
    ALL_CASKS+=("$caskname")

    for ((i=0; i < $INSTALLED_APP_LEN; i++))
    do 
        if [ "$caskname"  =  "${INSTALLED_APP[$i]}" ]
        then 
            printf "Found $caskname"
            FOUND=false 
            for ((j=0; j < $INSTALLED_CASK_LEN; j++))
            do 
                if [ "$caskname" = "${INSTALLED_CASK[$j]}" ]
                then
                    FOUND=true
                fi
            done 

            if [ "$FOUND" = true ] 
            then 
                printf "\e[32m (installed by brew-cask) \e[0m" 
            else 
                printf "\e[31m (not installed by brew-cask) \e[0m" 
            fi

            printf "\n"
        fi 
    done
done 

# Number of casks provided by brew-cask
echo "!!! All casks: ${#ALL_CASKS[@]}"
