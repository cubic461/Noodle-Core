# Converted from Python to NoodleCore
# Original file: noodle-core

import enum.Enum


class Type(Enum)
    #     """Enumeration for data types in Noodle."""

    INTEGER = "integer"
    FLOAT = "float"
    STRING = "string"
    BOOLEAN = "boolean"
    MATRIX = "matrix"
    TENSOR = "tensor"


class ScopeType(Enum)
    #     """Enumeration for scope types in Noodle."""

    GLOBAL = "global"
    LOCAL = "local"
    MODULE = "module"
    FUNCTION = "function"
