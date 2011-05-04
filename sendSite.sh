#!/bin/sh
#
# sendSite.sh
# wrapper script to sync dev and production sites --> push to production
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
# When you're pushing a live version of the site to a dev version
# you may have to kludge some stuff around. Fix symlinks etc...
# do all that nasty stuff here...
#

# load all the passwords etc and do the heavy lifting
cd ${0%/*}
pushDrupal.sh siterc unsetrc

# now you can kludge up a bunch of files and symlinks

