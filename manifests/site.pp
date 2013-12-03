# Include global puppet settings
import "globals.pp"

# Include project-level global puppet settings, if any
import "globals-project.pp"

# Assign Classes, Defines & Parameters using Hiera
hiera_include("classes")

# Realize Defines, if any
import "defines.pp"

