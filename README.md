Puppet Framework:
=================

This is a framework by convention for developing projects that use puppet.

It is intended to be a tool to install and update puppet frameworks in one or more project repositories.

It will get installed to each project by convention at `tools/puppet/`

This makes it easier to create and troubleshoot puppet configuration and push out updates accross multiple projects.

After using this framework to install an initial puppet framework, please do not edit a puppet-framework-managed file, but work with this puppet-framework project to edit it at the source.

Some files are are intended as starters for the project to edit, and will not be tagged with puppet-framework-managed comments.


How to Use:
===========

- Checkout this repository and cd to it
- *To Install*:  `install.sh </path/to/my/project/repo>`
- *To Upgrade*:  `install.sh -u </path/to/my/project/repo>`

How to Test:
============

- This works best if also using the framework-vagrant:
    https://github.com/tylerwalts/framework-vagrant

- `cd </path/to/my/project/repo>`
- `vagrant up`

- This should create a CentOS VM instance and run the puppet apply with the starter project files.


