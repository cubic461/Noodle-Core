"""
Integration::Performance Integration - performance_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Performance Integration Module for NoodleNet
Integrates all performance optimization components into a cohesive system
"""

import asyncio
import time
import logging
from typing import Dict, List, Optional, Any, Callable
from dataclasses import dataclass, field
from enum import Enum
import threading
import uuid

from ..ahr.ahr_performance_optimizer import PerformanceOptimizer
from ..scaling.horizontal_scaler import HorizontalScaler, LoadBalancer
from ..monitoring.performance_monitor import PerformanceMonitor
from ..mesh import NoodleMesh
from ..config import NoodleNetConfig
from ..ahr.ahr_base import AHRBase
from ..identity import NoodleIdentityManager

logger = logging.getLogger(__name__)


class PerformanceMode(Enum):
    """Performance optimization modes"""
    CONSERVATIVE = "conservative"  # Minimal optimizations, maximum stability
    BALANCED = "balanced"        # Balanced performance and resource usage
    AGGRESSIVE = "aggressive"    # Maximum performance, higher resource usage
    AUTO = "auto"               # Adaptive based on system conditions


@dataclass
class PerformanceMetrics:
    """Comprehensive performance metrics"""
    timestamp: float
    cpu_usage: float
    memory_usage: float
    response_time: float
    throughput: float
    error_rate: float
    cache_hit_rate: float
    active_nodes: int
    total_requests: int
    optimization_score: float = 0.0
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class PerformanceReport:
    """Performance optimization report"""
    report_id: str
    timestamp: float
    mode: PerformanceMode
    metrics: PerformanceMetrics
    optimizations_applied: List[str]
    scaling_actions: List[str]
    alerts: List[Dict[str, Any]]
    recommendations: List[str]
    efficiency_score: float
    system_health: str  # "healthy", "warning", "critical"


class PerformanceIntegration:
    """Main integration class for all performance optimization components"""
    
    def __init__(self, ahr: AHRBase, mesh: NoodleMesh, 
                 identity_manager: NoodleIdentityManager, config: NoodleNetConfig):
        self.ahr = ahr
        self.mesh = mesh
        self.identity_manager = identity_manager
        self.config = config
        
        # Performance optimization components
        self.performance_optimizer = PerformanceOptimizer(ahr, mesh, config)
        self.load_balancer = LoadBalancer(mesh, config)
        self.horizontal_scaler = HorizontalScaler(mesh, self.load_balancer, identity_manager, config)
        self.performance_monitor = PerformanceMonitor(mesh, config)
        
        # Performance state
        self.current_mode = PerformanceMode.BALANCED
        self.performance_history = []
        self.optimization_history = []
        
        # Configuration
        self.mode_thresholds = {
            PerformanceMode.CONSERVATIVE: {
                'cpu_threshold': 70.0,
                'memory_threshold': 75.0,
                'response_time_threshold': 1000.0,
                'error_rate_threshold': 0.02
            },
            PerformanceMode.BALANCED: {
                'cpu_threshold': 80.0,
                'memory_threshold': 85.0,
                'response_time_threshold': 1500.0,
                'error_rate_threshold': 0.05
            },
            PerformanceMode.AGGRESSIVE: {
                'cpu_threshold': 90.0,
                'memory_threshold': 95.0,
                'response_time_threshold': 2000.0,
                'error_rate_threshold': 0.08
            }
        }
        
        # Callbacks
        self.metrics_callback: Optional[Callable] = None
        self.alert_callback: Optional[Callable] = None
        self.optimization_callback: Optional[Callable] = None
        
        # Running state
        self._running = False
        self._integration_task = None
        
        logger.info("PerformanceIntegration initialized")
    
    async def start(self):
        """Start the performance integration system"""
        if self._running:
            return
        
        self._running = True
        
        # Start all components
        await self.performance_optimizer.start()
        await self.horizontal_scaler.start()
        await self.performance_monitor.start()
        
        # Start integration loop
        self._integration_task = asyncio.create_task(self._integration_loop())
        
        logger.info("PerformanceIntegration started")
    
    async def stop(self):
        """Stop the performance integration system"""
        if not self._running:
            return
        
        self._running = False
        
        # Stop integration loop
        if self._integration_task:
            self._integration_task.cancel()
            try:
                await self._integration_task
            except asyncio.CancelledError:
                pass
        
        # Stop all components
        await self.performance_optimizer.stop()
        await self.horizontal_scaler.stop()
        await self.performance_monitor.stop()
        
        logger.info("PerformanceIntegration stopped")
    
    async def _integration_loop(self):
        """Main integration loop"""
        while self._running:
            try:
                # Collect comprehensive metrics
                metrics = await self._collect_comprehensive_metrics()
                
                # Analyze performance
                analysis = await self._analyze_performance(metrics)
                
                # Determine optimal mode
                optimal_mode = await self._determine_optimal_mode(metrics, analysis)
                
                # Apply optimizations
                optimizations = await self._apply_optimizations(metrics, analysis, optimal_mode)
                
                # Update performance mode
                if optimal_mode != self.current_mode:
                    await self._set_performance_mode(optimal_mode)
                
                # Generate performance report
                report = await self._generate_performance_report(metrics, optimizations)
                
                # Call callbacks
                if self.metrics_callback:
                    self.metrics_callback(metrics)
                
                if self.optimization_callback:
                    self.optimization_callback(optimizations)
                
                # Store history
                self.performance_history.append(metrics)
                self.optimization_history.append(optimizations)
                
                # Log performance summary
                self._log_performance_summary(report)
                
                # Wait for next iteration
                await asyncio.sleep(30.0)  # Check every 30 seconds
                
            except Exception as e:
                logger.error(f"Error in integration loop: {e}")
                await asyncio.sleep(10.0)
    
    async def _collect_comprehensive_metrics(self) -> PerformanceMetrics:
        """Collect comprehensive performance metrics"""
        # Get system metrics
        system_metrics = await self._get_system_metrics()
        
        # Get application metrics
        application_metrics = await self._get_application_metrics()
        
        # Get mesh metrics
        mesh_metrics = await self._get_mesh_metrics()
        
        # Get optimization metrics
        optimization_metrics = await self._get_optimization_metrics()
        
        # Combine metrics
        metrics = PerformanceMetrics(
            timestamp=time.time(),
            cpu_usage=system_metrics.get('cpu_usage', 0.0),
            memory_usage=system_metrics.get('memory_usage', 0.0),
            response_time=application_metrics.get('response_time', 0.0),
            throughput=application_metrics.get('throughput', 0.0),
            error_rate=application_metrics.get('error_rate', 0.0),
            cache_hit_rate=optimization_metrics.get('cache_hit_rate', 0.0),
            active_nodes=mesh_metrics.get('active_nodes', 0),
            total_requests=application_metrics.get('total_requests', 0),
            metadata={
                'system_metrics': system_metrics,
                'application_metrics': application_metrics,
                'mesh_metrics': mesh_metrics,
                'optimization_metrics': optimization_metrics
            }
        )
        
        return metrics
    
    async def _get_system_metrics(self) -> Dict[str, Any]:
        """Get system-level metrics"""
        try:
            import psutil
            
            return {
                'cpu_usage': psutil.cpu_percent(interval=1),
                'memory_usage': psutil.virtual_memory().percent,
                'disk_usage': psutil.disk_usage('/').percent,
                'network_io': psutil.net_io_counters()._asdict(),
                'process_count': len(psutil.pids()),
                'load_average': psutil.getloadavg() if hasattr(psutil, 'getloadavg') else [0.0, 0.0, 0.0]
            }
        except Exception as e:
            logger.error(f"Error getting system metrics: {e}")
            return {}
    
    async def _get_application_metrics(self) -> Dict[str, Any]:
        """Get application-level metrics"""
        try:
            # Get AHR metrics
            ahr_metrics = self.ahr.get_execution_history()
            
            # Calculate application metrics
            total_requests = len(ahr_metrics)
            response_times = [m.get('total_time', 0) for m in ahr_metrics if m.get('total_time', 0) > 0]
            error_count = len([m for m in ahr_metrics if m.get('error_count', 0) > 0])
            
            avg_response_time = sum(response_times) / len(response_times) if response_times else 0.0
            error_rate = error_count / total_requests if total_requests > 0 else 0.0
            throughput = total_requests / 300.0  # Requests per 5 minutes
            
            return {
                'total_requests': total_requests,
                'average_response_time': avg_response_time,
                'error_rate': error_rate,
                'throughput': throughput,
                'active_components': len(self.ahr.model_profiles)
            }
        except Exception as e:
            logger.error(f"Error getting application metrics: {e}")
            return {}
    
    async def _get_mesh_metrics(self) -> Dict[str, Any]:
        """Get mesh-level metrics"""
        try:
            return {
                'active_nodes': self.mesh.get_node_count(),
                'total_edges': self.mesh.get_edge_count(),
                'average_latency': self.mesh.get_average_latency(),
                'network_throughput': self.mesh.get_total_throughput(),
                'reliability': self.mesh.get_reliability()
            }
        except Exception as e:
            logger.error(f"Error getting mesh metrics: {e}")
            return {}
    
    async def _get_optimization_metrics(self) -> Dict[str, Any]:
        """Get optimization-specific metrics"""
        try:
            # Get cache metrics
            cache_stats = self.performance_optimizer.cache.get_stats()
            
            # Get memory metrics
            memory_stats = self.performance_optimizer.memory_optimizer.get_memory_stats()
            
            # Get load balancer metrics
            load_balancer_stats = self.load_balancer.get_balancer_stats()
            
            return {
                'cache_hit_rate': cache_stats.get('hit_rate', 0.0),
                'cache_size': cache_stats.get('current_size', 0),
                'memory_efficiency': memory_stats.get('memory_efficiency', 0.0),
                'load_balancer_efficiency': load_balancer_stats.get('load_balancing_efficiency', 0.0),
                'optimization_decisions': len(self.performance_optimizer.decisions)
            }
        except Exception as e:
            logger.error(f"Error getting optimization metrics: {e}")
            return {}
    
    async def _analyze_performance(self, metrics: PerformanceMetrics) -> Dict[str, Any]:
        """Analyze performance data"""
        analysis = {
            'bottlenecks': [],
            'strengths': [],
            'recommendations': [],
            'risk_factors': [],
            'optimization_potential': 0.0
        }
        
        # Identify bottlenecks
        if metrics.cpu_usage > 80.0:
            analysis['bottlenecks'].append('high_cpu_usage')
            analysis['risk_factors'].append('cpu_overload')
        
        if metrics.memory_usage > 85.0:
            analysis['bottlenecks'].append('high_memory_usage')
            analysis['risk_factors'].append('memory_pressure')
        
        if metrics.response_time > 1500.0:
            analysis['bottlenecks'].append('high_response_time')
            analysis['risk_factors'].append('performance_degradation')
        
        if metrics.error_rate > 0.05:
            analysis['bottlenecks'].append('high_error_rate')
            analysis['risk_factors'].append('system_instability')
        
        # Identify strengths
        if metrics.cache_hit_rate > 0.8:
            analysis['strengths'].append('effective_caching')
        
        if metrics.throughput > 100.0:
            analysis['strengths'].append('high_throughput')
        
        if metrics.active_nodes > 3:
            analysis['strengths'].append('good_distribution')
        
        # Generate recommendations
        if 'high_cpu_usage' in analysis['bottlenecks']:
            analysis['recommendations'].append('Consider JIT compilation for frequently executed components')
        
        if 'high_memory_usage' in analysis['bottlenecks']:
            analysis['recommendations'].append('Enable aggressive memory optimization and garbage collection')
        
        if 'high_response_time' in analysis['bottlenecks']:
            analysis['recommendations'].append('Implement request parallelization and load balancing')
        
        if 'high_error_rate' in analysis['bottlenecks']:
            analysis['recommendations'].append('Review error handling and implement circuit breakers')
        
        # Calculate optimization potential
        optimization_factors = [
            1.0 - (metrics.cache_hit_rate / 1.0),  # Cache improvement potential
            1.0 - (metrics.memory_usage / 100.0),  # Memory efficiency potential
            1.0 - (min(metrics.response_time / 2000.0, 1.0)),  # Response time improvement potential
            1.0 - (metrics.error_rate / 0.1)  # Error rate reduction potential
        ]
        
        analysis['optimization_potential'] = sum(optimization_factors) / len(optimization_factors)
        
        return analysis
    
    async def _determine_optimal_mode(self, metrics: PerformanceMetrics, 
                                    analysis: Dict[str, Any]) -> PerformanceMode:
        """Determine optimal performance mode"""
        # Check if system is under stress
        if metrics.cpu_usage > 90.0 or metrics.memory_usage > 95.0:
            return PerformanceMode.CONSERVATIVE
        
        # Check if system has headroom
        if (metrics.cpu_usage < 50.0 and metrics.memory_usage < 60.0 and
            metrics.response_time < 500.0 and metrics.error_rate < 0.01):
            return PerformanceMode.AGGRESSIVE
        
        # Check optimization potential
        if analysis['optimization_potential'] > 0.5:
            return PerformanceMode.AGGRESSIVE
        
        # Default to balanced mode
        return PerformanceMode.BALANCED
    
    async def _apply_optimizations(self, metrics: PerformanceMetrics,
                                  analysis: Dict[str, Any], mode: PerformanceMode) -> List[str]:
        """Apply performance optimizations"""
        optimizations_applied = []
        
        try:
            # Apply cache optimizations
            cache_optimizations = await self.performance_optimizer.apply_cache_optimizations()
            optimizations_applied.extend(cache_optimizations)
            
            # Apply memory optimizations
            memory_optimizations = await self.performance_optimizer.apply_memory_optimizations()
            optimizations_applied.extend(memory_optimizations)
            
            # Apply execution mode optimizations
            execution_optimizations = await self.performance_optimizer.apply_execution_mode_optimizations()
            optimizations_applied.extend(execution_optimizations)
            
            # Apply load balancing optimizations
            load_balancing_optimizations = await self._apply_load_balancing_optimizations(mode)
            optimizations_applied.extend(load_balancing_optimizations)
            
            # Apply scaling optimizations
            scaling_optimizations = await self._apply_scaling_optimizations(mode, analysis)
            optimizations_applied.extend(scaling_optimizations)
            
        except Exception as e:
            logger.error(f"Error applying optimizations: {e}")
        
        return optimizations_applied
    
    async def _apply_load_balancing_optimizations(self, mode: PerformanceMode) -> List[str]:
        """Apply load balancing optimizations"""
        optimizations = []
        
        try:
            # Adjust load balancer strategy based on mode
            if mode == PerformanceMode.CONSERVATIVE:
                self.load_balancer.set_strategy('least_connections')
            elif mode == PerformanceMode.BALANCED:
                self.load_balancer.set_strategy('resource_based')
            elif mode == PerformanceMode.AGGRESSIVE:
                self.load_balancer.set_strategy('least_response_time')
            
            optimizations.append(f'load_balancer_strategy_{mode.value}')
            
        except Exception as e:
            logger.error(f"Error applying load balancing optimizations: {e}")
        
        return optimizations
    
    async def _apply_scaling_optimizations(self, mode: PerformanceMode, 
                                        analysis: Dict[str, Any]) -> List[str]:
        """Apply scaling optimizations"""
        optimizations = []
        
        try:
            # Adjust scaling parameters based on mode
            if mode == PerformanceMode.CONSERVATIVE:
                self.horizontal_scaler.auto_scaling_enabled = False
            elif mode == PerformanceMode.BALANCED:
                self.horizontal_scaler.auto_scaling_enabled = True
                self.horizontal_scaler.scale_up_cooldown = 300
                self.horizontal_scaler.scale_down_cooldown = 600
            elif mode == PerformanceMode.AGGRESSIVE:
                self.horizontal_scaler.auto_scaling_enabled = True
                self.horizontal_scaler.scale_up_cooldown = 120
                self.horizontal_scaler.scale_down_cooldown = 300
            
            optimizations.append(f'scaling_mode_{mode.value}')
            
        except Exception as e:
            logger.error(f"Error applying scaling optimizations: {e}")
        
        return optimizations
    
    async def _set_performance_mode(self, mode: PerformanceMode):
        """Set the performance mode"""
        if mode != self.current_mode:
            logger.info(f"Performance mode changed: {self.current_mode.value} -> {mode.value}")
            self.current_mode = mode
    
    async def _generate_performance_report(self, metrics: PerformanceMetrics,
                                          optimizations: List[str]) -> PerformanceReport:
        """Generate comprehensive performance report"""
        # Calculate efficiency score
        efficiency_score = self._calculate_efficiency_score(metrics)
        
        # Determine system health
        system_health = self._determine_system_health(metrics)
        
        # Get alerts
        alerts = self.performance_monitor.get_alerts_summary()
        
        # Generate recommendations
        recommendations = self._generate_recommendations(metrics)
        
        report = PerformanceReport(
            report_id=str(uuid.uuid4()),
            timestamp=time.time(),
            mode=self.current_mode,
            metrics=metrics,
            optimizations_applied=optimizations,
            scaling_actions=self.horizontal_scaler.get_scaling_summary().get('scaling_history', []),
            alerts=alerts.get('recent_alerts', []),
            recommendations=recommendations,
            efficiency_score=efficiency_score,
            system_health=system_health
        )
        
        return report
    
    def _calculate_efficiency_score(self, metrics: PerformanceMetrics) -> float:
        """Calculate overall efficiency score"""
        # Normalize metrics to 0-1 scale
        cpu_efficiency = 1.0 - (metrics.cpu_usage / 100.0)
        memory_efficiency = 1.0 - (metrics.memory_usage / 100.0)
        response_efficiency = 1.0 - (min(metrics.response_time / 2000.0, 1.0))
        error_efficiency = 1.0 - (min(metrics.error_rate / 0.1, 1.0))
        cache_efficiency = metrics.cache_hit_rate
        
        # Weighted combination
        efficiency_score = (
            cpu_efficiency * 0.25 +
            memory_efficiency * 0.25 +
            response_efficiency * 0.25 +
            error_efficiency * 0.15 +
            cache_efficiency * 0.10
        )
        
        return max(0.0, min(1.0, efficiency_score))
    
    def _determine_system_health(self, metrics: PerformanceMetrics) -> str:
        """Determine system health status"""
        if (metrics.cpu_usage > 95.0 or metrics.memory_usage > 95.0 or 
            metrics.error_rate > 0.1):
            return "critical"
        elif (metrics.cpu_usage > 85.0 or metrics.memory_usage > 85.0 or 
              metrics.response_time > 2000.0 or metrics.error_rate > 0.05):
            return "warning"
        else:
            return "healthy"
    
    def _generate_recommendations(self, metrics: PerformanceMetrics) -> List[str]:
        """Generate performance recommendations"""
        recommendations = []
        
        # CPU recommendations
        if metrics.cpu_usage > 80.0:
            recommendations.append("Consider upgrading CPU or optimizing CPU-intensive operations")
        
        # Memory recommendations
        if metrics.memory_usage > 80.0:
            recommendations.append("Enable memory optimization and consider increasing memory allocation")
        
        # Response time recommendations
        if metrics.response_time > 1000.0:
            recommendations.append("Implement request caching and parallel processing")
        
        # Error rate recommendations
        if metrics.error_rate > 0.02:
            recommendations.append("Review error handling and implement retry mechanisms")
        
        # Cache recommendations
        if metrics.cache_hit_rate < 0.5:
            recommendations.append("Optimize cache strategy and increase cache size")
        
        return recommendations
    
    def _log_performance_summary(self, report: PerformanceReport):
        """Log performance summary"""
        logger.info(f"Performance Report - Mode: {report.mode.value}, "
                   f"Health: {report.system_health}, "
                   f"Efficiency: {report.efficiency_score:.2f}, "
                   f"Active Nodes: {report.metrics.active_nodes}, "
                   f"Cache Hit Rate: {report.metrics.cache_hit_rate:.2f}")
        
        if report.optimizations_applied:
            logger.info(f"Optimizations Applied: {', '.join(report.optimizations_applied)}")
        
        if report.alerts:
            logger.warning(f"Active Alerts: {len(report.alerts)}")
    
    def get_performance_summary(self) -> Dict[str, Any]:
        """Get current performance summary"""
        if not self.performance_history:
            return {}
        
        latest_metrics = self.performance_history[-1]
        
        return {
            'current_mode': self.current_mode.value,
            'metrics': {
                'cpu_usage': latest_metrics.cpu_usage,
                'memory_usage': latest_metrics.memory_usage,
                'response_time': latest_metrics.response_time,
                'throughput': latest_metrics.throughput,
                'error_rate': latest_metrics.error_rate,
                'cache_hit_rate': latest_metrics.cache_hit_rate,
                'active_nodes': latest_metrics.active_nodes,
                'total_requests': latest_metrics.total_requests
            },
            'optimization_summary': self.performance_optimizer.get_optimization_summary(),
            'scaling_summary': self.horizontal_scaler.get_scaling_summary(),
            'monitoring_summary': self.performance_monitor.get_performance_report(),
            'system_health': self._determine_system_health(latest_metrics),
            'efficiency_score': self._calculate_efficiency_score(latest_metrics)
        }
    
    def get_performance_history(self, limit: int = 100) -> List[Dict[str, Any]]:
        """Get performance history"""
        return [
            {
                'timestamp': m.timestamp,
                'cpu_usage': m.cpu_usage,
                'memory_usage': m.memory_usage,
                'response_time': m.response_time,
                'throughput': m.throughput,
                'error_rate': m.error_rate,
                'cache_hit_rate': m.cache_hit_rate,
                'active_nodes': m.active_nodes,
                'total_requests': m.total_requests
            }
            for m in self.performance_history[-limit:]
        ]
    
    def is_integration_active(self) -> bool:
        """Check if performance integration is active"""
        return self._running

