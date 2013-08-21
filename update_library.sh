#!/bin/sh

# Directory in which librarian-puppet should manage its modules directory
PUPPET_DIR=/vagrant/tools/puppet/
[[ "$1" != "" ]] && PUPPET_DIR=$1

$(which git > /dev/null 2>&1)
FOUND_GIT=$?
if [ "$FOUND_GIT" -ne '0' ]; then
  echo 'Attempting to install git.'
  $(which apt-get > /dev/null 2>&1)
  FOUND_APT=$?
  $(which yum > /dev/null 2>&1)
  FOUND_YUM=$?

  if [ "${FOUND_YUM}" -eq '0' ]; then
    echo 'Installing Git...'
    yum -q -y makecache
    yum -q -y install git
  elif [ "${FOUND_APT}" -eq '0' ]; then
    echo 'Installing Git...'
    apt-get -q -y update
    apt-get -q -y install git
  else
    echo 'No package installer available. You may need to install git manually.'
  fi
fi

# Ensure the puppet librarian gem is installed.
[[ "$(gem search -i librarian-puppet)" == "false" ]] && gem install librarian-puppet --no-ri --no-rdoc

# Install or update the puppet module library
cd $PUPPET_DIR
if [ -f $PUPPET_DIR/.librarian ]; then
    echo "Installing librarian..."
    command="librarian-puppet update --path ./lib --verbose"
else
    echo "Updating puppet lib with librarian"
    command="librarian-puppet install --path ./lib --verbose"
fi
echo "Running command: $command"
$command

