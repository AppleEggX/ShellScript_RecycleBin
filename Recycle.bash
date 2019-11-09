#!/bin/bash


#######################################################################
##################  This is the function for first level errer#########
#######################################################################

#Create recyclebin if it's not there
function first_check(){
        if [ -d $HOME/recyclebin ]
        then
                rbin=$HOME/recyclebin
        else
                mkdir $HOME/recyclebin
        fi

# Here starts to detect wheather there are arguments or not
        if [[ -z $fileName ]]
        then
                echo "No filename provided"
                exit
        fi
}

##########################################################################
####   these two funciton check the argurment r right or not##############
##########################################################################
function directory_check(){
        if [[ $opt_f = true ]]  #If -f is used than ignore this check
        then
                return 0
        else
                if [[ "$fileType" = directory ]]
                then
                        echo "directory name provided"
                        exit
                fi
        fi
}

function error_Check(){
        find $fileName >/dev/null 2>/dev/null
        local result=$?

        if [[ $fileName =~ .*recycle.sh ]]
        then
                echo "Attempting to delete recycle - operation aborted"
                exit
        elif [[ $result = 1 ]]
        then
                echo "File does not exit"
                exit
        fi
}

#################################################################################
#### if -r is used, then this is the fucntion to delete the folder recusivley####
#################################################################################
function delete_directory(){
        local temp=$fileNme
        fileName=$fileName/* 2>/dev/null
        local result=$(file $fileName |cut -d' ' -f2 2>/dev/null)
        # get the folder name
        [[ $result = 'cannot' ]] && return 0
                #strarts the recusive folder creation
                for file_in_dir in $fileName
                do
                        local pre_fileName=$file_in_dir
                        local filetype=$(file $file_in_dir |rev |cut -d ' ' -f1 |rev )
                        if [[ $filetype = directory ]]
                        then
                                delete_directory
                                rmdir $pre_fileName
                                if [[ $opt_v = true ]]; then
                                        echo "removed folder '$pre_fileName'"
                                fi
                        else
                                #The deleteion process is same as the normal one
                                inode=$(ls $file_in_dir -i |cut -d' ' -f1)
                                local filename=$(echo $file_in_dir |rev |cut -d'/' -f1 |rev) 2>/dev/null
                                newName=${filename}_${inode}
                                local abpath=$(readlink -f $file_in_dir)
                                echo "${newName}:${abpath}" >> $HOME/.restore.info
                                mv $file_in_dir $HOME/recyclebin/$newName
                                if [[ $opt_v = true ]]; then
                                        echo "removed '$filename' to the bin"
                                fi
                        fi
                done


}
####################################################################
##### THis is the normal deleting process fucntion #################
####################################################################
function change_Name(){
        if [[ $fileType = directory ]]
        then
                delete_directory
                rmdir $i
                if [[ $opt_v = true ]]; then
                        echo "removed folder '$i'"
                fi
        else
                # this is the deleting process
                inode=$(ls $fileName -i | cut -d ' ' -f1)
                filename=$(echo $fileName | rev | cut -d '/' -f1 |rev)
                newName=${filename}_${inode}
                echo "${newName}:${abPath}" >> $HOME/.restore.info
                mv $fileName $HOME/recyclebin/$newName
                if [[ $opt_v = true ]]; then
                        echo "removed '$filenam to the bin'"
                fi
        fi

}

########################################################################################
#####################   MAIN FUCNTION   ################################################
#################################################################################

if [[ $1 =~ ^'-' ]]
# check the first is opts or not if is not , then go to the reguler one,
# if it is opts then the file name start with the one behind the opts
then
        while getopts ivf opt
        do
                case $opt in
                        i) opt_i=true;;
                        v) opt_v=true;;
                        f) opt_f=true;;
                        *) echo "Wrong options were input, please input -v -i -f or nothing"
                                exit 1 ;;
                esac
                count=$[${count} + 1]
        done
fi
# find the first file name argument
for i in $@
do
        if [[ $i =~ ^'-' ]]; then
                shift
        else
                fileName=$i
                break
        fi
done
# stats the deleting process
first_check
fileType=$(file $1|rev|cut -d ' ' -f1 |rev )
directory_check
error_Check

# statrs the multiple deletetion
for i in $@
do
        find $i >/dev/null 2>/dev/null
        [[ $? = 1 ]] && echo "File '$i' not found" && continue
        abPath=$(readlink -f $i)
        fileName=$i
        fileType=$(file $i |rev |cut -d ' ' -f1 |rev )

        if [[ $opt_i = true ]]
        then
                read -p "Do you want to delete $fileType $fileName [No] " answer
                if [[ $answer =~ ^[y,Y] ]]; then
                        change_Name
                fi
        else
                change_Name
        fi
done

echo "Command done"


