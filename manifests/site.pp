# Include global puppet settings
import "globals.pp"

# Assign Classes, Defines & Parameters using Hiera
hiera_include("classes")

# Realize Defines, if any
import "defines.pp"

