#!/bin/bash
#######################################################
#################    check the arguments ##############
#######################################################
#check the aggrigation exist
function fisrt_check(){
        if [[ -z $fileName ]]; then
                echo "No filename provided!"
                exit
        fi
}


function error_check(){
        if [[ -z $filePath ]]; then
                echo "File does not exist"
                exit
        fi
}
########################################################
################  delete record in .restore.in #########
########################################################
function delete_record(){
        fileRecord=$(cat $HOME/.restore.info |grep -w $fileName)
        (cat $HOME/.restore.info | grep -v $fileRecord) | tee $HOME/.restore.info >/dev/null

}
#########################################################
#############  create the folder if neede and restore####
#########################################################
function restore_R(){
        local folder_path="/"
        local counter=2
        until [[ $folder_path = "${filePath}/" ]]
        do
                add_path=$(echo $filePath | cut -d'/' -f${counter})
                folder_path=${folder_path}${add_path}'/'
                mkdir $folder_path 2>/dev/null
                counter=$[${counter}+1]
        done
        mv ${HOME}/recyclebin/${fileName} ${filePath} 2>/dev/null
        delete_record
        echo "file ${fileName} is restored"
}

#######################################################
#####################   restore function ##############
#######################################################
function check_exist(){
        find $filePath >/dev/null 2>/dev/null
        local result=$?
        if [ $result -eq 1 ]; then
                if [[ $opt_r = "true" ]]; then
                        mv ${HOME}/recyclebin/${fileName} ${filePath} 2>/dev/null
                        [[ $? = 1 ]] && temp_path=$filePath && restore_R
                else
                        mv ${HOME}/recyclebin/${fileName} ${filePath} 2>/dev/null
                        [[ $? = 1 ]] && echo "can't restored without -r for recursive mode" && return 0
                        echo "restored the file '$fileName_orgin' to ${filePath}"
                        delete_record
                        exit
                fi
##########  This if for overwirt the file name ########
        else
                read -p "Do you want to overwrite '$fileName_orgin?[no] " answer
                if [[ $answer =~ ^[y,Y] ]]; then
                        mv %/HOME/recyclebin/$1 $filePathcd
                        echo "File '$fileName_orgin' has been restored"
                        delete_record
                        exit
                else
                        echo "Action cancled "
                        exit
                fi
        fi
}

##########################################################
##################  Main function  #######################
##########################################################

while getopts r opt
do
        case $opt in
                r) opt_r=true;;
                *) echo "Wrong options were input, please input -r for recursive resture"
        esac
done
################ find the first fle argument ############
if [[ $1 =~ ^'-' ]]
then
        fileName=$2
else
        fileName=$1
fi

fileName_orgin=$(echo $fileName | cut -d '_' -f1)
fisrt_check
filePath=$(cat $HOME/.restore.info |grep -w $fileName | cut -d':' -f2)
error_check
check_exist


