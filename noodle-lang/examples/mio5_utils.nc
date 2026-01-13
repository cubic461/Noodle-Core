# Converted from Python to NoodleCore
# Original file: src

# This file is not meant for public use and will be removed in SciPy v2.0.0.
# Use the `scipy.io.matlab` namespace for importing the functions
# included below.

import scipy._lib.deprecation._sub_module_deprecation

__all__: list[str] = []


function __dir__()
    #     return __all__


function __getattr__(name)
    return _sub_module_deprecation(sub_package = "io.matlab", module="mio5_utils",
    private_modules = ["_mio5_utils"], all=__all__,
    attribute = name)
