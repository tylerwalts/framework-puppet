#!/bin/bash
#
# Install framework for using puppet
#
# Assumes this is installed as a submodule in the parent project's root, and installs itself
# by copying templates and creating symbolic links to common tools.
#

frameworkPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
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
    fi
}
function symLink {
    filename=$1
    sourceFile=$frameworkPath/$filename
    destFile=$targetPuppetPath/$filename
    # If existing target is a file, skip it, means project has customized it.
    if [[ -f $destFile ]]; then
        # If existing target is a symlink, delete and recreate it.
        if [[ -h $destFile ]]; then
            echo "- Updating symlink: $filename"
            rm $destFile
            ln -s $sourceFile $destFile
        else
            echo "* Skipping existing file in place of symlink (customized for project): $destFile"
        fi
    else
        echo "Linking: $filename"
        ln -s $sourceFile $destFile
        # Add to .gitignore : Every new checkout will need to run this script.
        [[ "$(grep $filename $targetPuppetPath/.gitignore)" == "" ]] && echo "$filename" >> $targetPuppetPath/.gitignore
    fi
}

echo "Installing puppet framework into project repository...
    Note:
        - Files which the project will want to customize are copied to the project path.
        - Files which should remain unchanged and common between projects are symlinked.
"

# Create directory structure
mkdir -p $targetPuppetPath/lib \
    $targetPuppetPath/manifests/config/domains \
    $targetPuppetPath/manifests/config/hosts \
    $targetPuppetPath/manifests/config/roles \
    $targetPuppetPath/modules/general/manifests
touch $targetPuppetPath/.gitignore

copyAndTag Puppetfile
symLink    lib/.gitignore
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

echo -e "\nAdding puppet templates and links to project repository...\n"
$(cd ../ && git add .gitignore *)
echo -e "Remember to review & commit git changes:\n\tcd ..\n\tgit status\n\tgit diff\n\tgit commit -m 'Added puppet framework artifacts'\n\tgit push\n"

# TODO:  prompt for common stack components: (tomcat, mysql, apache, node.js, mongo)
# - Add modules to Puppetfile and put entry in project.json

echo -e "\nPuppet installation done."

