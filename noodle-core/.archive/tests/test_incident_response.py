"""
Test Suite::Noodle Core - test_incident_response.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test Suite for NoodleCore Security Incident Response System

Comprehensive test suite covering all aspects of the incident response system
including detection, workflow management, response actions, and reporting.
"""

import os
import sys
import unittest
import asyncio
import json
import uuid
import time
from datetime import datetime, timedelta
from unittest.mock import Mock, AsyncMock, patch, MagicMock
import tempfile
import hashlib

# Add the noodle-core path to sys.path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.security.incident_response import (
    IncidentResponseSystem, SecurityIncident, IncidentType, IncidentSeverity, 
    IncidentStatus, IncidentSource, IncidentEvidence, IncidentTimeline, 
    IncidentAction, ResponseAction, EscalationLevel, SLARequirement,
    IncidentReport, IncidentDetectionEngine, IncidentResponseEngine,
    IncidentWorkflowManager
)
from noodlecore.security.audit_logger import AuditLogger, EventType, AuditLevel
from noodlecore.security.penetration_testing import (
    PenetrationTestingFramework, Vulnerability, VulnerabilityType, VulnerabilitySeverity
)
from noodlecore.database.database_manager import DatabaseManager, DatabaseConfig

class TestIncidentDetectionEngine(unittest.TestCase):
    """Test cases for incident detection engine"""
    
    def setUp(self):
        """Set up test environment"""
        self.config = {
            'detection_rules': [
                {
                    'name': 'test_rule_1',
                    'enabled': True,
                    'incident_type': 'suspicious_activity',
                    'severity': 'medium',
                    'title': 'Test Rule 1',
                    'description': 'Test detection rule',
                    'confidence': 0.8,
                    'conditions': [
                        {
                            'field': 'event_type',
                            'operator': 'equals',
                            'value': 'authentication'
                        },
                        {
                            'field': 'status_code',
                            'operator': 'equals',
                            'value': 401
                        }
                    ],
                    'tags': ['test']
                }
            ]
        }
        
        self.audit_logger = Mock(spec=AuditLogger)
        self.detection_engine = IncidentDetectionEngine(self.config, self.audit_logger)
    
    def test_load_detection_rules(self):
        """Test loading of detection rules"""
        rules = self.detection_engine._load_detection_rules()
        self.assertEqual(len(rules), 1)
        self.assertEqual(rules[0]['name'], 'test_rule_1')
    
    def test_compile_patterns(self):
        """Test pattern compilation"""
        patterns = self.detection_engine._compile_patterns()
        self.assertIn('test_rule_1', patterns)
    
    async def test_detect_incidents_with_matching_conditions(self):
        """Test incident detection with matching conditions"""
        event_data = {
            'event_type': 'authentication',
            'status_code': 401,
            'ip_address': '192.168.1.100'
        }
        
        incidents = await self.detection_engine.detect_incidents(event_data)
        self.assertEqual(len(incidents), 1)
        self.assertEqual(incidents[0].incident_type, IncidentType.SUSPICIOUS_ACTIVITY)
        self.assertEqual(incidents[0].severity, IncidentSeverity.MEDIUM)
    
    async def test_detect_incidents_with_non_matching_conditions(self):
        """Test incident detection with non-matching conditions"""
        event_data = {
            'event_type': 'authentication',
            'status_code': 200,
            'ip_address': '192.168.1.100'
        }
        
        incidents = await self.detection_engine.detect_incidents(event_data)
        self.assertEqual(len(incidents), 0)
    
    async def test_detect_incidents_with_disabled_rule(self):
        """Test incident detection with disabled rule"""
        # Disable the rule
        self.config['detection_rules'][0]['enabled'] = False
        
        event_data = {
            'event_type': 'authentication',
            'status_code': 401,
            'ip_address': '192.168.1.100'
        }
        
        incidents = await self.detection_engine.detect_incidents(event_data)
        self.assertEqual(len(incidents), 0)
    
    def test_evaluate_conditions(self):
        """Test condition evaluation"""
        conditions = [
            {'field': 'field1', 'operator': 'equals', 'value': 'value1'},
            {'field': 'field2', 'operator': 'contains', 'value': 'test'},
            {'field': 'field3', 'operator': 'greater_than', 'value': 10}
        ]
        
        event_data = {
            'field1': 'value1',
            'field2': 'testing',
            'field3': 15
        }
        
        result = self.detection_engine._evaluate_conditions(conditions, event_data)
        self.assertTrue(result)
    
    def test_get_nested_value(self):
        """Test nested value extraction"""
        event_data = {
            'level1': {
                'level2': {
                    'target': 'value'
                }
            }
        }
        
        value = self.detection_engine._get_nested_value(event_data, 'level1.level2.target')
        self.assertEqual(value, 'value')
        
        value = self.detection_engine._get_nested_value(event_data, 'level1.level2.nonexistent')
        self.assertIsNone(value)

class TestIncidentResponseEngine(unittest.TestCase):
    """Test cases for incident response engine"""
    
    def setUp(self):
        """Set up test environment"""
        self.config = {
            'response_playbooks': {
                'suspicious_activity_medium': {
                    'actions': [
                        {
                            'type': 'notify_admin',
                            'enabled': True,
                            'description': 'Notify administrators',
                            'notification_method': 'email',
                            'admin_contacts': ['admin@test.com']
                        }
                    ]
                }
            }
        }
        
        self.audit_logger = Mock(spec=AuditLogger)
        self.response_engine = IncidentResponseEngine(self.config, self.audit_logger)
    
    async def test_execute_response_actions(self):
        """Test execution of response actions"""
        incident = SecurityIncident(
            incident_id='test-incident-1',
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.SUSPICIOUS_ACTIVITY,
            severity=IncidentSeverity.MEDIUM,
            status=IncidentStatus.DETECTED,
            source=IncidentSource(
                source_type='test',
                source_id='test-source',
                source_details={},
                confidence=0.8
            ),
            detected_at=datetime.utcnow(),
            reported_by='system',
            assigned_to=None,
            escalation_level=EscalationLevel.TIER_1,
            affected_users=['user1'],
            technical_details={}
        )
        
        actions = await self.response_engine.execute_response_actions(incident)
        self.assertEqual(len(actions), 1)
        self.assertEqual(actions[0].action_type, ResponseAction.NOTIFY_ADMIN)
    
    async def test_execute_action_with_conditions(self):
        """Test action execution with conditions"""
        incident = SecurityIncident(
            incident_id='test-incident-2',
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.SUSPICIOUS_ACTIVITY,
            severity=IncidentSeverity.MEDIUM,
            status=IncidentStatus.DETECTED,
            source=IncidentSource(
                source_type='test',
                source_id='test-source',
                source_details={},
                confidence=0.8
            ),
            detected_at=datetime.utcnow(),
            reported_by='system',
            assigned_to=None,
            escalation_level=EscalationLevel.TIER_1,
            affected_users=[],
            technical_details={}
        )
        
        # Action should not execute because affected_users is empty
        actions = await self.response_engine.execute_response_actions(incident)
        self.assertEqual(len(actions), 0)
    
    async def test_block_ip_action(self):
        """Test IP blocking action"""
        incident = SecurityIncident(
            incident_id='test-incident-3',
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.UNAUTHORIZED_ACCESS,
            severity=IncidentSeverity.HIGH,
            status=IncidentStatus.DETECTED,
            source=IncidentSource(
                source_type='test',
                source_id='test-source',
                source_details={},
                confidence=0.8
            ),
            detected_at=datetime.utcnow(),
            reported_by='system',
            assigned_to=None,
            escalation_level=EscalationLevel.TIER_1,
            affected_assets=[],
            affected_users=[],
            technical_details={'ip_address': '192.168.1.100'}
        )
        
        action_config = {
            'type': 'block_ip',
            'enabled': True,
            'duration': '1hour'
        }
        
        action = await self.response_engine._execute_action(incident, action_config)
        self.assertIsNotNone(action)
        self.assertEqual(action.action_type, ResponseAction.BLOCK_IP)
        self.assertTrue(action.success)
    
    async def test_suspend_account_action(self):
        """Test account suspension action"""
        incident = SecurityIncident(
            incident_id='test-incident-4',
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.UNAUTHORIZED_ACCESS,
            severity=IncidentSeverity.HIGH,
            status=IncidentStatus.DETECTED,
            source=IncidentSource(
                source_type='test',
                source_id='test-source',
                source_details={},
                confidence=0.8
            ),
            detected_at=datetime.utcnow(),
            reported_by='system',
            assigned_to=None,
            escalation_level=EscalationLevel.TIER_1,
            affected_assets=[],
            affected_users=['user1'],
            technical_details={}
        )
        
        action_config = {
            'type': 'suspend_account',
            'enabled': True
        }
        
        action = await self.response_engine._execute_action(incident, action_config)
        self.assertIsNotNone(action)
        self.assertEqual(action.action_type, ResponseAction.SUSPEND_ACCOUNT)
        self.assertTrue(action.success)
    
    def test_should_execute_action(self):
        """Test action execution condition checking"""
        incident = SecurityIncident(
            incident_id='test-incident-5',
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.SUSPICIOUS_ACTIVITY,
            severity=IncidentSeverity.MEDIUM,
            status=IncidentStatus.DETECTED,
            source=IncidentSource(
                source_type='test',
                source_id='test-source',
                source_details={},
                confidence=0.8
            ),
            detected_at=datetime.utcnow(),
            reported_by='system',
            assigned_to=None,
            escalation_level=EscalationLevel.TIER_1,
            affected_users=['user1'],
            technical_details={}
        )
        
        action_config = {
            'type': 'notify_admin',
            'enabled': True,
            'conditions': [
                {
                    'field': 'affected_users',
                    'operator': 'not_contains',
                    'value': []
                }
            ]
        }
        
        # Should execute because affected_users is not empty
        result = self.response_engine._should_execute_action(incident, action_config)
        self.assertTrue(result)
        
        # Test with empty affected_users
        incident.affected_users = []
        result = self.response_engine._should_execute_action(incident, action_config)
        self.assertFalse(result)
    
    def test_extract_ip_from_incident(self):
        """Test IP extraction from incident"""
        incident = SecurityIncident(
            incident_id='test-incident-6',
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.UNAUTHORIZED_ACCESS,
            severity=IncidentSeverity.HIGH,
            status=IncidentStatus.DETECTED,
            source=IncidentSource(
                source_type='test',
                source_id='test-source',
                source_details={},
                confidence=0.8
            ),
            detected_at=datetime.utcnow(),
            reported_by='system',
            assigned_to=None,
            escalation_level=EscalationLevel.TIER_1,
            affected_assets=[],
            affected_users=[],
            technical_details={'ip_address': '192.168.1.100'}
        )
        
        ip = self.response_engine._extract_ip_from_incident(incident)
        self.assertEqual(ip, '192.168.1.100')
        
        # Test with no IP
        incident.technical_details = {}
        ip = self.response_engine._extract_ip_from_incident(incident)
        self.assertIsNone(ip)
    
    def test_extract_user_from_incident(self):
        """Test user extraction from incident"""
        incident = SecurityIncident(
            incident_id='test-incident-7',
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.UNAUTHORIZED_ACCESS,
            severity=IncidentSeverity.HIGH,
            status=IncidentStatus.DETECTED,
            source=IncidentSource(
                source_type='test',
                source_id='test-source',
                source_details={},
                confidence=0.8
            ),
            detected_at=datetime.utcnow(),
            reported_by='system',
            assigned_to=None,
            escalation_level=EscalationLevel.TIER_1,
            affected_assets=[],
            affected_users=['user1'],
            technical_details={}
        )
        
        user = self.response_engine._extract_user_from_incident(incident)
        self.assertEqual(user, 'user1')
        
        # Test with no users
        incident.affected_users = []
        user = self.response_engine._extract_user_from_incident(incident)
        self.assertIsNone(user)

class TestIncidentWorkflowManager(unittest.TestCase):
    """Test cases for incident workflow manager"""
    
    def setUp(self):
        """Set up test environment"""
        self.config = {
            'sla_requirements': [
                {
                    'incident_type': 'suspicious_activity',
                    'severity': 'medium',
                    'detection_time_minutes': 30,
                    'response_time_minutes': 120,
                    'resolution_time_minutes': 720,
                    'escalation_time_minutes': 240
                }
            ],
            'escalation_policies': {
                'tier_1_to_tier_2': {
                    'conditions': [
                        {
                            'field': 'time_since_detection_minutes',
                            'operator': 'greater_than',
                            'value': 60
                        }
                    ],
                    'actions': ['notify_team_lead']
                }
            }
        }
        
        self.audit_logger = Mock(spec=AuditLogger)
        self.workflow_manager = IncidentWorkflowManager(self.config, self.audit_logger)
    
    def test_load_sla_requirements(self):
        """Test loading of SLA requirements"""
        requirements = self.workflow_manager._load_sla_requirements()
        self.assertEqual(len(requirements), 1)
        self.assertEqual(requirements[0].incident_type, IncidentType.SUSPICIOUS_ACTIVITY)
        self.assertEqual(requirements[0].severity, IncidentSeverity.MEDIUM)
    
    def test_load_escalation_policies(self):
        """Test loading of escalation policies"""
        policies = self.workflow_manager._load_escalation_policies()
        self.assertIn('tier_1_to_tier_2', policies)
    
    async def test_update_incident_status(self):
        """Test incident status update"""
        incident = SecurityIncident(
            incident_id='test-incident-8',
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.SUSPICIOUS_ACTIVITY,
            severity=IncidentSeverity.MEDIUM,
            status=IncidentStatus.NEW,
            source=IncidentSource(
                source_type='test',
                source_id='test-source',
                source_details={},
                confidence=0.8
            ),
            detected_at=datetime.utcnow(),
            reported_by='system',
            assigned_to=None,
            escalation_level=EscalationLevel.TIER_1,
            affected_assets=[],
            affected_users=[],
            technical_details={}
        )
        
        updated_incident = await self.workflow_manager.update_incident_status(
            incident, 
            IncidentStatus.ANALYZING, 
            user_id='user1',
            comment='Starting analysis'
        )
        
        self.assertEqual(updated_incident.status, IncidentStatus.ANALYZING)
        self.assertEqual(len(updated_incident.timeline), 2)  # Initial + status change
        self.assertEqual(updated_incident.timeline[1].event_type, 'status_change')
        self.assertEqual(updated_incident.timeline[1].user_id, 'user1')
    
    async def test_assign_incident(self):
        """Test incident assignment"""
        incident = SecurityIncident(
            incident_id='test-incident-9',
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.SUSPICIOUS_ACTIVITY,
            severity=IncidentSeverity.MEDIUM,
            status=IncidentStatus.NEW,
            source=IncidentSource(
                source_type='test',
                source_id='test-source',
                source_details={},
                confidence=0.8
            ),
            detected_at=datetime.utcnow(),
            reported_by='system',
            assigned_to=None,
            escalation_level=EscalationLevel.TIER_1,
            affected_assets=[],
            affected_users=[],
            technical_details={}
        )
        
        updated_incident = await self.workflow_manager.assign_incident(
            incident, 
            'user1',
            assigned_by='system'
        )
        
        self.assertEqual(updated_incident.assigned_to, 'user1')
        self.assertEqual(len(updated_incident.timeline), 2)  # Initial + assignment
        self.assertEqual(updated_incident.timeline[1].event_type, 'assignment')
        self.assertEqual(updated_incident.timeline[1].user_id, 'system')
    
    async def test_escalate_incident(self):
        """Test incident escalation"""
        incident = SecurityIncident(
            incident_id='test-incident-10',
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.SUSPICIOUS_ACTIVITY,
            severity=IncidentSeverity.MEDIUM,
            status=IncidentStatus.ANALYZING,
            source=IncidentSource(
                source_type='test',
                source_id='test-source',
                source_details={},
                confidence=0.8
            ),
            detected_at=datetime.utcnow(),
            reported_by='system',
            assigned_to='user1',
            escalation_level=EscalationLevel.TIER_1,
            affected_assets=[],
            affected_users=[],
            technical_details={}
        )
        
        updated_incident = await self.workflow_manager.escalate_incident(
            incident, 
            EscalationLevel.TIER_2,
            reason='Complex analysis required',
            escalated_by='system'
        )
        
        self.assertEqual(updated_incident.escalation_level, EscalationLevel.TIER_2)
        self.assertEqual(len(updated_incident.timeline), 2)  # Initial + escalation
        self.assertEqual(updated_incident.timeline[1].event_type, 'escalation')
        self.assertEqual(updated_incident.timeline[1].user_id, 'system')
    
    def test_calculate_sla_compliance(self):
        """Test SLA compliance calculation"""
        incident = SecurityIncident(
            incident_id='test-incident-11',
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.SUSPICIOUS_ACTIVITY,
            severity=IncidentSeverity.MEDIUM,
            status=IncidentStatus.RESOLVED,
            source=IncidentSource(
                source_type='test',
                source_id='test-source',
                source_details={},
                confidence=0.8
            ),
            detected_at=datetime.utcnow() - timedelta(hours=2),
            reported_by='system',
            assigned_to='user1',
            escalation_level=EscalationLevel.TIER_1,
            affected_assets=[],
            affected_users=[],
            technical_details={},
            resolved_at=datetime.utcnow(),
            actions_taken=[
                IncidentAction(
                    action_id='action-1',
                    action_type=ResponseAction.NOTIFY_ADMIN,
                    description='Test action',
                    executed_at=datetime.utcnow() - timedelta(hours=1),
                    executed_by='system',
                    success=True,
                    details={},
                    rollback_possible=False
                )
            ]
        )
        
        compliance = self.workflow_manager.calculate_sla_compliance(incident)
        
        self.assertTrue(compliance['compliant'])
        self.assertIn('detection_compliant', compliance['compliance'])
        self.assertIn('response_compliant', compliance['compliance'])
        self.assertIn('resolution_compliant', compliance['compliance'])
        self.assertIn('escalation_compliant', compliance['compliance'])
    
    def test_get_sla_requirement(self):
        """Test SLA requirement retrieval"""
        sla = self.workflow_manager._get_sla_requirement(
            IncidentType.SUSPICIOUS_ACTIVITY, 
            IncidentSeverity.MEDIUM
        )
        
        self.assertIsNotNone(sla)
        self.assertEqual(sla.incident_type, IncidentType.SUSPICIOUS_ACTIVITY)
        self.assertEqual(sla.severity, IncidentSeverity.MEDIUM)
        self.assertEqual(sla.detection_time_minutes, 30)
        self.assertEqual(sla.response_time_minutes, 120)
        self.assertEqual(sla.resolution_time_minutes, 720)
        self.assertEqual(sla.escalation_time_minutes, 240)
    
    def test_next_escalation_level(self):
        """Test next escalation level calculation"""
        current_level = EscalationLevel.TIER_1
        next_level = self.workflow_manager._next_escalation_level(current_level)
        self.assertEqual(next_level, EscalationLevel.TIER_2)
        
        # Test highest level
        current_level = EscalationLevel.TIER_5
        next_level = self.workflow_manager._next_escalation_level(current_level)
        self.assertEqual(next_level, EscalationLevel.TIER_5)

class TestIncidentResponseSystem(unittest.TestCase):
    """Test cases for the main incident response system"""
    
    def setUp(self):
        """Set up test environment"""
        # Create temporary config file
        self.temp_config = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        config_data = {
            'incident_response': {
                'enabled': True,
                'database': {
                    'store_incidents': True,
                    'table_name': 'test_security_incidents'
                },
                'detection': {
                    'enabled': True,
                    'detection_rules': []
                },
                'response': {
                    'auto_response': True,
                    'response_playbooks': {}
                },
                'workflow': {
                    'auto_escalation': True,
                    'sla_requirements': [],
                    'escalation_policies': {}
                }
            }
        }
        
        json.dump(config_data, self.temp_config, indent=2)
        self.temp_config.close()
        
        # Mock dependencies
        self.mock_database_manager = Mock(spec=DatabaseManager)
        self.mock_audit_logger = Mock(spec=AuditLogger)
        self.mock_pentest_framework = Mock(spec=PenetrationTestingFramework)
        self.mock_jwt_manager = Mock()
        self.mock_rate_limiter = Mock()
        self.mock_input_validator = Mock()
        self.mock_waf = Mock()
        
        # Create system instance
        self.incident_system = IncidentResponseSystem(
            config_path=self.temp_config.name,
            database_manager=self.mock_database_manager,
            audit_logger=self.mock_audit_logger,
            penetration_testing=self.mock_pentest_framework,
            jwt_manager=self.mock_jwt_manager,
            rate_limiter=self.mock_rate_limiter,
            input_validator=self.mock_input_validator,
            waf=self.mock_waf
        )
    
    def tearDown(self):
        """Clean up test environment"""
        try:
            os.unlink(self.temp_config.name)
        except FileNotFoundError:
            pass
    
    def test_load_config(self):
        """Test configuration loading"""
        self.assertTrue(self.incident_system.config.get('enabled', False))
        self.assertEqual(
            self.incident_system.config.get('database', {}).get('table_name'),
            'test_security_incidents'
        )
    
    def test_create_incident(self):
        """Test incident creation"""
        source = IncidentSource(
            source_type='manual',
            source_id='user-report',
            source_details={'report_method': 'email'},
            confidence=0.9
        )
        
        incident = asyncio.run(self.incident_system.create_incident(
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.SUSPICIOUS_ACTIVITY,
            severity=IncidentSeverity.MEDIUM,
            source=source,
            reported_by='user1',
            technical_details={'test_field': 'test_value'},
            affected_assets=['asset1', 'asset2'],
            affected_users=['user1', 'user2'],
            tags=['test', 'manual']
        ))
        
        self.assertEqual(incident.title, 'Test Incident')
        self.assertEqual(incident.incident_type, IncidentType.SUSPICIOUS_ACTIVITY)
        self.assertEqual(incident.severity, IncidentSeverity.MEDIUM)
        self.assertEqual(incident.reported_by, 'user1')
        self.assertEqual(incident.affected_assets, ['asset1', 'asset2'])
        self.assertEqual(incident.affected_users, ['user1', 'user2'])
        self.assertEqual(incident.tags, ['test', 'manual'])
        self.assertEqual(len(incident.timeline), 1)  # Creation entry
        self.assertEqual(incident.timeline[0].event_type, 'creation')
        self.assertIsNotNone(incident.sla_deadline)
    
    def test_detect_from_penetration_test(self):
        """Test incident creation from penetration test results"""
        vulnerabilities = [
            Vulnerability(
                id='vuln-1',
                type=VulnerabilityType.SQL_INJECTION,
                severity=VulnerabilitySeverity.HIGH,
                title='SQL Injection Vulnerability',
                description='SQL injection found in login form',
                endpoint='/api/login',
                payload="' OR '1'='1",
                request_data={'method': 'POST'},
                response_data={'status_code': 200},
                evidence='SQL error in response',
                recommendation='Use parameterized queries',
                cvss_score=7.5,
                discovered_at=datetime.utcnow(),
                request_id='req-1'
            ),
            Vulnerability(
                id='vuln-2',
                type=VulnerabilityType.XSS,
                severity=VulnerabilitySeverity.MEDIUM,
                title='XSS Vulnerability',
                description='Reflected XSS found',
                endpoint='/api/search',
                payload='<script>alert(1)</script>',
                request_data={'method': 'GET'},
                response_data={'status_code': 200},
                evidence='Script executed in response',
                recommendation='Implement output encoding',
                cvss_score=5.0,
                discovered_at=datetime.utcnow(),
                request_id='req-2'
            )
        ]
        
        # Mock the pentest framework to return vulnerabilities
        self.mock_pentest_framework.generate_report.return_value = {
            'vulnerabilities': vulnerabilities
        }
        
        incidents = asyncio.run(self.incident_system.detect_from_penetration_test(vulnerabilities))
        
        self.assertEqual(len(incidents), 2)
        self.assertEqual(incidents[0].incident_type, IncidentType.INJECTION_ATTACK)
        self.assertEqual(incidents[0].severity, IncidentSeverity.HIGH)
        self.assertEqual(incidents[1].incident_type, IncidentType.XSS_ATTACK)
        self.assertEqual(incidents[1].severity, IncidentSeverity.MEDIUM)
        self.assertIn('penetration_test', incidents[0].tags)
        self.assertIn('penetration_test', incidents[1].tags)
    
    def test_detect_from_audit_logs(self):
        """Test incident detection from audit logs"""
        audit_events = [
            {
                'event_type': 'authentication',
                'status_code': 401,
                'ip_address': '192.168.1.100',
                'user_id': None,
                'timestamp': datetime.utcnow().isoformat(),
                'failure_count': 15
            },
            {
                'event_type': 'data_access',
                'user_id': 'user1',
                'ip_address': '192.168.1.100',
                'timestamp': datetime.utcnow().isoformat(),
                'data_volume': 15000
            }
        ]
        
        # Mock detection engine to return incidents
        mock_incident = SecurityIncident(
            incident_id='test-incident-12',
            title='Brute Force Attack Detected',
            description='Multiple failed authentication attempts',
            incident_type=IncidentType.BRUTE_FORCE,
            severity=IncidentSeverity.HIGH,
            status=IncidentStatus.DETECTED,
            source=IncidentSource(
                source_type='detection_engine',
                source_id='brute_force_detection',
                source_details={},
                confidence=0.8
            ),
            detected_at=datetime.utcnow(),
            reported_by='system',
            assigned_to=None,
            escalation_level=EscalationLevel.TIER_1,
            affected_assets=[],
            affected_users=[],
            technical_details={},
            timeline=[],
            actions_taken=[]
        )
        
        self.incident_system.detection_engine.detect_incidents = AsyncMock(
            return_value=[mock_incident]
        )
        
        incidents = asyncio.run(self.incident_system.detect_from_audit_logs(audit_events))
        
        self.assertEqual(len(incidents), 1)
        self.assertEqual(incidents[0].incident_type, IncidentType.BRUTE_FORCE)
        self.assertEqual(incidents[0].severity, IncidentSeverity.HIGH)
    
    def test_update_incident(self):
        """Test incident update"""
        # First create an incident
        source = IncidentSource(
            source_type='manual',
            source_id='user-report',
            source_details={'report_method': 'email'},
            confidence=0.9
        )
        
        incident = asyncio.run(self.incident_system.create_incident(
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.SUSPICIOUS_ACTIVITY,
            severity=IncidentSeverity.MEDIUM,
            source=source,
            reported_by='user1'
        ))
        
        # Update the incident
        updates = {
            'status': 'analyzing',
            'assigned_to': 'analyst1',
            'business_impact': 'Medium impact on user access'
        }
        
        updated_incident = asyncio.run(self.incident_system.update_incident(
            incident.incident_id,
            updates,
            user_id='manager1'
        ))
        
        self.assertEqual(updated_incident.status, IncidentStatus.ANALYZING)
        self.assertEqual(updated_incident.assigned_to, 'analyst1')
        self.assertEqual(updated_incident.business_impact, 'Medium impact on user access')
        self.assertEqual(len(updated_incident.timeline), 2)  # Creation + update
        self.assertEqual(updated_incident.timeline[1].event_type, 'update')
        self.assertEqual(updated_incident.timeline[1].user_id, 'manager1')
    
    def test_add_evidence(self):
        """Test adding evidence to incident"""
        # First create an incident
        source = IncidentSource(
            source_type='manual',
            source_id='user-report',
            source_details={'report_method': 'email'},
            confidence=0.9
        )
        
        incident = asyncio.run(self.incident_system.create_incident(
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.SUSPICIOUS_ACTIVITY,
            severity=IncidentSeverity.MEDIUM,
            source=source,
            reported_by='user1'
        ))
        
        # Add evidence
        evidence_content = 'Suspicious log entries showing multiple failed attempts'
        evidence_metadata = {
            'source_file': '/var/log/auth.log',
            'file_hash': hashlib.sha256(evidence_content.encode()).hexdigest(),
            'size_bytes': len(evidence_content.encode())
        }
        
        success = asyncio.run(self.incident_system.add_evidence(
            incident.incident_id,
            'log_file',
            evidence_content,
            evidence_metadata,
            user_id='analyst1'
        ))
        
        self.assertTrue(success)
        self.assertEqual(len(incident.evidence), 1)
        self.assertEqual(incident.evidence[0].evidence_type, 'log_file')
        self.assertEqual(incident.evidence[0].content, evidence_content)
        self.assertEqual(incident.evidence[0].metadata, evidence_metadata)
        self.assertEqual(len(incident.timeline), 2)  # Creation + evidence added
        self.assertEqual(incident.timeline[1].event_type, 'evidence_added')
        self.assertEqual(incident.timeline[1].user_id, 'analyst1')
    
    def test_execute_response_action(self):
        """Test manual response action execution"""
        # First create an incident
        source = IncidentSource(
            source_type='manual',
            source_id='user-report',
            source_details={'report_method': 'email'},
            confidence=0.9
        )
        
        incident = asyncio.run(self.incident_system.create_incident(
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.UNAUTHORIZED_ACCESS,
            severity=IncidentSeverity.HIGH,
            source=source,
            reported_by='user1'
        ))
        
        # Execute manual action
        success = asyncio.run(self.incident_system.execute_response_action(
            incident.incident_id,
            ResponseAction.BLOCK_IP,
            'Block malicious IP address',
            user_id='analyst1',
            details={'ip_address': '192.168.1.100', 'duration': 'permanent'}
        ))
        
        self.assertTrue(success)
        self.assertEqual(len(incident.actions_taken), 1)
        self.assertEqual(incident.actions_taken[0].action_type, ResponseAction.BLOCK_IP)
        self.assertEqual(incident.actions_taken[0].description, 'Block malicious IP address')
        self.assertEqual(incident.actions_taken[0].executed_by, 'analyst1')
        self.assertEqual(len(incident.timeline), 2)  # Creation + action taken
        self.assertEqual(incident.timeline[1].event_type, 'action_taken')
        self.assertEqual(incident.timeline[1].user_id, 'analyst1')
    
    def test_generate_incident_report(self):
        """Test incident report generation"""
        # First create an incident with full lifecycle
        source = IncidentSource(
            source_type='manual',
            source_id='user-report',
            source_details={'report_method': 'email'},
            confidence=0.9
        )
        
        incident = asyncio.run(self.incident_system.create_incident(
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.UNAUTHORIZED_ACCESS,
            severity=IncidentSeverity.HIGH,
            source=source,
            reported_by='user1',
            technical_details={'ip_address': '192.168.1.100'}
        ))
        
        # Update incident with resolution
        updates = {
            'status': 'resolved',
            'root_cause': 'Weak password allowed brute force attack',
            'lessons_learned': 'Implement strong password policies and account lockout',
            'resolution_summary': 'Blocked IP and suspended compromised account'
        }
        
        resolved_incident = asyncio.run(self.incident_system.update_incident(
            incident.incident_id,
            updates,
            user_id='analyst1'
        ))
        
        # Generate report
        report = asyncio.run(self.incident_system.generate_incident_report(incident.incident_id))
        
        self.assertIsNotNone(report)
        self.assertEqual(report.incident_id, incident.incident_id)
        self.assertIsNotNone(report.executive_summary)
        self.assertEqual(len(report.detailed_timeline), 3)  # Creation + update + resolution
        self.assertEqual(report.root_cause_analysis, 'Weak password allowed brute force attack')
        self.assertEqual(report.lessons_learned[0], 'Implement strong password policies and account lockout')
        self.assertIn('recommendations', report)
        self.assertIn('prevention_measures', report)
        self.assertIn('compliance_status', report)
        self.assertIn('metrics', report)
    
    def test_get_incidents(self):
        """Test incident retrieval with filters"""
        # Create multiple incidents
        for i in range(5):
            source = IncidentSource(
                source_type='manual',
                source_id='user-report',
                source_details={'report_method': 'email'},
                confidence=0.9
            )
            
            asyncio.run(self.incident_system.create_incident(
                title=f'Test Incident {i}',
                description=f'Test incident description {i}',
                incident_type=IncidentType.SUSPICIOUS_ACTIVITY,
                severity=IncidentSeverity.MEDIUM,
                source=source,
                reported_by='user1'
            ))
        
        # Get all incidents
        all_incidents = asyncio.run(self.incident_system.get_incidents())
        self.assertEqual(len(all_incidents), 5)
        
        # Get incidents with filters
        filtered_incidents = asyncio.run(self.incident_system.get_incidents(
            filters={'severity': 'medium'}
        ))
        self.assertEqual(len(filtered_incidents), 5)
        
        # Get incidents with limit
        limited_incidents = asyncio.run(self.incident_system.get_incidents(limit=3))
        self.assertEqual(len(limited_incidents), 3)
    
    def test_get_incident_metrics(self):
        """Test incident metrics calculation"""
        # Create incidents with different resolutions times
        for i in range(3):
            source = IncidentSource(
                source_type='manual',
                source_id='user-report',
                source_details={'report_method': 'email'},
                confidence=0.9
            )
            
            incident = asyncio.run(self.incident_system.create_incident(
                title=f'Test Incident {i}',
                description=f'Test incident description {i}',
                incident_type=IncidentType.SUSPICIOUS_ACTIVITY,
                severity=IncidentSeverity.MEDIUM,
                source=source,
                reported_by='user1'
            ))
            
            # Resolve incident with different times
            resolution_time = datetime.utcnow() + timedelta(hours=i+1)
            updates = {
                'status': 'resolved',
                'resolved_at': resolution_time
            }
            
            asyncio.run(self.incident_system.update_incident(
                incident.incident_id,
                updates,
                user_id='analyst1'
            ))
        
        # Get metrics
        metrics = asyncio.run(self.incident_system.get_incident_metrics(time_window_days=30))
        
        self.assertIn('time_window_days', metrics)
        self.assertIn('total_incidents', metrics)
        self.assertIn('incidents_by_type', metrics)
        self.assertIn('incidents_by_severity', metrics)
        self.assertIn('average_resolution_time_minutes', metrics)
    
    def test_map_vulnerability_to_incident_type(self):
        """Test vulnerability to incident type mapping"""
        # Test SQL injection
        incident_type = self.incident_system._map_vulnerability_to_incident_type(
            VulnerabilityType.SQL_INJECTION
        )
        self.assertEqual(incident_type, IncidentType.INJECTION_ATTACK)
        
        # Test XSS
        incident_type = self.incident_system._map_vulnerability_to_incident_type(
            VulnerabilityType.XSS
        )
        self.assertEqual(incident_type, IncidentType.XSS_ATTACK)
        
        # Test unknown vulnerability
        incident_type = self.incident_system._map_vulnerability_to_incident_type(
            'unknown_vulnerability'
        )
        self.assertEqual(incident_type, IncidentType.VULNERABILITY_EXPLOITATION)
    
    def test_map_vulnerability_severity(self):
        """Test vulnerability severity mapping"""
        # Test critical
        severity = self.incident_system._map_vulnerability_severity(
            VulnerabilitySeverity.CRITICAL
        )
        self.assertEqual(severity, IncidentSeverity.CRITICAL)
        
        # Test high
        severity = self.incident_system._map_vulnerability_severity(
            VulnerabilitySeverity.HIGH
        )
        self.assertEqual(severity, IncidentSeverity.HIGH)
        
        # Test medium
        severity = self.incident_system._map_vulnerability_severity(
            VulnerabilitySeverity.MEDIUM
        )
        self.assertEqual(severity, IncidentSeverity.MEDIUM)
    
    def test_generate_executive_summary(self):
        """Test executive summary generation"""
        incident = SecurityIncident(
            incident_id='test-incident-13',
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.UNAUTHORIZED_ACCESS,
            severity=IncidentSeverity.HIGH,
            status=IncidentStatus.RESOLVED,
            source=IncidentSource(
                source_type='manual',
                source_id='user-report',
                source_details={'report_method': 'email'},
                confidence=0.9
            ),
            detected_at=datetime.utcnow() - timedelta(hours=2),
            reported_by='user1',
            assigned_to='analyst1',
            escalation_level=EscalationLevel.TIER_1,
            affected_assets=[],
            affected_users=['user1'],
            technical_details={},
            resolved_at=datetime.utcnow(),
            actions_taken=[],
            timeline=[],
            root_cause='Weak password',
            lessons_learned='Implement stronger passwords',
            resolution_summary='Account suspended and password reset'
        )
        
        summary = self.incident_system._generate_executive_summary(incident)
        
        self.assertIn('test-incident-13', summary)
        self.assertIn('Test Incident', summary)
        self.assertIn('unauthorized_access', summary)
        self.assertIn('high', summary)
        self.assertIn('resolved', summary)
        self.assertIn('Test incident description', summary)
    
    def test_assess_impact(self):
        """Test impact assessment"""
        incident = SecurityIncident(
            incident_id='test-incident-14',
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.DATA_BREACH,
            severity=IncidentSeverity.CRITICAL,
            status=IncidentStatus.RESOLVED,
            source=IncidentSource(
                source_type='manual',
                source_id='user-report',
                source_details={'report_method': 'email'},
                confidence=0.9
            ),
            detected_at=datetime.utcnow() - timedelta(hours=4),
            reported_by='user1',
            assigned_to='analyst1',
            escalation_level=EscalationLevel.TIER_1,
            affected_assets=['database1', 'api_server1'],
            affected_users=['user1', 'user2', 'user3'],
            business_impact='Customer data exposed',
            technical_details={},
            resolved_at=datetime.utcnow(),
            actions_taken=[],
            timeline=[],
            root_cause='SQL injection',
            lessons_learned='Implement input validation',
            resolution_summary='Patched vulnerability and notified users'
        )
        
        impact = self.incident_system._assess_impact(incident)
        
        self.assertEqual(impact['severity'], 'critical')
        self.assertEqual(impact['affected_assets'], 2)
        self.assertEqual(impact['affected_users'], 3)
        self.assertEqual(impact['business_impact'], 'Customer data exposed')
        self.assertGreater(impact['duration_hours'], 0)
    
    def test_assess_response_effectiveness(self):
        """Test response effectiveness assessment"""
        incident = SecurityIncident(
            incident_id='test-incident-15',
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.UNAUTHORIZED_ACCESS,
            severity=IncidentSeverity.HIGH,
            status=IncidentStatus.RESOLVED,
            source=IncidentSource(
                source_type='manual',
                source_id='user-report',
                source_details={'report_method': 'email'},
                confidence=0.9
            ),
            detected_at=datetime.utcnow() - timedelta(hours=1),
            reported_by='user1',
            assigned_to='analyst1',
            escalation_level=EscalationLevel.TIER_1,
            affected_assets=[],
            affected_users=['user1'],
            business_impact='Unauthorized access',
            technical_details={},
            resolved_at=datetime.utcnow(),
            actions_taken=[
                IncidentAction(
                    action_id='action-1',
                    action_type=ResponseAction.BLOCK_IP,
                    description='Block IP',
                    executed_at=datetime.utcnow() - timedelta(minutes=30),
                    executed_by='system',
                    success=True,
                    details={'ip': '192.168.1.100'},
                    rollback_possible=True
                ),
                IncidentAction(
                    action_id='action-2',
                    action_type=ResponseAction.SUSPEND_ACCOUNT,
                    description='Suspend account',
                    executed_at=datetime.utcnow() - timedelta(minutes=45),
                    executed_by='analyst1',
                    success=True,
                    details={'user': 'user1'},
                    rollback_possible=True
                ),
                IncidentAction(
                    action_id='action-3',
                    action_type=ResponseAction.NOTIFY_ADMIN,
                    description='Notify admin',
                    executed_at=datetime.utcnow() - timedelta(minutes=15),
                    executed_by='system',
                    success=False,
                    details={'error': 'Email server down'},
                    rollback_possible=False
                )
            ],
            timeline=[],
            root_cause='Weak password',
            lessons_learned='Implement MFA',
            resolution_summary='Account secured'
        )
        
        effectiveness = self.incident_system._assess_response_effectiveness(incident)
        
        self.assertEqual(effectiveness['total_actions'], 3)
        self.assertEqual(effectiveness['successful_actions'], 2)
        self.assertAlmostEqual(effectiveness['success_rate'], 2/3, places=2)
        self.assertEqual(effectiveness['automated_actions'], 2)
        self.assertEqual(effectiveness['manual_actions'], 1)
    
    def test_generate_recommendations(self):
        """Test recommendations generation"""
        incident = SecurityIncident(
            incident_id='test-incident-16',
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.UNAUTHORIZED_ACCESS,
            severity=IncidentSeverity.HIGH,
            status=IncidentStatus.RESOLVED,
            source=IncidentSource(
                source_type='manual',
                source_id='user-report',
                source_details={'report_method': 'email'},
                confidence=0.9
            ),
            detected_at=datetime.utcnow() - timedelta(hours=1),
            reported_by='user1',
            assigned_to='analyst1',
            escalation_level=EscalationLevel.TIER_1,
            affected_assets=[],
            affected_users=['user1'],
            business_impact='Unauthorized access',
            technical_details={},
            resolved_at=datetime.utcnow(),
            actions_taken=[],
            timeline=[],
            root_cause='Weak password',
            lessons_learned='Implement MFA',
            resolution_summary='Account secured'
        )
        
        recommendations = self.incident_system._generate_recommendations(incident)
        
        self.assertIn('Implement multi-factor authentication', recommendations)
        self.assertIn('Review and update access control policies', recommendations)
        self.assertIn('Conduct regular access reviews', recommendations)
    
    def test_generate_prevention_measures(self):
        """Test prevention measures generation"""
        incident = SecurityIncident(
            incident_id='test-incident-17',
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.UNAUTHORIZED_ACCESS,
            severity=IncidentSeverity.HIGH,
            status=IncidentStatus.RESOLVED,
            source=IncidentSource(
                source_type='manual',
                source_id='user-report',
                source_details={'report_method': 'email'},
                confidence=0.9
            ),
            detected_at=datetime.utcnow() - timedelta(hours=1),
            reported_by='user1',
            assigned_to='analyst1',
            escalation_level=EscalationLevel.TIER_1,
            affected_assets=[],
            affected_users=['user1'],
            business_impact='Unauthorized access',
            technical_details={},
            resolved_at=datetime.utcnow(),
            actions_taken=[],
            timeline=[],
            root_cause='Weak password',
            lessons_learned='Implement MFA',
            resolution_summary='Account secured'
        )
        
        measures = self.incident_system._generate_prevention_measures(incident)
        
        self.assertIn('Deploy intrusion detection systems', measures)
        self.assertIn('Implement account lockout policies', measures)
        self.assertIn('Monitor for anomalous login patterns', measures)
    
    def test_calculate_incident_metrics(self):
        """Test incident metrics calculation"""
        incident = SecurityIncident(
            incident_id='test-incident-18',
            title='Test Incident',
            description='Test incident description',
            incident_type=IncidentType.UNAUTHORIZED_ACCESS,
            severity=IncidentSeverity.HIGH,
            status=IncidentStatus.RESOLVED,
            source=IncidentSource(
                source_type='manual',
                source_id='user-report',
                source_details={'report_method': 'email'},
                confidence=0.9
            ),
            detected_at=datetime.utcnow() - timedelta(hours=2),
            reported_by='user1',
            assigned_to='analyst1',
            escalation_level=EscalationLevel.TIER_1,
            affected_assets=['server1', 'database1'],
            affected_users=['user1', 'user2'],
            business_impact='Unauthorized access',
            technical_details={},
            resolved_at=datetime.utcnow(),
            actions_taken=[
                IncidentAction(
                    action_id='action-1',
                    action_type=ResponseAction.BLOCK_IP,
                    description='Block IP',
                    executed_at=datetime.utcnow() - timedelta(minutes=30),
                    executed_by='system',
                    success=True,
                    details={'ip': '192.168.1.100'},
                    rollback_possible=True
                ),
                IncidentAction(
                    action_id='action-2',
                    action_type=ResponseAction.SUSPEND_ACCOUNT,
                    description='Suspend account',
                    executed_at=datetime.utcnow() - timedelta(minutes=45),
                    executed_by='analyst1',
                    success=True,
                    details={'user': 'user1'},
                    rollback_possible=True
                )
            ],
            timeline=[],
            root_cause='Weak password',
            lessons_learned='Implement MFA',
            resolution_summary='Account secured'
        )
        
        metrics = self.incident_system._calculate_incident_metrics(incident)
        
        self.assertGreater(metrics['detection_to_resolution_minutes'], 0)
        self.assertEqual(metrics['total_actions'], 2)
        self.assertEqual(metrics['evidence_count'], 0)
        self.assertEqual(metrics['timeline_entries'], 1)  # Creation only
        self.assertEqual(metrics['escalation_level'], 'tier_1')
        self.assertEqual(metrics['affected_assets_count'], 2)
        self.assertEqual(metrics['affected_users_count'], 2)

class TestIncidentIntegration(unittest.TestCase):
    """Test integration between incident response and other security components"""
    
    def setUp(self):
        """Set up test environment"""
        # Create temporary config file
        self.temp_config = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        config_data = {
            'incident_response': {
                'enabled': True,
                'database': {
                    'store_incidents': True,
                    'table_name': 'test_security_incidents'
                },
                'integration': {
                    'penetration_testing': {
                        'auto_create_incidents': True,
                        'severity_mapping': {
                            'critical': 'critical',
                            'high': 'high',
                            'medium': 'medium',
                            'low': 'low'
                        }
                    },
                    'audit_logs': {
                        'auto_analyze': True,
                        'batch_size': 100
                    },
                    'waf': {
                        'auto_block': True,
                        'block_threshold': 80
                    }
                }
            }
        }
        
        json.dump(config_data, self.temp_config, indent=2)
        self.temp_config.close()
        
        # Mock dependencies
        self.mock_database_manager = Mock(spec=DatabaseManager)
        self.mock_audit_logger = Mock(spec=AuditLogger)
        
        # Create real instances of other security components
        self.mock_pentest_framework = Mock(spec=PenetrationTestingFramework)
        self.mock_jwt_manager = Mock()
        self.mock_rate_limiter = Mock()
        self.mock_input_validator = Mock()
        self.mock_waf = Mock()
        
        # Create system instance
        self.incident_system = IncidentResponseSystem(
            config_path=self.temp_config.name,
            database_manager=self.mock_database_manager,
            audit_logger=self.mock_audit_logger,
            penetration_testing=self.mock_pentest_framework,
            jwt_manager=self.mock_jwt_manager,
            rate_limiter=self.mock_rate_limiter,
            input_validator=self.mock_input_validator,
            waf=self.mock_waf
        )
    
    def tearDown(self):
        """Clean up test environment"""
        try:
            os.unlink(self.temp_config.name)
        except FileNotFoundError:
            pass
    
    def test_penetration_testing_integration(self):
        """Test integration with penetration testing framework"""
        # Create mock vulnerabilities
        vulnerabilities = [
            Vulnerability(
                id='vuln-1',
                type=VulnerabilityType.SQL_INJECTION,
                severity=VulnerabilitySeverity.CRITICAL,
                title='SQL Injection',
                description='SQL injection in login form',
                endpoint='/api/login',
                payload="' OR '1'='1",
                request_data={'method': 'POST'},
                response_data={'status_code': 200},
                evidence='SQL error in response',
                recommendation='Use parameterized queries',
                cvss_score=9.0,
                discovered_at=datetime.utcnow(),
                request_id='req-1'
            )
        ]
        
        # Mock pentest framework
        self.mock_pentest_framework.generate_report.return_value = {
            'vulnerabilities': vulnerabilities
        }
        
        # Test integration
        incidents = asyncio.run(self.incident_system.detect_from_penetration_test(vulnerabilities))
        
        self.assertEqual(len(incidents), 1)
        self.assertEqual(incidents[0].incident_type, IncidentType.INJECTION_ATTACK)
        self.assertEqual(incidents[0].severity, IncidentSeverity.CRITICAL)
        self.assertIn('penetration_test', incidents[0].tags)
        
        # Verify pentest framework was called
        self.mock_pentest_framework.generate_report.assert_called_once()
    
    def test_audit_log_integration(self):
        """Test integration with audit logger"""
        # Create mock audit events
        audit_events = [
            {
                'event_type': 'authentication',
                'status_code': 401,
                'ip_address': '192.168.1.100',
                'user_id': None,
                'timestamp': datetime.utcnow().isoformat(),
                'failure_count': 15
            }
        ]
        
        # Mock detection engine to return incidents
        mock_incident = SecurityIncident(
            incident_id='test-incident-19',
            title='Brute Force Attack',
            description='Multiple failed authentication attempts',
            incident_type=IncidentType.BRUTE_FORCE,
            severity=IncidentSeverity.HIGH,
            status=IncidentStatus.DETECTED,
            source=IncidentSource(
                source_type='detection_engine',
                source_id='brute_force_detection',
                source_details={},
                confidence=0.8
            ),
            detected_at=datetime.utcnow(),
            reported_by='system',
            assigned_to=None,
            escalation_level=EscalationLevel.TIER_1,
            affected_assets=[],
            affected_users=[],
            technical_details={},
            timeline=[],
            actions_taken=[]
        )
        
        self.incident_system.detection_engine.detect_incidents = AsyncMock(
            return_value=[mock_incident]
        )
        
        # Test integration
        incidents = asyncio.run(self.incident_system.detect_from_audit_logs(audit_events))
        
        self.assertEqual(len(incidents), 1)
        self.assertEqual(incidents[0].incident_type, IncidentType.BRUTE_FORCE)
        
        # Verify audit logger was called for logging
        self.mock_audit_logger.log_event.assert_called()
    
    def test_waf_integration(self):
        """Test integration with web application firewall"""
        # Create incident that should trigger WAF blocking
        incident = SecurityIncident(
            incident_id='test-incident-20',
            title='XSS Attack',
            description='Cross-site scripting attack detected',
            incident_type=IncidentType.XSS_ATTACK,
            severity=IncidentSeverity.HIGH,
            status=IncidentStatus.DETECTED,
            source=IncidentSource(
                source_type='waf',
                source_id='xss_detection',
                source_details={
                    'threat_score': 85,
                    'blocked_request': True
                },
                confidence=0.9
            ),
            detected_at=datetime.utcnow(),
            reported_by='system',
            assigned_to=None,
            escalation_level=EscalationLevel.TIER_1,
            affected_assets=['/api/search'],
            affected_users=[],
            technical_details={
                'attack_vector': '<script>alert(1)</script>',
                'blocked': True
            },
            timeline=[],
            actions_taken=[]
        )
        
        # Test response action that should integrate with WAF
        action_config = {
            'type': 'block_ip',
            'enabled': True,
            'duration': 'permanent'
        }
        
        # Mock WAF to verify integration
        self.mock_waf.add_ip_to_blacklist = Mock()
        
        # Execute action
        action = asyncio.run(self.incident_system.response_engine._execute_action(
            incident, 
            action_config
        ))
        
        self.assertIsNotNone(action)
        self.assertEqual(action.action_type, ResponseAction.BLOCK_IP)
        self.assertTrue(action.success)

def run_tests():
    """Run all tests"""
    # Create test suite
    suite = unittest.TestSuite()
    
    # Add test cases
    suite.addTest(unittest.makeSuite(TestIncidentDetectionEngine))
    suite.addTest(unittest.makeSuite(TestIncidentResponseEngine))
    suite.addTest(unittest.makeSuite(TestIncidentWorkflowManager))
    suite.addTest(unittest.makeSuite(TestIncidentResponseSystem))
    suite.addTest(unittest.makeSuite(TestIncidentIntegration))
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Return success status
    return result.wasSuccessful()

if __name__ == '__main__':
    success = run_tests()
    sys.exit(0 if success else 1)

