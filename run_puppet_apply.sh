#!/bin/bash
[[ "$EUID" != "0" ]] && echo -e "\nError:\n\t**Run this script as root or sudo.\n" && exit 1
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


function usagePrompt {
    echo -e "
    run_puppet_apply.sh [options]

    -l | --librarian      Run Puppet Librarian to update modules
    -f | --facter         Run Puppet and use custom facter overrides
    -n | --noop           Run Puppet in No Operation (noop) mode

    "
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
        -n | --noop )
            shift
            noopArg=" --noop "
            echo "Using noop (no operation) run mode - no changes will be realized"
            shift
            ;;
        *) usagePrompt
            shift
            exit
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
command="puppet apply $puppetOpts $noopArg --modulepath ${basedir}/modules/:${basedir}/lib/ ${basedir}/manifests/site.pp"
echo -e "\nRunning Masterless Puppet using command: \n\t$command\n"
$command
