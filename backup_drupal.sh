#!/bin/sh
#
# make a backup of a drupal installation
#
# REQUIRES: (IDEALLY, these should all be stored in a resource file)
#
# site_name     -- name of the site we're backing up
# drupal_dir    -- base directory of the drupal install
# backup_dir    -- directory to send backups to
# sql_user      -- username for the database
# sql_pass      -- password for sql user
# database_name -- name of the drupal database
#
# creates a gzipped backup of the db in the backupdir.
#

if [ $# = 0 ] ; then
    echo ERROR: usage $0 site_name drupal_dir backup_dir sql_user sql_pass db_name [keep_settings]
    exit
fi

# poor mans getopt
site_name=$1
drupal_dir=$2
backup_dir=$3
sql_user=$4
sql_pass=$5
database_name=$6

# check if we sould copy the settings file...
while getopts s AA
do case $AA in
    s) copy_settings="1"
    ;;
esac
done

# set some filenames
timestamp=$(date '+%s')
mkdir -p $backup_dir
sql_filename=$drupal_dir"/"$database_name"."$timestamp".sql.gz"
tar_filename=$backup_dir"/"$site_name"_"$timestamp".tar.gz"

# SQL
sql_id="--user="$sql_user" -p"$sql_pass" "$database_name
mysqldump $sql_id | gzip -9 > $sql_filename

# FILES
cd $drupal_dir
eval "tar cf "$timestamp".tar *"
if test -z $copy_settings ; then
    eval "tar --delete sites/default/settings.php -f "$timestamp".tar"
    eval "tar --delete sites/default/default.settings.php -f "$timestamp".tar"
fi

eval "gzip "$timestamp".tar"
eval "mv "$timestamp".tar.gz "$tar_filename

# DUN!
rm $sql_filename
echo $site_name"_"$timestamp".tar.gz"

