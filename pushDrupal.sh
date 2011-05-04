#!/bin/sh
#
# pushDrupal.sh
# Dev vs production sync for a drupal website
# Script to push from a dev machine to the production machine
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
# Dev vs production sync for a drupal website
# Script to push from a dev machine to the production machine
#
# You can't really call this script directly, you'll need to have it wrapped in
# some other sheel script which sets a whole bunch of environment variables 
# and can also do a number of kludges specific to the site you are trying to sync.
#

if [ $# = 0 ] ; then
echo ERROR: usage $0 siterc unsetrc
exit
fi

# load the passwords etc...
. $1

# make a backup of this directory and send it across...
echo "Bundling up dev site files and SQL..."
bundle_cmd=$dev_bin_dir"/"$backup_script" "$site_name" "$dev_site_location" "$dev_backup_location" "$dev_db_user" "$dev_db_pass" "$dev_db_name
#echo "using dev backup command: "$backup_cmd
bundle=$($bundle_cmd)

# copy it across
echo "Uploading file: "$bundle" to the production server..."
scp_cmd="scp "$dev_backup_location"/"$bundle" "$server_name":"$production_backup_location"/"$bundle
#echo "using scp command: "$scp_cmd
eval $scp_cmd

# remove the bundled files to save some room
echo "Removing bundled file on dev server..."
dev_clean_cmd="rm "$dev_backup_location"/"$bundle
#echo "DEV cleanup command: "$dev_clean_cmd
eval $dev_clean_cmd

# make a backup of the production directory
echo "Backing up production site files and SQL..."
prod_backup_cmd="ssh "$server_name" "$production_bin_dir"/"$backup_script" "$site_name" "$production_site_location" "$production_backup_location" "$production_db_user" "$production_db_pass" "$production_db_name
#echo "PROD BCK CMD "$prod_backup_cmd
prod_backup=$($prod_backup_cmd)
echo "Backup stored at: "$production_backup_location"/"$prod_backup

# restore the production directory from here
echo "Overwriting production site files and SQL..."
prod_rst_cmd="ssh "$server_name" "$production_bin_dir"/"$restore_script" "$production_site_location" "$production_db_user" "$production_db_pass" "$production_db_name" "$production_backup_location"/"$bundle
#echo "REM RST CMD "$prod_rst_cmd
eval $prod_rst_cmd

# remove the file copied over:
echo "Removing uploaded file..."
prod_clean_cmd="ssh "$server_name" rm "$production_backup_location"/"$bundle
#echo "PROD cleanup command: "$prod_clean_cmd
eval $prod_clean_cmd

# unload the passwords etc...
. $2
