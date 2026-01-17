"""
Noodle Improvement Planner - v2 Interface

The Planner is responsible for:
- Analyzing improvement requests
- Prioritizing tasks based on impact and risk
- Resolving dependencies between tasks
- Coordinating multi-task improvements
- Generating execution plans
"""
from abc import ABC, abstractmethod
from typing import Any, Optional
from dataclasses import dataclass
from enum import Enum


class TaskPriority(Enum):
    """Task priority levels."""
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"


class TaskStatus(Enum):
    """Task status in planning."""
    PROPOSED = "proposed"
    APPROVED = "approved"
    REJECTED = "rejected"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    BLOCKED = "blocked"
    CANCELLED = "cancelled"


@dataclass
class Dependency:
    """Represents a dependency between tasks."""
    task_id: str
    depends_on: str
    type: str  # "hard", "soft", "conflict"
    reason: str


@dataclass
class ExecutionPlan:
    """An execution plan for improvement tasks."""
    plan_id: str
    tasks: list[str]  # Task IDs in execution order
    dependencies: list[Dependency]
    estimated_duration: Optional[int] = None  # minutes
    estimated_impact: Optional[str] = None
    risk_assessment: Optional[str] = None

    def to_dict(self) -> dict[str, Any]:
        """Convert to dictionary."""
        return {
            "plan_id": self.plan_id,
            "tasks": self.tasks,
            "dependencies": [dep.__dict__ for dep in self.dependencies],
            "estimated_duration": self.estimated_duration,
            "estimated_impact": self.estimated_impact,
            "risk_assessment": self.risk_assessment
        }

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> "ExecutionPlan":
        """Create from dictionary."""
        dependencies = [
            Dependency(**dep) for dep in data.get("dependencies", [])
        ]
        return cls(
            plan_id=data["plan_id"],
            tasks=data["tasks"],
            dependencies=dependencies,
            estimated_duration=data.get("estimated_duration"),
            estimated_impact=data.get("estimated_impact"),
            risk_assessment=data.get("risk_assessment")
        )


class Planner(ABC):
    """
    Abstract base class for improvement planners.

    The Planner analyzes improvement requests and creates
    execution plans that consider dependencies, priorities,
    and resource constraints.
    """

    @abstractmethod
    def plan_improvement(
        self,
        tasks: list[dict[str, Any]],
        constraints: Optional[dict[str, Any]] = None
    ) -> ExecutionPlan:
        """
        Create an execution plan for improvement tasks.

        Args:
            tasks: List of task specifications
            constraints: Optional constraints (time, resources, etc.)

        Returns:
            ExecutionPlan with ordered tasks and dependencies
        """
        pass

    @abstractmethod
    def prioritize_tasks(
        self,
        tasks: list[dict[str, Any]]
    ) -> list[TaskPriority]:
        """
        Assign priorities to tasks based on impact and risk.

        Args:
            tasks: List of task specifications

        Returns:
            List of priorities corresponding to tasks
        """
        pass

    @abstractmethod
    def resolve_dependencies(
        self,
        tasks: list[dict[str, Any]]
    ) -> list[Dependency]:
        """
        Identify and resolve dependencies between tasks.

        Args:
            tasks: List of task specifications

        Returns:
            List of dependencies
        """
        pass

    @abstractmethod
    def estimate_impact(
        self,
        task: dict[str, Any]
    ) -> str:
        """
        Estimate the impact of a task.

        Args:
            task: Task specification

        Returns:
            Impact description (e.g., "high", "medium", "low")
        """
        pass

    @abstractmethod
    def validate_plan(
        self,
        plan: ExecutionPlan
    ) -> bool:
        """
        Validate that an execution plan is feasible.

        Args:
            plan: Execution plan to validate

        Returns:
            True if plan is valid
        """
        pass


class SimplePlanner(Planner):
    """
    Simple implementation of a Planner for v2.

    This is a basic implementation that can be extended
    with more sophisticated planning algorithms.
    """

    def __init__(self):
        self.plans_created = 0

    def plan_improvement(
        self,
        tasks: list[dict[str, Any]],
        constraints: Optional[dict[str, Any]] = None
    ) -> ExecutionPlan:
        """Create a simple execution plan."""
        # Prioritize tasks
        priorities = self.prioritize_tasks(tasks)

        # Resolve dependencies
        dependencies = self.resolve_dependencies(tasks)

        # Order tasks by priority (critical first)
        prioritized_tasks = [
            task for _, task in sorted(
                zip(priorities, tasks),
                key=lambda x: (
                    {"critical": 0, "high": 1, "medium": 2, "low": 3}
                )[x[0].value]
            )
        ]

        # Create plan
        plan_id = f"plan-{self.plans_created}"
        self.plans_created += 1

        return ExecutionPlan(
            plan_id=plan_id,
            tasks=[task.get("id", f"task-{i}") for i, task in enumerate(prioritized_tasks)],
            dependencies=dependencies,
            estimated_duration=sum(task.get("estimated_duration", 30) for task in tasks),
            estimated_impact=self._estimate_overall_impact(tasks),
            risk_assessment=self._assess_overall_risk(tasks)
        )

    def prioritize_tasks(
        self,
        tasks: list[dict[str, Any]]
    ) -> list[TaskPriority]:
        """Prioritize tasks based on risk and impact."""
        priorities = []
        for task in tasks:
            risk = task.get("risk", "medium")
            goal_type = task.get("goal", {}).get("type", "unknown")

            # Simple prioritization logic
            if risk == "high" and goal_type == "bugfix":
                priorities.append(TaskPriority.CRITICAL)
            elif risk == "high" or goal_type == "performance":
                priorities.append(TaskPriority.HIGH)
            elif risk == "medium":
                priorities.append(TaskPriority.MEDIUM)
            else:
                priorities.append(TaskPriority.LOW)

        return priorities

    def resolve_dependencies(
        self,
        tasks: list[dict[str, Any]]
    ) -> list[Dependency]:
        """
        Identify dependencies between tasks.

        Simple implementation: checks for overlapping file paths
        which might indicate potential conflicts.
        """
        dependencies = []
        {task.get("id"): task for task in tasks}

        for i, task_a in enumerate(tasks):
            for task_b in tasks[i+1:]:
                # Check for overlapping scope
                scope_a = set(task_a.get("scope", {}).get("repo_paths", []))
                scope_b = set(task_b.get("scope", {}).get("repo_paths", []))

                if scope_a & scope_b:  # Overlap detected
                    # Create soft dependency
                    dependencies.append(Dependency(
                        task_id=task_b.get("id"),
                        depends_on=task_a.get("id"),
                        type="soft",
                        reason=f"Overlapping scope: {scope_a & scope_b}"
                    ))

        return dependencies

    def estimate_impact(
        self,
        task: dict[str, Any]
    ) -> str:
        """Estimate task impact."""
        goal_type = task.get("goal", {}).get("type", "unknown")
        risk = task.get("risk", "medium")

        if goal_type == "performance" and risk == "high":
            return "high"
        elif goal_type == "bugfix" or goal_type == "feature":
            return "medium"
        else:
            return "low"

    def validate_plan(
        self,
        plan: ExecutionPlan
    ) -> bool:
        """Validate execution plan."""
        # Check for circular dependencies
        task_deps = {dep.task_id: [] for dep in plan.dependencies}
        for dep in plan.dependencies:
            task_deps.setdefault(dep.depends_on, [])
            task_deps[dep.task_id].append(dep.depends_on)

        # Simple cycle detection
        visited = set()
        rec_stack = set()

        def has_cycle(task_id: str) -> bool:
            visited.add(task_id)
            rec_stack.add(task_id)

            for dep in task_deps.get(task_id, []):
                if dep not in visited:
                    if has_cycle(dep):
                        return True
                elif dep in rec_stack:
                    return True

            rec_stack.remove(task_id)
            return False

        return all(not (task_id not in visited and has_cycle(task_id)) for task_id in task_deps)

    def _estimate_overall_impact(self, tasks: list[dict[str, Any]]) -> str:
        """Estimate overall impact of all tasks."""
        impacts = [self.estimate_impact(task) for task in tasks]

        if "high" in impacts:
            return "high"
        elif "medium" in impacts:
            return "medium"
        else:
            return "low"

    def _assess_overall_risk(self, tasks: list[dict[str, Any]]) -> str:
        """Assess overall risk of all tasks."""
        risks = [task.get("risk", "medium") for task in tasks]

        if "high" in risks:
            return "high"
        elif "medium" in risks:
            return "medium"
        else:
            return "low"


def create_planner(planner_type: str = "simple") -> Planner:
    """
    Factory function to create a planner instance.

    Args:
        planner_type: Type of planner ("simple", "advanced", etc.)

    Returns:
        Planner instance
    """
    if planner_type == "simple":
        return SimplePlanner()
    else:
        raise ValueError(f"Unknown planner type: {planner_type}")


# Convenience function for quick planning
def plan_improvements(
    tasks: list[dict[str, Any]],
    constraints: Optional[dict[str, Any]] = None
) -> ExecutionPlan:
    """
    Quick function to create an improvement plan.

    Args:
        tasks: List of task specifications
        constraints: Optional constraints

    Returns:
        ExecutionPlan
    """
    planner = create_planner()
    return planner.plan_improvement(tasks, constraints)
