# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Distributed Tracing for NoodleCore with TRM-Agent
# """

import os
import time
import json
import uuid
import logging
import threading
import asyncio
import typing.Dict,
import dataclasses.dataclass,
import functools.wraps
import contextlib.contextmanager,

import opentelemetry.trace,
import opentelemetry.trace.SpanKind,
import opentelemetry.exporter.jaeger.thrift.JaegerExporter
import opentelemetry.sdk.trace.TracerProvider
import opentelemetry.sdk.trace.export.BatchSpanProcessor
import opentelemetry.propagate.extract,
import opentelemetry.baggage.propagation.W3CBaggagePropagator
import opentelemetry.trace.propagation.tracecontext

import .metrics_collector.get_metrics_collector

logger = logging.getLogger(__name__)


# @dataclass
class SpanContext
    #     """Span context for distributed tracing"""
    #     trace_id: str
    #     span_id: str
    parent_span_id: Optional[str] = None
    baggage: Dict[str, str] = field(default_factory=dict)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             "trace_id": self.trace_id,
    #             "span_id": self.span_id,
    #             "parent_span_id": self.parent_span_id,
    #             "baggage": self.baggage
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> "SpanContext":
    #         """Create from dictionary"""
            return cls(
    trace_id = data.get("trace_id", ""),
    span_id = data.get("span_id", ""),
    parent_span_id = data.get("parent_span_id"),
    baggage = data.get("baggage", {})
    #         )

    #     @classmethod
    #     def from_trace(cls) -> "SpanContext":
    #         """Create from current trace"""
    current_span = trace.get_current_span()
    #         if current_span:
    span_context = current_span.get_span_context()
                return cls(
    trace_id = format(span_context.trace_id, "032x"),
    span_id = format(span_context.span_id, "016x"),
    #                 parent_span_id=format(span_context.parent_id, "016x") if span_context.parent_id else None,
    baggage = dict(baggage.get_all())
    #             )
    #         else:
    #             # Generate new trace and span IDs
    trace_id = format(uuid.uuid4().int, "032x")[:32]
    span_id = format(uuid.uuid4().int, "016x")[:16]
    return cls(trace_id = trace_id, span_id=span_id)


class DistributedTracer
    #     """Distributed tracer for NoodleCore with TRM-Agent"""

    #     def __init__(self, service_name: str = "noodle-core", jaeger_endpoint: str = "http://localhost:14268/api/traces",
    sampling_rate: float = 0.1):
    self.service_name = service_name
    self.jaeger_endpoint = jaeger_endpoint
    self.sampling_rate = sampling_rate

    #         # Tracer
    self.tracer = None
    self.initialized = False

    #         # Metrics
    self.metrics_collector = get_metrics_collector()

    #         # Initialize
            self._initialize()

    #     def _initialize(self):
    #         """Initialize the tracer"""
    #         try:
    #             # Set up tracer provider
                trace.set_tracer_provider(TracerProvider())
    tracer_provider = trace.get_tracer_provider()

    #             # Set up Jaeger exporter
    jaeger_exporter = JaegerExporter(
    endpoint = self.jaeger_endpoint,
    collector_endpoint = self.jaeger_endpoint,
    #             )

    #             # Add span processor
    span_processor = BatchSpanProcessor(jaeger_exporter)
                tracer_provider.add_span_processor(span_processor)

    #             # Get tracer
    self.tracer = trace.get_tracer(self.service_name)

    #             # Set up propagators
    #             from opentelemetry.propagate import set_global_textmap
                set_global_textmap(tracecontext)

    self.initialized = True
    #             logger.info(f"Distributed tracer initialized for service: {self.service_name}")

    #         except Exception as e:
                logger.error(f"Failed to initialize distributed tracer: {e}")
    self.initialized = False

    #     def is_initialized(self) -> bool:
    #         """Check if the tracer is initialized"""
    #         return self.initialized

    #     def start_span(self, name: str, kind: SpanKind = SpanKind.INTERNAL,
    attributes: Optional[Dict[str, Any]] = None,
    parent_span: Optional[trace.Span] = math.subtract(None), > trace.Span:)
    #         """Start a new span"""
    #         if not self.initialized:
    #             # Create a dummy span if tracer is not initialized
                return trace.NonRecordingSpan(trace.INVALID_SPAN_CONTEXT)

    #         # Start span
    span = self.tracer.start_span(
    name = name,
    kind = kind,
    attributes = attributes,
    parent = parent_span
    #         )

    #         # Track span metrics
            self.metrics_collector.increment_counter(
    #             "noodle_core_spans_total",
    labels = {
    #                 "service": self.service_name,
    #                 "operation": name,
                    "kind": kind.name.lower()
    #             }
    #         )

    #         return span

    #     def finish_span(self, span: trace.Span, status: Status = None,
    error: Optional[Exception] = None):
    #         """Finish a span"""
    #         if not self.initialized or not span.is_recording():
    #             return

    #         # Set status
    #         if status:
                span.set_status(status)
    #         elif error:
                span.set_status(Status(StatusCode.ERROR, str(error)))
                span.record_exception(error)
    #         else:
                span.set_status(Status(StatusCode.OK))

    #         # End span
            span.end()

    #         # Track span metrics
            self.metrics_collector.increment_counter(
    #             "noodle_core_spans_completed_total",
    labels = {
    #                 "service": self.service_name,
    #                 "operation": span.name,
    #                 "status": status.status_code.name.lower() if status else "ok"
    #             }
    #         )

    #     @contextmanager
    #     def trace_span(self, name: str, kind: SpanKind = SpanKind.INTERNAL,
    attributes: Optional[Dict[str, Any]] = None):
    #         """Context manager for tracing a span"""
    span = None
    #         try:
    span = self.start_span(name, kind, attributes)
    #             yield span
    #         except Exception as e:
    #             if span:
    self.finish_span(span, error = e)
    #             raise
    #         else:
    #             if span:
                    self.finish_span(span)

    #     @asynccontextmanager
    #     async def trace_span_async(self, name: str, kind: SpanKind = SpanKind.INTERNAL,
    attributes: Optional[Dict[str, Any]] = None):
    #         """Async context manager for tracing a span"""
    span = None
    #         try:
    span = self.start_span(name, kind, attributes)
    #             yield span
    #         except Exception as e:
    #             if span:
    self.finish_span(span, error = e)
    #             raise
    #         else:
    #             if span:
                    self.finish_span(span)

    #     def trace_function(self, name: Optional[str] = None, kind: SpanKind = SpanKind.INTERNAL,
    attributes: Optional[Dict[str, Any]] = None):
    #         """Decorator for tracing a function"""
    #         def decorator(func):
    func_name = name or f"{func.__module__}.{func.__name__}"

                @wraps(func)
    #             def wrapper(*args, **kwargs):
    span_attrs = {
    #                     "function.name": func.__name__,
    #                     "function.module": func.__module__,
                        "function.args_count": len(args) + len(kwargs)
    #                 }

    #                 if attributes:
                        span_attrs.update(attributes)

    #                 with self.trace_span(func_name, kind, span_attrs) as span:
    #                     if span.is_recording():
    #                         # Add arguments as attributes (be careful with sensitive data)
    #                         for i, arg in enumerate(args):
                                span.set_attribute(f"arg.{i}", str(arg)[:100])  # Limit length

    #                         for key, value in kwargs.items():
                                span.set_attribute(f"kwarg.{key}", str(value)[:100])  # Limit length

                        return func(*args, **kwargs)

    #             return wrapper
    #         return decorator

    #     def trace_function_async(self, name: Optional[str] = None, kind: SpanKind = SpanKind.INTERNAL,
    attributes: Optional[Dict[str, Any]] = None):
    #         """Decorator for tracing an async function"""
    #         def decorator(func):
    func_name = name or f"{func.__module__}.{func.__name__}"

                @wraps(func)
    #             async def wrapper(*args, **kwargs):
    span_attrs = {
    #                     "function.name": func.__name__,
    #                     "function.module": func.__module__,
                        "function.args_count": len(args) + len(kwargs)
    #                 }

    #                 if attributes:
                        span_attrs.update(attributes)

    #                 async with self.trace_span_async(func_name, kind, span_attrs) as span:
    #                     if span.is_recording():
    #                         # Add arguments as attributes (be careful with sensitive data)
    #                         for i, arg in enumerate(args):
                                span.set_attribute(f"arg.{i}", str(arg)[:100])  # Limit length

    #                         for key, value in kwargs.items():
                                span.set_attribute(f"kwarg.{key}", str(value)[:100])  # Limit length

                        return await func(*args, **kwargs)

    #             return wrapper
    #         return decorator

    #     def trace_method(self, name: Optional[str] = None, kind: SpanKind = SpanKind.INTERNAL,
    attributes: Optional[Dict[str, Any]] = None):
    #         """Decorator for tracing a method"""
    #         def decorator(func):
    func_name = name or f"{func.__qualname__}"

                @wraps(func)
    #             def wrapper(self, *args, **kwargs):
    span_attrs = {
    #                     "method.name": func.__name__,
    #                     "class.name": self.__class__.__name__,
                        "method.args_count": len(args) + len(kwargs)
    #                 }

    #                 if attributes:
                        span_attrs.update(attributes)

    #                 with self.trace_span(func_name, kind, span_attrs) as span:
    #                     if span.is_recording():
    #                         # Add class and method info
                            span.set_attribute("class.name", self.__class__.__name__)
                            span.set_attribute("method.name", func.__name__)

    #                         # Add arguments as attributes (be careful with sensitive data)
    #                         for i, arg in enumerate(args):
                                span.set_attribute(f"arg.{i}", str(arg)[:100])  # Limit length

    #                         for key, value in kwargs.items():
                                span.set_attribute(f"kwarg.{key}", str(value)[:100])  # Limit length

                        return func(self, *args, **kwargs)

    #             return wrapper
    #         return decorator

    #     def trace_method_async(self, name: Optional[str] = None, kind: SpanKind = SpanKind.INTERNAL,
    attributes: Optional[Dict[str, Any]] = None):
    #         """Decorator for tracing an async method"""
    #         def decorator(func):
    func_name = name or f"{func.__qualname__}"

                @wraps(func)
    #             async def wrapper(self, *args, **kwargs):
    span_attrs = {
    #                     "method.name": func.__name__,
    #                     "class.name": self.__class__.__name__,
                        "method.args_count": len(args) + len(kwargs)
    #                 }

    #                 if attributes:
                        span_attrs.update(attributes)

    #                 async with self.trace_span_async(func_name, kind, span_attrs) as span:
    #                     if span.is_recording():
    #                         # Add class and method info
                            span.set_attribute("class.name", self.__class__.__name__)
                            span.set_attribute("method.name", func.__name__)

    #                         # Add arguments as attributes (be careful with sensitive data)
    #                         for i, arg in enumerate(args):
                                span.set_attribute(f"arg.{i}", str(arg)[:100])  # Limit length

    #                         for key, value in kwargs.items():
                                span.set_attribute(f"kwarg.{key}", str(value)[:100])  # Limit length

                        return await func(self, *args, **kwargs)

    #             return wrapper
    #         return decorator

    #     def inject_headers(self, headers: Dict[str, str]) -> Dict[str, str]:
    #         """Inject tracing context into headers"""
    #         if not self.initialized:
    #             return headers

    #         # Create a copy of headers
    injected_headers = headers.copy()

    #         # Inject tracing context
            inject(injected_headers)

    #         return injected_headers

    #     def extract_headers(self, headers: Dict[str, str]) -> SpanContext:
    #         """Extract tracing context from headers"""
    #         if not self.initialized:
                return SpanContext.from_trace()

    #         # Extract tracing context
    ctx = extract(headers)

    #         # Get current span
    span = trace.get_current_span()
    #         if span and span.is_recording():
    span_context = span.get_span_context()
                return SpanContext(
    trace_id = format(span_context.trace_id, "032x"),
    span_id = format(span_context.span_id, "016x"),
    #                 parent_span_id=format(span_context.parent_id, "016x") if span_context.parent_id else None,
    baggage = dict(baggage.get_all())
    #             )

            return SpanContext.from_trace()

    #     def get_current_span_context(self) -> Optional[SpanContext]:
    #         """Get current span context"""
    #         if not self.initialized:
    #             return None

    current_span = trace.get_current_span()
    #         if current_span and current_span.is_recording():
    span_context = current_span.get_span_context()
                return SpanContext(
    trace_id = format(span_context.trace_id, "032x"),
    span_id = format(span_context.span_id, "016x"),
    #                 parent_span_id=format(span_context.parent_id, "016x") if span_context.parent_id else None,
    baggage = dict(baggage.get_all())
    #             )

    #         return None

    #     def set_baggage(self, key: str, value: str):
    #         """Set baggage item"""
    #         if self.initialized:
                baggage.set_baggage(key, value)

    #     def get_baggage(self, key: str) -> Optional[str]:
    #         """Get baggage item"""
    #         if self.initialized:
                return baggage.get_baggage(key)
    #         return None

    #     def trace_api_request(self, method: str, path: str, status_code: int,
    response_time: float, request_id: str = None,
    user_id: str = math.multiply(None,, *kwargs):)
    #         """Trace an API request"""
    #         # Create attributes
    attributes = {
    #             "http.method": method,
    #             "http.path": path,
                "http.status_code": str(status_code),
    #             "http.response_time": response_time,
    #             "service": self.service_name
    #         }

    #         if request_id:
    attributes["request.id"] = request_id

    #         if user_id:
    attributes["user.id"] = user_id

    #         # Add additional attributes
    #         for key, value in kwargs.items():
    #             if key not in attributes:
    attributes[key] = str(value)[:100]  # Limit length

    #         # Create span name
    span_name = f"{method} {path}"

    #         # Create span kind based on status code
    kind = SpanKind.SERVER
    #         if status_code >= 400:
    kind = SpanKind.INTERNAL

    #         # Create and finish span
    #         with self.trace_span(span_name, kind, attributes) as span:
    #             if span.is_recording():
    #                 # Set status based on status code
    #                 if status_code >= 500:
                        span.set_status(Status(StatusCode.ERROR, "Server error"))
    #                 elif status_code >= 400:
                        span.set_status(Status(StatusCode.ERROR, "Client error"))
    #                 else:
                        span.set_status(Status(StatusCode.OK))

    #                 # Add response time as an event
                    span.add_event("response", {"response_time": response_time})

    #     def trace_compilation(self, source_code_hash: str, optimization_types: List[str],
    #                           strategy: str, status: str, compilation_time: float,
    request_id: str = math.multiply(None,, *kwargs):)
    #         """Trace a compilation"""
    #         # Create attributes
    attributes = {
    #             "compilation.source_code_hash": source_code_hash,
                "compilation.optimization_types": ",".join(sorted(optimization_types)),
    #             "compilation.strategy": strategy,
    #             "compilation.status": status,
    #             "compilation.time": compilation_time,
    #             "service": self.service_name
    #         }

    #         if request_id:
    attributes["request.id"] = request_id

    #         # Add additional attributes
    #         for key, value in kwargs.items():
    #             if key not in attributes:
    attributes[key] = str(value)[:100]  # Limit length

    #         # Create span name
    span_name = "compilation"

    #         # Create span kind based on status
    kind = SpanKind.INTERNAL

    #         # Create and finish span
    #         with self.trace_span(span_name, kind, attributes) as span:
    #             if span.is_recording():
    #                 # Set status based on compilation status
    #                 if status == "failed":
                        span.set_status(Status(StatusCode.ERROR, "Compilation failed"))
    #                 elif status == "timeout":
                        span.set_status(Status(StatusCode.ERROR, "Compilation timeout"))
    #                 else:
                        span.set_status(Status(StatusCode.OK))

    #                 # Add compilation time as an event
                    span.add_event("compilation_completed", {"time": compilation_time})

    #     def trace_trm_agent_optimization(self, ir_hash: str, optimization_type: str,
    #                                      strategy: str, status: str, optimization_time: float,
    cache_hit: bool = math.multiply(False, request_id: str = None,, *kwargs):)
    #         """Trace a TRM-Agent optimization"""
    #         # Create attributes
    attributes = {
    #             "trm_agent.ir_hash": ir_hash,
    #             "trm_agent.optimization_type": optimization_type,
    #             "trm_agent.strategy": strategy,
    #             "trm_agent.status": status,
    #             "trm_agent.optimization_time": optimization_time,
                "trm_agent.cache_hit": str(cache_hit),
    #             "service": self.service_name
    #         }

    #         if request_id:
    attributes["request.id"] = request_id

    #         # Add additional attributes
    #         for key, value in kwargs.items():
    #             if key not in attributes:
    attributes[key] = str(value)[:100]  # Limit length

    #         # Create span name
    span_name = "trm_agent_optimization"

    #         # Create span kind based on status
    kind = SpanKind.INTERNAL

    #         # Create and finish span
    #         with self.trace_span(span_name, kind, attributes) as span:
    #             if span.is_recording():
    #                 # Set status based on optimization status
    #                 if status == "failed":
                        span.set_status(Status(StatusCode.ERROR, "TRM-Agent optimization failed"))
    #                 elif status == "timeout":
                        span.set_status(Status(StatusCode.ERROR, "TRM-Agent optimization timeout"))
    #                 else:
                        span.set_status(Status(StatusCode.OK))

    #                 # Add optimization time as an event
                    span.add_event("optimization_completed", {"time": optimization_time})

    #                 # Add cache hit as an event
                    span.add_event("cache_lookup", {"hit": cache_hit})

    #     def trace_distributed_task(self, task_id: str, task_type: str, node_id: str,
    #                               status: str, task_time: float, **kwargs):
    #         """Trace a distributed task"""
    #         # Create attributes
    attributes = {
    #             "distributed.task_id": task_id,
    #             "distributed.task_type": task_type,
    #             "distributed.node_id": node_id,
    #             "distributed.status": status,
    #             "distributed.task_time": task_time,
    #             "service": self.service_name
    #         }

    #         # Add additional attributes
    #         for key, value in kwargs.items():
    #             if key not in attributes:
    attributes[key] = str(value)[:100]  # Limit length

    #         # Create span name
    span_name = f"distributed_task_{task_type}"

    #         # Create span kind based on status
    kind = SpanKind.INTERNAL

    #         # Create and finish span
    #         with self.trace_span(span_name, kind, attributes) as span:
    #             if span.is_recording():
    #                 # Set status based on task status
    #                 if status == "failed":
                        span.set_status(Status(StatusCode.ERROR, "Task failed"))
    #                 elif status == "timeout":
                        span.set_status(Status(StatusCode.ERROR, "Task timeout"))
    #                 else:
                        span.set_status(Status(StatusCode.OK))

    #                 # Add task time as an event
                    span.add_event("task_completed", {"time": task_time})


# Global tracer instance
_distributed_tracer = None


def get_distributed_tracer(service_name: str = "noodle-core",
jaeger_endpoint: str = "http://localhost:14268/api/traces",
sampling_rate: float = math.subtract(0.1), > DistributedTracer:)
#     """Get the global distributed tracer instance"""
#     global _distributed_tracer

#     if _distributed_tracer is None:
_distributed_tracer = DistributedTracer(
#             service_name, jaeger_endpoint, sampling_rate
#         )

#     return _distributed_tracer


def initialize_distributed_tracer(service_name: str = "noodle-core",
jaeger_endpoint: str = "http://localhost:14268/api/traces",
sampling_rate: float = 0.1):
#     """Initialize the global distributed tracer"""
#     global _distributed_tracer

#     if _distributed_tracer is not None:
        logger.warning("Distributed tracer already initialized")
#         return

_distributed_tracer = DistributedTracer(
#         service_name, jaeger_endpoint, sampling_rate
#     )

    logger.info("Distributed tracer initialized")


function shutdown_distributed_tracer()
    #     """Shutdown the global distributed tracer"""
    #     global _distributed_tracer

    #     if _distributed_tracer is not None:
    #         # In a real implementation, you would shut down the tracer provider here
    _distributed_tracer = None

        logger.info("Distributed tracer shutdown")


# Decorators for easy use
def trace_function(name: Optional[str] = None, kind: SpanKind = SpanKind.INTERNAL,
attributes: Optional[Dict[str, Any]] = None):
#     """Decorator for tracing a function"""
tracer = get_distributed_tracer()
    return tracer.trace_function(name, kind, attributes)


def trace_function_async(name: Optional[str] = None, kind: SpanKind = SpanKind.INTERNAL,
attributes: Optional[Dict[str, Any]] = None):
#     """Decorator for tracing an async function"""
tracer = get_distributed_tracer()
    return tracer.trace_function_async(name, kind, attributes)


def trace_method(name: Optional[str] = None, kind: SpanKind = SpanKind.INTERNAL,
attributes: Optional[Dict[str, Any]] = None):
#     """Decorator for tracing a method"""
tracer = get_distributed_tracer()
    return tracer.trace_method(name, kind, attributes)


def trace_method_async(name: Optional[str] = None, kind: SpanKind = SpanKind.INTERNAL,
attributes: Optional[Dict[str, Any]] = None):
#     """Decorator for tracing an async method"""
tracer = get_distributed_tracer()
    return tracer.trace_method_async(name, kind, attributes)