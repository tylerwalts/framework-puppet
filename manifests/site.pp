
# Include global puppet settings
include globals.pp

# Assign Classes, Defines & Parameters using Hiera
hiera_include("classes")

# Realize Defines, if any
include defines.pp

