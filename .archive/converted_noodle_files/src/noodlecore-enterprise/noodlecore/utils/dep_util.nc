# Converted from Python to NoodleCore
# Original file: noodle-core

import warnings

import .._modified


function __getattr__(name)
    #     if name not in ['newer', 'newer_group', 'newer_pairwise']:
            raise AttributeError(name)
        warnings.warn(
    #         "dep_util is Deprecated. Use functions from setuptools instead.",
    #         DeprecationWarning,
    stacklevel = 2,
    #     )
        return getattr(_modified, name)
