#!/bin/bash
#
# Install framework for using puppet
#
# Assumes this is installed as a submodule in the parent project's root, and installs itself
# by copying templates and creating symbolic links to common tools.
#

frameworkPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
targetProjectFolder=$1
targetPuppetFolder="$targetProjectFolder/tools/puppet"

if [[ ! -d $targetProjectFolder ]]; then 
  echo "The target Vagrant of [$targetProjectFolder] installation path is invalid"
  exit 127
fi

# Get version of this repository that we're working with, to tag copies.
# Assumes this was installed using the sprint-zero framework
frameworkSource="$(cd $frameworkPath && git rev-parse --short HEAD) on $(date +%Y-%m-%d_%H%M)"

function copyAndTag {
    local filename=$1
    local skipTagging=$2
    local sourceFile=$frameworkPath/$filename
    local destFile=$targetPuppetFolder/$filename
    if [[ -f $destFile ]]; then
            echo "* Skipping existing template: $destFile"
    else
        echo "Copying: $filename"
        command="cp $sourceFile $destFile"
        $command
        if [[ "$skipTagging" != "true" ]]; then 
          echo "#$frameworkSource" >> $destFile
        fi
        copiedFileList=" $copiedFileList $filename "
    fi
}

function symLink {
    filename=$1
    osType="$(uname)"
    if [[ $osType == *WIN* || $osType == *MIN* ]]; then
        # Look for CYGWIN or MINGW
        copyAndTag $filename
    else
        filenameOnly=$(basename "$filename")
        relativePath="${filename%/*}"
        if [[ "$filenameOnly" == "$relativePath" ]]; then
            relativePath=""
        else
            pathCount="$( echo $relativePath | grep -o '/' | wc -l)"
            relativePath=""
            while [[ "$pathCount" != "-1" ]]; do
                relativePath="${relativePath}../"
                (( pathCount-- ))
            done
        fi
        sourceFile="${relativePath}.framework-puppet/$filename"
        destFile=$targetPuppetFolder/$filename
        if [[ -h $destFile ]]; then
            echo "- Updating symlink: $filename"
            rm $destFile
            ln -s $sourceFile $destFile
        elif [[ -e $destFile ]]; then
            echo "* Skipping existing file in place of symlink (customized for project): $destFile"
        else
            echo "Linking: $filename"
            ln -s $sourceFile $destFile
            if [[ "$(grep $filename $targetPuppetFolder/.gitignore)" == "" ]];then
                echo "$filename" >> $targetPuppetFolder/.gitignore
            fi
        fi
    fi
}

echo "Installing puppet framework into project repository...
    Notes:
        - Files which the project will want to customize are copied to the project path.
        - Files which should remain unchanged and common between projects are symlinked on Mac/Linux, copied and .gitignored on Windows.
"

# Create directory structure
mkdir -p $targetPuppetFolder/lib \
    $targetPuppetFolder/manifests/config/{domains,hosts,roles,manifests} \
    $targetPuppetFolder/modules/general/manifests  

[[ ! -e $targetPuppetFolder/.gitignore || "$(grep 'maintained' $targetPuppetFolder/.gitignore)" == "" ]] && \
    echo "# These are maintained by the puppet framework" >> $targetPuppetFolder/.gitignore
[[ "$(grep -e '^lib$' $targetPuppetFolder/.gitignore)" == "" ]] && \
    echo "lib" >> $targetPuppetFolder/.gitignore

copyAndTag Puppetfile
copyAndTag manifests/config/common.json true
copyAndTag manifests/config/domains/example.json true
copyAndTag manifests/config/hosts/example.json true
copyAndTag manifests/config/project.json true
copyAndTag manifests/config/roles/example.json true
copyAndTag manifests/defines.pp
copyAndTag manifests/hiera.yaml
copyAndTag manifests/site.pp
copyAndTag manifests/globals.pp
copyAndTag manifests/globals-project.pp
copyAndTag modules/general/manifests/init.pp
copyAndTag run_puppet_apply.sh
copyAndTag update_library.sh

echo -e "Updating project's README.md..."
[[ ! -e $projectPath/README.md \
    || "$(grep -e '^Puppet Framework:$' $projectPath/README.md)" == "" ]] \
        && cat $frameworkPath/README.md >> $projectPath/README.md

# TODO:  prompt for common stack components: (tomcat, mysql, apache, node.js, mongo)
# - Add modules to Puppetfile and put entry in project.json

echo -e "\nPuppet installation done."

