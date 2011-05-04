#!/bin/sh
#
# Dev vs production sync for a drupal website
# Script to pull from a production machine to the dev machine
#
# You can't call this script directly, you'll need to have it wrapped in
# some other sheel script which sets a whole bunch of environment variables 
# and can also do a number of kludges specific to the site you are trying to sync.
#
# Michael Imelfort - May - 4 - 2011
#

if [ $# = 0 ] ; then
    echo ERROR: usage $0 rcfile unsetfile
    exit
fi

# load the passwords etc...
. $1

# bundle the production directory
echo "Bundling production server files and SQL..."
prod_bundle_cmd="ssh "$server_name" "$production_bin_dir"/"$backup_script" "$site_name" "$production_site_location" "$production_backup_location" "$production_db_user" "$production_db_pass" "$production_db_name
#echo "PROD BNDL CMD "$prod_bundle_cmd
bundle=$($prod_bundle_cmd)

# copy it across
echo "Downloading file: "$bundle" from the production server..."
scp_cmd="scp "$server_name":"$production_backup_location"/"$bundle" "$dev_backup_location"/"$bundle 
#echo "using scp command: "$scp_cmd
eval $scp_cmd

# remove the bundled files to save some room
echo "Removing bundled file on production server..."
prod_clean_cmd="ssh "$server_name" rm "$production_backup_location"/"$bundle
#echo "PROD cleanup command: "$prod_clean_cmd
eval $prod_clean_cmd

# make a bundle of this directory.
echo "Backing up dev files and SQL..."
dev_backup_cmd=$dev_bin_dir"/"$backup_script" "$site_name" "$dev_site_location" "$dev_backup_location" "$dev_db_user" "$dev_db_pass" "$dev_db_name
#echo "using dev backup command: "$dev_backup_cmd
dev_backup=$($dev_backup_cmd)
echo "Backup stored at: "$dev_backup_location"/"$dev_backup

# restore the production directory from here
echo "Overwriting dev site files and SQL..."
dev_rst_cmd=$dev_bin_dir"/"$restore_script" "$dev_site_location" "$dev_db_user" "$dev_db_pass" "$dev_db_name" "$dev_backup_location"/"$bundle
#echo "DEV RST CMD "$dev_rst_cmd
eval $dev_rst_cmd

# remove the file copied over:
echo "Removing downloaded file..."
dev_clean_cmd="rm "$dev_backup_location"/"$bundle
#echo "DEV cleanup command: "$dev_clean_cmd
eval $dev_clean_cmd

# unload the passwords etc...
. $2