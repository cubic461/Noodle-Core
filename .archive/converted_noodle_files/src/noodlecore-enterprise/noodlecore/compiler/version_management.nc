# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Version management system for Noodle compiler.
# Provides version tracking, comparison, and management capabilities.
# """

import typing.Any,
import dataclasses.dataclass,
import enum.Enum
import json
import re
import hashlib
import datetime.datetime
import os
import pathlib.Path
import semver
import uuid
import threading
import dataclasses.asdict


class VersionStatus(Enum)
    #     """Status of a version"""
    DRAFT = "draft"
    ACTIVE = "active"
    DEPRECATED = "deprecated"
    ARCHIVED = "archived"


# @dataclass
class Version
    #     """Represents a version of the compiler or project"""
    #     major: int
    #     minor: int
    #     patch: int
    prerelease: Optional[str] = None
    build_metadata: Optional[str] = None
    status: VersionStatus = VersionStatus.ACTIVE
    release_date: Optional[datetime] = None
    description: Optional[str] = None
    changelog: Optional[str] = None
    compatibility_notes: Optional[str] = None
    deprecation_info: Optional[str] = None
    dependencies: Dict[str, str] = field(default_factory=dict)
    features: List[str] = field(default_factory=list)
    bug_fixes: List[str] = field(default_factory=list)
    breaking_changes: List[str] = field(default_factory=list)
    api_changes: List[str] = field(default_factory=list)
    performance_improvements: List[str] = field(default_factory=list)
    security_patches: List[str] = field(default_factory=list)
    contributors: List[str] = field(default_factory=list)
    commit_hash: Optional[str] = None
    build_number: Optional[int] = None
    branch_name: Optional[str] = None
    version_id: str = field(default_factory=lambda: str(uuid.uuid4()))

    #     def __str__(self) -> str:
    version_str = f"{self.major}.{self.minor}.{self.patch}"
    #         if self.prerelease:
    version_str + = f"-{self.prerelease}"
    #         if self.build_metadata:
    version_str + = f"+{self.build_metadata}"
    #         return version_str

    #     def to_semver(self) -> str:
    #         """Convert to semantic version string"""
            return str(self)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary for serialization"""
    data = asdict(self)
    data['status'] = self.status.value
    #         if self.release_date:
    data['release_date'] = self.release_date.isoformat()
    #         return data

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> 'Version':
    #         """Create from dictionary"""
    #         if 'status' in data and isinstance(data['status'], str):
    data['status'] = VersionStatus(data['status'])

    #         if 'release_date' in data and data['release_date']:
    data['release_date'] = datetime.fromisoformat(data['release_date'])

            return cls(**data)

    #     def increment_major(self) -> 'Version':
    #         """Increment major version"""
            return Version(
    major = math.add(self.major, 1,)
    minor = 0,
    patch = 0,
    prerelease = self.prerelease,
    build_metadata = self.build_metadata,
    status = VersionStatus.DRAFT
    #         )

    #     def increment_minor(self) -> 'Version':
    #         """Increment minor version"""
            return Version(
    major = self.major,
    minor = math.add(self.minor, 1,)
    patch = 0,
    prerelease = self.prerelease,
    build_metadata = self.build_metadata,
    status = VersionStatus.DRAFT
    #         )

    #     def increment_patch(self) -> 'Version':
    #         """Increment patch version"""
            return Version(
    major = self.major,
    minor = self.minor,
    patch = math.add(self.patch, 1,)
    prerelease = self.prerelease,
    build_metadata = self.build_metadata,
    status = VersionStatus.DRAFT
    #         )

    #     def is_compatible(self, other: 'Version') -> bool:
    #         """Check if this version is compatible with another version"""
    #         # For now, consider major version compatibility
    return self.major = = other.major

    #     def satisfies_requirement(self, requirement: str) -> bool:
    #         """Check if this version satisfies a requirement string"""
    #         try:
    #             # Use semver to parse and check requirement
    spec = semver.Spec(requirement)
    version = semver.VersionInfo.parse(str(self))
                return spec.match(version)
    #         except:
    #             # Fallback to simple comparison
                return self._simple_requirement_check(requirement)

    #     def _simple_requirement_check(self, requirement: str) -> bool:
    #         """Simple requirement check as fallback"""
    # Handle >, <, > = , <=, ==, !=
    #         if requirement.startswith(">="):
    min_ver = Version.from_string(requirement[2:])
    return self > = min_ver
    #         elif requirement.startswith("<="):
    max_ver = Version.from_string(requirement[2:])
    return self < = max_ver
    #         elif requirement.startswith(">"):
    min_ver = Version.from_string(requirement[1:])
    #             return self > min_ver
    #         elif requirement.startswith("<"):
    max_ver = Version.from_string(requirement[1:])
    #             return self < max_ver
    #         elif requirement.startswith("=="):
    exact_ver = Version.from_string(requirement[2:])
    return self = = exact_ver
    #         elif requirement.startswith("!="):
    not_ver = Version.from_string(requirement[2:])
    return self ! = not_ver
    #         else:
    #             # Default to exact match
    return self = = Version.from_string(requirement)

    #     @classmethod
    #     def from_string(cls, version_str: str) -> 'Version':
    #         """Parse version from string"""
    #         try:
    #             # Use semver to parse the version
    parsed = semver.parse(version_str)

                return cls(
    major = parsed.major,
    minor = parsed.minor,
    patch = parsed.patch,
    prerelease = parsed.prerelease,
    build_metadata = parsed.build
    #             )
    #         except:
    #             # Fallback to simple parsing
    parts = re.match(r'^(\d+)\.(\d+)\.(\d+)(?:-([0-9a-zA-Z.-]+))?(?:\+([0-9a-zA-Z.-]+))?$', version_str)
    #             if parts:
                    return cls(
    major = int(parts.group(1)),
    minor = int(parts.group(2)),
    patch = int(parts.group(3)),
    prerelease = parts.group(4),
    build_metadata = parts.group(5)
    #                 )
    #             else:
                    raise ValueError(f"Invalid version string: {version_str}")

    #     def __eq__(self, other: object) -> bool:
    #         if not isinstance(other, Version):
    #             return False
    return (self.major = = other.major and
    self.minor = = other.minor and
    self.patch = = other.patch and
    self.prerelease = = other.prerelease and
    self.build_metadata = = other.build_metadata)

    #     def __lt__(self, other: 'Version') -> bool:
            return self.to_semver() < other.to_semver()

    #     def __le__(self, other: 'Version') -> bool:
    return self.to_semver() < = other.to_semver()

    #     def __gt__(self, other: 'Version') -> bool:
            return self.to_semver() > other.to_semver()

    #     def __ge__(self, other: 'Version') -> bool:
    return self.to_semver() > = other.to_semver()


# @dataclass
class VersionHistory
    #     """Tracks version history"""
    versions: List[Version] = field(default_factory=list)
    current_version: Optional[Version] = None
    default_branch: str = "main"
    support_policy: Dict[str, int] = field(default_factory=dict)  # major_version: years_of_support

    #     def add_version(self, version: Version):
    #         """Add a version to history"""
            self.versions.append(version)
    self.versions.sort(key = lambda v: (v.major, v.minor, v.patch))

    #         if version.status == VersionStatus.ACTIVE:
    self.current_version = version

    #     def get_version(self, version_id: str) -> Optional[Version]:
    #         """Get version by ID"""
    #         for version in self.versions:
    #             if version.version_id == version_id:
    #                 return version
    #         return None

    #     def get_version_by_string(self, version_str: str) -> Optional[Version]:
    #         """Get version by string representation"""
    #         for version in self.versions:
    #             if str(version) == version_str:
    #                 return version
    #         return None

    #     def get_latest_version(self, include_prerelease: bool = False) -> Optional[Version]:
    #         """Get the latest version"""
    versions = self.versions

    #         if not include_prerelease:
    #             versions = [v for v in versions if v.prerelease is None]

    #         if not versions:
    #             return None

            return max(versions)

    #     def get_previous_version(self, version: Version) -> Optional[Version]:
    #         """Get the version before the specified one"""
    #         index = self.versions.index(version) if version in self.versions else -1
    #         if index > 0:
    #             return self.versions[index - 1]
    #         return None

    #     def get_next_version(self, version: Version) -> Optional[Version]:
    #         """Get the version after the specified one"""
    #         index = self.versions.index(version) if version in self.versions else -1
    #         if index < len(self.versions) - 1:
    #             return self.versions[index + 1]
    #         return None

    #     def get_versions_by_status(self, status: VersionStatus) -> List[Version]:
    #         """Get versions with specific status"""
    #         return [v for v in self.versions if v.status == status]

    #     def get_deprecated_versions(self) -> List[Version]:
    #         """Get all deprecated versions"""
            return self.get_versions_by_status(VersionStatus.DEPRECATED)

    #     def get_supported_versions(self) -> List[Version]:
    #         """Get all currently supported versions"""
    current_year = datetime.now().year
    supported = []

    #         for version in self.versions:
    #             if version.status == VersionStatus.ACTIVE:
                    supported.append(version)
    #             elif version.status == VersionStatus.DEPRECATED:
    #                 # Check if still within support period
    #                 if version.release_date:
    years_since_release = math.subtract(current_year, version.release_date.year)
    support_years = self.support_policy.get(str(version.major), 0)

    #                     if years_since_release < support_years:
                            supported.append(version)

    #         return supported

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary for serialization"""
    #         return {
    #             'versions': [v.to_dict() for v in self.versions],
    #             'current_version': self.current_version.to_dict() if self.current_version else None,
    #             'default_branch': self.default_branch,
    #             'support_policy': self.support_policy
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> 'VersionHistory':
    #         """Create from dictionary"""
    #         versions = [Version.from_dict(v) for v in data.get('versions', [])]
    #         current_version = Version.from_dict(data['current_version']) if data.get('current_version') else None

    history = cls(
    versions = versions,
    current_version = current_version,
    default_branch = data.get('default_branch', 'main'),
    support_policy = data.get('support_policy', {})
    #         )

    #         return history


class VersionManagement
    #     """Main version management system"""

    #     def __init__(self, storage_path: Optional[str] = None):
    self.storage_path = storage_path or "versions.json"
    self.version_history: VersionHistory = VersionHistory()
    self._lock = threading.Lock()
            self._load_from_storage()

    #     def _load_from_storage(self):
    #         """Load version history from storage"""
    #         try:
    #             if os.path.exists(self.storage_path):
    #                 with open(self.storage_path, 'r') as f:
    data = json.load(f)
    self.version_history = VersionHistory.from_dict(data)
    #         except Exception as e:
                print(f"Warning: Could not load version history: {e}")
    self.version_history = VersionHistory()

    #     def _save_to_storage(self):
    #         """Save version history to storage"""
    #         try:
    #             with open(self.storage_path, 'w') as f:
    json.dump(self.version_history.to_dict(), f, indent = 2)
    #         except Exception as e:
                print(f"Warning: Could not save version history: {e}")

    #     def create_version(self,
    #                       major: int,
    #                       minor: int,
    #                       patch: int,
    prerelease: Optional[str] = None,
    build_metadata: Optional[str] = None,
    description: Optional[str] = None,
    changelog: Optional[str] = None,
    status: VersionStatus = VersionStatus.DRAFT,
    release_date: Optional[datetime] = math.subtract(None), > Version:)
    #         """Create a new version"""
    version = Version(
    major = major,
    minor = minor,
    patch = patch,
    prerelease = prerelease,
    build_metadata = build_metadata,
    description = description,
    changelog = changelog,
    status = status,
    release_date = release_date
    #         )

    #         with self._lock:
                self.version_history.add_version(version)
                self._save_to_storage()

    #         return version

    #     def release_version(self, version_id: str, release_date: Optional[datetime] = None) -> bool:
    #         """Release a version"""
    #         with self._lock:
    version = self.version_history.get_version(version_id)
    #             if version:
    version.status = VersionStatus.ACTIVE
    version.release_date = release_date or datetime.now()
                    self._save_to_storage()
    #                 return True
    #             return False

    #     def deprecate_version(self, version_id: str, deprecation_info: Optional[str] = None) -> bool:
    #         """Deprecate a version"""
    #         with self._lock:
    version = self.version_history.get_version(version_id)
    #             if version:
    version.status = VersionStatus.DEPRECATED
    version.deprecation_info = deprecation_info
                    self._save_to_storage()
    #                 return True
    #             return False

    #     def archive_version(self, version_id: str) -> bool:
    #         """Archive a version"""
    #         with self._lock:
    version = self.version_history.get_version(version_id)
    #             if version:
    version.status = VersionStatus.ARCHIVED
                    self._save_to_storage()
    #                 return True
    #             return False

    #     def get_version(self, version_id: str) -> Optional[Version]:
    #         """Get version by ID"""
            return self.version_history.get_version(version_id)

    #     def get_version_by_string(self, version_str: str) -> Optional[Version]:
    #         """Get version by string representation"""
            return self.version_history.get_version_by_string(version_str)

    #     def get_latest_version(self, include_prerelease: bool = False) -> Optional[Version]:
    #         """Get the latest version"""
            return self.version_history.get_latest_version(include_prerelease)

    #     def get_current_version(self) -> Optional[Version]:
    #         """Get the current active version"""
    #         return self.version_history.current_version

    #     def get_versions_by_status(self, status: VersionStatus) -> List[Version]:
    #         """Get versions by status"""
            return self.version_history.get_versions_by_status(status)

    #     def get_next_version(self, version: Version) -> Optional[Version]:
    #         """Get the next version"""
            return self.version_history.get_next_version(version)

    #     def get_previous_version(self, version: Version) -> Optional[Version]:
    #         """Get the previous version"""
            return self.version_history.get_previous_version(version)

    #     def find_compatible_versions(self, version: Version) -> List[Version]:
    #         """Find versions compatible with the given version"""
    #         return [v for v in self.version_history.versions if v.is_compatible(version)]

    #     def find_versions_satisfying_requirement(self, requirement: str) -> List[Version]:
    #         """Find versions that satisfy the given requirement"""
    #         return [v for v in self.version_history.versions if v.satisfies_requirement(requirement)]

    #     def generate_changelog(self, version_id: str) -> Optional[str]:
    #         """Generate changelog for a version"""
    version = self.version_history.get_version(version_id)
    #         if not version or not version.changelog:
    #             return None

    changelog = []
    #         changelog.append(f"# Changelog for {version}")
            changelog.append("")

    #         if version.features:
                changelog.append("## Features")
                changelog.append("")
    #             for feature in version.features:
                    changelog.append(f"- {feature}")
                changelog.append("")

    #         if version.bug_fixes:
                changelog.append("## Bug Fixes")
                changelog.append("")
    #             for fix in version.bug_fixes:
                    changelog.append(f"- {fix}")
                changelog.append("")

    #         if version.performance_improvements:
                changelog.append("## Performance Improvements")
                changelog.append("")
    #             for improvement in version.performance_improvements:
                    changelog.append(f"- {improvement}")
                changelog.append("")

    #         if version.api_changes:
                changelog.append("## API Changes")
                changelog.append("")
    #             for change in version.api_changes:
                    changelog.append(f"- {change}")
                changelog.append("")

    #         if version.security_patches:
                changelog.append("## Security Patches")
                changelog.append("")
    #             for patch in version.security_patches:
                    changelog.append(f"- {patch}")
                changelog.append("")

    #         if version.breaking_changes:
                changelog.append("## Breaking Changes")
                changelog.append("")
    #             for change in version.breaking_changes:
                    changelog.append(f"- {change}")
                changelog.append("")

            return "\n".join(changelog)

    #     def export_version_info(self, version_id: str, format: str = "json") -> Optional[str]:
    #         """Export version information"""
    version = self.version_history.get_version(version_id)
    #         if not version:
    #             return None

    #         if format.lower() == "json":
    return json.dumps(version.to_dict(), indent = 2)
    #         elif format.lower() == "markdown":
    lines = []
                lines.append(f"# Version {version}")
                lines.append("")

    #             if version.description:
                    lines.append(f"## Description")
                    lines.append("")
                    lines.append(version.description)
                    lines.append("")

    #             if version.release_date:
                    lines.append(f"## Release Date")
                    lines.append("")
                    lines.append(f"- {version.release_date.strftime('%Y-%m-%d')}")
                    lines.append("")

    #             if version.changelog:
                    lines.append("## Changelog")
                    lines.append("")
                    lines.append(version.changelog)
                    lines.append("")

    #             if version.features:
                    lines.append("## Features")
                    lines.append("")
    #                 for feature in version.features:
                        lines.append(f"- {feature}")
                    lines.append("")

    #             if version.bug_fixes:
                    lines.append("## Bug Fixes")
                    lines.append("")
    #                 for fix in version.bug_fixes:
                        lines.append(f"- {fix}")
                    lines.append("")

    #             if version.contributors:
                    lines.append("## Contributors")
                    lines.append("")
    #                 for contributor in version.contributors:
                        lines.append(f"- {contributor}")
                    lines.append("")

                return "\n".join(lines)
    #         else:
                raise ValueError(f"Unsupported export format: {format}")

    #     def get_version_statistics(self) -> Dict[str, Any]:
    #         """Get version statistics"""
    versions = self.version_history.versions

    stats = {
                'total_versions': len(versions),
                'active_versions': len(self.version_history.get_versions_by_status(VersionStatus.ACTIVE)),
                'deprecated_versions': len(self.version_history.get_versions_by_status(VersionStatus.DEPRECATED)),
                'archived_versions': len(self.version_history.get_versions_by_status(VersionStatus.ARCHIVED)),
                'draft_versions': len(self.version_history.get_versions_by_status(VersionStatus.DRAFT)),
                'supported_versions': len(self.version_history.get_supported_versions()),
    #             'latest_version': str(self.version_history.get_latest_version()) if self.version_history.get_latest_version() else None,
    #             'oldest_version': str(min(versions)) if versions else None,
    #             'newest_version': str(max(versions)) if versions else None,
    #         }

    #         # Count features, bug fixes, etc.
    all_features = []
    all_bug_fixes = []
    all_breaking_changes = []

    #         for version in versions:
                all_features.extend(version.features)
                all_bug_fixes.extend(version.bug_fixes)
                all_breaking_changes.extend(version.breaking_changes)

    stats['total_features'] = len(all_features)
    stats['total_bug_fixes'] = len(all_bug_fixes)
    stats['total_breaking_changes'] = len(all_breaking_changes)

    #         return stats


class GlobalVersionManager
    #     """Global version manager instance"""

    _instance = None
    _lock = threading.Lock()

    #     def __new__(cls, storage_path: Optional[str] = None):
    #         if cls._instance is None:
    #             with cls._lock:
    #                 if cls._instance is None:
    cls._instance = super().__new__(cls)
    cls._instance._initialized = False
    #         return cls._instance

    #     def __init__(self, storage_path: Optional[str] = None):
    #         if not self._initialized:
    self.version_manager = VersionManagement(storage_path)
    self._initialized = True

    #     def get_version_manager(self) -> VersionManagement:
    #         """Get the version manager instance"""
    #         return self.version_manager


# Global instance
global_version_manager = GlobalVersionManager()


def get_version_manager() -> VersionManagement:
#     """Get the global version manager"""
    return global_version_manager.get_version_manager()


def create_version(major: int,
#                   minor: int,
#                   patch: int,
prerelease: Optional[str] = None,
build_metadata: Optional[str] = None,
description: Optional[str] = None,
changelog: Optional[str] = None,
status: VersionStatus = VersionStatus.DRAFT,
release_date: Optional[datetime] = math.subtract(None), > Version:)
#     """Create a new version using the global manager"""
    return get_version_manager().create_version(
major = major,
minor = minor,
patch = patch,
prerelease = prerelease,
build_metadata = build_metadata,
description = description,
changelog = changelog,
status = status,
release_date = release_date
#     )


def get_current_version() -> Optional[Version]:
#     """Get the current version using the global manager"""
    return get_version_manager().get_current_version()


def get_latest_version(include_prerelease: bool = False) -> Optional[Version]:
#     """Get the latest version using the global manager"""
    return get_version_manager().get_latest_version(include_prerelease)


def release_version(version_id: str, release_date: Optional[datetime] = None) -> bool:
#     """Release a version using the global manager"""
    return get_version_manager().release_version(version_id, release_date)


# Example usage
if __name__ == "__main__"
    #     # Create a version
    version = create_version(
    major = 1,
    minor = 0,
    patch = 0,
    description = "Initial release",
    changelog = "First stable release",
    features = ["Core language implementation", "Type system"],
    bug_fixes = ["Fixed parser issues"],
    contributors = ["Developer 1", "Developer 2"]
    #     )

        print(f"Created version: {version}")
        print(f"Version ID: {version.version_id}")

    #     # Get current version
    current = get_current_version()
        print(f"Current version: {current}")

    #     # Get latest version
    latest = get_latest_version()
        print(f"Latest version: {latest}")

    #     # Release the version
        release_version(version.version_id)
        print(f"Released version: {version}")

    #     # Get statistics
    stats = get_version_manager().get_version_statistics()
        print(f"Version statistics: {stats}")
