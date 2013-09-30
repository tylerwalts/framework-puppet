#!/bin/bash
#
# Install framework for using puppet
#
# Assumes convention of installing this in a project's repository at:
#  tools/puppet/
#
frameworkPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function usagePrompt {
    echo -e "\n
    install.sh [options] project_path\n
    -u | --upgrade    Upgrade the puppet framework, overwriting existing framework files\n
    Example:
        install.sh -u /path/to/project/repo\n"
}

while [ "$1" != "" ]; do
    case $1 in
        -u | --upgrade )
            echo "Running in update mode... (framework files will be updated)"
            updateFlag="Y"
            shift
            ;;
        -*) usagePrompt
            exit 1
            ;;
        *)  [[ "$targetProjectFolder" != "" ]] \
              && echo "ERROR:  Too many args." && usagePrompt && exit 1
            targetProjectFolder=$1
            shift
            ;;
    esac
done

targetPuppetFolder="$targetProjectFolder/tools/puppet"

if [[ ! -d $targetProjectFolder ]]; then 
  echo "The target Vagrant of [$targetProjectFolder] installation path is invalid"
  exit 127
fi

# Get version of this repository that we're working with, to tag copies.
# Assumes this was installed using the sprint-zero framework
frameworkSource="$(cd $frameworkPath && git rev-parse --short HEAD) on $(date +%Y-%m-%d_%H%M)"
tagContent="
#####
#
# DO NOT EDIT THIS FILE
#
# This is managed by the puppet framework at:
#   https://github.com/tylerwalts/framework-puppet
#
# framework-puppet version: $frameworkSource
#####"

function copyAndTag {
    local filename=$1
    local skipTagging=$2
    local sourceFile=$frameworkPath/$filename
    local destFile=$targetPuppetFolder/$filename
    if [[ -f $destFile && "$updateFlag" != "Y" ]]; then
            echo "* Skipping existing template: $destFile"
    else
        echo "Copying: $filename"
        # Make sure this script can write to the target file
        [[ -f $destFile && ! -w $destFile ]] && chmod u+w $destFile
        command="cp $sourceFile $destFile"
        $command
        if [[ "$skipTagging" != "true" ]]; then 
          echo "$tagContent" >> $destFile
        fi
        # Remove user write bit for all files to help make clear this is managed by framework
        chmod u-w $destFile
    fi
}

# This is intended for one-time copy of starter file that project should customize.
# Any existing project file will not get modified.
function copyForProject {
    local filename=$1
    local skipTagging=$2
    local sourceFile=$frameworkPath/$filename
    local destFile=$targetPuppetFolder/$filename
    if [[ -f $destFile ]]; then
            echo "* Project file already exists, skipping: $destFile"
    else
        echo "Copying: $filename"
        command="cp $sourceFile $destFile"
        $command
    fi
}

echo "Installing puppet framework into project repository... "

# Create directory structure
mkdir -p $targetPuppetFolder/lib \
    $targetPuppetFolder/manifests/config/{domains,hosts,roles,manifests} \
    $targetPuppetFolder/modules/general/manifests  

# Prevent the puppet-librarian- managed modules from getting into git
[[ ! -e $targetPuppetFolder/lib/.gitignore || "$(grep  'gitignore' $targetPuppetFolder/lib/.gitignore)" == "" ]] && \
    echo "!.gitignore" >> $targetPuppetFolder/lib/.gitignore

# Project starter files
copyForProject Puppetfile
copyForProject manifests/config/project.json true
copyForProject modules/general/manifests/init.pp
copyForProject manifests/defines.pp
copyForProject manifests/globals-project.pp

# Framework files
copyAndTag manifests/config/common.json true
copyAndTag manifests/hiera.yaml
copyAndTag manifests/site.pp
copyAndTag manifests/globals.pp
copyAndTag run_puppet_apply.sh
copyAndTag update_library.sh
copyAndTag README.md

    # TODO: put these examples in the readme instead of codebase
    copyAndTag manifests/config/domains/example.json true
    copyAndTag manifests/config/hosts/example.json true
    copyAndTag manifests/config/roles/example.json true

# TODO:  prompt for common stack components: (tomcat, mysql, apache, node.js, mongo)
# - Add modules to Puppetfile and put entry in project.json

echo -e "\nPuppet installation done."

