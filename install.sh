#!/bin/bash
#
# Install framework for using puppet
#
# Assumes this is installed as a submodule in the parent project's root, and installs itself
# by copying templates and creating symbolic links to common tools.
#

frameworkPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $frameworkPath # For when calling from other paths
targetPuppetPath="$( cd "$frameworkPath/../" && pwd )"

# Get version of this repository that we're working with, to tag copies.
# Assumes this was installed using the sprint-zero framework
frameworkSource="$(cat ../../../.git/modules/tools/puppet/.framework-puppet/HEAD) on $(date +%Y-%m-%d_%H%M)"
function copyAndTag {
    filename=$1
    sourceFile=$frameworkPath/$filename
    destFile=$targetPuppetPath/$filename
    if [[ -f $destFile ]]; then
            echo "* Skipping existing template: $destFile"
    else
        echo "Copying: $filename"
        command="cp $sourceFile $destFile"
        $command
        echo "#$frameworkSource" >> $destFile
        copiedFileList=" $filename"
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
        destFile=$targetPuppetPath/$filename
        if [[ -h $destFile ]]; then
            echo "- Updating symlink: $filename"
            rm $destFile
            ln -s $sourceFile $destFile
        elif [[ -e $destFile ]]; then
            echo "* Skipping existing file in place of symlink (customized for project): $destFile"
        else
            echo "Linking: $filename"
            ln -s $sourceFile $destFile
            [[ "$(grep $filename $targetPuppetPath/.gitignore)" == "" ]] && echo "$filename" >> $targetPuppetPath/.gitignore
        fi
    fi
}

echo "Installing puppet framework into project repository...
    Notes:
        - Files which the project will want to customize are copied to the project path.
        - Files which should remain unchanged and common between projects are symlinked on Mac/Linux, copied and .gitignored on Windows.
"

# Create directory structure
mkdir -p $targetPuppetPath/lib \
    $targetPuppetPath/manifests/config/domains \
    $targetPuppetPath/manifests/config/hosts \
    $targetPuppetPath/manifests/config/roles \
    $targetPuppetPath/modules/general/manifests

[[ "$(grep 'maintained' $targetPuppetPath/.gitignore)" == "" ]] && \
    echo "# These are maintained by the puppet framework" >> $targetPuppetPath/.gitignore
[[ "$(grep -e '^lib$' $targetPuppetPath/.gitignore)" == "" ]] && \
    echo "lib" >> $targetPuppetPath/.gitignore

copyAndTag Puppetfile
symLink    manifests/config/common.json
copyAndTag manifests/config/domains/example.json
copyAndTag manifests/config/hosts/example.json
copyAndTag manifests/config/project.json
copyAndTag manifests/config/roles/example.json
copyAndTag manifests/defines.pp
symLink    manifests/hiera.yaml
symLink    manifests/site.pp
symLink    manifests/globals.pp
symLink    modules/general/manifests/init.pp
symLink    run_puppet_apply.sh
symLink    update_library.sh

gitStatus=$(cd $targetPuppetPath && git status Puppetfile | grep 'working directory clean' | wc -l | tr -d ' ' )
if [[ "$gitStatus" != "1" ]]; then
    echo -e "\nAdding puppet templates and links to project repository...\n"
    $(cd $targetPuppetPath && git add .gitignore $copiedFileList)
    echo -e "Remember to review & commit git changes:\n\tcd ..\n\tgit status\n\tgit diff\n\tgit commit -m 'Added puppet framework artifacts'\n\tgit push\n"
fi

# TODO:  prompt for common stack components: (tomcat, mysql, apache, node.js, mongo)
# - Add modules to Puppetfile and put entry in project.json

echo -e "\nPuppet installation done."

