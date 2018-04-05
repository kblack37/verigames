#!/bin/bash

# Pulls down and builds all of our own projects that this build depends on.
#
# You must have the following projects checked out, and in the directory
# specified by the JSR308 environment variable:
#
# - jsr308-langtools
# - annotation-tools
# - checker-framework/checkers
# - checker-framework-inference
#
# It is not advisable to run this script if you have local changes in any of
# these repositories

if [[ -z $JSR308 ]]; then
  echo 'must set the JSR308 environment variable'
  exit 1
fi

# Fail on any failed command
set -e

cd $JSR308/jsr308-langtools
hg pull
hg update
cd make
ant clean-and-build-all-tools

cd $JSR308/annotation-tools
hg pull
hg update
ant

cd $JSR308/checker-framework
hg pull
hg update
cd checkers
ant

cd $JSR308/checker-framework-inference
hg pull
hg update
gradle clean dist

echo
echo SUCCESS
