framework-puppet
================

This is a framework for developing projects using puppet.

It will initially get called by the sprint-zero installer, and will get installed as a submodule in your project's repository at `tools/puppet/.framework-puppet`.

Run this each time new code is checked out to update the framework:

```bash
    # From the root of your project repository:
    git submodules update --init
    ./tools/puppet/.framework-puppet/install.sh
```

To over-ride a framework-managed file in your project, replace with your own copy and remove the reference in tools/puppet/.gitignore


