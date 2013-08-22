framework-puppet
================

This is a framework for developing projects using puppet.

It will initially get called by the sprint-zero installer, and will get installed in your project's repository at `tools/puppet/.framework-puppet` and by every user each time a new code is checked out or if the working directory is moved and the symlinks need to get updated.

```bash
    # From the root of your project repository:
    cd tools/puppet/.framework-puppet/
    ./install.sh
```



