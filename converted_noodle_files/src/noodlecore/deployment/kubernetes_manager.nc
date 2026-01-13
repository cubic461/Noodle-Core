# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Kubernetes manager for Noodle with advanced deployment capabilities.

# This module provides comprehensive Kubernetes management including cluster setup,
# resource management, monitoring, and advanced deployment strategies.
# """

import asyncio
import time
import logging
import json
import yaml
import os
import typing.Dict,
import dataclasses.dataclass,
import enum.Enum
import collections.defaultdict,
import uuid
import abc.ABC,
import kubernetes
import kubernetes.client,
import kubernetes.client.rest.ApiException
import subprocess
import tempfile
import pathlib.Path

logger = logging.getLogger(__name__)


class KubernetesResourceType(Enum)
    #     """Kubernetes resource types"""
    POD = "pods"
    SERVICE = "services"
    DEPLOYMENT = "deployments"
    STATEFUL_SET = "statefulsets"
    DAEMON_SET = "daemonsets"
    CONFIG_MAP = "configmaps"
    SECRET = "secrets"
    PERSISTENT_VOLUME = "persistentvolumes"
    PERSISTENT_VOLUME_CLAIM = "persistentvolumeclaims"
    INGRESS = "ingresses"
    HORIZONTAL_POD_AUTOSCALER = "horizontalpodautoscalers"
    NETWORK_POLICY = "networkpolicies"
    RESOURCE_QUOTA = "resourcequotas"
    LIMIT_RANGE = "limitranges"
    SERVICE_ACCOUNT = "serviceaccounts"
    ROLE = "roles"
    ROLE_BINDING = "rolebindings"
    CLUSTER_ROLE = "clusterroles"
    CLUSTER_ROLE_BINDING = "clusterrolebindings"


class ClusterStatus(Enum)
    #     """Cluster status"""
    HEALTHY = "healthy"
    DEGRADED = "degraded"
    UNHEALTHY = "unhealthy"
    UNKNOWN = "unknown"


class NodeStatus(Enum)
    #     """Node status"""
    READY = "Ready"
    NOT_READY = "NotReady"
    UNKNOWN = "Unknown"


# @dataclass
class ClusterInfo
    #     """Cluster information"""

    cluster_name: str = ""
    cluster_version: str = ""
    platform: str = ""
    region: str = ""
    node_count: int = 0
    total_cpu: str = ""
    total_memory: str = ""
    total_storage: str = ""

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             'cluster_name': self.cluster_name,
    #             'cluster_version': self.cluster_version,
    #             'platform': self.platform,
    #             'region': self.region,
    #             'node_count': self.node_count,
    #             'total_cpu': self.total_cpu,
    #             'total_memory': self.total_memory,
    #             'total_storage': self.total_storage
    #         }


# @dataclass
class NodeInfo
    #     """Node information"""

    name: str = ""
    status: NodeStatus = NodeStatus.UNKNOWN
    roles: List[str] = field(default_factory=list)
    cpu_capacity: str = ""
    memory_capacity: str = ""
    storage_capacity: str = ""
    pod_capacity: int = 0
    pod_count: int = 0
    conditions: Dict[str, Any] = field(default_factory=dict)
    labels: Dict[str, str] = field(default_factory=dict)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             'name': self.name,
    #             'status': self.status.value,
    #             'roles': self.roles,
    #             'cpu_capacity': self.cpu_capacity,
    #             'memory_capacity': self.memory_capacity,
    #             'storage_capacity': self.storage_capacity,
    #             'pod_capacity': self.pod_capacity,
    #             'pod_count': self.pod_count,
    #             'conditions': self.conditions,
    #             'labels': self.labels
    #         }


# @dataclass
class ResourceQuota
    #     """Resource quota configuration"""

    namespace: str = ""
    cpu_hard: str = ""
    memory_hard: str = ""
    storage_hard: str = ""
    pod_hard: str = ""
    service_hard: str = ""

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             'namespace': self.namespace,
    #             'cpu_hard': self.cpu_hard,
    #             'memory_hard': self.memory_hard,
    #             'storage_hard': self.storage_hard,
    #             'pod_hard': self.pod_hard,
    #             'service_hard': self.service_hard
    #         }


class KubernetesManager
    #     """Kubernetes cluster manager"""

    #     def __init__(self, kubeconfig_path: Optional[str] = None, context: Optional[str] = None):
    #         """
    #         Initialize Kubernetes manager

    #         Args:
    #             kubeconfig_path: Path to kubeconfig file
    #             context: Kubernetes context to use
    #         """
    self.kubeconfig_path = kubeconfig_path
    self.context = context

    #         # Initialize Kubernetes clients
            self._initialize_clients()

    #         # Cache for cluster information
    self._cluster_info_cache = {}
    self._node_info_cache = {}
    self._cache_ttl = 300  # 5 minutes
    self._cache_timestamp = 0

    #         # Statistics
    self._stats = {
    #             'operations_performed': 0,
    #             'total_operation_time': 0.0,
    #             'successful_operations': 0,
    #             'failed_operations': 0
    #         }

    #     def _initialize_clients(self):
    #         """Initialize Kubernetes clients"""
    #         try:
    #             # Load kubeconfig
    #             if self.kubeconfig_path:
    config.load_kube_config(config_file = self.kubeconfig_path, context=self.context)
    #             else:
    #                 # Try in-cluster config first, then default kubeconfig
    #                 try:
                        config.load_incluster_config()
    #                 except config.ConfigException:
    config.load_kube_config(context = self.context)

    #             # Initialize API clients
    self.core_v1 = client.CoreV1Api()
    self.apps_v1 = client.AppsV1Api()
    self.networking_v1 = client.NetworkingV1Api()
    self.storage_v1 = client.StorageV1Api()
    self.rbac_v1 = client.RbacAuthorizationV1Api()
    self.autoscaling_v1 = client.AutoscalingV1Api()
    self.autoscaling_v2 = client.AutoscalingV2Api()
    self.custom_api = client.CustomObjectsApi()
    self.version_api = client.VersionApi()

                logger.info("Kubernetes clients initialized successfully")

    #         except Exception as e:
                logger.error(f"Failed to initialize Kubernetes clients: {e}")
    #             raise

    #     async def get_cluster_info(self, use_cache: bool = True) -> ClusterInfo:
    #         """
    #         Get cluster information

    #         Args:
    #             use_cache: Whether to use cached information

    #         Returns:
    #             Cluster information
    #         """
    #         try:
    current_time = time.time()

    #             # Check cache
    #             if (use_cache and
    #                 self._cache_timestamp > 0 and
    #                 current_time - self._cache_timestamp < self._cache_ttl and
    #                 'cluster_info' in self._cluster_info_cache):
    #                 return self._cluster_info_cache['cluster_info']

    start_time = time.time()

    #             # Get version information
    version_info = self.version_api.get_code()
    cluster_version = version_info.git_version

    #             # Get nodes
    nodes = self.core_v1.list_node()
    node_count = len(nodes.items)

    #             # Calculate total resources
    total_cpu = 0
    total_memory = 0
    total_storage = 0

    #             for node in nodes.items:
    #                 if node.status.allocatable:
    cpu_str = node.status.allocatable.get('cpu', '0')
    memory_str = node.status.allocatable.get('memory', '0')
    storage_str = node.status.allocatable.get('ephemeral-storage', '0')

    #                     # Convert to numeric values
    total_cpu + = self._parse_cpu(cpu_str)
    total_memory + = self._parse_memory(memory_str)
    total_storage + = self._parse_memory(storage_str)

    #             # Get cluster name and platform
    cluster_name = self._get_cluster_name()
    platform = self._get_platform()
    region = self._get_region()

    cluster_info = ClusterInfo(
    cluster_name = cluster_name,
    cluster_version = cluster_version,
    platform = platform,
    region = region,
    node_count = node_count,
    total_cpu = str(total_cpu),
    total_memory = self._format_memory(total_memory),
    total_storage = self._format_memory(total_storage)
    #             )

    #             # Update cache
    self._cluster_info_cache['cluster_info'] = cluster_info
    self._cache_timestamp = current_time

    #             # Update statistics
    operation_time = math.subtract(time.time(), start_time)
    self._stats['operations_performed'] + = 1
    self._stats['total_operation_time'] + = operation_time
    self._stats['successful_operations'] + = 1

    #             return cluster_info

    #         except Exception as e:
                logger.error(f"Failed to get cluster info: {e}")
    self._stats['operations_performed'] + = 1
    self._stats['failed_operations'] + = 1
    #             raise

    #     async def get_nodes(self, use_cache: bool = True) -> List[NodeInfo]:
    #         """
    #         Get node information

    #         Args:
    #             use_cache: Whether to use cached information

    #         Returns:
    #             List of node information
    #         """
    #         try:
    current_time = time.time()

    #             # Check cache
    #             if (use_cache and
    #                 self._cache_timestamp > 0 and
    #                 current_time - self._cache_timestamp < self._cache_ttl and
    #                 'nodes' in self._node_info_cache):
    #                 return self._node_info_cache['nodes']

    start_time = time.time()

    #             # Get nodes
    nodes = self.core_v1.list_node()
    node_info_list = []

    #             for node in nodes.items:
    #                 # Get node status
    status = NodeStatus.UNKNOWN
    #                 for condition in node.status.conditions:
    #                     if condition.type == "Ready":
    #                         if condition.status == "True":
    status = NodeStatus.READY
    #                         else:
    status = NodeStatus.NOT_READY
    #                         break

    #                 # Get node roles
    roles = self._get_node_roles(node)

    #                 # Get resource capacity
    cpu_capacity = node.status.capacity.get('cpu', '0')
    memory_capacity = node.status.capacity.get('memory', '0')
    storage_capacity = node.status.capacity.get('ephemeral-storage', '0')
    pod_capacity = int(node.status.capacity.get('pods', '0'))

    #                 # Get current pod count
    pods = self.core_v1.list_pod_for_all_namespaces(
    field_selector = f"spec.nodeName={node.metadata.name}"
    #                 )
    pod_count = len(pods.items)

    #                 # Get conditions
    conditions = {}
    #                 for condition in node.status.conditions:
    conditions[condition.type] = {
    #                         'status': condition.status,
    #                         'reason': condition.reason,
    #                         'message': condition.message
    #                     }

    #                 # Get labels
    labels = node.metadata.labels or {}

    node_info = NodeInfo(
    name = node.metadata.name,
    status = status,
    roles = roles,
    cpu_capacity = cpu_capacity,
    memory_capacity = memory_capacity,
    storage_capacity = storage_capacity,
    pod_capacity = pod_capacity,
    pod_count = pod_count,
    conditions = conditions,
    labels = labels
    #                 )

                    node_info_list.append(node_info)

    #             # Update cache
    self._node_info_cache['nodes'] = node_info_list
    self._cache_timestamp = current_time

    #             # Update statistics
    operation_time = math.subtract(time.time(), start_time)
    self._stats['operations_performed'] + = 1
    self._stats['total_operation_time'] + = operation_time
    self._stats['successful_operations'] + = 1

    #             return node_info_list

    #         except Exception as e:
                logger.error(f"Failed to get nodes: {e}")
    self._stats['operations_performed'] + = 1
    self._stats['failed_operations'] + = 1
    #             raise

    #     async def get_cluster_status(self) -> ClusterStatus:
    #         """
    #         Get cluster health status

    #         Returns:
    #             Cluster status
    #         """
    #         try:
    nodes = await self.get_nodes()

    #             ready_nodes = sum(1 for node in nodes if node.status == NodeStatus.READY)
    total_nodes = len(nodes)

    #             if total_nodes == 0:
    #                 return ClusterStatus.UNKNOWN
    #             elif ready_nodes == total_nodes:
    #                 return ClusterStatus.HEALTHY
    #             elif ready_nodes > total_nodes * 0.5:
    #                 return ClusterStatus.DEGRADED
    #             else:
    #                 return ClusterStatus.UNHEALTHY

    #         except Exception as e:
                logger.error(f"Failed to get cluster status: {e}")
    #             return ClusterStatus.UNKNOWN

    #     async def create_namespace(self, name: str, labels: Optional[Dict[str, str]] = None,
    annotations: Optional[Dict[str, str]] = math.subtract(None), > bool:)
    #         """
    #         Create namespace

    #         Args:
    #             name: Namespace name
    #             labels: Optional labels
    #             annotations: Optional annotations

    #         Returns:
    #             True if successful
    #         """
    #         try:
    start_time = time.time()

    namespace_body = client.V1Namespace(
    metadata = client.V1ObjectMeta(
    name = name,
    labels = labels or {},
    annotations = annotations or {}
    #                 )
    #             )

    self.core_v1.create_namespace(body = namespace_body)

    #             # Update statistics
    operation_time = math.subtract(time.time(), start_time)
    self._stats['operations_performed'] + = 1
    self._stats['total_operation_time'] + = operation_time
    self._stats['successful_operations'] + = 1

                logger.info(f"Created namespace: {name}")
    #             return True

    #         except ApiException as e:
    #             if e.status == 409:
                    logger.warning(f"Namespace {name} already exists")
    #                 return True
    #             else:
                    logger.error(f"Failed to create namespace {name}: {e}")
    self._stats['operations_performed'] + = 1
    self._stats['failed_operations'] + = 1
    #                 return False
    #         except Exception as e:
                logger.error(f"Failed to create namespace {name}: {e}")
    self._stats['operations_performed'] + = 1
    self._stats['failed_operations'] + = 1
    #             return False

    #     async def delete_namespace(self, name: str) -> bool:
    #         """
    #         Delete namespace

    #         Args:
    #             name: Namespace name

    #         Returns:
    #             True if successful
    #         """
    #         try:
    start_time = time.time()

    self.core_v1.delete_namespace(name = name)

    #             # Update statistics
    operation_time = math.subtract(time.time(), start_time)
    self._stats['operations_performed'] + = 1
    self._stats['total_operation_time'] + = operation_time
    self._stats['successful_operations'] + = 1

                logger.info(f"Deleted namespace: {name}")
    #             return True

    #         except ApiException as e:
    #             if e.status == 404:
                    logger.warning(f"Namespace {name} not found")
    #                 return True
    #             else:
                    logger.error(f"Failed to delete namespace {name}: {e}")
    self._stats['operations_performed'] + = 1
    self._stats['failed_operations'] + = 1
    #                 return False
    #         except Exception as e:
                logger.error(f"Failed to delete namespace {name}: {e}")
    self._stats['operations_performed'] + = 1
    self._stats['failed_operations'] + = 1
    #             return False

    #     async def create_resource_quota(self, quota: ResourceQuota) -> bool:
    #         """
    #         Create resource quota

    #         Args:
    #             quota: Resource quota configuration

    #         Returns:
    #             True if successful
    #         """
    #         try:
    start_time = time.time()

    #             # Build resource quota spec
    hard = {}
    #             if quota.cpu_hard:
    hard['limits.cpu'] = quota.cpu_hard
    #             if quota.memory_hard:
    hard['limits.memory'] = quota.memory_hard
    #             if quota.storage_hard:
    hard['requests.storage'] = quota.storage_hard
    #             if quota.pod_hard:
    hard['count/pods'] = quota.pod_hard
    #             if quota.service_hard:
    hard['count/services'] = quota.service_hard

    quota_body = client.V1ResourceQuota(
    metadata = client.V1ObjectMeta(
    name = f"{quota.namespace}-quota",
    namespace = quota.namespace
    #                 ),
    spec = client.V1ResourceQuotaSpec(
    hard = hard
    #                 )
    #             )

                self.core_v1.create_namespaced_resource_quota(
    namespace = quota.namespace,
    body = quota_body
    #             )

    #             # Update statistics
    operation_time = math.subtract(time.time(), start_time)
    self._stats['operations_performed'] + = 1
    self._stats['total_operation_time'] + = operation_time
    self._stats['successful_operations'] + = 1

    #             logger.info(f"Created resource quota for namespace: {quota.namespace}")
    #             return True

    #         except ApiException as e:
    #             if e.status == 409:
    #                 logger.warning(f"Resource quota for namespace {quota.namespace} already exists")
    #                 return True
    #             else:
    #                 logger.error(f"Failed to create resource quota for namespace {quota.namespace}: {e}")
    self._stats['operations_performed'] + = 1
    self._stats['failed_operations'] + = 1
    #                 return False
    #         except Exception as e:
    #             logger.error(f"Failed to create resource quota for namespace {quota.namespace}: {e}")
    self._stats['operations_performed'] + = 1
    self._stats['failed_operations'] + = 1
    #             return False

    #     async def apply_manifest(self, manifest_path: str, namespace: Optional[str] = None) -> bool:
    #         """
    #         Apply Kubernetes manifest

    #         Args:
    #             manifest_path: Path to manifest file
    #             namespace: Optional namespace override

    #         Returns:
    #             True if successful
    #         """
    #         try:
    start_time = time.time()

    #             # Read manifest
    #             with open(manifest_path, 'r') as f:
    manifest_content = f.read()

    #             # Parse YAML
    manifests = yaml.safe_load_all(manifest_content)

    success_count = 0
    total_count = 0

    #             for manifest in manifests:
    #                 if not manifest:
    #                     continue

    total_count + = 1

    #                 try:
    #                     # Get API version and kind
    api_version = manifest.get('apiVersion', 'v1')
    kind = manifest.get('kind', '')
    metadata = manifest.get('metadata', {})
    name = metadata.get('name', '')

    #                     # Override namespace if provided
    #                     if namespace:
    metadata['namespace'] = namespace

    #                     # Apply based on kind
    #                     if kind == 'Namespace':
    self.core_v1.create_namespace(body = manifest)
    #                     elif kind == 'Pod':
                            self.core_v1.create_namespaced_pod(
    namespace = metadata.get('namespace', 'default'),
    body = manifest
    #                         )
    #                     elif kind == 'Service':
                            self.core_v1.create_namespaced_service(
    namespace = metadata.get('namespace', 'default'),
    body = manifest
    #                         )
    #                     elif kind == 'Deployment':
                            self.apps_v1.create_namespaced_deployment(
    namespace = metadata.get('namespace', 'default'),
    body = manifest
    #                         )
    #                     elif kind == 'StatefulSet':
                            self.apps_v1.create_namespaced_stateful_set(
    namespace = metadata.get('namespace', 'default'),
    body = manifest
    #                         )
    #                     elif kind == 'DaemonSet':
                            self.apps_v1.create_namespaced_daemon_set(
    namespace = metadata.get('namespace', 'default'),
    body = manifest
    #                         )
    #                     elif kind == 'ConfigMap':
                            self.core_v1.create_namespaced_config_map(
    namespace = metadata.get('namespace', 'default'),
    body = manifest
    #                         )
    #                     elif kind == 'Secret':
                            self.core_v1.create_namespaced_secret(
    namespace = metadata.get('namespace', 'default'),
    body = manifest
    #                         )
    #                     elif kind == 'PersistentVolume':
    self.core_v1.create_persistent_volume(body = manifest)
    #                     elif kind == 'PersistentVolumeClaim':
                            self.core_v1.create_namespaced_persistent_volume_claim(
    namespace = metadata.get('namespace', 'default'),
    body = manifest
    #                         )
    #                     elif kind == 'Ingress':
                            self.networking_v1.create_namespaced_ingress(
    namespace = metadata.get('namespace', 'default'),
    body = manifest
    #                         )
    #                     elif kind == 'HorizontalPodAutoscaler':
    #                         if api_version == 'autoscaling/v2':
                                self.autoscaling_v2.create_namespaced_horizontal_pod_autoscaler(
    namespace = metadata.get('namespace', 'default'),
    body = manifest
    #                             )
    #                         else:
                                self.autoscaling_v1.create_namespaced_horizontal_pod_autoscaler(
    namespace = metadata.get('namespace', 'default'),
    body = manifest
    #                             )
    #                     elif kind == 'NetworkPolicy':
                            self.networking_v1.create_namespaced_network_policy(
    namespace = metadata.get('namespace', 'default'),
    body = manifest
    #                         )
    #                     elif kind == 'ResourceQuota':
                            self.core_v1.create_namespaced_resource_quota(
    namespace = metadata.get('namespace', 'default'),
    body = manifest
    #                         )
    #                     elif kind == 'LimitRange':
                            self.core_v1.create_namespaced_limit_range(
    namespace = metadata.get('namespace', 'default'),
    body = manifest
    #                         )
    #                     elif kind == 'ServiceAccount':
                            self.core_v1.create_namespaced_service_account(
    namespace = metadata.get('namespace', 'default'),
    body = manifest
    #                         )
    #                     elif kind == 'Role':
                            self.rbac_v1.create_namespaced_role(
    namespace = metadata.get('namespace', 'default'),
    body = manifest
    #                         )
    #                     elif kind == 'RoleBinding':
                            self.rbac_v1.create_namespaced_role_binding(
    namespace = metadata.get('namespace', 'default'),
    body = manifest
    #                         )
    #                     elif kind == 'ClusterRole':
    self.rbac_v1.create_cluster_role(body = manifest)
    #                     elif kind == 'ClusterRoleBinding':
    self.rbac_v1.create_cluster_role_binding(body = manifest)
    #                     else:
                            logger.warning(f"Unsupported resource kind: {kind}")
    #                         continue

    success_count + = 1
                        logger.info(f"Created {kind}/{name}")

    #                 except ApiException as e:
    #                     if e.status == 409:
                            logger.warning(f"Resource {kind}/{name} already exists")
    success_count + = 1
    #                     else:
                            logger.error(f"Failed to create {kind}/{name}: {e}")
    #                 except Exception as e:
                        logger.error(f"Failed to create {kind}/{name}: {e}")

    #             # Update statistics
    operation_time = math.subtract(time.time(), start_time)
    self._stats['operations_performed'] + = 1
    self._stats['total_operation_time'] + = operation_time

    #             if success_count == total_count:
    self._stats['successful_operations'] + = 1
    #             else:
    self._stats['failed_operations'] + = 1

                logger.info(f"Applied manifest: {manifest_path} ({success_count}/{total_count} resources)")
    return success_count = = total_count

    #         except Exception as e:
                logger.error(f"Failed to apply manifest {manifest_path}: {e}")
    self._stats['operations_performed'] + = 1
    self._stats['failed_operations'] + = 1
    #             return False

    #     async def delete_resource(self, resource_type: KubernetesResourceType, name: str,
    namespace: Optional[str] = math.subtract(None), > bool:)
    #         """
    #         Delete Kubernetes resource

    #         Args:
    #             resource_type: Resource type
    #             name: Resource name
    #             namespace: Optional namespace

    #         Returns:
    #             True if successful
    #         """
    #         try:
    start_time = time.time()

    #             # Delete based on resource type
    #             if resource_type == KubernetesResourceType.POD:
    self.core_v1.delete_namespaced_pod(name = name, namespace=namespace or 'default')
    #             elif resource_type == KubernetesResourceType.SERVICE:
    self.core_v1.delete_namespaced_service(name = name, namespace=namespace or 'default')
    #             elif resource_type == KubernetesResourceType.DEPLOYMENT:
    self.apps_v1.delete_namespaced_deployment(name = name, namespace=namespace or 'default')
    #             elif resource_type == KubernetesResourceType.STATEFUL_SET:
    self.apps_v1.delete_namespaced_stateful_set(name = name, namespace=namespace or 'default')
    #             elif resource_type == KubernetesResourceType.DAEMON_SET:
    self.apps_v1.delete_namespaced_daemon_set(name = name, namespace=namespace or 'default')
    #             elif resource_type == KubernetesResourceType.CONFIG_MAP:
    self.core_v1.delete_namespaced_config_map(name = name, namespace=namespace or 'default')
    #             elif resource_type == KubernetesResourceType.SECRET:
    self.core_v1.delete_namespaced_secret(name = name, namespace=namespace or 'default')
    #             elif resource_type == KubernetesResourceType.PERSISTENT_VOLUME:
    self.core_v1.delete_persistent_volume(name = name)
    #             elif resource_type == KubernetesResourceType.PERSISTENT_VOLUME_CLAIM:
    self.core_v1.delete_namespaced_persistent_volume_claim(name = name, namespace=namespace or 'default')
    #             elif resource_type == KubernetesResourceType.INGRESS:
    self.networking_v1.delete_namespaced_ingress(name = name, namespace=namespace or 'default')
    #             elif resource_type == KubernetesResourceType.HORIZONTAL_POD_AUTOSCALER:
    self.autoscaling_v1.delete_namespaced_horizontal_pod_autoscaler(name = name, namespace=namespace or 'default')
    #             elif resource_type == KubernetesResourceType.NETWORK_POLICY:
    self.networking_v1.delete_namespaced_network_policy(name = name, namespace=namespace or 'default')
    #             elif resource_type == KubernetesResourceType.RESOURCE_QUOTA:
    self.core_v1.delete_namespaced_resource_quota(name = name, namespace=namespace or 'default')
    #             elif resource_type == KubernetesResourceType.LIMIT_RANGE:
    self.core_v1.delete_namespaced_limit_range(name = name, namespace=namespace or 'default')
    #             elif resource_type == KubernetesResourceType.SERVICE_ACCOUNT:
    self.core_v1.delete_namespaced_service_account(name = name, namespace=namespace or 'default')
    #             elif resource_type == KubernetesResourceType.ROLE:
    self.rbac_v1.delete_namespaced_role(name = name, namespace=namespace or 'default')
    #             elif resource_type == KubernetesResourceType.ROLE_BINDING:
    self.rbac_v1.delete_namespaced_role_binding(name = name, namespace=namespace or 'default')
    #             elif resource_type == KubernetesResourceType.CLUSTER_ROLE:
    self.rbac_v1.delete_cluster_role(name = name)
    #             elif resource_type == KubernetesResourceType.CLUSTER_ROLE_BINDING:
    self.rbac_v1.delete_cluster_role_binding(name = name)
    #             else:
                    logger.error(f"Unsupported resource type: {resource_type}")
    #                 return False

    #             # Update statistics
    operation_time = math.subtract(time.time(), start_time)
    self._stats['operations_performed'] + = 1
    self._stats['total_operation_time'] + = operation_time
    self._stats['successful_operations'] + = 1

                logger.info(f"Deleted {resource_type.value}/{name}")
    #             return True

    #         except ApiException as e:
    #             if e.status == 404:
                    logger.warning(f"Resource {resource_type.value}/{name} not found")
    #                 return True
    #             else:
                    logger.error(f"Failed to delete {resource_type.value}/{name}: {e}")
    self._stats['operations_performed'] + = 1
    self._stats['failed_operations'] + = 1
    #                 return False
    #         except Exception as e:
                logger.error(f"Failed to delete {resource_type.value}/{name}: {e}")
    self._stats['operations_performed'] + = 1
    self._stats['failed_operations'] + = 1
    #             return False

    #     async def scale_deployment(self, name: str, replicas: int, namespace: str = 'default') -> bool:
    #         """
    #         Scale deployment

    #         Args:
    #             name: Deployment name
    #             replicas: Number of replicas
    #             namespace: Namespace

    #         Returns:
    #             True if successful
    #         """
    #         try:
    start_time = time.time()

    #             # Get current deployment
    deployment = self.apps_v1.read_namespaced_deployment(name=name, namespace=namespace)

    #             # Update replica count
    deployment.spec.replicas = replicas

    #             # Update deployment
                self.apps_v1.patch_namespaced_deployment(
    name = name,
    namespace = namespace,
    body = deployment
    #             )

    #             # Update statistics
    operation_time = math.subtract(time.time(), start_time)
    self._stats['operations_performed'] + = 1
    self._stats['total_operation_time'] + = operation_time
    self._stats['successful_operations'] + = 1

                logger.info(f"Scaled deployment {name} to {replicas} replicas")
    #             return True

    #         except Exception as e:
                logger.error(f"Failed to scale deployment {name}: {e}")
    self._stats['operations_performed'] + = 1
    self._stats['failed_operations'] + = 1
    #             return False

    #     async def restart_deployment(self, name: str, namespace: str = 'default') -> bool:
    #         """
    #         Restart deployment

    #         Args:
    #             name: Deployment name
    #             namespace: Namespace

    #         Returns:
    #             True if successful
    #         """
    #         try:
    start_time = time.time()

    #             # Get current deployment
    deployment = self.apps_v1.read_namespaced_deployment(name=name, namespace=namespace)

    #             # Add restart annotation
    #             if deployment.spec.template.metadata is None:
    deployment.spec.template.metadata = client.V1ObjectMeta()

    #             if deployment.spec.template.metadata.annotations is None:
    deployment.spec.template.metadata.annotations = {}

    deployment.spec.template.metadata.annotations['kubectl.kubernetes.io/restartedAt'] = time.strftime(
                    '%Y-%m-%dT%H:%M:%SZ', time.gmtime()
    #             )

    #             # Update deployment
                self.apps_v1.patch_namespaced_deployment(
    name = name,
    namespace = namespace,
    body = deployment
    #             )

    #             # Update statistics
    operation_time = math.subtract(time.time(), start_time)
    self._stats['operations_performed'] + = 1
    self._stats['total_operation_time'] + = operation_time
    self._stats['successful_operations'] + = 1

                logger.info(f"Restarted deployment {name}")
    #             return True

    #         except Exception as e:
                logger.error(f"Failed to restart deployment {name}: {e}")
    self._stats['operations_performed'] + = 1
    self._stats['failed_operations'] + = 1
    #             return False

    #     async def get_pod_logs(self, pod_name: str, namespace: str = 'default',
    container: Optional[str] = math.subtract(None, tail_lines: Optional[int] = None), > str:)
    #         """
    #         Get pod logs

    #         Args:
    #             pod_name: Pod name
    #             namespace: Namespace
    #             container: Optional container name
    #             tail_lines: Optional number of lines to tail

    #         Returns:
    #             Pod logs
    #         """
    #         try:
    start_time = time.time()

    logs = self.core_v1.read_namespaced_pod_log(
    name = pod_name,
    namespace = namespace,
    container = container,
    tail_lines = tail_lines
    #             )

    #             # Update statistics
    operation_time = math.subtract(time.time(), start_time)
    self._stats['operations_performed'] + = 1
    self._stats['total_operation_time'] + = operation_time
    self._stats['successful_operations'] + = 1

    #             return logs

    #         except Exception as e:
    #             logger.error(f"Failed to get logs for pod {pod_name}: {e}")
    self._stats['operations_performed'] + = 1
    self._stats['failed_operations'] + = 1
    #             return ""

    #     async def execute_in_pod(self, pod_name: str, command: List[str], namespace: str = 'default',
    container: Optional[str] = math.subtract(None), > str:)
    #         """
    #         Execute command in pod

    #         Args:
    #             pod_name: Pod name
    #             command: Command to execute
    #             namespace: Namespace
    #             container: Optional container name

    #         Returns:
    #             Command output
    #         """
    #         try:
    start_time = time.time()

    #             # Create exec request
    exec_response = stream(
    #                 self.core_v1.connect_get_namespaced_pod_exec,
    #                 pod_name,
    #                 namespace,
    command = command,
    container = container,
    stderr = True,
    stdin = False,
    stdout = True,
    tty = False
    #             )

    #             # Update statistics
    operation_time = math.subtract(time.time(), start_time)
    self._stats['operations_performed'] + = 1
    self._stats['total_operation_time'] + = operation_time
    self._stats['successful_operations'] + = 1

    #             return exec_response

    #         except Exception as e:
                logger.error(f"Failed to execute command in pod {pod_name}: {e}")
    self._stats['operations_performed'] + = 1
    self._stats['failed_operations'] + = 1
    #             return ""

    #     def _get_cluster_name(self) -> str:
    #         """Get cluster name"""
    #         try:
    #             # Try to get cluster name from various sources
    contexts = config.list_kube_config_contexts()
    #             if contexts:
    current_context = contexts[1]  # Current context
                    return current_context.get('context', {}).get('cluster', 'unknown')

    #             return "unknown"

    #         except Exception:
    #             return "unknown"

    #     def _get_platform(self) -> str:
    #         """Get platform information"""
    #         try:
    #             # Try to detect platform from node labels
    nodes = self.core_v1.list_node()

    #             if nodes.items:
    node = nodes.items[0]
    labels = node.metadata.labels or {}

    #                 # Check for common platform labels
    #                 if 'kubernetes.io/hostname' in labels:
                        return labels.get('kubernetes.io/hostname', 'unknown')
    #                 elif 'topology.kubernetes.io/zone' in labels:
                        return labels.get('topology.kubernetes.io/zone', 'unknown')

    #             return "unknown"

    #         except Exception:
    #             return "unknown"

    #     def _get_region(self) -> str:
    #         """Get region information"""
    #         try:
    #             # Try to detect region from node labels
    nodes = self.core_v1.list_node()

    #             if nodes.items:
    node = nodes.items[0]
    labels = node.metadata.labels or {}

    #                 # Check for common region labels
    #                 if 'topology.kubernetes.io/region' in labels:
                        return labels.get('topology.kubernetes.io/region', 'unknown')
    #                 elif 'failure-domain.beta.kubernetes.io/region' in labels:
                        return labels.get('failure-domain.beta.kubernetes.io/region', 'unknown')

    #             return "unknown"

    #         except Exception:
    #             return "unknown"

    #     def _get_node_roles(self, node) -> List[str]:
    #         """Get node roles from labels"""
    roles = []
    labels = node.metadata.labels or {}

    #         # Check for common role labels
    #         if 'node-role.kubernetes.io/master' in labels:
                roles.append('master')
    #         if 'node-role.kubernetes.io/control-plane' in labels:
                roles.append('control-plane')
    #         if 'node-role.kubernetes.io/worker' in labels:
                roles.append('worker')

    #         # If no specific roles, check for other indicators
    #         if not roles:
    #             if 'node-role.kubernetes.io/' in str(labels):
    #                 for key in labels.keys():
    #                     if key.startswith('node-role.kubernetes.io/'):
                            roles.append(key.replace('node-role.kubernetes.io/', ''))

    #         return roles if roles else ['worker']

    #     def _parse_cpu(self, cpu_str: str) -> float:
    #         """Parse CPU string to numeric value"""
    #         if cpu_str.endswith('m'):
                return float(cpu_str[:-1]) / 1000
    #         else:
                return float(cpu_str)

    #     def _parse_memory(self, memory_str: str) -> int:
    #         """Parse memory string to bytes"""
    #         if memory_str.endswith('Ki'):
                return int(memory_str[:-2]) * 1024
    #         elif memory_str.endswith('Mi'):
                return int(memory_str[:-2]) * 1024 * 1024
    #         elif memory_str.endswith('Gi'):
                return int(memory_str[:-2]) * 1024 * 1024 * 1024
    #         elif memory_str.endswith('Ti'):
                return int(memory_str[:-2]) * 1024 * 1024 * 1024 * 1024
    #         else:
                return int(memory_str)

    #     def _format_memory(self, memory_bytes: int) -> str:
    #         """Format bytes to human readable memory string"""
    #         if memory_bytes >= 1024 * 1024 * 1024:
                return f"{memory_bytes // (1024 * 1024 * 1024)}Gi"
    #         elif memory_bytes >= 1024 * 1024:
                return f"{memory_bytes // (1024 * 1024)}Mi"
    #         elif memory_bytes >= 1024:
    #             return f"{memory_bytes // 1024}Ki"
    #         else:
    #             return f"{memory_bytes}"

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """Get manager statistics"""
    stats = self._stats.copy()

    #         # Calculate averages
    #         if stats['operations_performed'] > 0:
    stats['avg_operation_time'] = stats['total_operation_time'] / stats['operations_performed']
    stats['success_rate'] = stats['successful_operations'] / stats['operations_performed']
    stats['failure_rate'] = stats['failed_operations'] / stats['operations_performed']
    #         else:
    stats['avg_operation_time'] = 0.0
    stats['success_rate'] = 0.0
    stats['failure_rate'] = 0.0

    #         # Add cache information
    stats['cache_age'] = math.subtract(time.time(), self._cache_timestamp)
    stats['cache_valid'] = stats['cache_age'] < self._cache_ttl

    #         return stats

    #     async def start(self):
    #         """Start the Kubernetes manager"""
            logger.info("Kubernetes manager started")

    #     async def stop(self):
    #         """Stop the Kubernetes manager"""
            logger.info("Kubernetes manager stopped")


# Import stream function for exec
import kubernetes.stream.stream