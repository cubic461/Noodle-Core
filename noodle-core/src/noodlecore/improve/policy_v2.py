"""
Enhanced Policy Gates with v2 Integrations

This module extends the v1 policy gates with:
- LSP-based API break detection
- Planner integration for task coordination
- Enhanced validation workflows
"""
from typing import List, Dict, Any, Optional
from .policy import PolicyRule, PolicyGate, PolicyResult
from .lsp_facts_gate import LSPAnalysisResult, create_lsp_facts_gate
import sys
import os

# Add paths for v2 integrations
_brain_path = os.path.join(os.path.dirname(__file__), '../../../noodle-brain/src/core')
_agents_path = os.path.join(os.path.dirname(__file__), '../../../noodle-agents-trm')

if _brain_path not in sys.path:
    sys.path.insert(0, _brain_path)
if _agents_path not in sys.path:
    sys.path.insert(0, _agents_path)

try:
    from planner import Planner, create_planner
    from patch_agent import PatchAgent, create_patch_agent
    V2_AVAILABLE = True
except ImportError:
    V2_AVAILABLE = False
    Planner = None
    create_planner = None
    PatchAgent = None
    create_patch_agent = None


class LSPAPIBreakRule(PolicyRule):
    """
    Policy rule that validates no breaking API changes occurred.
    
    Uses the LspFactsGate to analyze changes and detect
    breaking changes to public APIs.
    """
    
    def __init__(self, strict_mode: bool = True):
        """
        Initialize LSP API break rule.
        
        Args:
            strict_mode: If True, fail on any breaking change. 
                        If False, warn but allow.
        """
        super().__init__(
            name="lsp_api_break",
            description="Validate no breaking API changes using LSP analysis"
        )
        self.strict_mode = strict_mode
        self.gate = create_lsp_facts_gate()
    
    def check(self, context: Dict[str, Any]) -> PolicyResult:
        """
        Check for breaking API changes.
        
        Args:
            context: Must contain 'old_files' and 'new_files' dictionaries
                    mapping file paths to content
        """
        old_files = context.get('old_files', {})
        new_files = context.get('new_files', {})
        
        if not old_files or not new_files:
            return PolicyResult(
                passed=True,
                score=1.0,
                details="No files to compare (skipping LSP check)"
            )
        
        # Run LSP analysis
        result: LSPAnalysisResult = self.gate.validate_no_api_break(
            old_files=old_files,
            new_files=new_files
        )
        
        # Build details
        details = []
        details.append(f"Symbols analyzed: {len(old_files)} files")
        details.append(f"Public symbols added: {result.public_symbols_added}")
        details.append(f"Public symbols removed: {result.public_symbols_removed}")
        details.append(f"Public symbols modified: {result.public_symbols_modified}")
        
        if result.breaking_changes:
            details.append(f"\nBreaking changes detected:")
            for change in result.breaking_changes:
                details.append(f"  - {change.description}")
        
        if result.errors:
            details.append(f"\nErrors: {result.errors}")
        
        # Determine if passed
        if self.strict_mode:
            passed = result.passed
        else:
            # Non-strict mode: pass if no errors, even with breaking changes
            passed = result.passed or (len(result.errors) == 0)
        
        # Calculate score
        if result.passed:
            score = 1.0
        elif len(result.breaking_changes) == 0:
            score = 0.8  # Minor issues but no breaking changes
        else:
            # Reduce score based on number of breaking changes
            score = max(0.0, 1.0 - (len(result.breaking_changes) * 0.2))
        
        return PolicyResult(
            passed=passed,
            score=score,
            details="\n".join(details),
            metadata={
                "breaking_changes": [c.to_dict() for c in result.breaking_changes],
                "all_changes": [c.to_dict() for c in result.changes]
            }
        )


class EnhancedPolicyGate(PolicyGate):
    """
    Enhanced policy gate with v2 integrations.
    
    Extends the base PolicyGate with:
    - LSP-based API validation
    - Optional planner integration
    - Enhanced rule composition
    """
    
    def __init__(self, name: str = "enhanced", strict_mode: bool = True):
        """
        Initialize enhanced policy gate.
        
        Args:
            name: Gate name
            strict_mode: Whether to use strict mode for LSP validation
        """
        super().__init__(name)
        self.strict_mode = strict_mode
        
        # Add LSP rule
        self.add_rule(LSPAPIBreakRule(strict_mode=strict_mode))
    
    def validate_with_lsp(
        self,
        old_files: Dict[str, str],
        new_files: Dict[str, str],
        additional_context: Optional[Dict[str, Any]] = None
    ) -> PolicyResult:
        """
        Validate with explicit LSP analysis.
        
        Args:
            old_files: Files before changes
            new_files: Files after changes
            additional_context: Additional context for validation
            
        Returns:
            PolicyResult with LSP validation included
        """
        context = additional_context or {}
        context['old_files'] = old_files
        context['new_files'] = new_files
        
        return self.check_all(context)
    
    def validate_candidate_with_lsp(
        self,
        candidate: Any,
        snapshot_content: Dict[str, str],
        modified_content: Dict[str, str]
    ) -> PolicyResult:
        """
        Validate a candidate with LSP analysis.
        
        Args:
            candidate: Candidate object
            snapshot_content: Original content from snapshot
            modified_content: Content after patch application
            
        Returns:
            PolicyResult with full validation
        """
        context = {
            'candidate_id': candidate.id if hasattr(candidate, 'id') else 'unknown',
            'old_files': snapshot_content,
            'new_files': modified_content,
            'task_id': candidate.task_id if hasattr(candidate, 'task_id') else 'unknown'
        }
        
        return self.check_all(context)


def create_enhanced_policy_gate(
    name: str = "enhanced",
    strict_mode: bool = True,
    enable_lsp: bool = True
) -> EnhancedPolicyGate:
    """
    Factory function to create an enhanced policy gate.
    
    Args:
        name: Gate name
        strict_mode: Strict validation mode
        enable_lsp: Enable LSP-based validation
        
    Returns:
        EnhancedPolicyGate instance
    """
    gate = EnhancedPolicyGate(name=name, strict_mode=strict_mode)
    
    if not enable_lsp:
        # Remove LSP rule if disabled
        gate.rules = [r for r in gate.rules if r.name != "lsp_api_break"]
    
    return gate


# Convenience function for quick LSP validation
def validate_no_api_break(
    old_files: Dict[str, str],
    new_files: Dict[str, str],
    strict_mode: bool = True
) -> PolicyResult:
    """
    Quick function to validate no breaking API changes.
    
    Args:
        old_files: Files before changes
        new_files: Files after changes
        strict_mode: Whether to fail on breaking changes
        
    Returns:
        PolicyResult
    """
    gate = create_enhanced_policy_gate(strict_mode=strict_mode)
    return gate.validate_with_lsp(old_files, new_files)
