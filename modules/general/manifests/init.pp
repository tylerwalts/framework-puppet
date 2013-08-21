# Installs the general components necessary for all servers
class general ($ensure = "latest"){

    $packages=[
        "wget",
        "nmap",
        "lynx",
        "ftp",
        "unzip",
        "zip",
        "e2fsprogs",
        "git",
        "subversion",
        "vim-enhanced",
        "screen",
        "tree",
        "net-snmp",
        "ntp",
        "curl"
    ]

    package { $packages:
        ensure    => $ensure,
    }

}
