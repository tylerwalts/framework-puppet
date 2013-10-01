#!/bin/sh

# Directory in which librarian-puppet should manage its modules directory
PUPPET_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
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
cd $PUPPET_DIR

# Ensure the puppet librarian gem is installed.
if [[ "$(gem search -i librarian-puppet)" == "false" ]]; then
  gem install librarian-puppet --no-ri --no-rdoc
  return=$?
  # If the existing/default gem source is bad/old, then use rubygems.
  # TODO: refactor this to gem search first, and be >= 0.9.10
  libVersion="$(gem search librarian-puppet | grep '0.9.10')"
  if [[ "$return" != "0" || "$libVersion" == "" ]]; then
    gem install bundler
    echo -e "source 'https://rubygems.org'\ngem 'librarian-puppet'" > Gemfile
    bundle install
  fi
fi

# Install or update the puppet module library
if [ -f $PUPPET_DIR/.librarian ]; then
    echo "Installing librarian..."
    command="librarian-puppet update --path ./lib"
else
    echo "Updating puppet lib with librarian"
    command="librarian-puppet install --path ./lib"
fi
echo "Running command: $command"
$command

