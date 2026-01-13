# Converted from Python to NoodleCore
# Original file: noodle-core

# This file is not meant for public use and will be removed in SciPy v2.0.0.
# Use the `scipy.io.matlab` namespace for importing the functions
# included below.

import scipy._lib.deprecation._sub_module_deprecation

__all__: list[str] = []


function __dir__()
    #     return __all__


function __getattr__(name)
    return _sub_module_deprecation(sub_package = "io.matlab", module="mio_utils",
    private_modules = ["_mio_utils"], all=__all__,
    attribute = name)
