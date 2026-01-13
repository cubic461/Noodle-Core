"""
Test Suite::Integration - test_ahr_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Tests voor NoodleNet & AHR integratie
"""

import pytest
import asyncio
import time
from unittest.mock import Mock, AsyncMock, patch

from .ahr_integration import NoodleNetAHRIntegration, IntegrationStatus
from ..config import NoodleNetConfig


class TestNoodleNetAHRIntegration:
    """Test cases voor NoodleNetAHRIntegration"""
    
    @pytest.fixture
    def config(self):
        """Test configuratie"""
        return NoodleNetConfig()
    
    @pytest.fixture
    def integration(self, config):
        """Integratie instance"""
        return NoodleNetAHRIntegration(config)
    
    @pytest.mark.asyncio
    async def test_initialization(self, integration):
        """Test initialisatie van integratie"""
        # Mock componenten
        with patch.object(integration, '_initialize_components') as mock_init:
            mock_init.return_value = None
            
            # Initialiseer
            await integration.initialize()
            
            # Check status
            assert integration.status == IntegrationStatus.STOPPED
            assert integration._running == False
    
    @pytest.mark.asyncio
    async def test_start_stop(self, integration):
        """Test start en stop van integratie"""
        # Mock componenten
        with patch.object(integration, '_initialize_components'), \
             patch.object(integration.link, 'start', new_callable=AsyncMock), \
             patch.object(integration.discovery, 'start', new_callable=AsyncMock), \
             patch.object(integration.mesh, 'start', new_callable=AsyncMock), \
             patch.object(integration.ahr, 'start', new_callable=AsyncMock), \
             patch.object(integration.core_interface, 'start', new_callable=AsyncMock):
            
            # Start integratie
            await integration.start()
            
            # Check status
            assert integration._running == True
            assert integration.status == IntegrationStatus.RUNNING
            
            # Stop integratie
            await integration.stop()
            
            # Check status
            assert integration._running == False
            assert integration.status == IntegrationStatus.STOPPED
    
    @pytest.mark.asyncio
    async def test_register_model(self, integration):
        """Test model registratie"""
        # Mock AHR
        integration.ahr = Mock()
        integration.ahr.register_model = AsyncMock()
        
        # Registreer model
        await integration.register_model("test_model", "pytorch", "1.0")
        
        # Check aanroep
        integration.ahr.register_model.assert_called_once_with("test_model", "pytorch", "1.0")
    
    @pytest.mark.asyncio
    async def test_execute_distributed_task(self, integration):
        """Test uitvoeren van distributed task"""
        # Mock core interface
        integration.core_interface = Mock()
        integration.core_interface.execute_matrix_operation = AsyncMock(return_value=Mock(to_dict=Mock(return_value={"result": "success"})))
        
        # Voer task uit
        result = await integration.execute_distributed_task(
            "matrix",
            {"matrix_a": [[1, 2]], "matrix_b": [[3, 4]], "operation": "multiply"}
        )
        
        # Check resultaat
        assert result == {"result": "success"}
        integration.core_interface.execute_matrix_operation.assert_called_once()
    
    def test_get_integration_status(self, integration):
        """Test verkrijgen van integratiestatus"""
        # Mock componenten
        integration.link = Mock()
        integration.link.is_running.return_value = True
        
        integration.discovery = Mock()
        integration.discovery.is_running.return_value = True
        
        integration.mesh = Mock()
        integration.mesh.is_running.return_value = True
        
        integration.ahr = Mock()
        integration.ahr.is_running.return_value = True
        
        integration.core_interface = Mock()
        integration.core_interface.is_running.return_value = True
        
        # Get status
        status = integration.get_integration_status()
        
        # Check status
        assert status['status'] == IntegrationStatus.STOPPED.value
        assert status['component_status']['link'] == True
        assert status['component_status']['discovery'] == True
        assert status['component_status']['mesh'] == True
        assert status['component_status']['ahr'] == True
        assert status['component_status']['core_interface'] == True
    
    def test_set_integration_setting(self, integration):
        """Test instellen van integratie settings"""
        # Stel setting in
        integration.set_integration_setting('auto_optimize', False)
        
        # Check waarde
        assert integration.integration_settings['auto_optimize'] == False
    
    def test_is_running(self, integration):
        """Test check of integratie draait"""
        # Test niet draaiend
        assert integration.is_running() == False
        
        # Test draaiend
        integration._running = True
        integration.status = IntegrationStatus.RUNNING
        assert integration.is_running() == True


class TestIntegrationMetrics:
    """Test cases voor IntegrationMetrics"""
    
    def test_metrics_to_dict(self):
        """Test conversie van metrics naar dictionary"""
        from .ahr_integration import IntegrationMetrics
        
        metrics = IntegrationMetrics(
            start_time=time.time() - 100,
            nodes_connected=5,
            models_registered=3,
            requests_processed=10,
            optimizations_triggered=2,
            errors_count=1,
            total_execution_time=50.0,
            average_latency=5.0
        )
        
        result = metrics.to_dict()
        
        # Check waarden
        assert result['uptime'] == 100
        assert result['nodes_connected'] == 5
        assert result['models_registered'] == 3
        assert result['requests_processed'] == 10
        assert result['optimizations_triggered'] == 2
        assert result['errors_count'] == 1
        assert result['total_execution_time'] == 50.0
        assert result['average_latency'] == 5.0


if __name__ == "__main__":
    pytest.main([__file__])

