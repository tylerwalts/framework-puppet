#!/bin/bash
[[ "$EUID" != "0" ]] && echo -e "\nError:\n\t**Run this script as root or sudo.\n" && exit 1
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


function usagePrompt {
    echo -e "\n\trun_puppet_apply.sh [options]\n\n\t-l | --librarian\t\tRun Puppet Librarian to update modules"
}

while [ "$1" != "" ]; do
    case $1 in
        -l | --librarian )
            shift
            echo "Ensuring puppet librarian is run..."
            ${basedir}/update_library.sh $basedir
            ;;
        -f | --facter_override )
            shift
            facterOptions="$1"
            echo "Overriding Facter with: $facterOptions"
            export $facterOptions
            shift
            ;;
        *) usagePrompt
            ;;
    esac
done

puppetVersion="$(puppet --version)"
echo "Running puppet version: $puppetVersion"
[[ $puppetVersion == 2* ]] && cp ${basedir}/manifests/hiera.yaml /etc/puppet/
[[ $puppetVersion == 3* ]] && puppetOpts="--hiera_config ${basedir}/manifests/hiera.yaml"

# Hiera needs to know where to find the config data, via facter
export FACTER_hiera_config="$basedir/manifests/config"

cd ${basedir}/manifests
command="puppet apply $puppetOpts --modulepath ${basedir}/modules/:${basedir}/lib/ ${basedir}/manifests/site.pp"
echo -e "\nRunning Masterless Puppet using command: \n\t$command\n"
$command
