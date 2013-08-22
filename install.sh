#!/bin/bash
#
# Install framework for using puppet
#
# Assumes this is installed as a submodule in the parent project's root, and installs itself
# by copying templates and creating symbolic links to common tools.
#

frameworkPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
targetPuppetPath="$( cd "$sprintZeroPath/../" && pwd )"

# Get version of this repository that we're working with, to tag copies.
frameworkSource="$(cat .git/HEAD) on $(date +%Y-%m-%d_%H%M)"
function copyAndTag {
    filename=$1
    sourceFile=$frameworkPath/$filename
    destFile=$targetPuppetPath/$filename
    [[ -f $destFile ]] && echo "FAIL: file exists: $destFile" && exit 1
    cp $sourceFile $destFile
    echo "#$frameworkSource" >> $destFile
}
function symLink {
    filename=$1
    sourceFile=$frameworkPath/$filename
    destFile=$targetPuppetPath/$filename
    [[ -f $destFile ]] && echo "FAIL: file exists: $destFile" && exit 1
    ln -s $sourceFile $destFile
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

copyAndTag Puppetfile
symLink    lib/.gitignore
symLink    manifests/config/common.json
copyAndTag manifests/config/domains/clientdomain.tld.json
copyAndTag manifests/config/domains/clientname.slalomcloud.us.json
copyAndTag manifests/config/hosts/examplehost.clientname.slalomcloud.us.json
copyAndTag manifests/config/project.json
copyAndTag manifests/config/roles/app.json
copyAndTag manifests/defines.pp
symLink    manifests/hiera.yaml
symLink    manifests/site.pp
symLink    modules/general/manifests/init.pp
symLink    run_puppet_apply.sh
symLink    update_library.sh

echo "Adding puppet templates and links to project repository..."
$(cd ../tools/puppet && git add *)

read -p "Do you want to automatically commit and push to your project repo?" commitRepo
if [[ "$commitRepo" == "y" ]]; then
    cd ..
    git commit -m 'Added puppet framework artifacts'
    git push
else
    echo -e "Remember to review git changes:\n\tcd ..\n\tgit status\n\tgit diff\n\tgit commit -m 'Added puppet framework artifacts'\n\tgit push\n"
fi

# TODO:  prompt for common stack components: (tomcat, mysql, apache, node.js, mongo)
# - Add modules to Puppetfile and put entry in project.json

echo -e "\nPuppet installation done."

