#! /bin/bash
#
# Filename: mybackup.sh
# Author: Eitan Raul Chavez

#Here display a message in case the argument was not introduced
#filename=$1
#filename=${1:?"filename missing."}

echo -e "\n##############################"
echo "#### Syncronized backup  #####"
echo -e "##############################\n"
sleep 0.5

#Function that will be called in future operations
source_backup () 
{
until [ $loop == "Y" ]; do
echo -e " **** Welcome this section allows to make a manual backup using rsync command ****"
	echo -n "Type an existing source directory or file: "
	read source
	if [ -z $source ]; then
		echo "enter an existing directory or file, please"
## Typing echo -n suppres the trailing newline
	elif [ -f $source ] || [ -d $source ] ; then
		echo -n "Is $source your source? Y/n: "
		read answer
		if [ $answer == "Y" ] || [ $answer == "y" ]
       			then
			loop="Y"
		else
			echo "Please retype directory"
		fi
	else
		echo -e "There is not directory or file, try again\n"
	fi
## Typing echo -e enables backescape sequences
done
}


#Check if the argument filename has been declared in case not will ask again

#Function that will be called in future operations
destination_source ()
{
until [ $loop2 == "Y" ]; do
	echo -n "Type destination directory, in case the directory does not exist, this script will create a new one: "
	read destination
#destination=$@
	#if [ -d $destination ]; then
	#	echo "procfile: No file specified"
	case $destination in
		${destination%%.*}) echo -n "is $destination your destination? y/n: "
		read answer
		if [ $answer == "Y" ] || [ $answer == "y" ]
			then
			mkdir $destination	
			loop2="Y"
			echo -e "\n ######## making a rsync #######\n"
			rsync -azvh $source $destination
		else
			echo "Please retype directory"
		fi
			;;
	*) echo "$destination format not supported, please do not write extensions"
			;;		
	esac
	#else

# -a Create a rsync using the archive mode,-z compress de data,-v verbose, -h humand readable numbers and -ecopies data recursively (but don't preserve
#timestamps and permissions while transferring data
	##--include --exclude
	##--dry-run
done
}


#Creates a new script used to run when it is applied to a cronjob.

script_generator () {
echo -e "**** Welcome! This section allows to schedule backups using tar command ****\n"
echo -n "Please, select an existing directory or file to back up: "
read source_backup

if [ -f $source_backup ] || [ -d $source_backup ]; then
	echo -en "Also write a name for the new script, this will be used to run automatically with crontab: "
	read script
	script=${script%%.*}.sh
	echo -n "The new script file '$script' will be created, alright? y/n: "
	read ans
	if [ $ans == "Y" ] || [ $ans == "y" ]
	  then
cat > ${script} <<EOF
#!/bin/bash
tar -cvf ${source_backup}_$(date +%Y%m%d).tar ${source_backup}
EOF
cat >> ${script} <<EOD
touch file.jpg
EOD
chmod +x ${script}
	cronjob_start
	echo "Script created, now please once the script is done type crontab -e and modify the parameters"
	else
		echo "retype, again"
	fi
else
 	echo "no files or directory found, try again"
fi
}

cronjob_start () {
	crontab -l > mycron
	echo "* */8 * * 1-5 $PWD/$script" >> mycron
	crontab mycron
	rm mycron
}

exit_trap () {	
trap 'echo Thank you for using this script!' EXIT
sleep 1
}

#This is the start of the menu, where you have to select the option

PS3="Welcome, please select one operation: "
select opt in rsync_manual_backup cronjob_tar quit; do
#restart values
loop=0
loop2=0

	case $opt in
		rsync_manual_backup) 
			echo -e "\nYou chose manual backup, you can specifiy the source and destination to backup with rsync command\n"
			source_backup
			destination_source
			;;

		cronjob_tar)
			echo -e "\nYou chose to schedule a cronjob and tar commands"
			script_generator
			;;

		quit)
			exit_trap
			break
			;;
		*)
			echo "Invalid option try again"
			;;
	esac
done


#It start the backup process by display the statement and date
#echo "Preparing to create a new backup"
#fecha=$(date +"Year: %Y, Month: %m, Day: %d")


#Here checks file to determine which are going to be copiead 
#echo "Checking all the files"
#for filename in "$@"; do
	#create backup
#	backup_date=$(date +%Y%m)
#	tar cvf backup_${backup_date}.tar ${filename} . #create version file xtract version file
#done
