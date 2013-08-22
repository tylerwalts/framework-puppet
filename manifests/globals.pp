# Global default
Exec { path        => [ '/usr/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin', ], }

# Hiera needs to know where to find the config, relative to puppet root
if ( $ec2_security_groups == "elasticbamboo" ) {
    # Bamboo
    $puppet_cwd="/mnt/bamboo-ebs/bin/code/tools/puppet/"
} elsif ( $::fqdn =~ /vagrant/ ) {
    # Vagrant
    $puppet_cwd="/vagrant/tools/puppet/"
} else {
    # Default
    $puppet_cwd="."
}


