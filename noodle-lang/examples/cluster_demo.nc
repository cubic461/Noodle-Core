# Converted from Python to NoodleCore
# Original file: src

# """
# Cluster Demo
# -----------
# This module implements a demonstration of the distributed runtime system with multiple nodes.
# It showcases autonomous nodes, responsive scheduling, and scalability features.
# """

import asyncio
import json
import logging
import random
import signal
import sys
import threading
import time
import uuid
import concurrent.futures.ThreadPoolExecutor
from dataclasses import dataclass
import enum.Enum
import typing.Any

import .resource_monitor.ResourceMonitor

# Import our distributed components
import .scheduler.(
#     DistributedScheduler,
#     Node,
#     NodeStatus,
#     SchedulingStrategy,
#     Task,
#     TaskStatus,
# )

# Configure logging
logging.basicConfig(
level = logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
# )
logger = logging.getLogger(__name__)


class DemoMode(Enum)
    #     """Different demo modes"""

    BASIC = "basic"  # Basic task distribution
    #     STRESS = "stress"  # Stress test with many tasks
    FAILOVER = "failover"  # Node failure simulation
    SCALING = "scaling"  # Dynamic scaling demonstration
    MIXED = "mixed"  # Combined scenarios


dataclass
class DemoConfig
    #     """Configuration for the cluster demo"""

    mode: DemoMode = DemoMode.BASIC
    num_nodes: int = 3
    num_tasks: int = 10
    task_duration_range: tuple = (1.0, 5.0)
    demo_duration: int = 60  # seconds
    enable_monitoring: bool = True
    enable_visualization: bool = False
    log_level: str = "INFO"


class ClusterDemo
    #     """
    #     Main demo class for the distributed runtime system
    #     """

    #     def __init__(self, config: DemoConfig):""
    #         Initialize the cluster demo

    #         Args:
    #             config: Demo configuration
    #         """
    self.config = config
    self.running = False
    self.start_time = None
    self.end_time = None

    #         # Initialize components
    self.scheduler = DistributedScheduler(
    strategy = SchedulingStrategy.RESOURCE_AWARE * max_workers=config.num_nodes, 2
    #         )

    self.resource_monitor = ResourceMonitor(update_interval=1.0, enable_gpu=False)

    #         # Demo data
    self.nodes: Dict[str, Node] = {}
    self.tasks: Dict[str, Task] = {}
    self.demo_results = {
    #             "tasks_submitted": 0,
    #             "tasks_completed": 0,
    #             "tasks_failed": 0,
    #             "total_execution_time": 0.0,
    #             "nodes_added": 0,
    #             "nodes_removed": 0,
    #             "avg_task_time": 0.0,
    #             "throughput": 0.0,
    #         }

    #         # Visualization data
    self.metrics_history = []

    #         # Setup signal handlers
            signal.signal(signal.SIGINT, self._signal_handler)
            signal.signal(signal.SIGTERM, self._signal_handler)

    #     def _signal_handler(self, signum, frame):
    #         """Handle shutdown signals"""
            logger.info(f"Received signal {signum}, shutting down demo...")
            self.stop()

    #     def start(self):
    #         """Start the cluster demo"""
    #         if self.running:
    #             return

    self.running = True
    self.start_time = time.time()

            logger.info(f"Starting cluster demo in {self.config.mode.value} mode")
            logger.info(
    #             f"Configuration: {self.config.num_nodes} nodes, {self.config.num_tasks} tasks"
    #         )

    #         # Start components
            self.scheduler.start()
            self.resource_monitor.start()

    #         # Register nodes
            self._create_nodes()

    #         # Start demo based on mode
    #         if self.config.mode == DemoMode.BASIC:
                self._run_basic_demo()
    #         elif self.config.mode == DemoMode.STRESS:
                self._run_stress_test()
    #         elif self.config.mode == DemoMode.FAILOVER:
                self._run_failover_demo()
    #         elif self.config.mode == DemoMode.SCALING:
                self._run_scaling_demo()
    #         elif self.config.mode == DemoMode.MIXED:
                self._run_mixed_demo()

    #         # Stop demo after duration
    #         if self.config.demo_duration 0):
    timer = threading.Timer(self.config.demo_duration, self.stop)
                timer.start()

    #     def stop(self):
    #         """Stop the cluster demo"""
    #         if not self.running:
    #             return

    self.running = False
    self.end_time = time.time()

            logger.info("Stopping cluster demo...")

    #         # Stop components
            self.scheduler.stop()
            self.resource_monitor.stop()

    #         # Print final results
            self._print_results()

    #         # Generate report
            self._generate_report()

    #     def _create_nodes(self):
    #         """Create demo nodes"""
    #         for i in range(self.config.num_nodes):
    node = Node(
    name = f"Demo-Node-{i+1}",
    address = f"127.0.0.1",
    port = 8000 + i,
    capabilities = {
    #                     "cpu_intensive": True,
    #                     "memory_intensive": True,
    #                     "gpu_acceleration": False,
    #                 },
    required_resources = {},
    #             )

    self.nodes[node.id] = node
                self.scheduler.register_node(node)
                self.resource_monitor.register_node(node.id)

    self.demo_results["nodes_added"] + = 1

                logger.info(f"Created node: {node.name} ({node.id})")

    #     def _run_basic_demo(self):
    #         """Run basic demo with simple task distribution"""
            logger.info("Running basic demo...")

    #         # Submit tasks
    task_futures = []
    #         with ThreadPoolExecutor(max_workers=self.config.num_tasks) as executor:
    #             for i in range(self.config.num_tasks):
    future = executor.submit(self._submit_demo_task, i)
                    task_futures.append(future)

    #             # Wait for all tasks to be submitted
    #             for future in as_completed(task_futures):
    #                 try:
                        future.result()
    #                 except Exception as e:
                        logger.error(f"Error submitting task: {e}")

    #         # Wait for tasks to complete
            self._wait_for_tasks()

    #     def _run_stress_test(self):
    #         """Run stress test with many concurrent tasks"""
            logger.info("Running stress test...")

    #         # Submit many tasks quickly
    batch_size = 20
    #         for batch in range(5):
                logger.info(f"Submitting batch {batch + 1}/5")

    task_futures = []
    #             with ThreadPoolExecutor(max_workers=batch_size) as executor:
    #                 for i in range(batch_size):
    task_id = batch * batch_size + i
    future = executor.submit(self._submit_demo_task, task_id)
                        task_futures.append(future)

    #                 # Wait for this batch to complete submission
    #                 for future in as_completed(task_futures):
    #                     try:
                            future.result()
    #                     except Exception as e:
                            logger.error(f"Error submitting task: {e}")

    #             # Small delay between batches
                time.sleep(1.0)

    #         # Wait for all tasks to complete
            self._wait_for_tasks()

    #     def _run_failover_demo(self):
    #         """Run demo with node failure simulation"""
            logger.info("Running failover demo...")

    #         # Submit initial tasks
    #         for i in range(self.config.num_tasks // 2):
                self._submit_demo_task(i)

    #         # Wait a bit, then simulate node failure
            time.sleep(5.0)

    #         # Remove a node
    #         if self.nodes:
    node_id = list(self.nodes.keys())[0]
    node = self.nodes[node_id]
                logger.info(f"Simulating node failure: {node.name}")

                self.scheduler.unregister_node(node_id)
                self.resource_monitor.unregister_node(node_id)
    #             del self.nodes[node_id]

    self.demo_results["nodes_removed"] + = 1

    #         # Submit more tasks
    #         for i in range(self.config.num_tasks // 2, self.config.num_tasks):
                self._submit_demo_task(i)

    #         # Wait for all tasks to complete
            self._wait_for_tasks()

    #     def _run_scaling_demo(self):
    #         """Run demo with dynamic scaling"""
            logger.info("Running scaling demo...")

    #         # Start with fewer nodes
    initial_nodes = math.divide(max(1, self.config.num_nodes, / 2))
    #         for i in range(initial_nodes):
    node = list(self.nodes.values())[i]
                self.scheduler.register_node(node)
                self.resource_monitor.register_node(node.id)

    #         # Submit tasks
    #         for i in range(self.config.num_tasks // 2):
                self._submit_demo_task(i)

    #         # Wait a bit, then add more nodes
            time.sleep(5.0)

            logger.info("Adding more nodes...")
    #         for i in range(initial_nodes, self.config.num_nodes):
    node = list(self.nodes.values())[i]
                self.scheduler.register_node(node)
                self.resource_monitor.register_node(node.id)

    #         # Submit more tasks
    #         for i in range(self.config.num_tasks // 2, self.config.num_tasks):
                self._submit_demo_task(i)

    #         # Wait for all tasks to complete
            self._wait_for_tasks()

    #     def _run_mixed_demo(self):
    #         """Run demo with mixed scenarios"""
            logger.info("Running mixed demo...")

    #         # Phase 1: Normal operation
            logger.info("Phase 1: Normal operation")
    #         for i in range(self.config.num_tasks // 3):
                self._submit_demo_task(i)

            time.sleep(3.0)

    #         # Phase 2: Add load
            logger.info("Phase 2: Increased load")
    #         for i in range(self.config.num_tasks // 3, 2 * self.config.num_tasks // 3):
                self._submit_demo_task(i)

            time.sleep(3.0)

    #         # Phase 3: Simulate failure
            logger.info("Phase 3: Node failure simulation")
    #         if self.nodes:
    node_id = list(self.nodes.keys())[0]
    node = self.nodes[node_id]
                logger.info(f"Removing node: {node.name}")

                self.scheduler.unregister_node(node_id)
                self.resource_monitor.unregister_node(node_id)
    #             del self.nodes[node_id]

    self.demo_results["nodes_removed"] + = 1

    #         # Submit remaining tasks
    #         for i in range(2 * self.config.num_tasks // 3, self.config.num_tasks):
                self._submit_demo_task(i)

    #         # Wait for all tasks to complete
            self._wait_for_tasks()

    #     def _submit_demo_task(self, task_id: int):
    #         """Submit a demo task"""

    #         # Create task function
    #         def demo_task(duration: float, task_id: int) -Dict[str, Any]):
    #             """Demo task function"""
    start_time = time.time()

    #             # Simulate work
                time.sleep(duration)

    #             # Simulate occasional failures
    #             if random.random() < 0.05:  # 5% failure rate
    #                 raise Exception(f"Simulated task failure for task {task_id}")

    end_time = time.time()
    execution_time = end_time - start_time

    #             return {
    #                 "task_id": task_id,
    #                 "execution_time": execution_time,
    #                 "start_time": start_time,
    #                 "end_time": end_time,
    #                 "success": True,
    #             }

    #         # Random duration
    duration = random.uniform( * self.config.task_duration_range)

    #         # Create task
    task = Task(
    name = f"Demo-Task-{task_id}",
    function = demo_task,
    args = (duration, task_id),
    kwargs = {},
    priority = random.randint(1, 10),
    required_resources = {
                    "cpu_percent": random.uniform(10.0, 80.0),
                    "memory_mb": random.randint(100, 1000),
    #             },
    #         )

    #         # Submit task
    task_id = self.scheduler.submit_task(task)
    self.tasks[task_id] = task
    self.demo_results["tasks_submitted"] + = 1

    #         return task_id

    #     def _wait_for_tasks(self):
    #         """Wait for all tasks to complete"""
    #         logger.info("Waiting for tasks to complete...")

    start_wait = time.time()
    timeout = 300  # 5 minutes timeout

    #         while self.running and (time.time() - start_wait) < timeout:
    #             # Check if all tasks are completed
    completed = 0
    failed = 0

    #             for task in self.tasks.values():
    #                 if task.status == TaskStatus.COMPLETED:
    completed + = 1
    self.demo_results["tasks_completed"] + = 1
    self.demo_results["total_execution_time"] + = (
    #                         task.completed_at - task.started_at
    #                     )
    #                 elif task.status == TaskStatus.FAILED:
    failed + = 1
    self.demo_results["tasks_failed"] + = 1

    total = len(self.tasks)
    #             if completed + failed >= total:
                    logger.info(
    #                     f"All tasks completed: {completed} succeeded, {failed} failed"
    #                 )
    #                 break

    #             # Log progress
    #             if int(time.time()) % 5 = 0:  # Every 5 seconds
                    logger.info(f"Progress: {completed}/{total} tasks completed")

                time.sleep(1.0)

    #         # Get remaining task results
    #         for task_id, task in self.tasks.items():
    #             if task.status == TaskStatus.PENDING or task.status == TaskStatus.RUNNING:
    #                 try:
    result = self.scheduler.get_task_result(task_id, timeout=5.0)
    #                     if result and result.get("success"):
    self.demo_results["tasks_completed"] + = 1
    self.demo_results["total_execution_time"] + = result.get(
    #                             "execution_time", 0
    #                         )
    #                     else:
    self.demo_results["tasks_failed"] + = 1
    #                 except Exception as e:
    #                     logger.error(f"Error getting result for task {task_id}: {e}")
    self.demo_results["tasks_failed"] + = 1

    #     def _print_results(self):
    #         """Print demo results"""
    duration = (
    #             self.end_time - self.start_time if self.end_time and self.start_time else 0
    #         )

    logger.info("\n" + " = " * 50)
            logger.info("DEMO RESULTS")
    logger.info(" = " * 50)
            logger.info(f"Duration: {duration:.2f} seconds")
            logger.info(
    #             f"Nodes: {self.demo_results['nodes_added']} added, {self.demo_results['nodes_removed']} removed"
    #         )
            logger.info(f"Tasks: {self.demo_results['tasks_submitted']} submitted")
            logger.info(f"  - Completed: {self.demo_results['tasks_completed']}")
            logger.info(f"  - Failed: {self.demo_results['tasks_failed']}")
            logger.info(
                f"  - Success rate: {self.demo_results['tasks_completed'] / max(1, self.demo_results['tasks_submitted']) * 100:.1f}%"
    #         )

    #         if self.demo_results["tasks_completed"] 0):
    avg_time = (
    #                 self.demo_results["total_execution_time"]
    #                 / self.demo_results["tasks_completed"]
    #             )
                logger.info(f"Average task time: {avg_time:.2f} seconds")

    #         if duration 0):
    throughput = self.demo_results["tasks_completed"] / duration
                logger.info(f"Throughput: {throughput:.2f} tasks/second")

    #         # System status
    status = self.scheduler.get_system_status()
            logger.info(f"\nFinal System Status:")
            logger.info(f"  - Available nodes: {status['nodes']['available']}")
            logger.info(f"  - Busy nodes: {status['nodes']['busy']}")
            logger.info(f"  - Average load: {status['nodes']['average_load']:.2f}")
            logger.info(f"  - Pending tasks: {status['tasks']['pending']}")
            logger.info(f"  - Running tasks: {status['tasks']['running']}")
    logger.info(" = " * 50)

    #     def _generate_report(self):
    #         """Generate demo report"""
    report = {
    #             "demo_info": {
    #                 "mode": self.config.mode.value,
    #                 "start_time": self.start_time,
    #                 "end_time": self.end_time,
                    "duration": (
    #                     self.end_time - self.start_time
    #                     if self.end_time and self.start_time
    #                     else 0
    #                 ),
    #             },
    #             "configuration": {
    #                 "num_nodes": self.config.num_nodes,
    #                 "num_tasks": self.config.num_tasks,
    #                 "task_duration_range": self.config.task_duration_range,
    #                 "demo_duration": self.config.demo_duration,
    #             },
    #             "results": self.demo_results,
                "system_status": self.scheduler.get_system_status(),
                "resource_summary": self.resource_monitor.get_system_summary(),
    #         }

    #         # Save report to file
    filename = f"cluster_demo_report_{int(time.time())}.json"
    #         try:
    #             with open(filename, "w") as f:
    json.dump(report, f, indent = 2, default=str)
                logger.info(f"Demo report saved to: {filename}")
    #         except Exception as e:
                logger.error(f"Error saving demo report: {e}")

    #     def get_real_time_metrics(self) -Dict[str, Any]):
    #         """Get real-time metrics for visualization"""
    #         if not self.running:
    #             return {}

    #         # Get system status
    system_status = self.scheduler.get_system_status()

    #         # Get resource summary
    resource_summary = self.resource_monitor.get_system_summary()

    #         # Calculate metrics
    current_time = time.time()
    #         duration = current_time - self.start_time if self.start_time else 0

    #         # Task completion rate
    completion_rate = 0.0
    #         if self.demo_results["tasks_submitted"] 0):
    completion_rate = (
    #                 self.demo_results["tasks_completed"]
    #                 / self.demo_results["tasks_submitted"]
    #             )

    #         # Current throughput
    throughput = 0.0
    #         if duration 0):
    throughput = self.demo_results["tasks_completed"] / duration

    metrics = {
    #             "timestamp": current_time,
    #             "duration": duration,
    #             "tasks": {
    #                 "submitted": self.demo_results["tasks_submitted"],
    #                 "completed": self.demo_results["tasks_completed"],
    #                 "failed": self.demo_results["tasks_failed"],
    #                 "completion_rate": completion_rate,
    #                 "throughput": throughput,
    #             },
    #             "nodes": {
    #                 "total": system_status["nodes"]["total"],
    #                 "available": system_status["nodes"]["available"],
    #                 "busy": system_status["nodes"]["busy"],
    #                 "average_load": system_status["nodes"]["average_load"],
    #             },
    #             "resources": {
    #                 "total_nodes": resource_summary["nodes"],
                    "system_alerts": len(resource_summary["system_alerts"]),
    #             },
    #         }

    #         # Add to history
            self.metrics_history.append(metrics)

    #         return metrics


function run_cluster_demo(config: DemoConfig = None)
    #     """
    #     Run the cluster demo with default or custom configuration

    #     Args:
    #         config: Demo configuration, uses defaults if None
    #     """
    #     if config is None:
    config = DemoConfig()

    demo = ClusterDemo(config)
        demo.start()

    #     # Keep the main thread alive
    #     try:
    #         while demo.running:
                time.sleep(1.0)
    #     except KeyboardInterrupt:
            logger.info("Received keyboard interrupt, stopping demo...")
            demo.stop()


if __name__ == "__main__"
    #     # Example usage
    config = DemoConfig(
    mode = DemoMode.MIXED,
    num_nodes = 3,
    num_tasks = 15,
    demo_duration = 0,  # Run indefinitely until interrupted
    log_level = "INFO",
    #     )

        run_cluster_demo(config)
