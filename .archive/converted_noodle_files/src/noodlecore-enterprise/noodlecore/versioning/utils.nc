# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Version management utilities for the Noodle project.

# This module provides classes and functions for:
# - Version parsing and validation
# - Version comparison operations
# - Version constraint handling
# - Semantic version compliance
# """

import re
import dataclasses.dataclass,
import enum.Enum
import functools.total_ordering
import typing.Any,


class VersionOperator(Enum)
    #     """Operators for version constraints."""

    EQUALS = "=="
    NOT_EQUALS = "!="
    GREATER_THAN = ">"
    GREATER_THAN_OR_EQUAL = ">="
    LESS_THAN = "<"
    LESS_THAN_OR_EQUAL = "<="
    COMPATIBLE = "~="  # Compatible release operator
    CARET = "^"  # Caret operator
    AND = "AND"  # Logical AND operator
    OR = "OR"  # Logical OR operator


# @total_ordering
# @dataclass
class Version
    #     """
    #     Represents a semantic version number.

        Follows Semantic Versioning 2.0.0 (https://semver.org/)
    #     Format: MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]
    #     """

    #     major: int
    #     minor: int
    #     patch: int
    prerelease: Optional[str] = None
    build: Optional[str] = None

    #     def __post_init__(self):
    #         """Validate version components after initialization."""
    #         if not isinstance(self.major, int) or self.major < 0:
                raise ValueError("Major version must be a non-negative integer")
    #         if not isinstance(self.minor, int) or self.minor < 0:
                raise ValueError("Minor version must be a non-negative integer")
    #         if not isinstance(self.patch, int) or self.patch < 0:
                raise ValueError("Patch version must be a non-negative integer")

    #         if self.prerelease is not None and not self._is_valid_prerelease(
    #             self.prerelease
    #         ):
                raise ValueError(f"Invalid prerelease identifier: {self.prerelease}")

    #         if self.build is not None and not self._is_valid_build(self.build):
                raise ValueError(f"Invalid build metadata: {self.build}")

    #     @staticmethod
    #     def parse(version_string: str) -> "Version":
    #         """
    #         Parse a version string into a Version object.

    #         Args:
                version_string: Version string to parse (e.g., "1.2.3", "2.0.0-alpha.1")

    #         Returns:
    #             Version object

    #         Raises:
    #             ValueError: If the version string is invalid
    #         """
    #         # Regex pattern for semantic versioning
    pattern = r"^(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$"
    match = re.match(pattern, version_string.strip())

    #         if not match:
                raise ValueError(f"Invalid version format: {version_string}")

    major, minor, patch = map(int, match.groups()[:3])
    prerelease = match.group(4)
    build = match.group(5)

            return Version(major, minor, patch, prerelease, build)

    #     @staticmethod
    #     def _is_valid_prerelease(prerelease: str) -> bool:
    #         """Check if a prerelease identifier is valid."""
    #         if not prerelease:
    #             return False

    #         # Prerelease identifiers MUST comprise only ASCII alphanumerics and hyphens [0-9A-Za-z-]
    #         # Identifiers MUST NOT be empty
    #         # Identifiers MUST NOT include leading zeros
    #         for identifier in prerelease.split("."):
    #             if not identifier:
    #                 return False
    #             if not re.match(r"^[0-9A-Za-z-]+$", identifier):
    #                 return False
    #             if identifier[0].isdigit() and len(identifier) > 1 and identifier[0] == "0":
    #                 return False

    #         return True

    #     @staticmethod
    #     def _is_valid_build(build: str) -> bool:
    #         """Check if build metadata is valid."""
    #         if not build:
    #             return False

    #         # Build metadata MAY comprise only ASCII alphanumerics and hyphens [0-9A-Za-z-]
    #         for identifier in build.split("."):
    #             if not identifier:
    #                 return False
    #             if not re.match(r"^[0-9A-Za-z-]+$", identifier):
    #                 return False

    #         return True

    #     def __str__(self) -> str:
    #         """String representation of the version."""
    version_str = f"{self.major}.{self.minor}.{self.patch}"
    #         if self.prerelease:
    version_str + = f"-{self.prerelease}"
    #         if self.build:
    version_str + = f"+{self.build}"
    #         return version_str

    #     def __repr__(self) -> str:
    #         """Detailed string representation."""
            return f"Version({self.major}, {self.minor}, {self.patch}, {repr(self.prerelease)}, {repr(self.build)})"

    #     def __eq__(self, other: object) -> bool:
    #         """Check if two versions are equal."""
    #         if not isinstance(other, Version):
    #             return False
            return (
    self.major = = other.major
    and self.minor = = other.minor
    and self.patch = = other.patch
    and self.prerelease = = other.prerelease
    #         )

    #     def __lt__(self, other: "Version") -> bool:
    #         """Check if this version is less than another version."""
    #         if not isinstance(other, Version):
    #             return NotImplemented

    #         # Compare major, minor, patch versions
    #         if self.major != other.major:
    #             return self.major < other.major
    #         if self.minor != other.minor:
    #             return self.minor < other.minor
    #         if self.patch != other.patch:
    #             return self.patch < other.patch

    #         # Compare prerelease versions
    #         # Normal versions have higher precedence than prerelease versions
    #         if self.prerelease is None and other.prerelease is not None:
    #             return False
    #         if self.prerelease is not None and other.prerelease is None:
    #             return True
    #         if self.prerelease is None and other.prerelease is None:
    #             return False

    #         # Both have prerelease versions, compare them
    self_prerelease_ids = self.prerelease.split(".")
    other_prerelease_ids = other.prerelease.split(".")

    #         for self_id, other_id in zip(self_prerelease_ids, other_prerelease_ids):
    self_is_num = self_id.isdigit()
    other_is_num = other_id.isdigit()

    #             # Numeric identifiers always have lower precedence than non-numeric identifiers
    #             if self_is_num and not other_is_num:
    #                 return True
    #             if not self_is_num and other_is_num:
    #                 return False

    #             # Both are numeric or both are non-numeric
    #             if self_is_num and other_is_num:
    self_num = int(self_id)
    other_num = int(other_id)
    #                 if self_num != other_num:
    #                     return self_num < other_num
    #             else:
    #                 # Both are non-numeric, compare lexicographically
    #                 if self_id != other_id:
    #                     return self_id < other_id

    #         # All compared identifiers are equal, the one with more identifiers has higher precedence
            return len(self_prerelease_ids) < len(other_prerelease_ids)

    #     def is_compatible(self, other: "Version") -> bool:
    #         """
    #         Check if this version is compatible with another version.

    #         Versions are compatible if they have the same major version number
    #         and this version is greater than or equal to the other version.
    #         """
    #         if self.major != other.major:
    #             return False
    return self > = other

    #     def next_major(self) -> "Version":
    #         """Get the next major version."""
            return Version(self.major + 1, 0, 0)

    #     def next_minor(self) -> "Version":
    #         """Get the next minor version."""
            return Version(self.major, self.minor + 1, 0)

    #     def next_patch(self) -> "Version":
    #         """Get the next patch version."""
            return Version(self.major, self.minor, self.patch + 1)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert version to dictionary representation."""
    #         return {
    #             "major": self.major,
    #             "minor": self.minor,
    #             "patch": self.patch,
    #             "prerelease": self.prerelease,
    #             "build": self.build,
                "string": str(self),
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> "Version":
    #         """Create version from dictionary representation."""
            return cls(
    major = data["major"],
    minor = data["minor"],
    patch = data["patch"],
    prerelease = data.get("prerelease"),
    build = data.get("build"),
    #         )


# @dataclass
class VersionRange
    #     """
    #     Represents a range of versions.

    #     A version range can include minimum and maximum versions,
    #     and can be inclusive or exclusive at either end.
    #     """

    min_version: Optional[Version] = None
    max_version: Optional[Version] = None
    include_min: bool = True
    include_max: bool = True

    #     def __post_init__(self):
    #         """Validate version range after initialization."""
    #         if (
    #             self.min_version
    #             and self.max_version
    #             and self.min_version > self.max_version
    #         ):
                raise ValueError("Minimum version cannot be greater than maximum version")

    #     def contains(self, version: Version) -> bool:
    #         """
    #         Check if a version is contained within this range.

    #         Args:
    #             version: Version to check

    #         Returns:
    #             True if the version is contained within the range, False otherwise
    #         """
    #         # Check minimum version
    #         if self.min_version:
    #             if self.include_min:
    #                 if version < self.min_version:
    #                     return False
    #             else:
    #                 if version <= self.min_version:
    #                     return False

    #         # Check maximum version
    #         if self.max_version:
    #             if self.include_max:
    #                 if version > self.max_version:
    #                     return False
    #             else:
    #                 if version >= self.max_version:
    #                     return False

    #         return True

    #     def __str__(self) -> str:
    #         """String representation of the version range."""
    parts = []

    #         if self.min_version:
    #             min_op = ">=" if self.include_min else ">"
                parts.append(f"{min_op} {self.min_version}")

    #         if self.max_version:
    #             max_op = "<=" if self.include_max else "<"
                parts.append(f"{max_op} {self.max_version}")

    #         if not parts:
    #             return "*"

            return ", ".join(parts)

    #     @staticmethod
    #     def parse(range_string: str) -> "VersionRange":
    #         """
    #         Parse a version range string into a VersionRange object.

    #         Args:
    range_string: Version range string to parse (e.g., "> = 1.0.0,<2.0.0")

    #         Returns:
    #             VersionRange object

    #         Raises:
    #             ValueError: If the range string is invalid
    #         """
    #         # Remove whitespace
    range_string = range_string.strip()

    #         # Handle wildcard range
    #         if range_string == "*" or range_string == "":
                return VersionRange()

    #         # Split into individual constraints
    constraints = re.split(r",\s*", range_string)

    min_version = None
    max_version = None
    include_min = True
    include_max = True

    #         for constraint in constraints:
    #             # Parse operator and version
    match = re.match(r"([<>=~^!]+)\s*([^\s,]+)", constraint)
    #             if not match:
                    raise ValueError(f"Invalid constraint format: {constraint}")

    operator, version_str = match.groups()
    version = Version.parse(version_str)

    #             if operator == ">=":
    #                 if min_version is None or version > min_version:
    min_version = version
    include_min = True
    #             elif operator == ">":
    #                 if min_version is None or version > min_version:
    min_version = version
    include_min = False
    #             elif operator == "<=":
    #                 if max_version is None or version < max_version:
    max_version = version
    include_max = True
    #             elif operator == "<":
    #                 if max_version is None or version < max_version:
    max_version = version
    include_max = False
    #             elif operator == "~=":
    # Compatible release operator: ~ = math.add(X.Y.Z means >=X.Y.Z, <X.(Y, 1).0)
    #                 if min_version is None or version > min_version:
    min_version = version
    include_min = True

    #                 # Calculate upper bound
    upper_version = version.next_minor()
    #                 if max_version is None or upper_version < max_version:
    max_version = upper_version
    include_max = False
    #             elif operator == "^":
    # Caret operator: ^X.Y.Z means > = math.add(X.Y.Z, <(X, 1).0.0)
    #                 if min_version is None or version > min_version:
    min_version = version
    include_min = True

    #                 # Calculate upper bound
    upper_version = version.next_major()
    #                 if max_version is None or upper_version < max_version:
    max_version = upper_version
    include_max = False
    #             else:
                    raise ValueError(f"Unsupported operator: {operator}")

            return VersionRange(min_version, max_version, include_min, include_max)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert version range to dictionary representation."""
    #         return {
    #             "min_version": self.min_version.to_dict() if self.min_version else None,
    #             "max_version": self.max_version.to_dict() if self.max_version else None,
    #             "include_min": self.include_min,
    #             "include_max": self.include_max,
                "string": str(self),
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> "VersionRange":
    #         """Create version range from dictionary representation."""
    min_version = (
    #             Version.from_dict(data["min_version"]) if data.get("min_version") else None
    #         )
    max_version = (
    #             Version.from_dict(data["max_version"]) if data.get("max_version") else None
    #         )

            return cls(
    min_version = min_version,
    max_version = max_version,
    include_min = data.get("include_min", True),
    include_max = data.get("include_max", True),
    #         )


# @dataclass
class VersionConstraint
    #     """
    #     Represents a version constraint.

    #     A version constraint can be a single version or a version range.
    #     It can also include multiple constraints that must all be satisfied.
    #     """

    constraints: List[Union[Version, VersionRange]] = field(default_factory=list)
    operator: VersionOperator = VersionOperator.AND

    #     def add_constraint(self, constraint: Union[Version, VersionRange]) -> None:
    #         """Add a constraint to this constraint set."""
            self.constraints.append(constraint)

    #     def satisfies(self, version: Version) -> bool:
    #         """
    #         Check if a version satisfies all constraints.

    #         Args:
    #             version: Version to check

    #         Returns:
    #             True if the version satisfies all constraints, False otherwise
    #         """
    #         if not self.constraints:
    #             return True

    #         if self.operator == VersionOperator.AND:
                return all(
                    (
                        constraint.contains(version)
    #                     if isinstance(constraint, VersionRange)
    else constraint = = version
    #                 )
    #                 for constraint in self.constraints
    #             )
    #         elif self.operator == VersionOperator.OR:
                return any(
                    (
                        constraint.contains(version)
    #                     if isinstance(constraint, VersionRange)
    else constraint = = version
    #                 )
    #                 for constraint in self.constraints
    #             )
    #         else:
                raise ValueError(f"Unsupported operator: {self.operator}")

    #     def __str__(self) -> str:
    #         """String representation of the version constraint."""
    #         if not self.constraints:
    #             return "*"

    constraint_strs = []
    #         for constraint in self.constraints:
    #             if isinstance(constraint, Version):
                    constraint_strs.append(str(constraint))
    #             else:
                    constraint_strs.append(str(constraint))

    #         if self.operator == VersionOperator.AND:
                return ", ".join(constraint_strs)
    #         elif self.operator == VersionOperator.OR:
                return " || ".join(constraint_strs)
    #         else:
                raise ValueError(f"Unsupported operator: {self.operator}")

    #     @staticmethod
    #     def parse(constraint_string: str) -> "VersionConstraint":
    #         """
    #         Parse a version constraint string into a VersionConstraint object.

    #         Args:
    constraint_string: Version constraint string to parse (e.g., "> = 1.0.0,<2.0.0")

    #         Returns:
    #             VersionConstraint object

    #         Raises:
    #             ValueError: If the constraint string is invalid
    #         """
    constraint_string = constraint_string.strip()

    #         # Handle empty constraint
    #         if not constraint_string or constraint_string == "*":
                return VersionConstraint()

    #         # Check for OR operator
    #         if " || " in constraint_string:
    parts = constraint_string.split(" || ")
    #             constraints = [VersionConstraint.parse(part) for part in parts]
                return VersionConstraint(
    constraints = [
    #                     c for constraint in constraints for c in constraint.constraints
    #                 ],
    operator = VersionOperator.OR,
    #             )

    #         # Parse individual constraints
    constraints = []
    #         for part in re.split(r",\s*", constraint_string):
    #             # Try to parse as a version range first
    #             try:
    range_constraint = VersionRange.parse(part)
                    constraints.append(range_constraint)
    #             except ValueError:
    #                 # If not a range, try to parse as a single version
    #                 try:
    version_constraint = Version.parse(part)
                        constraints.append(version_constraint)
    #                 except ValueError:
                        raise ValueError(f"Invalid constraint: {part}")

    return VersionConstraint(constraints = constraints)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert version constraint to dictionary representation."""
    #         return {
    #             "constraints": [
                    (
                        constraint.to_dict()
    #                     if hasattr(constraint, "to_dict")
                        else {"type": "version", "value": str(constraint)}
    #                 )
    #                 for constraint in self.constraints
    #             ],
    #             "operator": self.operator.value,
                "string": str(self),
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> "VersionConstraint":
    #         """Create version constraint from dictionary representation."""
    constraints = []
    #         for constraint_data in data.get("constraints", []):
    #             if constraint_data.get("type") == "version":
                    constraints.append(Version.parse(constraint_data["value"]))
    #             else:
                    constraints.append(VersionRange.from_dict(constraint_data))

    operator = VersionOperator(data.get("operator", "AND"))

    return cls(constraints = constraints, operator=operator)
