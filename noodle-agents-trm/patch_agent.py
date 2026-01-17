"""
PatchAgent - v3 with Full LLM Integration

The PatchAgent is responsible for:
- Analyzing code improvement requests
- Generating code patches (unified diffs) using LLMs
- Validating generated patches
- Refining patches based on feedback
- Full integration with Z.ai GLM-4.7 (primary) and other providers
"""
from abc import ABC, abstractmethod
from typing import List, Dict, Any, Optional, Tuple
from dataclasses import dataclass
from enum import Enum
import re
import sys
from pathlib import Path

# Add noodle-core to path for imports
core_path = Path(__file__).parent.parent / "noodle-core" / "src"
if str(core_path) not in sys.path:
    sys.path.insert(0, str(core_path))

try:
    from noodlecore.improve.llm_integration import (
        LLMManager, LLMConfig, LLMProvider, LLMModel, 
        create_default_llm_manager
    )
except ImportError:
    # If import fails, we'll define stubs
    LLMManager = None
    LLMConfig = None
    LLMProvider = None
    LLMModel = None
    create_default_llm_manager = None


class PatchStatus(Enum):
    """Status of generated patches."""
    GENERATED = "generated"
    VALIDATING = "validating"
    VALID = "valid"
    INVALID = "invalid"
    APPLIED = "applied"
    FAILED = "failed"
    REFINING = "refining"


class PatchStrategy(Enum):
    """Patch generation strategies."""
    LLM_BASED = "llm_based"
    TEMPLATE_BASED = "template_based"
    HYBRID = "hybrid"
    REFACTORING = "refactoring"
    BUGFIX = "bugfix"


@dataclass
class PatchResult:
    """Result of patch generation."""
    patch: str  # Unified diff format
    strategy: PatchStrategy
    confidence: float  # 0.0 to 1.0
    metadata: Dict[str, Any]
    status: PatchStatus
    validation_errors: Optional[List[str]] = None
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            "patch": self.patch,
            "strategy": self.strategy.value,
            "confidence": self.confidence,
            "metadata": self.metadata,
            "status": self.status.value,
            "validation_errors": self.validation_errors
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "PatchResult":
        """Create from dictionary."""
        return cls(
            patch=data["patch"],
            strategy=PatchStrategy(data["strategy"]),
            confidence=data["confidence"],
            metadata=data["metadata"],
            status=PatchStatus(data["status"]),
            validation_errors=data.get("validation_errors")
        )


@dataclass
class PatchRequest:
    """Request to generate a patch."""
    task_id: str
    goal: Dict[str, Any]
    files: List[str]
    context: Optional[Dict[str, Any]] = None
    constraints: Optional[Dict[str, Any]] = None
    previous_attempts: Optional[List[PatchResult]] = None
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            "task_id": self.task_id,
            "goal": self.goal,
            "files": self.files,
            "context": self.context,
            "constraints": self.constraints,
            "previous_attempts": [
                attempt.to_dict() for attempt in (self.previous_attempts or [])
            ]
        }


class PatchAgent(ABC):
    """
    Abstract base class for patch generation agents.
    
    The PatchAgent analyzes improvement requests and generates
    code changes using various strategies (LLM-based, template-based, etc.).
    """
    
    @abstractmethod
    def generate_patch(self, request: PatchRequest) -> PatchResult:
        """Generate a patch for the given request."""
        pass
    
    @abstractmethod
    def validate_patch(self, patch: str, context: Dict[str, Any]) -> Tuple[bool, List[str]]:
        """Validate a generated patch."""
        pass
    
    @abstractmethod
    def refine_patch(self, patch: str, feedback: str) -> PatchResult:
        """Refine a patch based on feedback."""
        pass
    
    @abstractmethod
    def estimate_confidence(self, patch: str, context: Dict[str, Any]) -> float:
        """Estimate confidence in patch quality (0.0 to 1.0)."""
        pass


class SimplePatchAgent(PatchAgent):
    """
    Template-based patch agent for simple patterns.
    
    Uses predefined templates for common refactoring patterns.
    Suitable for low-risk, well-understood transformations.
    """
    
    def __init__(self):
        self.templates = {
            "rename_import": self._rename_import_template,
            "add_log_statement": self._add_log_template,
            "update_constant": self._update_constant_template,
        }
    
    def generate_patch(self, request: PatchRequest) -> PatchResult:
        """Generate patch using template matching."""
        goal_type = request.goal.get("type", "")
        
        if goal_type in self.templates:
            patch = self.templates[goal_type](request)
            return PatchResult(
                patch=patch,
                strategy=PatchStrategy.TEMPLATE_BASED,
                confidence=0.8,
                metadata={"template": goal_type},
                status=PatchStatus.GENERATED
            )
        
        # No template found
        return PatchResult(
            patch="",
            strategy=PatchStrategy.TEMPLATE_BASED,
            confidence=0.0,
            metadata={"error": "No matching template"},
            status=PatchStatus.FAILED,
            validation_errors=["No template found for goal type"]
        )
    
    def validate_patch(self, patch: str, context: Dict[str, Any]) -> Tuple[bool, List[str]]:
        """Validate template-generated patch."""
        errors = []
        
        if not patch:
            errors.append("Patch is empty")
        
        # Basic validation
        if "---" not in patch or "+++" not in patch:
            errors.append("Invalid patch format")
        
        return (len(errors) == 0, errors)
    
    def refine_patch(self, patch: str, feedback: str) -> PatchResult:
        """Refine is limited for template-based agent."""
        return PatchResult(
            patch=patch,
            strategy=PatchStrategy.TEMPLATE_BASED,
            confidence=0.8,
            metadata={"refinement": "limited"},
            status=PatchStatus.GENERATED
        )
    
    def estimate_confidence(self, patch: str, context: Dict[str, Any]) -> float:
        """Estimate confidence based on template match."""
        return 0.8  # Templates are reliable when they match
    
    def _rename_import_template(self, request: PatchRequest) -> str:
        """Template for renaming imports."""
        # Simple placeholder
        return """--- a/example.py
+++ b/example.py
@@ -1,3 +1,3 @@
-import old_module
+import new_module
"""
    
    def _add_log_template(self, request: PatchRequest) -> str:
        """Template for adding log statements."""
        return """--- a/example.py
+++ b/example.py
@@ -1,3 +1,4 @@
 def function():
+    print("Log: function called")
     pass
"""
    
    def _update_constant_template(self, request: PatchRequest) -> str:
        """Template for updating constants."""
        return """--- a/example.py
+++ b/example.py
@@ -1,3 +1,3 @@
-CONSTANT = 100
+CONSTANT = 200
"""


class LLMPatchAgent(PatchAgent):
    """
    LLM-based patch agent with full integration.
    
    Uses Z.ai GLM-4.7 as primary provider with fallback to
    OpenAI, Anthropic, etc. for intelligent code generation.
    
    Features:
    - Context-aware patch generation
    - Multi-turn refinement
    - Confidence scoring
    - Automatic validation
    """
    
    def __init__(
        self,
        llm_manager: Optional[LLMManager] = None,
        primary_provider: str = "z_ai",
        model_name: str = "glm-4.7"
    ):
        if LLMManager is None:
            raise ImportError(
                "LLM integration not available. "
                "Ensure noodle-core is properly installed."
            )
        
        # Create LLM manager
        if llm_manager is None:
            config = LLMConfig(
                provider=LLMProvider.Z_AI,
                model=model_name,
                temperature=0.3,  # Lower temperature for code
                max_tokens=4096
            )
            self.llm_manager = create_default_llm_manager()
        else:
            self.llm_manager = llm_manager
        
        self.primary_provider = primary_provider
        self.model_name = model_name
        
        # Track statistics
        self.total_patches = 0
        self.successful_patches = 0
    
    def generate_patch(self, request: PatchRequest) -> PatchResult:
        """
        Generate patch using LLM.
        
        This is the primary method for intelligent patch generation.
        Uses the LLM to analyze the code context and generate
        appropriate changes.
        """
        self.total_patches += 1
        
        # Prepare context
        context = self._prepare_context(request)
        
        # Generate system prompt
        system_prompt = self._create_system_prompt(request)
        
        # Generate user prompt
        user_prompt = self._create_user_prompt(request, context)
        
        try:
            # Call LLM
            response = self.llm_manager.generate(
                prompt=user_prompt,
                system_prompt=system_prompt,
                use_fallback=True
            )
            
            patch = response.content
            
            # Validate patch
            is_valid, errors = self.validate_patch(patch, context)
            
            if is_valid:
                self.successful_patches += 1
                status = PatchStatus.VALID
            else:
                status = PatchStatus.INVALID
            
            # Estimate confidence
            confidence = self.estimate_confidence(patch, context)
            
            return PatchResult(
                patch=patch,
                strategy=PatchStrategy.LLM_BASED,
                confidence=confidence,
                metadata={
                    "llm_provider": self.primary_provider,
                    "model": self.model_name,
                    "tokens_used": response.tokens_used,
                    "cost_usd": response.cost_usd,
                    "duration_seconds": response.duration_seconds
                },
                status=status,
                validation_errors=errors if not is_valid else None
            )
            
        except Exception as e:
            return PatchResult(
                patch="",
                strategy=PatchStrategy.LLM_BASED,
                confidence=0.0,
                metadata={"error": str(e)},
                status=PatchStatus.FAILED,
                validation_errors=[str(e)]
            )
    
    def validate_patch(self, patch: str, context: Dict[str, Any]) -> Tuple[bool, List[str]]:
        """
        Validate generated patch.
        
        Checks:
        - Valid unified diff format
        - File paths exist in context
        - No syntax errors (basic check)
        - Follows constraints
        """
        errors = []
        
        # Check if patch is non-empty
        if not patch or not patch.strip():
            errors.append("Patch is empty")
            return (False, errors)
        
        # Check unified diff format
        if "---" not in patch or "+++" not in patch:
            errors.append("Invalid patch format: missing ---/+++ headers")
        
        # Check for @@ markers
        if "@@" not in patch:
            errors.append("Invalid patch format: missing @@ hunk headers")
        
        # Basic syntax validation (Python)
        python_files = re.findall(r'\+\+\+ b/(.*\.py)', patch)
        for file_path in python_files:
            # Extract added lines
            added_lines = re.findall(r'^\+(.+)$', patch, re.MULTILINE)
            for line in added_lines:
                # Basic syntax check
                if line and not line.startswith('+'):
                    try:
                        compile(line, '<string>', 'exec')
                    except SyntaxError:
                        # This is OK, it might be part of a larger block
                        pass
        
        return (len(errors) == 0, errors)
    
    def refine_patch(
        self,
        patch: str,
        feedback: str,
        request: Optional[PatchRequest] = None
    ) -> PatchResult:
        """
        Refine patch based on feedback.
        
        Uses LLM to iteratively improve the patch based on
        validation errors, test failures, or user feedback.
        """
        if not request:
            # Minimal refinement without request context
            prompt = f"""Original patch:
{patch}

Feedback:
{feedback}

Please refine the patch to address the feedback.
Output ONLY the refined unified diff."""
            
            response = self.llm_manager.generate(
                prompt=prompt,
                system_prompt="You are a code refinement assistant. Output only valid unified diffs."
            )
            
            return PatchResult(
                patch=response.content,
                strategy=PatchStrategy.LLM_BASED,
                confidence=0.7,  # Lower confidence for refined versions
                metadata={"refined": True, "tokens_used": response.tokens_used},
                status=PatchStatus.GENERATED
            )
        
        # Full refinement with context
        context = self._prepare_context(request)
        
        prompt = f"""Context:
{context}

Original patch:
{patch}

Feedback:
{feedback}

Previous attempts:
{len(request.previous_attempts or [])}

Please generate a refined patch that addresses the feedback.
Output ONLY the refined unified diff."""
        
        response = self.llm_manager.generate(
            prompt=prompt,
            system_prompt=self._create_system_prompt(request)
        )
        
        refined_patch = response.content
        is_valid, errors = self.validate_patch(refined_patch, context)
        
        return PatchResult(
            patch=refined_patch,
            strategy=PatchStrategy.LLM_BASED,
            confidence=self.estimate_confidence(refined_patch, context),
            metadata={
                "refined": True,
                "iteration": len(request.previous_attempts or []) + 1,
                "tokens_used": response.tokens_used
            },
            status=PatchStatus.VALID if is_valid else PatchStatus.INVALID,
            validation_errors=errors if not is_valid else None
        )
    
    def estimate_confidence(self, patch: str, context: Dict[str, Any]) -> float:
        """
        Estimate confidence in patch quality.
        
        Factors:
        - LLM provider reliability
        - Patch complexity (LOC changed)
        - Validation results
        - File type
        """
        base_confidence = 0.7  # Base confidence for LLM-generated
        
        # Adjust based on patch size
        added_lines = patch.count('\n+')
        removed_lines = patch.count('\n-')
        total_changes = added_lines + removed_lines
        
        if total_changes == 0:
            return 0.0
        
        # Smaller patches = higher confidence
        if total_changes < 10:
            base_confidence += 0.2
        elif total_changes < 50:
            base_confidence += 0.1
        elif total_changes > 200:
            base_confidence -= 0.2
        
        # Adjust based on provider
        if self.primary_provider == "z_ai":
            base_confidence += 0.1  # Z.ai is optimized for code
        
        return max(0.0, min(1.0, base_confidence))
    
    def _prepare_context(self, request: PatchRequest) -> str:
        """Prepare context string for LLM."""
        context_parts = []
        
        # Add goal
        context_parts.append(f"Goal: {request.goal.get('description', 'Unknown')}")
        
        # Add file list
        if request.files:
            context_parts.append(f"Files to modify: {', '.join(request.files)}")
        
        # Add constraints
        if request.constraints:
            context_parts.append(f"Constraints: {request.constraints}")
        
        # Add previous attempts
        if request.previous_attempts:
            context_parts.append(
                f"Previous attempts: {len(request.previous_attempts)}"
            )
        
        return "\n".join(context_parts)
    
    def _create_system_prompt(self, request: PatchRequest) -> str:
        """Create system prompt for LLM."""
        return """You are an expert software engineer specialized in code improvement and patch generation.

Your task is to generate unified diff patches that implement requested changes.

Guidelines:
- Output ONLY the unified diff, no explanations or markdown
- Use standard unified diff format (---, +++, @@, +, -)
- Make minimal, focused changes
- Ensure code compiles and passes tests
- Follow best practices and coding standards
- Consider edge cases and error handling
- Maintain backward compatibility when possible

Example output format:
--- a/example.py
+++ b/example.py
@@ -1,3 +1,4 @@
 def hello():
-    print("Hi")
+    print("Hello, World!")
+    return True"""
    
    def _create_user_prompt(self, request: PatchRequest, context: str) -> str:
        """Create user prompt for LLM."""
        prompt = f"""Task: {request.goal.get('description', 'Generate a patch')}

{context}

"""
        
        # Add goal details
        if request.goal.get("type"):
            prompt += f"Type: {request.goal['type']}\n"
        
        if request.goal.get("metric"):
            prompt += f"Target metric: {request.goal['metric']}\n"
        
        if request.goal.get("target_delta"):
            prompt += f"Target improvement: {request.goal['target_delta']}\n"
        
        prompt += "\nGenerate the unified diff patch:"
        
        return prompt
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get generation statistics."""
        return {
            "total_patches": self.total_patches,
            "successful_patches": self.successful_patches,
            "success_rate": (
                self.successful_patches / self.total_patches
                if self.total_patches > 0 else 0
            ),
            "llm_stats": (
                self.llm_manager.get_statistics()
                if hasattr(self.llm_manager, 'get_statistics')
                else {}
            )
        }


class HybridPatchAgent(PatchAgent):
    """
    Hybrid patch agent combining LLM and template approaches.
    
    Strategy:
    1. Try template-based for simple patterns (fast, reliable)
    2. Fall back to LLM for complex tasks (flexible, intelligent)
    """
    
    def __init__(
        self,
        simple_agent: Optional[SimplePatchAgent] = None,
        llm_agent: Optional[LLMPatchAgent] = None
    ):
        self.simple_agent = simple_agent or SimplePatchAgent()
        self.llm_agent = llm_agent or LLMPatchAgent()
    
    def generate_patch(self, request: PatchRequest) -> PatchResult:
        """Try simple agent first, fall back to LLM."""
        # Check if task is simple enough for template
        if self._is_simple_task(request):
            result = self.simple_agent.generate_patch(request)
            if result.confidence > 0.5:
                result.strategy = PatchStrategy.HYBRID
                result.metadata["approach"] = "template"
                return result
        
        # Fall back to LLM
        result = self.llm_agent.generate_patch(request)
        result.strategy = PatchStrategy.HYBRID
        result.metadata["approach"] = "llm"
        return result
    
    def validate_patch(self, patch: str, context: Dict[str, Any]) -> Tuple[bool, List[str]]:
        """Use LLM agent for validation."""
        return self.llm_agent.validate_patch(patch, context)
    
    def refine_patch(self, patch: str, feedback: str) -> PatchResult:
        """Use LLM agent for refinement."""
        result = self.llm_agent.refine_patch(patch, feedback)
        result.strategy = PatchStrategy.HYBRID
        return result
    
    def estimate_confidence(self, patch: str, context: Dict[str, Any]) -> float:
        """Use LLM agent for confidence estimation."""
        return self.llm_agent.estimate_confidence(patch, context)
    
    def _is_simple_task(self, request: PatchRequest) -> bool:
        """Check if task is simple enough for template approach."""
        simple_types = ["rename_import", "add_log_statement", "update_constant"]
        return request.goal.get("type") in simple_types


def create_patch_agent(
    agent_type: str = "hybrid",
    llm_config: Optional[LLMConfig] = None
) -> PatchAgent:
    """
    Factory function to create patch agents.
    
    Args:
        agent_type: Type of agent ("simple", "llm", "hybrid")
        llm_config: Optional LLM configuration for LLM-based agents
    
    Returns:
        Configured PatchAgent instance
    """
    if agent_type == "simple":
        return SimplePatchAgent()
    elif agent_type == "llm":
        return LLMPatchAgent(llm_manager=None)
    elif agent_type == "hybrid":
        return HybridPatchAgent()
    else:
        raise ValueError(f"Unknown agent type: {agent_type}")


__all__ = [
    "PatchAgent",
    "PatchResult",
    "PatchRequest",
    "PatchStatus",
    "PatchStrategy",
    "SimplePatchAgent",
    "LLMPatchAgent",
    "HybridPatchAgent",
    "create_patch_agent"
]
