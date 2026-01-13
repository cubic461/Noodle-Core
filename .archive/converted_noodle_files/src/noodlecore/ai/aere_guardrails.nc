# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
AERE (AI Error Resolution Engine) Guardrails

# This module provides safety validation and risk assessment for suggested fixes,
# ensuring that automated patches meet security and quality standards.
# """

import logging
import os
import re
import uuid
import typing.Dict,
import datetime.datetime
import pathlib.Path

import .aere_event_models.PatchProposal,

logger = logging.getLogger(__name__)

# Error codes for guardrails
GUARDRAIL_ERROR_CODES = {
#     "SAFETY_VALIDATION_FAILED": 7101,
#     "RISK_ASSESSMENT_FAILED": 7102,
#     "APPROVAL_WORKFLOW_FAILED": 7103,
#     "GUARDRAIL_CONFIG_ERROR": 7104,
#     "PATCH_VALIDATION_FAILED": 7105
# }

class AEREGuardrailsError(Exception)
    #     """Custom exception for AERE guardrails errors."""
    #     def __init__(self, message: str, error_code: int = 7101, data: Optional[Dict] = None):
            super().__init__(message)
    self.error_code = error_code
    self.data = data or {}

class RiskLevel
    #     """Risk levels for patch assessment."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

class AEREGuardrails
    #     """
    #     Provides safety validation and risk assessment for patch proposals.

    #     This component ensures that suggested fixes meet security and quality
    #     standards before being applied to the codebase.
    #     """

    #     def __init__(self, config_path: Optional[str] = None):
    #         """
    #         Initialize AERE guardrails.

    #         Args:
    #             config_path: Path to guardrails configuration file
    #         """
    self.config_path = config_path
    self.config = self._load_config()

    #         # Risk assessment rules
    self._risk_rules = self._initialize_risk_rules()

    #         # Safety patterns to detect
    self._safety_patterns = self._initialize_safety_patterns()

    #         # Approval workflow state
    self._approval_state = {}

            logger.info("AERE Guardrails initialized")

    #     def _load_config(self) -> Dict[str, Any]:
    #         """Load guardrails configuration."""
    default_config = {
    #             "auto_approve_low_risk": True,
    #             "require_approval_high_risk": True,
    #             "require_approval_critical_risk": True,
    #             "max_files_per_patch": 10,
    #             "forbidden_patterns": [
                    r"eval\s*\(",
                    r"exec\s*\(",
    #                 r"os\.system",
    #                 r"subprocess\.call",
    #                 r"__import__",
                    r"open\s*\([^)]*\s*,\s*['\"]w['\"]",
    #                 r"rm\s+-rf",
    #                 r"sudo",
    #                 r"passwd",
    r"password\s* = ",
    r"secret\s* = ",
    r"token\s* = "
    #             ],
    #             "high_risk_operations": [
    #                 "database_schema_change",
    #                 "file_deletion",
    #                 "network_access",
    #                 "system_configuration",
    #                 "security_policy_change"
    #             ],
    #             "file_type_restrictions": {
    #                 "executable": [".sh", ".bat", ".exe", ".com"],
    #                 "config": [".conf", ".config", ".ini", ".env"],
    #                 "critical": [".py", ".nc", ".js", ".ts"]
    #             }
    #         }

    #         if self.config_path and os.path.exists(self.config_path):
    #             try:
    #                 import json
    #                 with open(self.config_path, 'r') as f:
    user_config = json.load(f)
                    default_config.update(user_config)
                    logger.info(f"Loaded guardrails config from {self.config_path}")
    #             except Exception as e:
                    logger.warning(f"Failed to load guardrails config: {e}, using defaults")

    #         return default_config

    #     def _initialize_risk_rules(self) -> Dict[str, Any]:
    #         """Initialize risk assessment rules."""
    #         return {
    #             # Risk levels by patch type
    #             "patch_type_risk": {
    #                 PatchType.FIX: RiskLevel.LOW,
    #                 PatchType.OPTIMIZATION: RiskLevel.MEDIUM,
    #                 PatchType.REFACTOR: RiskLevel.MEDIUM,
    #                 PatchType.SECURITY_PATCH: RiskLevel.HIGH,
    #                 PatchType.DEPRECATION_UPDATE: RiskLevel.LOW,
    #                 PatchType.DEPENDENCY_UPDATE: RiskLevel.MEDIUM
    #             },

    #             # Risk levels by error category
    #             "category_risk": {
    #                 ErrorCategory.SYNTAX: RiskLevel.LOW,
    #                 ErrorCategory.RUNTIME: RiskLevel.MEDIUM,
    #                 ErrorCategory.IMPORT: RiskLevel.LOW,
    #                 ErrorCategory.TYPE: RiskLevel.LOW,
    #                 ErrorCategory.LOGIC: RiskLevel.MEDIUM,
    #                 ErrorCategory.PERFORMANCE: RiskLevel.MEDIUM,
    #                 ErrorCategory.SECURITY: RiskLevel.HIGH,
    #                 ErrorCategory.TEST_FAILURE: RiskLevel.LOW,
    #                 ErrorCategory.UNKNOWN: RiskLevel.MEDIUM
    #             },

    #             # Risk multipliers
    #             "risk_multipliers": {
    #                 "multiple_files": 1.5,
    #                 "large_patch": 1.3,
    #                 "critical_file": 1.8,
    #                 "low_confidence": 1.4
    #             }
    #         }

    #     def _initialize_safety_patterns(self) -> List[Dict[str, Any]]:
    #         """Initialize safety patterns to detect in patches."""
    #         return [
    #             {
    #                 "name": "dangerous_functions",
                    "pattern": r"(eval|exec|os\.system|subprocess\.call|__import__)\s*\(",
    #                 "risk": RiskLevel.HIGH,
    #                 "description": "Use of potentially dangerous functions"
    #             },
    #             {
    #                 "name": "file_operations",
                    "pattern": r"open\s*\([^)]*\s*,\s*['\"]w['\"]",
    #                 "risk": RiskLevel.MEDIUM,
    #                 "description": "File write operations"
    #             },
    #             {
    #                 "name": "system_commands",
                    "pattern": r"(rm\s+-rf|sudo|passwd|chmod|chown)",
    #                 "risk": RiskLevel.CRITICAL,
    #                 "description": "System command execution"
    #             },
    #             {
    #                 "name": "credential_exposure",
    "pattern": r"(password|secret|token|key)\s* = \s*['\"][^'\"]+['\"]",
    #                 "risk": RiskLevel.CRITICAL,
    #                 "description": "Hardcoded credentials or secrets"
    #             },
    #             {
    #                 "name": "network_access",
                    "pattern": r"(socket|urllib|requests|http)\.",
    #                 "risk": RiskLevel.MEDIUM,
    #                 "description": "Network access operations"
    #             }
    #         ]

    #     def validate_patch_safety(self, proposal: PatchProposal) -> Tuple[bool, List[str]]:
    #         """
    #         Validate a patch proposal for safety issues.

    #         Args:
    #             proposal: PatchProposal to validate

    #         Returns:
                Tuple of (is_safe, list_of_safety_issues)
    #         """
    safety_issues = []

    #         try:
    #             # Check file count
    #             if len(proposal.operations) > self.config["max_files_per_patch"]:
                    safety_issues.append(f"Patch affects too many files: {len(proposal.operations)}")

    #             # Check operations for safety patterns
    #             for operation in proposal.operations:
    #                 # Check operation type
    op_type = operation.get("type", "")
    #                 if op_type in self.config["high_risk_operations"]:
                        safety_issues.append(f"High-risk operation: {op_type}")

    #                 # Check for dangerous patterns in operation details
    op_details = str(operation.get("description", "")) + str(operation.get("code", ""))
    #                 for pattern_info in self._safety_patterns:
    #                     if re.search(pattern_info["pattern"], op_details, re.IGNORECASE):
                            safety_issues.append(f"Safety concern: {pattern_info['description']}")

    #             # Check file types
    #             for operation in proposal.operations:
    file_path = operation.get("file_path", proposal.file_path)
    #                 if file_path:
    file_ext = os.path.splitext(file_path)[1].lower()

    #                     # Check for restricted file types
    #                     for category, extensions in self.config["file_type_restrictions"].items():
    #                         if file_ext in extensions and category in ["executable", "config"]:
                                safety_issues.append(f"Modification of {category} file: {file_path}")

    #             # Check confidence level
    #             if proposal.confidence < 0.5:
                    safety_issues.append(f"Low confidence patch: {proposal.confidence}")

    is_safe = len(safety_issues) == 0
    #             logger.info(f"Safety validation for patch {proposal.request_id}: {'PASSED' if is_safe else 'FAILED'}")

    #             return is_safe, safety_issues

    #         except Exception as e:
                logger.error(f"Error in patch safety validation: {e}")
                return False, [f"Validation error: {str(e)}"]

    #     def assess_patch_risk(self, proposal: PatchProposal) -> Tuple[str, Dict[str, Any]]:
    #         """
    #         Assess the risk level of a patch proposal.

    #         Args:
    #             proposal: PatchProposal to assess

    #         Returns:
                Tuple of (risk_level, risk_assessment_details)
    #         """
    #         try:
    risk_score = 0.0
    risk_factors = []

    #             # Base risk from patch type
    logger.debug(f"DEBUG: proposal.patch_type = {proposal.patch_type}, type = {type(proposal.patch_type)}")

    #             # Handle both enum and string patch types
    patch_type_key = proposal.patch_type
    #             if isinstance(proposal.patch_type, str):
    #                 # Convert string to enum if needed
    #                 try:
    patch_type_key = PatchType(proposal.patch_type)
    #                 except ValueError:
                        logger.warning(f"Unknown patch type: {proposal.patch_type}, using MEDIUM risk")
    patch_type_key = PatchType.OPTIMIZATION  # Default to medium risk

    patch_type_risk = self._risk_rules["patch_type_risk"].get(patch_type_key, RiskLevel.MEDIUM)
    risk_score + = self._risk_level_to_score(patch_type_risk)

    #             # Get string representation for logging
    #             patch_type_str = patch_type_key.value if hasattr(patch_type_key, 'value') else str(patch_type_key)
                risk_factors.append(f"Patch type: {patch_type_str} ({patch_type_risk})")

    #             # Risk from error category (if available from context)
    #             # This would need to be enhanced to get the original error event
                risk_factors.append(f"Base risk assessment completed")

    #             # Risk from confidence
    #             if proposal.confidence < 0.7:
    risk_score + = 0.3
                    risk_factors.append("Low confidence")

    #             # Risk from safety flags
    #             if "high_priority" in proposal.safety_flags:
    risk_score + = 0.4
                    risk_factors.append("High priority flag")

    #             if "complex_change" in proposal.safety_flags:
    risk_score + = 0.3
                    risk_factors.append("Complex change")

    #             # Determine final risk level (with small epsilon to handle floating-point precision)
    #             if risk_score < 1.0 - 1e-10:
    risk_level = RiskLevel.LOW
    #             elif risk_score < 2.0 - 1e-10:
    risk_level = RiskLevel.MEDIUM
    #             elif risk_score < 3.0 - 1e-10:
    risk_level = RiskLevel.HIGH
    #             else:
    risk_level = RiskLevel.CRITICAL

    #             # Debug logging
    logger.debug(f"Risk assessment: score = {risk_score}, level={risk_level}, type={type(risk_level)}")
    #             if hasattr(risk_level, 'value'):
                    logger.debug(f"Risk level value: {risk_level.value}")
    #             else:
                    logger.debug(f"Risk level has no .value attribute")

    assessment = {
    #                 "risk_score": risk_score,
    #                 "risk_level": risk_level,
    #                 "risk_factors": risk_factors,
    #                 "confidence": proposal.confidence,
    #                 "safety_flags": proposal.safety_flags,
                    "requires_approval": self._requires_approval(risk_level)
    #             }

    #             logger.info(f"Risk assessment for patch {proposal.request_id}: {risk_level} (score: {risk_score})")

    #             return risk_level, assessment

    #         except Exception as e:
                logger.error(f"Error in risk assessment: {e}")
                return RiskLevel.HIGH, {"error": str(e), "risk_level": RiskLevel.HIGH}

    #     def _risk_level_to_score(self, risk_level) -> float:
    #         """Convert risk level to numeric score."""
    #         logger.debug(f"DEBUG: _risk_level_to_score called with risk_level = {risk_level}, type = {type(risk_level)}")
    mapping = {
    #             RiskLevel.LOW: 0.5,
    #             RiskLevel.MEDIUM: 1.0,
    #             RiskLevel.HIGH: 2.0,
    #             RiskLevel.CRITICAL: 3.0
    #         }
            return mapping.get(risk_level, 1.0)

    #     def _requires_approval(self, risk_level) -> bool:
    #         """Check if approval is required for the given risk level."""
    #         if risk_level == RiskLevel.LOW and self.config["auto_approve_low_risk"]:
    #             return False
    #         if risk_level in [RiskLevel.HIGH, RiskLevel.CRITICAL]:
    #             return self.config["require_approval_high_risk"]
    #         if risk_level == RiskLevel.CRITICAL:
    #             return self.config["require_approval_critical_risk"]
    #         return False

    #     def request_approval(self, proposal: PatchProposal, risk_assessment: Dict[str, Any]) -> str:
    #         """
    #         Request approval for a patch proposal.

    #         Args:
    #             proposal: PatchProposal requiring approval
    #             risk_assessment: Risk assessment results

    #         Returns:
    #             Approval request ID
    #         """
    approval_id = str(uuid.uuid4())

    approval_request = {
    #             "id": approval_id,
    #             "proposal_id": proposal.request_id,
                "proposal": proposal.to_dict(),
    #             "risk_assessment": risk_assessment,
    #             "status": "pending",
                "created_at": datetime.now().isoformat(),
                "expires_at": datetime.now().isoformat()  # Would add expiration logic
    #         }

    self._approval_state[approval_id] = approval_request

    #         logger.info(f"Created approval request {approval_id} for patch {proposal.request_id}")

    #         # In a real implementation, this would trigger notifications
    #         # For now, we'll just log the approval request
            self._log_approval_request(approval_request)

    #         return approval_id

    #     def _log_approval_request(self, approval_request: Dict[str, Any]) -> None:
    #         """Log approval request details."""
    proposal = approval_request["proposal"]
    risk = approval_request["risk_assessment"]

            logger.warning(f"APPROVAL REQUIRED: Patch {proposal['request_id']}")
            logger.warning(f"  Risk Level: {risk['risk_level']}")
            logger.warning(f"  Description: {proposal['description']}")
            logger.warning(f"  Files: {proposal['file_path']}")
            logger.warning(f"  Approval ID: {approval_request['id']}")

    #     def check_approval_status(self, approval_id: str) -> Optional[Dict[str, Any]]:
    #         """
    #         Check the status of an approval request.

    #         Args:
    #             approval_id: Approval request ID

    #         Returns:
    #             Approval request status or None if not found
    #         """
            return self._approval_state.get(approval_id)

    #     def approve_patch(self, approval_id: str, approved_by: str = "system") -> bool:
    #         """
    #         Approve a patch proposal.

    #         Args:
    #             approval_id: Approval request ID
    #             approved_by: Who approved the patch

    #         Returns:
    #             True if approval was successful
    #         """
    #         if approval_id not in self._approval_state:
                logger.error(f"Approval request {approval_id} not found")
    #             return False

    self._approval_state[approval_id]["status"] = "approved"
    self._approval_state[approval_id]["approved_by"] = approved_by
    self._approval_state[approval_id]["approved_at"] = datetime.now().isoformat()

            logger.info(f"Approved patch via approval request {approval_id} by {approved_by}")
    #         return True

    #     def reject_patch(self, approval_id: str, reason: str, rejected_by: str = "system") -> bool:
    #         """
    #         Reject a patch proposal.

    #         Args:
    #             approval_id: Approval request ID
    #             reason: Reason for rejection
    #             rejected_by: Who rejected the patch

    #         Returns:
    #             True if rejection was successful
    #         """
    #         if approval_id not in self._approval_state:
                logger.error(f"Approval request {approval_id} not found")
    #             return False

    self._approval_state[approval_id]["status"] = "rejected"
    self._approval_state[approval_id]["rejected_by"] = rejected_by
    self._approval_state[approval_id]["rejected_at"] = datetime.now().isoformat()
    self._approval_state[approval_id]["rejection_reason"] = reason

            logger.info(f"Rejected patch via approval request {approval_id} by {rejected_by}: {reason}")
    #         return True

    #     def can_apply_patch(self, proposal: PatchProposal) -> Tuple[bool, str, Optional[str]]:
    #         """
    #         Check if a patch can be applied based on safety and approval.

    #         Args:
    #             proposal: PatchProposal to check

    #         Returns:
                Tuple of (can_apply, reason, approval_id_if_required)
    #         """
    #         try:
    #             # Safety validation
    is_safe, safety_issues = self.validate_patch_safety(proposal)
    #             if not is_safe:
                    return False, f"Safety issues: {'; '.join(safety_issues)}", None

    #             # Risk assessment
    risk_level, risk_assessment = self.assess_patch_risk(proposal)

    #             # Check if approval is required
    #             if risk_assessment["requires_approval"]:
    approval_id = self.request_approval(proposal, risk_assessment)
                    return False, f"Approval required (risk: {risk_level})", approval_id

    #             return True, "Patch approved for application", None

    #         except Exception as e:
    #             logger.error(f"Error checking if patch can be applied: {e}")
                return False, f"Error: {str(e)}", None

    #     def get_approval_history(self) -> List[Dict[str, Any]]:
    #         """
    #         Get the history of approval requests.

    #         Returns:
    #             List of approval request history
    #         """
            return list(self._approval_state.values())

    #     def clear_approval_history(self) -> None:
    #         """Clear the approval history."""
    count = len(self._approval_state)
            self._approval_state.clear()
            logger.info(f"Cleared {count} approval requests from history")

    #     def update_config(self, new_config: Dict[str, Any]) -> None:
    #         """
    #         Update guardrails configuration.

    #         Args:
    #             new_config: New configuration values
    #         """
            self.config.update(new_config)

    #         # Save to file if path provided
    #         if self.config_path:
    #             try:
    #                 import json
    #                 with open(self.config_path, 'w') as f:
    json.dump(self.config, f, indent = 2)
                    logger.info(f"Updated guardrails config at {self.config_path}")
    #             except Exception as e:
                    logger.error(f"Failed to save guardrails config: {e}")

            logger.info("Updated guardrails configuration")


# Global guardrails instance
_global_guardrails = None

def get_guardrails(config_path: Optional[str] = None) -> AEREGuardrails:
#     """
#     Get the global AERE guardrails instance.

#     Args:
#         config_path: Path to guardrails configuration file

#     Returns:
#         Global AEREGuardrails instance
#     """
#     global _global_guardrails
#     if _global_guardrails is None:
_global_guardrails = AEREGuardrails(config_path)
#     return _global_guardrails

def set_guardrails(guardrails: AEREGuardrails) -> None:
#     """
#     Set the global AERE guardrails instance.

#     Args:
#         guardrails: AEREGuardrails instance to set as global
#     """
#     global _global_guardrails
_global_guardrails = guardrails