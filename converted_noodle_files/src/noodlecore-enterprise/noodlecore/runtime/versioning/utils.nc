# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Versioning utilities for Noodle

# This module provides basic versioning functionality for the Noodle project.
# """


class VersionConstraint
    #     """Basic version constraint class for versioning operations."""

    #     def __init__(self, version_string: str):
    #         """Initialize version constraint with version string."""
    self.version_string = version_string
    self.major, self.minor, self.patch = self._parse_version(version_string)

    #     def _parse_version(self, version_string: str) -> tuple:
    #         """Parse version string into major, minor, patch components."""
    parts = version_string.split(".")
    #         major = int(parts[0]) if len(parts) > 0 else 0
    #         minor = int(parts[1]) if len(parts) > 1 else 0
    #         patch = int(parts[2]) if len(parts) > 2 else 0
    #         return major, minor, patch

    #     def satisfies(self, other: "VersionConstraint") -> bool:
    #         """Check if this version constraint satisfies another constraint."""
    #         if self.major > other.major:
    #             return True
    #         elif self.major == other.major:
    #             if self.minor > other.minor:
    #                 return True
    #             elif self.minor == other.minor:
    return self.patch > = other.patch
    #         return False

    #     def __str__(self) -> str:
    #         """String representation of version constraint."""
            return f"VersionConstraint({self.version_string})"


def get_version_constraint(version_string: str) -> VersionConstraint:
#     """Create a version constraint from a version string."""
    return VersionConstraint(version_string)


def compare_versions(version1: str, version2: str) -> int:
#     """
#     Compare two version strings.

#     Returns:
#         -1 if version1 < version2
#          0 if version1 == version2
#          1 if version1 > version2
#     """
v1 = VersionConstraint(version1)
v2 = VersionConstraint(version2)

#     if v1.major > v2.major:
#         return 1
#     elif v1.major < v2.major:
#         return -1
#     elif v1.minor > v2.minor:
#         return 1
#     elif v1.minor < v2.minor:
#         return -1
#     elif v1.patch > v2.patch:
#         return 1
#     elif v1.patch < v2.patch:
#         return -1
#     else:
#         return 0
