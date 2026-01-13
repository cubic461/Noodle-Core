# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
AERE (AI Error Resolution Engine) HTTP API

# This module provides RESTful API endpoints for external control
# of the AERE system, following repository standards.
# """

import logging
import uuid
import json
import os
import typing.Dict,
import datetime.datetime
import pathlib.Path

import flask.Flask,
import flask_cors.CORS

import ..ai.aere_collector.get_collector
import ..ai.aere_analyzer.AEREAnalyzer
import ..ai.aere_router.get_router
import ..ai.aere_guardrails.get_guardrails
import ..ai.aere_executor.get_executor
import ..ai.self_improvement_orchestrator.get_orchestrator
import ..ai.aere_event_models.ErrorEvent,

logger = logging.getLogger(__name__)

# Error codes for API
API_ERROR_CODES = {
#     "INVALID_REQUEST": 7401,
#     "RESOURCE_NOT_FOUND": 7402,
#     "VALIDATION_FAILED": 7403,
#     "INTERNAL_ERROR": 7404,
#     "UNAUTHORIZED": 7405,
#     "RATE_LIMITED": 7406
# }

class AEREAPIError(Exception)
    #     """Custom exception for AERE API errors."""
    #     def __init__(self, message: str, error_code: int = 7401, status_code: int = 400):
            super().__init__(message)
    self.error_code = error_code
    self.status_code = status_code

def create_api_response(data: Any = None, error: str = None, status_code: int = 200) -> Response:
#     """
#     Create a standardized API response.

#     Args:
#         data: Response data
#         error: Error message
#         status_code: HTTP status code

#     Returns:
#         Flask Response object
#     """
response_data = {
        "requestId": str(uuid.uuid4()),
        "timestamp": datetime.now().isoformat(),
#         "success": error is None
#     }

#     if data is not None:
response_data["data"] = data

#     if error is not None:
response_data["error"] = error

    return jsonify(response_data), status_code

def validate_request_data(required_fields: List[str]) -> None:
#     """
#     Validate that required fields are present in request data.

#     Args:
#         required_fields: List of required field names

#     Raises:
#         AEREAPIError if validation fails
#     """
#     if not request.is_json:
        raise AEREAPIError("Request must be JSON", API_ERROR_CODES["INVALID_REQUEST"], 400)

data = request.get_json()
#     missing_fields = [field for field in required_fields if field not in data]

#     if missing_fields:
        raise AEREAPIError(f"Missing required fields: {', '.join(missing_fields)}",
#                           API_ERROR_CODES["VALIDATION_FAILED"], 400)

def init_aere_api(app: Flask) -> None:
#     """
#     Initialize AERE API endpoints.

#     Args:
#         app: Flask application instance
#     """
#     # Enable CORS
    CORS(app)

#     # Error handler
    @app.errorhandler(AEREAPIError)
#     def handle_api_error(error):
return create_api_response(error = str(error), status_code=error.status_code)

    @app.errorhandler(Exception)
#     def handle_general_error(error):
        logger.error(f"Unhandled API error: {error}")
return create_api_response(error = "Internal server error", status_code=500)

#     # API Routes

@app.route('/api/v1/aere/status', methods = ['GET'])
#     def get_aere_status():
#         """Get overall AERE system status."""
#         try:
collector = get_collector()
router = get_router()
guardrails = get_guardrails()
executor = get_executor()
orchestrator = get_orchestrator()

status = {
#                 "collector": {
                    "events_count": collector.get_event_count(),
                    "summary": collector.get_event_summary()
#                 },
                "router": router.get_router_status(),
#                 "guardrails": {
                    "approval_history_count": len(guardrails.get_approval_history()),
#                     "config": guardrails.config
#                 },
#                 "executor": {
                    "backup_count": len(executor.get_backup_list()),
#                     "session_active": executor._current_session is not None
#                 },
                "orchestrator": orchestrator.get_statistics()
#             }

return create_api_response(data = status)

#         except Exception as e:
            logger.error(f"Error getting AERE status: {e}")
            raise AEREAPIError("Failed to get system status", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/events', methods = ['GET'])
#     def get_events():
#         """Get collected error events."""
#         try:
#             # Get query parameters
limit = request.args.get('limit', type=int)
file_path = request.args.get('file_path')
severity = request.args.get('severity')
category = request.args.get('category')

collector = get_collector()

#             # Filter events based on parameters
#             if file_path:
events = collector.get_events_by_file(file_path)
#             elif severity:
events = collector.get_events_by_severity(severity)
#             elif category:
events = collector.get_events_by_category(category)
#             else:
events = collector.get_pending_events(limit)

#             # Convert to dict for JSON response
#             events_data = [event.to_dict() for event in events]

return create_api_response(data = {
#                 "events": events_data,
                "count": len(events_data)
#             })

#         except Exception as e:
            logger.error(f"Error getting events: {e}")
            raise AEREAPIError("Failed to get events", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/events', methods = ['POST'])
#     def create_event():
#         """Create a new error event."""
#         try:
            validate_request_data(['message', 'severity'])

data = request.get_json()

#             # Create event
event = ErrorEvent(
source = data.get('source', 'api'),
file_path = data.get('file_path'),
line = data.get('line'),
message = data['message'],
stack = data.get('stack'),
severity = ErrorSeverity(data['severity']),
category = ErrorCategory(data.get('category', 'unknown')),
context = data.get('context'),
code_snippet = data.get('code_snippet')
#             )

#             # Add to collector
collector = get_collector()
            collector.collect_custom_event(event)

return create_api_response(data = {
#                 "event_id": event.request_id,
#                 "message": "Event created successfully"
}, status_code = 201)

#         except AEREAPIError:
#             raise
#         except Exception as e:
            logger.error(f"Error creating event: {e}")
            raise AEREAPIError("Failed to create event", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/proposals', methods = ['GET'])
#     def get_proposals():
#         """Get patch proposals."""
#         try:
router = get_router()
proposals = router.get_pending_proposals()

#             # Convert to dict for JSON response
#             proposals_data = [proposal.to_dict() for proposal in proposals]

return create_api_response(data = {
#                 "proposals": proposals_data,
                "count": len(proposals_data)
#             })

#         except Exception as e:
            logger.error(f"Error getting proposals: {e}")
            raise AEREAPIError("Failed to get proposals", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/proposals/<proposal_id>/apply', methods = ['POST'])
#     def apply_proposal(proposal_id):
#         """Apply a specific patch proposal."""
#         try:
router = get_router()

            # Get proposal from router (would need enhancement to get by ID)
proposals = router.get_pending_proposals()
proposal = None
#             for p in proposals:
#                 if p.request_id == proposal_id:
proposal = p
#                     break

#             if not proposal:
                raise AEREAPIError("Proposal not found", API_ERROR_CODES["RESOURCE_NOT_FOUND"], 404)

#             # Apply proposal through executor
executor = get_executor()
outcome = executor.apply_patch(proposal)

#             # Record outcome with router
            router.record_resolution_outcome(
#                 proposal.request_id,
#                 outcome.status,
#                 outcome.applied,
#                 outcome.details,
#                 outcome.error
#             )

return create_api_response(data = {
#                 "proposal_id": proposal_id,
                "outcome": outcome.to_dict(),
#                 "message": "Proposal application completed"
#             })

#         except AEREAPIError:
#             raise
#         except Exception as e:
            logger.error(f"Error applying proposal {proposal_id}: {e}")
            raise AEREAPIError("Failed to apply proposal", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/approvals', methods = ['GET'])
#     def get_approvals():
#         """Get approval requests."""
#         try:
guardrails = get_guardrails()
approvals = guardrails.get_approval_history()

return create_api_response(data = {
#                 "approvals": approvals,
                "count": len(approvals)
#             })

#         except Exception as e:
            logger.error(f"Error getting approvals: {e}")
            raise AEREAPIError("Failed to get approvals", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/approvals/<approval_id>/approve', methods = ['POST'])
#     def approve_request(approval_id):
#         """Approve a patch proposal."""
#         try:
data = request.get_json() or {}
approved_by = data.get('approved_by', 'api_user')

guardrails = get_guardrails()
success = guardrails.approve_patch(approval_id, approved_by)

#             if not success:
                raise AEREAPIError("Approval request not found", API_ERROR_CODES["RESOURCE_NOT_FOUND"], 404)

return create_api_response(data = {
#                 "approval_id": approval_id,
#                 "approved_by": approved_by,
#                 "message": "Approval request approved"
#             })

#         except AEREAPIError:
#             raise
#         except Exception as e:
            logger.error(f"Error approving request {approval_id}: {e}")
            raise AEREAPIError("Failed to approve request", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/approvals/<approval_id>/reject', methods = ['POST'])
#     def reject_request(approval_id):
#         """Reject a patch proposal."""
#         try:
            validate_request_data(['reason'])

data = request.get_json()
reason = data['reason']
rejected_by = data.get('rejected_by', 'api_user')

guardrails = get_guardrails()
success = guardrails.reject_patch(approval_id, reason, rejected_by)

#             if not success:
                raise AEREAPIError("Approval request not found", API_ERROR_CODES["RESOURCE_NOT_FOUND"], 404)

return create_api_response(data = {
#                 "approval_id": approval_id,
#                 "reason": reason,
#                 "rejected_by": rejected_by,
#                 "message": "Approval request rejected"
#             })

#         except AEREAPIError:
#             raise
#         except Exception as e:
            logger.error(f"Error rejecting request {approval_id}: {e}")
            raise AEREAPIError("Failed to reject request", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/backups', methods = ['GET'])
#     def get_backups():
#         """Get backup files."""
#         try:
executor = get_executor()
backups = executor.get_backup_list()

return create_api_response(data = {
#                 "backups": backups,
                "count": len(backups)
#             })

#         except Exception as e:
            logger.error(f"Error getting backups: {e}")
            raise AEREAPIError("Failed to get backups", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/backups/cleanup', methods = ['POST'])
#     def cleanup_backups():
#         """Clean up old backup files."""
#         try:
data = request.get_json() or {}
days_to_keep = data.get('days_to_keep', 30)

executor = get_executor()
cleaned_count = executor.cleanup_old_backups(days_to_keep)

return create_api_response(data = {
#                 "cleaned_count": cleaned_count,
#                 "days_to_keep": days_to_keep,
#                 "message": "Backup cleanup completed"
#             })

#         except Exception as e:
            logger.error(f"Error cleaning up backups: {e}")
            raise AEREAPIError("Failed to cleanup backups", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/sessions', methods = ['POST'])
#     def create_session():
#         """Create a new executor session."""
#         try:
executor = get_executor()
session_id = executor.start_session()

return create_api_response(data = {
#                 "session_id": session_id,
#                 "message": "Session created successfully"
}, status_code = 201)

#         except Exception as e:
            logger.error(f"Error creating session: {e}")
            raise AEREAPIError("Failed to create session", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/sessions/<session_id>/rollback', methods = ['POST'])
#     def rollback_session(session_id):
#         """Rollback a specific session."""
#         try:
executor = get_executor()
success = executor.rollback_session(session_id)

#             if not success:
                raise AEREAPIError("Session not found", API_ERROR_CODES["RESOURCE_NOT_FOUND"], 404)

return create_api_response(data = {
#                 "session_id": session_id,
#                 "message": "Session rolled back successfully"
#             })

#         except AEREAPIError:
#             raise
#         except Exception as e:
            logger.error(f"Error rolling back session {session_id}: {e}")
            raise AEREAPIError("Failed to rollback session", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/orchestrator/cycles', methods = ['GET'])
#     def get_cycles():
#         """Get orchestrator cycles."""
#         try:
orchestrator = get_orchestrator()
cycles = orchestrator.get_cycle_status()

return create_api_response(data = {
#                 "cycles": cycles,
                "count": len(cycles)
#             })

#         except Exception as e:
            logger.error(f"Error getting cycles: {e}")
            raise AEREAPIError("Failed to get cycles", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/orchestrator/cycles/<cycle_id>/start', methods = ['POST'])
#     def start_cycle(cycle_id):
#         """Start a specific improvement cycle."""
#         try:
orchestrator = get_orchestrator()
success = orchestrator.start_cycle(cycle_id)

#             if not success:
                raise AEREAPIError("Cycle not found", API_ERROR_CODES["RESOURCE_NOT_FOUND"], 404)

return create_api_response(data = {
#                 "cycle_id": cycle_id,
#                 "message": "Cycle started successfully"
#             })

#         except AEREAPIError:
#             raise
#         except Exception as e:
            logger.error(f"Error starting cycle {cycle_id}: {e}")
            raise AEREAPIError("Failed to start cycle", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/orchestrator/cycles/<cycle_id>/stop', methods = ['POST'])
#     def stop_cycle(cycle_id):
#         """Stop a specific improvement cycle."""
#         try:
orchestrator = get_orchestrator()
success = orchestrator.stop_cycle(cycle_id)

#             if not success:
                raise AEREAPIError("Cycle not found", API_ERROR_CODES["RESOURCE_NOT_FOUND"], 404)

return create_api_response(data = {
#                 "cycle_id": cycle_id,
#                 "message": "Cycle stopped successfully"
#             })

#         except AEREAPIError:
#             raise
#         except Exception as e:
            logger.error(f"Error stopping cycle {cycle_id}: {e}")
            raise AEREAPIError("Failed to stop cycle", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/orchestrator/start', methods = ['POST'])
#     def start_orchestrator():
#         """Start the orchestrator."""
#         try:
orchestrator = get_orchestrator()
            orchestrator.start()

return create_api_response(data = {
#                 "message": "Orchestrator started successfully"
#             })

#         except Exception as e:
            logger.error(f"Error starting orchestrator: {e}")
            raise AEREAPIError("Failed to start orchestrator", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/orchestrator/stop', methods = ['POST'])
#     def stop_orchestrator():
#         """Stop the orchestrator."""
#         try:
orchestrator = get_orchestrator()
            orchestrator.stop()

return create_api_response(data = {
#                 "message": "Orchestrator stopped successfully"
#             })

#         except Exception as e:
            logger.error(f"Error stopping orchestrator: {e}")
            raise AEREAPIError("Failed to stop orchestrator", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/orchestrator/statistics', methods = ['GET'])
#     def get_orchestrator_statistics():
#         """Get orchestrator statistics."""
#         try:
orchestrator = get_orchestrator()
stats = orchestrator.get_statistics()

return create_api_response(data = stats)

#         except Exception as e:
            logger.error(f"Error getting orchestrator statistics: {e}")
            raise AEREAPIError("Failed to get statistics", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/config/guardrails', methods = ['GET'])
#     def get_guardrails_config():
#         """Get guardrails configuration."""
#         try:
guardrails = get_guardrails()
config = guardrails.config

return create_api_response(data = config)

#         except Exception as e:
            logger.error(f"Error getting guardrails config: {e}")
            raise AEREAPIError("Failed to get guardrails config", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/config/guardrails', methods = ['PUT'])
#     def update_guardrails_config():
#         """Update guardrails configuration."""
#         try:
            validate_request_data(['config'])

data = request.get_json()
new_config = data['config']

guardrails = get_guardrails()
            guardrails.update_config(new_config)

return create_api_response(data = {
#                 "message": "Guardrails configuration updated successfully"
#             })

#         except AEREAPIError:
#             raise
#         except Exception as e:
            logger.error(f"Error updating guardrails config: {e}")
            raise AEREAPIError("Failed to update guardrails config", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/config/orchestrator', methods = ['GET'])
#     def get_orchestrator_config():
#         """Get orchestrator configuration."""
#         try:
orchestrator = get_orchestrator()
config = orchestrator.config

return create_api_response(data = config)

#         except Exception as e:
            logger.error(f"Error getting orchestrator config: {e}")
            raise AEREAPIError("Failed to get orchestrator config", API_ERROR_CODES["INTERNAL_ERROR"], 500)

@app.route('/api/v1/aere/config/orchestrator', methods = ['PUT'])
#     def update_orchestrator_config():
#         """Update orchestrator configuration."""
#         try:
            validate_request_data(['config'])

data = request.get_json()
new_config = data['config']

orchestrator = get_orchestrator()
            orchestrator.update_config(new_config)

return create_api_response(data = {
#                 "message": "Orchestrator configuration updated successfully"
#             })

#         except AEREAPIError:
#             raise
#         except Exception as e:
            logger.error(f"Error updating orchestrator config: {e}")
            raise AEREAPIError("Failed to update orchestrator config", API_ERROR_CODES["INTERNAL_ERROR"], 500)

    logger.info("AERE API endpoints initialized")


def create_aere_app() -> Flask:
#     """
#     Create and configure the AERE Flask application.

#     Returns:
#         Configured Flask application
#     """
app = Flask(__name__)

#     # Configure app
app.config['JSON_SORT_KEYS'] = False
app.config['JSONIFY_PRETTYPRINT_REGULAR'] = True

#     # Initialize API endpoints
    init_aere_api(app)

#     return app


if __name__ == '__main__'
    #     # Create and run the app
    app = create_aere_app()

    #     # Get configuration from environment
    host = os.getenv('NOODLE_HOST', '0.0.0.0')
    port = int(os.getenv('NOODLE_PORT', 8080))
    debug = os.getenv('NOODLE_DEBUG', '0') == '1'

        logger.info(f"Starting AERE API server on {host}:{port}")
    app.run(host = host, port=port, debug=debug)