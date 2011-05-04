#!/bin/sh
#
# restore_drupal.sh
# restore a backed up version of a drupal website
#
# Author: Mike Imelfort : mike_at_mikeimelfort_dot_com
# Copyright Mike Imelfort 2011.
#
# The drupal_sync program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# REQUIRES:
#
# drupal_dir    -- base directory of the drupal install
# sql_user      -- username for the database
# sql_pass      -- password for sql user
# database_name -- name of the drupal database
#
# overwrites the existsing installation from a gzipped backup of the db in the backupdir. 
#
# WARNING! can nuke your website!
#
# You could use this file to make backups of your drupal site
# separate from the sync system
#

if [ $# = 0 ] ; then
    echo ERROR: usage $0 drupal_dir sql_user sql_pass db_name backup_file
    exit
fi

# poor mans getopt
drupal_dir=$1
sql_user=$2
sql_pass=$3
database_name=$4
backup_file_name=$5

rand_string=$( echo $backup_file_name | sed -e "s/^.*_//" -e "s/\..*$//")

# make some sql suff fo-rizzle
sql_filename=$drupal_dir"/"$database_name"."$rand_string".sql.gz"
sql_filename_unzipped=$drupal_dir"/"$database_name"."$rand_string".sql"
sql_id="--user="$sql_user" -p"$sql_pass" "$database_name

# GO GO GO!
echo "Extracting tarball: "$backup_file_name

# FILES
eval "tar -xzf "$backup_file_name" -C "$drupal_dir

# SQL
gunzip $sql_filename
sql_cmd="mysql --force "$sql_id" < "$sql_filename_unzipped
eval $sql_cmd
rm $sql_filename_unzipped
