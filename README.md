Puppet Framework:
=================

This is a framework by convention for developing projects that use puppet.

It is intended to be a tool to install and update puppet frameworks in one or more project repositories.

It will get installed to each project by convention at `tools/puppet/`

This makes it easier to create and troubleshoot puppet configuration and push out updates accross multiple projects.

After using this framework to install an initial puppet framework, please do not edit a puppet-framework-managed file, but work with this puppet-framework project to edit it at the source.

Some files are are intended as starters for the project to edit, and will not be tagged with puppet-framework-managed comments.


How to Install the Framework:
=============================
(If you are reading this file from your project repository, it is already installed)

- Checkout this framework repository and cd to it
- `install.sh </path/to/my/project/repo>`


How to Update the Framework:
=============================
- Checkout the framework repository (https://github.com/tylerwalts/framework-puppet/) and cd to it
- `install.sh -u </path/to/my/project/repo>`
- Review the changes to your project repository
- Commit changes to project repository


How to Use for Project:
=======================

- This works best if also using the framework-vagrant:
    https://github.com/tylerwalts/framework-vagrant

- `cd </path/to/my/project/repo>`
- `vagrant up`

- This should create a CentOS VM instance and run the puppet apply with the starter project files.




[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/tylerwalts/framework-puppet/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

