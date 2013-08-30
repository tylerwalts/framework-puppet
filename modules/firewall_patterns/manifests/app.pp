class firewall_patterns::app {

    firewall { '110 tomcat':
        port   => [8080],
        proto  => tcp,
        action => accept,
    }

}
