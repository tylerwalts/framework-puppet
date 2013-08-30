class firewall_patterns::post {
    firewall { '999 drop all':
        proto  => 'all',
        action => 'drop',
        before => undef,
    }
}
