# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Utility functions and dependency container for NBC Runtime.

# This module provides a DependencyContainer for managing dependencies
# to avoid circular imports between runtime components.
# """

import dataclasses.dataclass
import typing.Any,


# @dataclass
class DependencyContainer
    #     """Simple dependency injection container."""

    _dependencies: Dict[str, Any] = None
    _factories: Dict[str, Callable[[], Any]] = None

    #     def __post_init__(self):
    self._dependencies = {}
    self._factories = {}

    #     def register(self, name: str, dependency: Any) -> None:
    #         """Register a dependency."""
    self._dependencies[name] = dependency

    #     def register_factory(self, name: str, factory: Callable[[], Any]) -> None:
    #         """Register a factory function for lazy instantiation."""
    self._factories[name] = factory

    #     def get(self, name: str) -> Any:
    #         """Get a dependency, instantiating from factory if needed."""
    #         if name in self._dependencies:
    #             return self._dependencies[name]

    #         if name in self._factories:
    dep = self._factories[name]()
    self._dependencies[name] = dep
    #             return dep

            raise KeyError(f"Dependency '{name}' not registered")

    #     def has(self, name: str) -> bool:
    #         """Check if dependency exists."""
    #         return name in self._dependencies or name in self._factories


# Global container instance
container = DependencyContainer()


def get_container() -> DependencyContainer:
#     """Get the global dependency container."""
#     return container
