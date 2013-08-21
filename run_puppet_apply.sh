#!/bin/bash
[[ "$EUID" != "0" ]] && echo -e "\nError:\n\t**Run this script as root or sudo.\n" && exit 1
basedir="$( dirname $( readlink -f "${0}" ) )"


function usagePrompt {
    echo -e "\n\trun_puppet_apply.sh [options]\n\n\t-l | --librarian\t\tRun Puppet Librarian to update modules"
}

while [ "$1" != "" ]; do
    case $1 in
        -l | --librarian )
            shift
            echo "Ensuring puppet librarian is run..."
            sudo ${basedir}/update_library.sh $basedir
            ;;
        *) usagePrompt
            ;;
    esac
done

puppetVersion="$(puppet --version)"
echo "Running puppet version: $puppetVersion"
[[ $puppetVersion == 2* ]] && cp ${basedir}/manifests/hiera.yaml /etc/puppet/
[[ $puppetVersion == 3* ]] && puppetOpts="--hiera_config ${basedir}/manifests/hiera.yaml"

cd ${basedir}/manifests

command="sudo puppet apply $puppetOpts --modulepath ${basedir}/modules/:${basedir}/lib/ ${basedir}/manifests/site.pp"
echo -e "\nRunning Masterless Puppet using command: \n\t$command\n"
$command
