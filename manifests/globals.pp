# Global default
Exec { path        => [ '/usr/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin', ], }

# By convention, can control environments using multiple levels of subdomains.
# 7 levels should be enough for now.
# For example, with domain:  web.test.example.com
# 1st-level-domain:  com
# 2nd-level-domain:  example
# 3rd-level-domain:  test (aka "subdomain")
# 4rd-level-domain:  web (aka "hostname")
# 5th-level-domain:  -- (empty)
# 6th-level-domain:  -- (empty)
# 7th-level-domain:  -- (empty)
#
# These are used mapped in hiera.yaml to find the corresponding config in the subdirs
#
$domain_levels = split($domain, '[.]')
if (size($domain_levels)>0) { $domain1 = $domain_levels[size($domain_levels)-1] }
if (size($domain_levels)>1) { $domain2 = $domain_levels[size($domain_levels)-2] }
if (size($domain_levels)>2) { $domain3 = $domain_levels[size($domain_levels)-3] }
if (size($domain_levels)>3) { $domain4 = $domain_levels[size($domain_levels)-4] }
if (size($domain_levels)>4) { $domain5 = $domain_levels[size($domain_levels)-5] }
if (size($domain_levels)>5) { $domain6 = $domain_levels[size($domain_levels)-6] }
if (size($domain_levels)>6) { $domain7 = $domain_levels[size($domain_levels)-7] }

